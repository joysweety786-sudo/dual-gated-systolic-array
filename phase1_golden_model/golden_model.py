import numpy as np

def operand_classifier(val: int) -> int:
    """
    Mode 0: Zero (val == 0)
    Mode 1: Small Magnitude (Upper nibble redundant sign extension: -8 to 7)
    Mode 2: Full INT8 Precision (-128 to 127)
    """
    val = int(val) & 0xFF
    signed_val = val if val < 128 else val - 256
    
    if signed_val == 0:
        return 0  # Mode 0: Full Zero
    elif -8 <= signed_val <= 7:
        return 1  # Mode 1: Small magnitude (Upper nibble gated)
    else:
        return 2  # Mode 2: Full precision active

def simulate_4x4_systolic_matmul(weights, activations):
    accum = np.zeros((4, 4), dtype=np.int32)
    mode_counts = {0: 0, 1: 0, 2: 0}
    
    for r in range(4):
        for c in range(4):
            w = weights[r, c]
            a = activations[r, c]
            
            w_mode = operand_classifier(w)
            a_mode = operand_classifier(a)
            
            effective_mode = max(w_mode, a_mode)
            mode_counts[effective_mode] += 1
            
            accum[r, c] = int(w) * int(a)
            
    return accum, mode_counts

if __name__ == "__main__":
    np.random.seed(42)
    W = np.random.choice([0, 2, -3, 64, -100], size=(4, 4), p=[0.4, 0.2, 0.2, 0.1, 0.1])
    A = np.random.choice([0, 1, -2, 50, -80], size=(4, 4), p=[0.4, 0.2, 0.2, 0.1, 0.1])
    
    results, stats = simulate_4x4_systolic_matmul(W, A)
    print("Golden Model Ready!")