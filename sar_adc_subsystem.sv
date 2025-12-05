module sar_adc_subsystem #(
    parameter WIDTH = 8
)(
    input  logic clk,
    input  logic reset,
    input  logic enable,          // start SAR conversion
    input  logic compare_state1,         
    input  logic compare_state2,
    input  logic sar_switch,

             
    output logic done,        // 1 when conversion finished
    output logic [WIDTH-1:0] result,   // FINAL 8-bit output code
    output logic [WIDTH-1:0] dac_out,   // DAC value (result | mask)
    output logic sar_pwm_out
);

    logic cmp;
        always_comb begin
        case(sar_switch)
            1'b1: cmp = compare_state2;
            default: cmp = compare_state1;
        endcase
    end    

    // ------------------------------------------------------------
    // Internal registers
    // ------------------------------------------------------------
    typedef enum logic [1:0] { 
        IDLE, 
        SAMPLING, 
        CONVERSION, 
        COMPLETE 
    } fsm_state;

    fsm_state current_state;
    logic [WIDTH-1:0] mask;
    logic delay_zero;


    downcounter #(
        .PERIOD(2_000_000)
    ) delay_counter (
        .clk(clk),
        .reset(reset),
        .enable(1'b1),
        .zero(delay_zero)
    );

    // ------------------------------------------------------------
    // SAR FSM
    // ------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset) begin
            current_state  <= IDLE;
            result <= 0;
            mask   <= 1 << (WIDTH-1);
        end 
        else if (!enable) begin
            // enable=0 means idle/reset SAR
            current_state  <= IDLE;
            result <= 0;
            mask   <= 1 << (WIDTH-1);
        end
        else begin
            case (current_state)

                IDLE: begin
                    current_state <= SAMPLING;
                end

                SAMPLING: begin
                    mask   <= 1 << (WIDTH-1);  // start at MSB
                    result <= 0;
                    current_state  <= CONVERSION;
                end

                CONVERSION: begin
                    if (delay_zero) begin
                        if (cmp) begin
                            result <= result | mask;
                        end
                        mask <= mask >> 1;

                        if (mask == 1) begin
                            current_state <= COMPLETE;
                        end
                    end
                end

                COMPLETE: begin
                    // Stays done until enable goes low
                    current_state <= SAMPLING;
                end

            endcase
        end
    end

    // ------------------------------------------------------------
    // Outputs
    // ------------------------------------------------------------
    assign done    = (current_state == COMPLETE);
    assign dac_out = result | mask;
    
        sar_pwm #(
        .WIDTH(WIDTH)
    ) SAR_PWM (
        .clk(clk),
        .reset(reset),
        .enable(enable),    // Use the enable input
        .duty_cycle(dac_out),
        .sar_pwm_out(sar_pwm_out)   // Output PWM signal
    );


endmodule
