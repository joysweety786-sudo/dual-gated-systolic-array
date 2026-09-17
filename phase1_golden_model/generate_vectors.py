import numpy as np

def save_matrix_hex(filename, mat):
    with open(filename, 'w') as f:
        for val in mat.flatten():
            f.write(f"{(int(val) & 0xFF):02X}\n")

np.random.seed(42)
weights = np.random.choice([0, 2, -3, 64, -100], size=(4, 4), p=[0.4, 0.2, 0.2, 0.1, 0.1])
activations = np.random.choice([0, 1, -2, 50, -80], size=(4, 4), p=[0.4, 0.2, 0.2, 0.1, 0.1])

# Calculate expected outputs
outputs = weights * activations

save_matrix_hex("phase1_golden_model/vectors/weights.mem", weights)
save_matrix_hex("phase1_golden_model/vectors/activations.mem", activations)
save_matrix_hex("phase1_golden_model/vectors/expected_outputs.mem", outputs)

print("Test vectors saved to phase1_golden_model/vectors/")