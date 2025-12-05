transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib activehdl/xpm
vlib activehdl/xil_defaultlib

vmap xpm activehdl/xpm
vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xpm  -sv2k12 "+incdir+../../../Lab_7.gen/sources_1/ip/clk_wiz_0" -l xpm -l xil_defaultlib \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -93  \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../Lab_7.gen/sources_1/ip/clk_wiz_0" -l xpm -l xil_defaultlib \
"../../../Lab_7.gen/sources_1/ip/xadc_wiz_0/xadc_wiz_0.v" \
"../../../Lab_7.gen/sources_1/ip/clk_wiz_0/clk_wiz_0_clk_wiz.v" \
"../../../Lab_7.gen/sources_1/ip/clk_wiz_0/clk_wiz_0.v" \

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../Lab_7.gen/sources_1/ip/clk_wiz_0" -l xpm -l xil_defaultlib \
"../../../../adc_processing.sv" \
"../../../../averager.sv" \
"../../../../averager_simple.sv" \
"../../../../bin_to_bcd.sv" \
"../../../../digit_multiplexor.sv" \
"../../../../downcounter.sv" \
"../../../../mux4_16_bits.sv" \
"../../../../output_mode_fsm.sv" \
"../../../../pwm.sv" \
"../../../../sawtooth_waveform.sv" \
"../../../../seven_segment_decoder.sv" \
"../../../../seven_segment_digit_selector.sv" \
"../../../../seven_segment_display_subsystem.sv" \
"../../../../lab_7_top_level.sv" \
"../../../../mux_data_en.sv" \
"../../../../adc_processing_pwm.sv" \
"../../../../pwm_ramp_adc_subsystem.sv" \
"../../../../r2r_adc_subsystem.sv" \
"../../../../sar_adc_subsystem.sv" \
"../../../../adc_processing_r2r.sv" \
"../../../../mux2_16_bits.sv" \
"../../../Lab_7.srcs/sources_1/new/sar_pwm.sv" \
"../../../Lab_7.srcs/sources_1/new/sar_processing.sv" \
"../../../../input_sync.sv" \
"../../../../sar_adc_subsystem_tb.sv" \

vlog -work xil_defaultlib \
"glbl.v"

