`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2025 04:02:22 PM
// Design Name: 
// Module Name: input_sync
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module input_sync(
    input  logic clk,
    input  logic reset,

    input  logic [1:0] in2,
    input  logic in3,
    input  logic in4,
    input  logic in5,
    input  logic [1:0] in6,
    input  logic in7,
    input  logic in8,

    output logic [1:0] out2,
    output logic out3,
    output logic out4,
    output logic out5,
    output logic [1:0] out6,
    output logic out7,
    output logic out8
    
);

    logic [1:0] nout2;
    logic nout3;      
    logic nout4;    
    logic nout5;      
    logic [1:0] nout6;
    logic nout7;      
    logic nout8;       
    
    always_ff @(posedge clk) begin
            nout2 <= in2;
            nout3 <= in3;
            nout4 <= in4;
            nout5 <= in5;
            nout6 <= in6;
            nout7 <= in7;
            nout8 <= in8;     
    end

    always_ff @(posedge clk) begin  
            out2 <= nout2;
            out3 <= nout3;
            out4 <= nout4;
            out5 <= nout5;
            out6 <= nout6;
            out7 <= nout7;
            out8 <= nout8;
    end
endmodule