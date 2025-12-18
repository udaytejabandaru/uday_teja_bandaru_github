# Handwritten Number Detection through ANN on FPGA

This project implements a handwritten digit classifier using an Artificial Neural Network (ANN) mapped onto an Intel DE1-SoC FPGA board. It demonstrates an end-to-end hardware/software co-design approach, combining FPGA-based acceleration with ARM processor orchestration.

---

## Overview

- Built an ANN with the MNIST dataset for digit recognition (0–9).
- Input layer: 784 neurons (28x28 pixels).
- Hidden layer: 16 neurons with ReLU activation.
- Output layer: 10 neurons representing digit classes.
- Achieved more than 94% accuracy after training.

---

## Hardware and Tools

- Target board: Intel DE1-SoC FPGA
- Design software: Intel Quartus Prime
- High-Level Synthesis (HLS) compiler to convert C code into Verilog RTL
- ARM-based Hard Processor System (HPS) running Linux for software control
- AXI memory-mapped interface for communication between HPS and FPGA fabric

---

## Implementation Details

- ANN model first trained in TensorFlow and Keras.
- Trained weights and biases converted from 32-bit floating point to fixed-point representation.
- Network layers mapped into modular C functions, then synthesized to Verilog RTL.
- Integrated hardware IP with HPS software using AXI interconnect.
- End-to-end system:  
  1. Select MNIST test image in HPS.  
  2. Send pixel data to FPGA.  
  3. FPGA computes classification.  
  4. FPGA returns predicted class index.  
  5. HPS decodes and displays result.  

---

## Verification

- Tested with MNIST test images on the integrated system.
- Compared FPGA output against ground truth labels.
- Validated system with multiple random images.
- Demonstrated reliable classification with accuracy above 94%.

---

## Results

- Classification accuracy: 94.22% on MNIST test set.
- Successfully classified digits in real time using FPGA acceleration.
- Demonstrated skills in HW/SW co-design, HLS-based hardware generation, and FPGA deployment.

---

## Challenges Faced

- Conversion of C code to Verilog RTL.
- Floating-point to fixed-point quantization.
- Synthesis issues during HLS compilation.
- Wrapper integration for FPGA-HPS communication.

---

## Future Work

- Increase network depth and hidden units to improve accuracy.
- Optimize HLS directives for better resource usage and speed.
- Port final design to a low-power FPGA platform for edge deployment.
- Add more complex datasets beyond MNIST.

---

## Repository Structure



---

## Acknowledgments

- MNIST dataset  
- Intel FPGA design tools (Quartus Prime, HLS compiler)  
- TensorFlow and Keras for ANN training  

