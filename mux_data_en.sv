module mux_data_en(
    input logic [1:0] mode_select,
    input logic [15:0] xadc_data,
    input logic [15:0] captured_duty_cycle,
    input logic [15:0]  r2r_captured_duty_cycle,
    input logic [15:0]  result_code,
    
    output logic [15:0] data
    );
    
    always_comb begin
        case(mode_select)
            2'b01: data = captured_duty_cycle;
            2'b10: data = r2r_captured_duty_cycle;
            2'b11: data = result_code;

            default: data = xadc_data;  // Default case: output all zeros
        endcase
    end    
    
endmodule
