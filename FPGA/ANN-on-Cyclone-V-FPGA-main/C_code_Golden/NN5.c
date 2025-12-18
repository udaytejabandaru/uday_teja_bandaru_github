#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <time.h>

#define INPUT_NEURONS 784
#define HIDDEN_NEURONS 16
#define OUTPUT_NEURONS 10

// Convert 8-bit two's complement fixed-point to float
float fixed_to_float(int value, int int_bits, int frac_bits) {
    if (value & (1 << 7)) // If negative (check MSB in 8-bit number)
        value -= (1 << 8); // Convert to signed integer
    return value / (float)(1 << frac_bits); // Apply fixed-point scaling
}

// Read a single weight/bias from a .txt file (already converted to float)
void read_float_file(const char *filename, float *data, int size) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        printf("Error: Cannot open %s\n", filename);
        exit(1);
    }
    
    for (int i = 0; i < size; i++) {
        if (fscanf(file, "%f", &data[i]) != 1) {
            printf("Error: Invalid data format in %s\n", filename);
            exit(1);
        }
    }
    fclose(file);
}

// Read a single weight/bias from a .mif file
void read_and_save_mif_file(const char *filename, float *data, int size, int int_bits, int frac_bits) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        printf("Error: Cannot open %s\n", filename);
        exit(1);
    }
    
    char line[10];
    for (int i = 0; i < size; i++) {
        if (fgets(line, sizeof(line), file)) {
            int value = strtol(line, NULL, 2); // Convert binary string to integer
            data[i] = fixed_to_float(value, int_bits, frac_bits);
        }
    }
    fclose(file);
    //Save the converted values to a text file
    //save_to_text_file(filename, data, size);
}

// ReLU activation function
float relu(float x) {
    return x > 0 ? x : 0;
}

// Softmax activation function for final layer
void softmax(float *output, int size) {
    float sum = 0.0;
    for (int i = 0; i < size; i++) {
        output[i] = exp(output[i]);
        sum += output[i];
    }
    for (int i = 0; i < size; i++) {
        output[i] /= sum;
    }
}

// Forward propagation
void forward_pass(float input[INPUT_NEURONS], float hidden[HIDDEN_NEURONS], float output[OUTPUT_NEURONS]) {
    float weights_h[HIDDEN_NEURONS][INPUT_NEURONS];
    float bias_h[HIDDEN_NEURONS];
    float weights_o[OUTPUT_NEURONS][HIDDEN_NEURONS];
    float bias_o[OUTPUT_NEURONS];
    
    // Load weights and biases for hidden layer
    for (int i = 0; i < HIDDEN_NEURONS; i++) {
        char weight_file[50], bias_file[50];
        snprintf(weight_file, sizeof(weight_file), "w_b_py_conv/w_1_%d.txt", i);
        snprintf(bias_file, sizeof(bias_file), "w_b_py_conv/b_1_%d.txt", i);
        read_float_file(weight_file, weights_h[i], INPUT_NEURONS);
        read_float_file(bias_file, &bias_h[i], 1);
    }
    
    // Compute hidden layer activations
    for (int i = 0; i < HIDDEN_NEURONS; i++) {
        float sum = bias_h[i];
        for (int j = 0; j < INPUT_NEURONS; j++) {
            sum += input[j] * weights_h[i][j];
        }
        printf("Neuron before relu %d: %f\n", i, sum);
        hidden[i] = relu(sum);
    }

    
    // Load weights and biases for output layer
    for (int i = 0; i < OUTPUT_NEURONS; i++) {
        char weight_file[50], bias_file[50];
        snprintf(weight_file, sizeof(weight_file), "w_b_py_conv/w_2_%d.txt", i);
        snprintf(bias_file, sizeof(bias_file), "w_b_py_conv/b_2_%d.txt", i);
        read_float_file(weight_file, weights_o[i], HIDDEN_NEURONS);
        read_float_file(bias_file, &bias_o[i], 1);
    }
    
    // Compute output layer activations
    for (int i = 0; i < OUTPUT_NEURONS; i++) {
        float sum = bias_o[i];
        for (int j = 0; j < HIDDEN_NEURONS; j++) {
            sum += hidden[j] * weights_o[i][j];
        }
        output[i] = sum; // Softmax applied later
    }
    
    printf("\nOutputs Layer Outputs (After ReLU):\n");
    for (int i = 0; i < OUTPUT_NEURONS; i++) {
        printf("Neuron %d: %f\n", i, output[i]);
    }

    // Apply softmax to output layer
    softmax(output, OUTPUT_NEURONS);
}

int main() {
    srand(time(NULL));

    int label, img_choice;
    printf("Enter label number (0-9): ");
    scanf("%d", &label);

    printf("Use random image? Enter 1 for YES, 0 for NO: ");
    scanf("%d", &img_choice);

    int image_num;
    if (img_choice) {
        image_num = rand() % 800;
        printf("Randomly selected image_%d\n", image_num);
    } else {
        printf("Enter image number (0-799): ");
        scanf("%d", &image_num);
        if (image_num < 0 || image_num >= 800) {
            printf("Invalid image number.\n");
            return 1;
        }
    }

    // Load input image
    char input_file[100];
    snprintf(input_file, sizeof(input_file), "rdm_img_c/label_%d/image_%d.txt", label, image_num);
    float input[INPUT_NEURONS];

    // Check if file exists
    FILE *test_file = fopen(input_file, "r");
    if (!test_file) {
        printf("Error: File not found - %s\n", input_file);
        return 1;
    }
    fclose(test_file);

    read_and_save_mif_file(input_file, input, INPUT_NEURONS, 1, 7); // 1-bit int, 7-bit frac

    float hidden[HIDDEN_NEURONS];
    float output[OUTPUT_NEURONS];

    // Run forward pass
    forward_pass(input, hidden, output);

    // Print hidden layer outputs
    printf("\nHidden Layer Outputs (After ReLU):\n");
    for (int i = 0; i < HIDDEN_NEURONS; i++) {
        printf("Neuron %d: %f\n", i, hidden[i]);
    }

    // Print final output values
    printf("\nNeural Network Output (After Softmax):\n");
    int max_index = 0;
    float max_value = output[0];
    for (int i = 0; i < OUTPUT_NEURONS; i++) {
        printf("Neuron %d: %f\n", i, output[i]);
        if (output[i] > max_value) {
            max_value = output[i];
            max_index = i;
        }
    }

    printf("\nDominant Prediction: Neuron %d\n", max_index);
    if (max_index == label) {
        printf("Prediction is CORRECT!\n");
    } else {
        printf("Prediction is WRONG!\n");
    }

    return 0;
}

