import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

@cocotb.test()
async def test_tt_um_tinycore(dut):
    dut._log.info("Starting Test for tt_tinycore")

    # Create a clock on the "clk" signal with a period of 10us
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset the core
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1

    # Wait for the core to initialize and start processing
    await ClockCycles(dut.clk, 1)

    # The core should now be executing the instruction memory
    # Let's run for a number of cycles to execute all instructions
    for _ in range(10):
        await RisingEdge(dut.clk)

    # Check the result of the computation
    # We expect the accumulator to have a specific value based on our instructions
    expected_value = 1  # This should match the final value of the accumulator
    actual_value = int(dut.uo_out.value)
    dut._log.info(f"Checking output: Expected {expected_value}, Got {actual_value}")
    assert actual_value == expected_value, f"Output mismatch: {actual_value} != {expected_value}"

    # Check the IO direction is set to input (uio_oe should be all zeros)
    assert dut.uio_oe.value == BinaryValue("00000000"), "IO direction is not set to input."

    # Additional checks can be added here to validate the core's functionality
    # such as verifying the behavior after branching, jumping, etc.

