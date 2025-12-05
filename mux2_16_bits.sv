module mux2_16_bits(
    input  logic [7:0] in0,  
    input  logic [7:0] in1,  
    input  logic [7:0] in2, 
    input  logic  [1:0] select,
    input  logic   pwm_out,
    input  logic   sar_pwm_out,   
    output logic [7:0] mux_out,
    output logic pwm
    );

    always_comb begin
        case(select)
            2'b11: mux_out = in1;  
            default: mux_out = in0;
        endcase
    end 

    always_comb begin
        case(select)
            2'b11: pwm = sar_pwm_out;  
            default: pwm = pwm_out;
        endcase
    end 

endmodule