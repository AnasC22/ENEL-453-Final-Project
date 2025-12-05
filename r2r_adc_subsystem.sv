`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 05:26:55 PM
// Design Name: 
// Module Name: r2r_adc_subsystem
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


module r2r_adc_subsystem
#(parameter int WIDTH = 16)                   // Bit width for duty_cycle

    (
    input logic clk,
    input logic reset,
    input logic r2r_enable,
    input logic compare_state2,
    output logic [7:0] r2r_captured_duty_cycle,
    output logic r2r_neg_edge_out,
    output logic [7:0] r2r_internal
    );
    
    logic compare_state2_sync;
    logic compare_state2_sync2;
    logic temp;
    logic [WIDTH-1:0] duty_cycle;
    
    always_ff @(posedge clk) begin 
        compare_state2_sync <= compare_state2;
    end
    
     always_ff @(posedge clk) begin 
        compare_state2_sync2 <= compare_state2_sync;
    end
    
    assign r2r_neg_edge_out = (~compare_state2_sync2) & temp;
    
    always_ff @(posedge clk) begin
        if(reset) temp <= 0;
        else begin    
            temp <= compare_state2_sync2;
            if(r2r_neg_edge_out) r2r_captured_duty_cycle <= r2r_internal;
        end
    end
    
    
    sawtooth_generator #(
        .WIDTH(16),           // Bit width for duty_cycle (e.g. 8)
        .CLOCK_FREQ(100_000_000), // System clock frequency in Hz (e.g. 100_000_000)
        .WAVE_FREQ(1.0)    // Desired triangle wave frequency in Hz (e.g. 1.0)
    ) sawtooth_pwm_inst (
        .clk(clk),           // Connect to system clock
        .reset(reset),       // Connect to system reset
        .enable(r2r_enable), // Connect to enable signal
        .pwm_out(pwm_out_internal), // Connect to PWM output signal
        .R2R_out(r2r_internal)  // Connect to R2R ladder header, can leave empty if
    );                              // not required, i.e. .R2R_out()

endmodule
