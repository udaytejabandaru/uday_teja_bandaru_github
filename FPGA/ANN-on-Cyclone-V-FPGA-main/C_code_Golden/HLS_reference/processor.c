#include <stdint.h>
#include "xil_io.h"

// Example base addresses (CHANGE to match your Vivado address map)
#define COMBINED_MEM_BASE   0x40000000U   // BRAM AXI base
#define NN_ACCEL_CTRL_BASE  0x43C00000U   // AXI-Lite base

// AXI-Lite register offsets (typical HLS IP; adjust if your HLS tool generates different map)
#define REG_AP_CTRL   0x00
#define REG_GMEM_PTR  0x10   // combined_mem pointer (if tool exposes it)
#define REG_WORDS     0x1C   // words_total
// ap_ctrl bits:
#define AP_START      (1 << 0)
#define AP_DONE       (1 << 1)
#define AP_IDLE       (1 << 2)

#define INPUT_NEURONS 784
#define HIDDEN_NEURONS 16
#define OUTPUT_NEURONS 10

#define OFF_INPUT        0
#define OFF_W1           (OFF_INPUT + INPUT_NEURONS)
#define OFF_B1           (OFF_W1 + HIDDEN_NEURONS*INPUT_NEURONS)
#define OFF_W2           (OFF_B1 + HIDDEN_NEURONS)
#define OFF_B2           (OFF_W2 + OUTPUT_NEURONS*HIDDEN_NEURONS)
#define OFF_OUT_RAW      (OFF_B2 + OUTPUT_NEURONS)
#define OFF_PRED         (OFF_OUT_RAW + OUTPUT_NEURONS)
#define WORDS_TOTAL      (OFF_PRED + 1)

static inline uint32_t f_to_u32(float x) { union { uint32_t u; float f; } t; t.f=x; return t.u; }
static inline float    u32_to_f(uint32_t x){ union { uint32_t u; float f; } t; t.u=x; return t.f; }

void write_combined_mem_word(uint32_t word_off, uint32_t val) {
    Xil_Out32(COMBINED_MEM_BASE + 4U*word_off, val);
}
uint32_t read_combined_mem_word(uint32_t word_off) {
    return Xil_In32(COMBINED_MEM_BASE + 4U*word_off);
}

void nn_run_on_fpga(
    const float *input784,
    const float *w1, const float *b1,
    const float *w2, const float *b2
) {
    // 1) Fill input
    for (int i = 0; i < INPUT_NEURONS; i++)
        write_combined_mem_word(OFF_INPUT + i, f_to_u32(input784[i]));

    // 2) Fill w1 (16*784)
    for (int i = 0; i < HIDDEN_NEURONS*INPUT_NEURONS; i++)
        write_combined_mem_word(OFF_W1 + i, f_to_u32(w1[i]));

    // 3) Fill b1 (16)
    for (int i = 0; i < HIDDEN_NEURONS; i++)
        write_combined_mem_word(OFF_B1 + i, f_to_u32(b1[i]));

    // 4) Fill w2 (10*16)
    for (int i = 0; i < OUTPUT_NEURONS*HIDDEN_NEURONS; i++)
        write_combined_mem_word(OFF_W2 + i, f_to_u32(w2[i]));

    // 5) Fill b2 (10)
    for (int i = 0; i < OUTPUT_NEURONS; i++)
        write_combined_mem_word(OFF_B2 + i, f_to_u32(b2[i]));

    // 6) Program accelerator registers (depends on your HLS-generated reg map)
    // Many HLS IPs require writing the base address of combined_mem; some don’t if fixed.
    Xil_Out32(NN_ACCEL_CTRL_BASE + REG_GMEM_PTR, COMBINED_MEM_BASE);
    Xil_Out32(NN_ACCEL_CTRL_BASE + REG_WORDS, WORDS_TOTAL);

    // 7) Start
    Xil_Out32(NN_ACCEL_CTRL_BASE + REG_AP_CTRL, AP_START);

    // 8) Poll done
    while ((Xil_In32(NN_ACCEL_CTRL_BASE + REG_AP_CTRL) & AP_DONE) == 0) {;}

    // 9) Read results from combined_mem
    uint32_t pred_u = read_combined_mem_word(OFF_PRED);
    int pred = (int)pred_u;

    float out_raw[OUTPUT_NEURONS];
    for (int o = 0; o < OUTPUT_NEURONS; o++)
        out_raw[o] = u32_to_f(read_combined_mem_word(OFF_OUT_RAW + o));

    // Use pred/out_raw as needed (print, compare, etc.)
    (void)pred;
}

