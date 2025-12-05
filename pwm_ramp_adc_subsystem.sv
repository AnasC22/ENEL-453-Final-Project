`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2025 11:22:28 AM
// Design Name: 
// Module Name: pwm_ramp_adc_subsystem
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


module pwm_adc_subsystem
    #(parameter int WIDTH = 16)                   // Bit width for duty_cycle

    (
    input logic clk,
    input logic reset,
    input logic pwm_en,
    input logic compare_state1,
    output logic [WIDTH-1:0] captured_duty_cycle,
    output logic pwm_out,
    output logic neg_edge_out
    );
    
    logic compare_state1_sync;
    logic compare_state1_sync2;
    logic temp;
    logic [WIDTH-1:0] duty_cycle;
    
    always_ff @(posedge clk) begin 
        compare_state1_sync <= compare_state1;
    end
    
     always_ff @(posedge clk) begin 
        compare_state1_sync2 <= compare_state1_sync;
    end
    
    assign neg_edge_out = (~compare_state1_sync2) & temp;
    
    always_ff @(posedge clk) begin
        if(reset) temp <= 0;
        else begin     
            temp <= compare_state1_sync2;
            if(neg_edge_out) captured_duty_cycle <= duty_cycle;
        end
    end
    
    
    sawtooth_generator #(
        .WIDTH(16),           // Bit width for duty_cycle (e.g. 8)
        .CLOCK_FREQ(185_000_000), // System clock frequency in Hz (e.g. 100_000_000)
        .WAVE_FREQ(10.0)    // Desired triangle wave frequency in Hz (e.g. 1.0)
    ) sawtooth_pwm_inst (
        .clk(clk),           // Connect to system clock
        .reset(reset),       // Connect to system reset
        .enable(pwm_en),    // Connect to enable signal
        .pwm_out(pwm_out), // Connect to PWM output signal
        .R2R_out(R2R_out_internal),  // Connect to R2R ladder header, can leave empty if 
        .duty_cycle(duty_cycle)
    );                              // not required, i.e. .R2R_out()

endmodule