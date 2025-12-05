`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2025 04:53:37 PM
// Design Name: 
// Module Name: auto_cal
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


module auto_cal #(
    parameter int WIDTH = 16
)(
    input  logic                 clk,
    input  logic                 reset,
    input  logic                 cal_trig,      // 1 clock wide pulse to capture new offset
    input  logic                 cal_switch,  // slide switch, 1 = show calibrated

    input  logic [WIDTH-1:0]     xadc_ave,       // trusted XADC reading
    input  logic [WIDTH-1:0]     ave_data,    // raw PWM ADC reading

    output logic [WIDTH-1:0]      display_code    // selected value for display
);
    logic [WIDTH-1:0]      cal_data;    // selected value for display
    logic signed [WIDTH:0] offset_reg;
    
    // 1) store offset when calib_trig is asserted
    always_ff @(posedge clk) begin
        if (reset) begin
            offset_reg <= '0;
        end else if (cal_trig) begin
            // signed subtract with one extra bit
            offset_reg <= $signed({1'b0, xadc_ave}) - $signed({1'b0, ave_data});
        end
    end

    // 2) apply offset to current raw PWM reading, with simple saturation
    always_comb begin
        logic signed [WIDTH:0] pwm_ext;
        logic signed [WIDTH:0] sum;

        pwm_ext = $signed({1'b0, ave_data});
        sum     = pwm_ext + offset_reg;

        // saturate to 0 .. 2^WIDTH - 1
        if (sum < 0)
            cal_data = '0;
        else if (sum > $signed({1'b0, {WIDTH{1'b1}}}))
            cal_data = {WIDTH{1'b1}};
        else
            cal_data = sum;
    end

    // 3) choose what goes to the display
    always_comb begin
        if (cal_switch)
            display_code = cal_data;
        else
            display_code = ave_data;
    end
    
endmodule
