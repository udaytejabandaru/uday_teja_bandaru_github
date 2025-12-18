#include <stdint.h>

// Network sizes
#define INPUT_NEURONS   784
#define HIDDEN_NEURONS  16
#define OUTPUT_NEURONS  10

// -------------------------
// DSE knobs (sweep these)
// -------------------------
#ifndef IN_UNROLL
#define IN_UNROLL   28     // try: 1,2,4,7,14,28,49,98
#endif

#ifndef HID_UNROLL
#define HID_UNROLL  4      // try: 1,2,4,8,16
#endif

#ifndef PIPE_II
#define PIPE_II     1      // try: 1,2,4
#endif

#ifndef USE_LOCAL_W2
#define USE_LOCAL_W2 1     // try: 0/1 (cache w2/b2 locally)
#endif

#ifndef USE_LOCAL_W1
#define USE_LOCAL_W1 0     // w1 is huge; 0=stream from mem, 1=cache (area heavy)
#endif

// -------------------------
// combined_mem layout (words)
// -------------------------
#define OFF_INPUT        0
#define OFF_W1           (OFF_INPUT + INPUT_NEURONS)
#define OFF_B1           (OFF_W1 + HIDDEN_NEURONS*INPUT_NEURONS)
#define OFF_W2           (OFF_B1 + HIDDEN_NEURONS)
#define OFF_B2           (OFF_W2 + OUTPUT_NEURONS*HIDDEN_NEURONS)
#define OFF_OUT_RAW      (OFF_B2 + OUTPUT_NEURONS)
#define OFF_PRED         (OFF_OUT_RAW + OUTPUT_NEURONS)
#define WORDS_TOTAL      (OFF_PRED + 1)

// Reinterpret uint32 as float and back (synthesizable)
static inline float u32_to_f(uint32_t x) {
    union { uint32_t u; float f; } t;
    t.u = x;
    return t.f;
}
static inline uint32_t f_to_u32(float x) {
    union { uint32_t u; float f; } t;
    t.f = x;
    return t.u;
}

static inline float relu(float x) { return (x > 0.0f) ? x : 0.0f; }

