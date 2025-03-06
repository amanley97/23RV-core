//
// 23RV Register File
//

`timescale 1ns / 1ps

module regfile_23rv #(
    parameter ADDRESS_BITWIDTH = 5,
    parameter DATA_WIDTH = 32
) (
    input   logic                       clk,
    input   logic                       reset,
    
    input   logic[ADDRESS_BITWIDTH-1:0] rs1,    // register source 1 
    input   logic[ADDRESS_BITWIDTH-1:0] rs2,    // register source 2
    input   logic[ADDRESS_BITWIDTH-1:0] rd,     // register destination

    input   logic[DATA_WIDTH-1:0]       wd,     // write data

    input   logic                       we,     // write enable control

    output  logic[DATA_WIDTH-1:0]       rd1,    // register out 1
    output  logic[DATA_WIDTH-1:0]       rd2    // register out 2      
);

// register memory elements
reg [DATA_WIDTH-1:0] regfile [0:(1 << ADDRESS_BITWIDTH)-1];

// write port
always_ff @( posedge clk or posedge reset ) begin
    if (reset) begin
        integer idx;
        for (idx = 0; idx < (1 << ADDRESS_BITWIDTH); idx++) begin
            regfile[idx] <= 0;
        end
    end
    else if (we && (rd != 0)) begin
        regfile[rd] <= wd; 
    end
end

// read ports
assign rd1 = (rs1 != 0) ? regfile[rs1] : 0;
assign rd2 = (rs2 != 0) ? regfile[rs2] : 0;

endmodule