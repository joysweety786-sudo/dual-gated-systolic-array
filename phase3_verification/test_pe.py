import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge

@cocotb.test()
async def test_pe_modes_and_losslessness(dut):
    """Test Processing Element for lossless multiplication and clock gating"""
    
    # 10ns clock period (100 MHz)
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut.rst_n.value = 0
    dut.load_w.value = 0
    dut.w_in.value = 0
    dut.a_in.value = 0
    dut.acc_in.value = 0
    
    for _ in range(2):
        await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    # Test cases: (weight, activation, expected_mult, description)
    test_cases = [
        (0, 5, 0, "Mode 0: Zero Weight (Gated)"),
        (3, 0, 0, "Mode 0: Zero Activation (Gated)"),
        (2, -3, -6, "Mode 1: Small magnitude operands"),
        (-5, 4, -20, "Mode 1: Negative small operands"),
        (50, -2, -100, "Mode 2: Full scale operand")
    ]

    for w, a, expected_prod, desc in test_cases:
        # Load weight
        dut.load_w.value = 1
        dut.w_in.value = w
        await RisingEdge(dut.clk)
        dut.load_w.value = 0

        # Stream activation and accumulation
        dut.a_in.value = a
        dut.acc_in.value = 10  # Partial sum bias
        
        # Wait 2 cycles for systolic pipelining
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        
        # Mathematical losslessness check
        assert dut.a_out.value.signed_integer == a, f"Activation stream corrupted! Expected {a}, got {dut.a_out.value.signed_integer}"
        
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        expected_accum = 10 + expected_prod
        actual_accum = dut.acc_out.value.signed_integer
        
        assert actual_accum == expected_accum, f"Mismatch in {desc}! Expected {expected_accum}, got {actual_accum}"
        dut._log.info(f"PASS: {desc} -> Product: {expected_prod}, Accum: {actual_accum}")