// Top accelerator
void nn_accel(
    volatile uint32_t *combined_mem, // AXI-MM pointer to BRAM/memory map
    uint32_t words_total              // safety check; pass WORDS_TOTAL
) {
#pragma HLS TOP name=nn_accel

    // -------------------------
    // Interfaces
    // -------------------------
    // Control (AXI-Lite)
#pragma HLS interface s_axilite port=return bundle=CTRL
#pragma HLS interface s_axilite port=words_total bundle=CTRL
#pragma HLS interface s_axilite port=combined_mem bundle=CTRL

    // Data (AXI-MM) into the same combined_mem region that CPU fills
#pragma HLS interface m_axi port=combined_mem offset=slave bundle=GMEM \
    max_read_burst_length=64 max_write_burst_length=64

#pragma HLS inline off

    // Optional guard (avoid out-of-range access if something is misconfigured)
    if (words_total < (uint32_t)WORDS_TOTAL) return;

    // -------------------------
    // Local buffers
    // -------------------------
    float input[INPUT_NEURONS];
#pragma HLS bind_storage variable=input type=ram_1p impl=bram

    float b1[HIDDEN_NEURONS];
#pragma HLS array_partition variable=b1 complete dim=1

    float b2[OUTPUT_NEURONS];
#pragma HLS array_partition variable=b2 complete dim=1

    float hidden[HIDDEN_NEURONS];
#pragma HLS array_partition variable=hidden complete dim=1

    // Cache w2 locally (small)
    float w2_local[OUTPUT_NEURONS][HIDDEN_NEURONS];
#pragma HLS array_partition variable=w2_local complete dim=2
#pragma HLS bind_storage variable=w2_local type=ram_2p impl=bram

    // (Optional) Cache w1 locally (very large) -> not recommended unless you have RAM
#if USE_LOCAL_W1
    static float w1_local[HIDDEN_NEURONS][INPUT_NEURONS];
#pragma HLS bind_storage variable=w1_local type=ram_2p impl=bram
#endif

    // -------------------------
    // Burst load input + biases
    // -------------------------
load_input:
    for (int i = 0; i < INPUT_NEURONS; i++) {
#pragma HLS pipeline II=1
        input[i] = u32_to_f(combined_mem[OFF_INPUT + i]);
    }

load_b1:
    for (int i = 0; i < HIDDEN_NEURONS; i++) {
#pragma HLS pipeline II=1
        b1[i] = u32_to_f(combined_mem[OFF_B1 + i]);
    }

load_b2:
    for (int o = 0; o < OUTPUT_NEURONS; o++) {
#pragma HLS pipeline II=1
        b2[o] = u32_to_f(combined_mem[OFF_B2 + o]);
    }

#if USE_LOCAL_W2
load_w2:
    for (int o = 0; o < OUTPUT_NEURONS; o++) {
        for (int h = 0; h < HIDDEN_NEURONS; h++) {
#pragma HLS pipeline II=1
            w2_local[o][h] = u32_to_f(combined_mem[OFF_W2 + o*HIDDEN_NEURONS + h]);
        }
    }
#endif

#if USE_LOCAL_W1
load_w1:
    for (int i = 0; i < HIDDEN_NEURONS; i++) {
        for (int j = 0; j < INPUT_NEURONS; j++) {
#pragma HLS pipeline II=1
            w1_local[i][j] = u32_to_f(combined_mem[OFF_W1 + i*INPUT_NEURONS + j]);
        }
    }
#endif

    // -------------------------
    // Compute hidden layer
    // -------------------------
hidden_layer:
    for (int i = 0; i < HIDDEN_NEURONS; i++) {
#pragma HLS pipeline II=PIPE_II

        float sum = b1[i];

        // DSE: unroll the inner MAC loop
mac1:
        for (int j = 0; j < INPUT_NEURONS; j++) {
#pragma HLS unroll factor=IN_UNROLL

            float w;
#if USE_LOCAL_W1
            w = w1_local[i][j];
#else
            // stream from combined_mem (CPU-filled BRAM)
            w = u32_to_f(combined_mem[OFF_W1 + i*INPUT_NEURONS + j]);
#endif
            sum += input[j] * w;
        }

        hidden[i] = relu(sum);
    }

    // -------------------------
    // Compute output layer
    // -------------------------
    float out_raw[OUTPUT_NEURONS];
#pragma HLS array_partition variable=out_raw complete dim=1

output_layer:
    for (int o = 0; o < OUTPUT_NEURONS; o++) {
#pragma HLS pipeline II=PIPE_II

        float sum = b2[o];

mac2:
        for (int h = 0; h < HIDDEN_NEURONS; h++) {
#pragma HLS unroll factor=HID_UNROLL
#if USE_LOCAL_W2
            sum += hidden[h] * w2_local[o][h];
#else
            float w = u32_to_f(combined_mem[OFF_W2 + o*HIDDEN_NEURONS + h]);
            sum += hidden[h] * w;
#endif
        }
        out_raw[o] = sum;
    }

    // -------------------------
    // Argmax (prediction)
    // -------------------------
    int max_i = 0;
    float max_v = out_raw[0];

argmax:
    for (int k = 1; k < OUTPUT_NEURONS; k++) {
#pragma HLS pipeline II=1
        if (out_raw[k] > max_v) { max_v = out_raw[k]; max_i = k; }
    }

    // -------------------------
    // Store outputs back into combined_mem
    // -------------------------
store_out:
    for (int o = 0; o < OUTPUT_NEURONS; o++) {
#pragma HLS pipeline II=1
        combined_mem[OFF_OUT_RAW + o] = f_to_u32(out_raw[o]);
    }

    combined_mem[OFF_PRED] = (uint32_t)max_i;
}

