import cocotb
from cocotb.triggers import RisingEdge, Timer
import random

ADDRESS_WIDTH = 5
DATA_WIDTH = 32
NUM_REGS = 1 << ADDRESS_WIDTH  # 32 registers

@cocotb.test()
async def test_register_file(dut):
    """Test the RISC-V register file."""
    
    dut.reset.value = 1
    await Timer(10, units='ns')
    dut.reset.value = 0
    await Timer(10, units='ns')
    
    for i in range(NUM_REGS):
        dut.rs1.value = i
        await Timer(1, units='ns')
        assert dut.rd1.value == 0, f"Register x{i} not reset properly!"
    
    for i in range(1, NUM_REGS):
        dut.rd.value = i
        dut.wd.value = i * 10
        dut.we.value = 1
        await RisingEdge(dut.clk)
        dut.we.value = 0
    
    for i in range(1, NUM_REGS):
        dut.rs1.value = i
        await Timer(1, units='ns')
        assert dut.rd1.value == i * 10, f"Register x{i} read incorrect! Expected {i * 10}, got {dut.rd1.value}"
    
    dut.rs1.value = 0
    await Timer(1, units='ns')
    assert dut.rd1.value == 0, "Register x0 should always be zero!"
    
    cocotb.log.info("Register file test passed!")
