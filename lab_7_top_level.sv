/*
This design uses the XADC from the IP Catalog. The specific channel is XADC4.
The Auxiliary Analog Inputs are VAUXP[15] and VAUXN[15].
These map to the FPGA pins of N2 and N1, respecitively (also in .XDC).
These map to the JXADC PMOD and the specific PMOD inputs are
JXADC4:N2 and JXAC10:N1, respectively. These pin are right beside the PMOD GND
on JXAC11:GND and JXAC5:GND.

The ADC is set to single-ended, continuous sampling, 1 MSps, 256 averaging.
Additional averaging is done using the averager module below.
*/
module lab_7_top_level (
    input  logic   clk_in,
    input  logic   reset,
    input  logic [1:0] nbin_bcd_select,
    input  logic [1:0] nmode_select,
    input          vauxp15, // Analog input (positive) - connect to JXAC4:N2 PMOD pin  (XADC4)
    input          vauxn15, // Analog input (negative) - connect to JXAC10:N1 PMOD pin (XADC4)
    input logic    ncompare_state1,
    input logic    ncompare_state2,
    input logic    nsar_switch,
    input logic    ncal_switch,
    input logic    ncal_trig,
    output logic   CA, CB, CC, CD, CE, CF, CG, DP,
    output logic   AN1, AN2, AN3, AN4,
    output logic [15:0] led,
    output logic   pwm,//, buzzer_out,
    output logic [7:0] R2R_out
);
    // Internal signal declarations       
    logic        ready;              // Data ready from XADC
    logic [15:0] xadc_data;
    logic [15:0] data;                  // Raw ADC data
    logic [15:0] scaled_adc_data; // Scaled ADC data for display, plus pipelinging register
    logic [6:0]  daddr_in;              // XADC address
    logic        enable;                // XADC enable
    logic        eos_out;               // End of sequence
    logic        busy_out;              // XADC busy signal
    logic        ready_pulse;
    logic [15:0] bcd_value, mux_out;
    logic pwm_enable, r2r_enable, sar_enable;
    logic pwm_out_internal, buzzer_out_internal;
    logic [15:0] R2R_out_internal;
    logic [15:0] scaled_adc_data_xadc;
    logic [15:0] scaled_adc_data_pwm;
    logic [15:0] scaled_adc_data_r2r;
    logic [15:0] raw_data;
   
    logic neg_edge_out;
    logic r2r_neg_edge_out;
    logic [15:0] captured_duty_cycle;
    
    logic [15:0] r2r_captured_duty_cycle;
    logic [7:0] dac_code;
    logic [7:0] result_code;
    logic sar_go;
    logic [15:0] scaled_sar_data;
    logic [15:0] pwm_ave;
    logic [15:0] xadc_ave;
    logic [15:0] r2r_ave;
    logic [15:0] sar_ave;    
    
    logic [1:0] bin_bcd_select;
    logic [1:0] mode_select;
    logic    compare_state1;
    logic    compare_state2;
    logic    sar_switch;
    logic [15:0] ave_data;
    logic [7:0] r2r;
    logic cal_switch;
    logic cal_trig;
    logic [3:0] decimal_pt;
    logic sar_pwm_out;
    logic [15:0] display_code;

    
    logic clk;
    logic pll_locked;
    logic pll_reset;
    
    // PLL instantiation
    clk_wiz_0 u_clk_wiz (
        .clk_in1    (clk_in),
        .reset     (0),       // or controlled reset
        .clk_out1   (clk),   // this is your faster clock
        .locked     (pll_locked)
    );
    

    input_sync INPUT_SYNC (
        .clk(clk),
        .reset(reset),
    
        .in2(nmode_select),
        .in3(ncompare_state1),
        .in4(ncompare_state2),
        .in5(nsar_switch),
        .in6(nbin_bcd_select),
        .in7(ncal_switch),
        .in8(ncal_trig),
    
        .out2(mode_select),   
        .out3(compare_state1),
        .out4(compare_state2),
        .out5(sar_switch),    
        .out6(bin_bcd_select),
        .out7(cal_switch),
        .out8(cal_trig)
    );    
  
    // Instantiate the FSM
    output_mode_fsm FSM (
        .clk(clk),
        .reset(reset),
        .mode_select(mode_select),
        .pwm_enable(pwm_enable),
        .r2r_enable(r2r_enable),
        .sar_enable(sar_enable)
    );
          
    localparam CHANNEL_ADDR = 7'h1f;     // XA4/AD15 (for XADC4)  
    // XADC Instantiation
    xadc_wiz_0 XADC_INST (
        .di_in(16'h0000),        // Not used for reading
        .daddr_in(CHANNEL_ADDR), // Channel address
        .den_in(enable),         // Enable signal
        .dwe_in(1'b0),           // Not writing, so set to 0
        .drdy_out(ready),        // Data ready signal (when high, ADC data is valid)
        .do_out(xadc_data),           // ADC data output
        .dclk_in(clk),           // Use system clock
        .reset_in(reset),   // Active-high reset
        .vp_in(1'b0),            // Not used, leave disconnected
        .vn_in(1'b0),            // Not used, leave disconnected
        .vauxp15(vauxp15),       // Auxiliary analog input (positive)
        .vauxn15(vauxn15),       // Auxiliary analog input (negative)
        .channel_out(),          // Current channel being converted
        .eoc_out(enable),        // End of conversion
        .alarm_out(),            // Not used
        .eos_out(eos_out),       // End of sequence
        .busy_out(busy_out)      // XADC busy signal
    );
  
//    assign sawtooth_en = pwm_enable | r2r_enable;
    pwm_adc_subsystem #(
        .WIDTH(16)
    ) PWM_ADC_SUBSYSTEM (
        .clk(clk),
        .reset(reset),
        .pwm_en(pwm_enable),
        .compare_state1(compare_state1),
        .captured_duty_cycle(captured_duty_cycle),
        .pwm_out(pwm_out),
        .neg_edge_out(neg_edge_out)
    );
    
    r2r_adc_subsystem #(
        .WIDTH(16)
    ) R2R_ADC_SUBSYSTEM (
        .clk(clk),
        .reset(reset),
        .r2r_enable(r2r_enable),
        .compare_state2(compare_state2),
        .r2r_internal(R2R_out_internal),
        .r2r_captured_duty_cycle(r2r_captured_duty_cycle),
        .r2r_neg_edge_out(r2r_neg_edge_out)
    );
         
     sar_adc_subsystem SAR_ADC_SUBSYSTEM (
        .clk(clk),
        .reset(reset),
        .enable(sar_enable),              // switch 1 turns SAR on
        .compare_state2(compare_state2),
        .compare_state1(compare_state1),
        .sar_switch(sar_switch),
//        .done(sar_done),
        .result(result_code),
        .dac_out(dac_code),
        .sar_pwm_out(sar_pwm_out),
        .done(done)
       );

////     Instantiate the adc_processing module
    adc_processing ADC_PROC_XADC (
        .clk(clk),
        .reset(reset),
        .ready_out(ready),
        .xadc_data(xadc_data),
        .scaled_adc_data_xadc(scaled_adc_data_xadc),
        .ave_data(xadc_ave)
    );

     adc_processing_pwm ADC_PROC_PWM (
        .clk(clk),
        .reset(reset),
        .ready_out(neg_edge_out),
//        .data(adc_proc_data_in),
        .pwm_data(captured_duty_cycle),
        .scaled_adc_data_pwm(scaled_adc_data_pwm),
        .ave_data(pwm_ave)
    );
    
    adc_processing_r2r ADC_PROC_R2R (
        .clk(clk),
        .reset(reset),
        .ready_out(r2r_neg_edge_out),
//        .data(adc_proc_data_in),
        .r2r_data(r2r_captured_duty_cycle),
        .scaled_adc_data_r2r(scaled_adc_data_r2r),
        .ave_data(r2r_ave)
    );
    
    sar_processing SAR_PROC (
        .clk(clk),
        .reset(reset),
        .ready_out(done),
//        .data(adc_proc_data_in),
        .sar_data(result_code),
        .scaled_sar_data(scaled_sar_data),
        .ave_data(sar_ave)
    );
   
    mux_data_en MUX_SCALED_DATA_EN (
        .mode_select(mode_select),
        .xadc_data(scaled_adc_data_xadc),
        .captured_duty_cycle(scaled_adc_data_pwm),
        .r2r_captured_duty_cycle(scaled_adc_data_r2r),
        .result_code(scaled_sar_data),       
        .data(data)
    );

    bin_to_bcd BIN2BCD (
        .clk(    clk),
        .reset(  reset),
        .bin_in(data),
        .bcd_out(bcd_value)
    );
      
    mux_data_en MUX_RAW_DATA_EN ( 
        .mode_select(mode_select),
        .xadc_data(xadc_data),
        .captured_duty_cycle(captured_duty_cycle),
        .r2r_captured_duty_cycle(r2r_captured_duty_cycle),
        .result_code(result_code),
        .data(raw_data)
    );      
       
    mux_data_en AVE_DATA_EN (
        .mode_select(mode_select),
        .xadc_data(xadc_ave),
        .captured_duty_cycle(pwm_ave),
        .r2r_captured_duty_cycle(r2r_ave),
        .result_code(sar_ave),       
        .data(ave_data)
    );

    auto_cal #(.WIDTH(16)) AUTO_CAL (
        .clk(clk),
        .reset(reset),
        .cal_trig(cal_trig),
        .cal_switch(cal_switch),
        .xadc_ave(xadc_ave),
        .ave_data(ave_data),
        .display_code(display_code)
    );
         
    mux4_16_bits MUX4 (
        .in0(ave_data), // hexadecimal, scaled and averaged
        .in1(bcd_value),       // decimal, scaled and averaged
        .in2(raw_data),      // raw 12-bit ADC hexadecimal
        .in3(display_code),        // averaged and before scaling 16-bit ADC (extra 4-bits from averaging) hexadecimal
        .select(bin_bcd_select),
        .mux_out(mux_out),
        .decimal_point(decimal_pt)
    );   
                
    // Seven Segment Display Subsystem
    seven_segment_display_subsystem SEVEN_SEGMENT_DISPLAY (
        .clk(clk),
        .reset(reset),
        .sec_dig1(mux_out[3:0]),     // Lowest digit
        .sec_dig2(mux_out[7:4]),     // Second digit
        .min_dig1(mux_out[11:8]),    // Third digit
        .min_dig2(mux_out[15:12]),   // Highest digit
        .decimal_point(decimal_pt),
        .CA(CA), .CB(CB), .CC(CC), .CD(CD),
        .CE(CE), .CF(CF), .CG(CG), .DP(DP),
        .AN1(AN1), .AN2(AN2), .AN3(AN3), .AN4(AN4)
    );
    
     mux2_16_bits SAR_R2R_OUTPUT_MUX (
        .in0(R2R_out_internal), // hexadecimal, scaled and averaged
        .in1(dac_code),       // decimal, scaled and averaged
        .pwm_out(pwm_out),
        .sar_pwm_out(sar_pwm_out),
        .select(mode_select),
        .mux_out(r2r),
        .pwm(pwm)
    );

     assign R2R_out = r2r; 
     assign led = raw_data;
     
endmodule