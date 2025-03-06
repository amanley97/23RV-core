import cocotb
from cocotb.triggers import RisingEdge, Timer
import random

ADDRESS_WIDTH = 5
DATA_WIDTH = 32
NUM_REGS = 1 << ADDRESS_WIDTH  # 32 registers

@cocotb.test()
async def test_register_file(dut):
    """Test the RISC-V register file."""
    
    # Reset the register file
    dut.reset.value = 1
    await Timer(10, units='ns')
    dut.reset.value = 0
    await Timer(10, units='ns')
    
    # Verify all registers are reset to zero
    for i in range(NUM_REGS):
        dut.rs1.value = i
        await Timer(1, units='ns')
        assert dut.rd1.value == 0, f"Register x{i} not reset properly!"
    
    # Write test: Write values to registers
    for i in range(1, NUM_REGS):  # Skip x0 since it's always zero
        dut.rd.value = i
        dut.wd.value = i * 10  # Arbitrary test data
        dut.we.value = 1
        await RisingEdge(dut.clk)
        dut.we.value = 0
    
    # Read test: Verify written values
    for i in range(1, NUM_REGS):
        dut.rs1.value = i
        await Timer(1, units='ns')
        assert dut.rd1.value == i * 10, f"Register x{i} read incorrect! Expected {i * 10}, got {dut.rd1.value}"
    
    # Ensure x0 is still zero
    dut.rs1.value = 0
    await Timer(1, units='ns')
    assert dut.rd1.value == 0, "Register x0 should always be zero!"
    
    cocotb.log.info("Register file test passed!")
