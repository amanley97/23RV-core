`timescale 1ns / 1ps

module regfile_23rv_tb;

    parameter ADDRESS_BITWIDTH = 5;
    parameter DATA_WIDTH = 32;
    parameter NUM_REGS = (1 << ADDRESS_BITWIDTH);

    logic clk;
    logic reset;
    logic [ADDRESS_BITWIDTH-1:0] rs1, rs2, rd;
    logic [DATA_WIDTH-1:0] wd;
    logic we;
    logic [DATA_WIDTH-1:0] rd1, rd2;

    regfile_23rv dut (
        .clk(clk),
        .reset(reset),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wd(wd),
        .we(we),
        .rd1(rd1),
        .rd2(rd2)
    );

    always #5 clk = ~clk; // 10ns period -> 100MHz clock

    // Test Procedure
    initial begin
        clk = 0;
        reset = 1;
        we = 0;
        rs1 = 0;
        rs2 = 0;
        rd = 0;
        wd = 0;

        #20 reset = 0;
        $display("Reset complete. All registers should be zero.");

        // Check that all registers are reset to zero
        for (int i = 0; i < NUM_REGS; i++) begin
            rs1 = i;
            #2;
            if (rd1 !== 0) $display("ERROR: Register x%0d is not reset properly! Value: %h", i, rd1);
        end

        // Write test values to registers
        for (int i = 1; i < NUM_REGS; i++) begin
            rd = i;
            wd = i * 10;
            we = 1;
            #10;
            we = 0;
        end

        for (int i = 1; i < NUM_REGS; i++) begin
            rs1 = i;
            #2;
            if (rd1 !== i * 10) begin
                $display("ERROR: Register x%0d read incorrect! Expected: %h, Got: %h", i, i * 10, rd1);
            end
        end

        // Ensure x0 is always zero
        rs1 = 0;
        #2;
        if (rd1 !== 0) $display("ERROR: Register x0 should always be zero!");

        $display("Test completed.");
        $finish;
    end

endmodule
