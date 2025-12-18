import mnist_loader
import network2
import numpy as np
import random
import os

# Step 1: Load test data and trained network
_, _, test_data = mnist_loader.load_data_wrapper()
test_data = list(test_data)  # Ensure test_data is in list format
net = network2.load("WeightsAndBiases.txt")  # Load trained model

# Step 2: Function to process random image for a specific label
def process_random_image_by_label(label, test_data, net):
    # Filter images with the specified label
    filtered_data = [(x, y, idx) for idx, (x, y) in enumerate(test_data) if y == label]
    if not filtered_data:
        print(f"No images found for label {label}.")
        return

    # Pick a random image
    random_image, true_label, index = random.choice(filtered_data)

    # Feed the image into the network
    activations = net.collect_activations(random_image)  # Collect all neuron outputs
    prediction = np.argmax(activations[-1])  # Get prediction from the final layer

    # Calculate neuron contribution percentages
    total_activation = np.sum(activations[-1])
    neuron_accuracies = [(i, (activation / total_activation) * 100) for i, activation in     enumerate(activations[-1].flatten())]

    # Display neuron contributions
    print("Neuron Contributions (Accuracy %):")
    for neuron, percentage in neuron_accuracies:
        print(f"Neuron {neuron}: {percentage:.2f}%")

    # Display results
    print(f"Random Image Index: {index}")
    print(f"True Label: {true_label}")
    print(f"Network Prediction: {prediction}")
    print(f"Prediction {'Correct' if prediction == true_label else 'Incorrect'}.")

    # Save the random image to a file
    save_random_image(random_image, index)

    # Calculate overall accuracy
    accuracy = net.accuracy(test_data)
    print(f"Overall Accuracy on Test Data: {accuracy} / {len(test_data)}")

# Step 3: Function to save random image
def save_random_image(image, index):
    # Reshape image to 28x28 for MNIST
    reshaped_image = image.reshape(28, 28)

    # Create output folder if it doesn't exist
    output_folder = "random_images"
    os.makedirs(output_folder, exist_ok=True)

    # Write image data to file
    file_path = os.path.join(output_folder, f"image_{index}.txt")
    with open(file_path, "w") as f:
        for row in reshaped_image:
            f.write(" ".join(f"{pixel:.2f}" for pixel in row) + "\n")
    print(f"Image saved to {file_path}")

# Step 4: Main execution
if __name__ == "__main__":
    try:
        # Input label from the user
        label = int(input("Enter the label (0-9) you want to test: "))
        if 0 <= label <= 9:
            process_random_image_by_label(label, test_data, net)
        else:
            print("Invalid label! Please enter a number between 0 and 9.")
    except ValueError:
        print("Invalid input! Please enter an integer between 0 and 9.")

