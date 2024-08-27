//
// NeoPixel Controller for TomatoCube 6-Key Macro-KeyPad
// Author: Percy Chen
// Last Updated: 28th August 2024
//

module ws2812b_controller (
    input clk,                      // System clock
    input rst_n,                    // Active low reset
    input [23:0] rgb_data_0,      // RGB color data for LED 0 (8 bits for each of R, G, B)
    input [23:0] rgb_data_1,      // RGB color data for LED 1
    input start_n,                    // Start signal to send data
    output reg data_out             // WS2812B data line
);

    parameter SYS_FREQ = 12_090_000; 

    // WS2812B timing parameters (in clock cycles)
    localparam T0H = 5;     // (CLK_FREQ * 0.4) / 1000000;  //  High time for "0" bit (0.4 �s)
    localparam T1H = 10;    // (CLK_FREQ * 0.8) / 1000000;  //  High time for "1" bit (0.8 �s)
    localparam T0L = 10;    // (CLK_FREQ * 0.85) / 1000000; //  Low time for "0" bit (0.85 �s)
    localparam T1L = 5;     // (CLK_FREQ * 0.45) / 1000000; //  Low time for "1" bit (0.45 �s)
    localparam RESET_TIME = 610; // CLK_FREQ * 50) / 1000000;   //  Reset time (50 �s)
    
    reg [7:0] bit_counter;    // Counts the bits in the color data
    reg [15:0] clk_counter;   // Clock cycle counter for timing
    reg [23:0] shift_reg;     // Shift register to hold color data
    reg [2:0] state;          // State machine
    reg [1:0] led_index;      // LED index (0 or 1)
	
	wire [23:0] color_data_0 = {rgb_data_0[15:8], rgb_data_0[23:16], rgb_data_0[7:0]};	//Rearrange the NeoPixel Ordering
	wire [23:0] color_data_1 = {rgb_data_1[15:8], rgb_data_1[23:16], rgb_data_1[7:0]};	//Rearrange the NeoPixel Ordering
	
    localparam IDLE   = 3'd0;
    localparam LOAD   = 3'd1;
    localparam SEND   = 3'd2;
    localparam NEXT_LED = 3'd3;
    localparam RESET  = 3'd4;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= 0;
            bit_counter <= 0;
            clk_counter <= 0;
            shift_reg <= 0;
            state <= IDLE;
            led_index <= 0;
        end else begin
            case (state)
                IDLE: begin
                    data_out <= 0;
                    if (start_n == 0) begin
                        shift_reg <= color_data_0;
                        bit_counter <= 23;
                        led_index <= 0;
                        state <= LOAD;
                    end
                end
                
                LOAD: begin
                    // Load the first bit and transition to SEND state
                    data_out <= shift_reg[23];
                    shift_reg <= {shift_reg[22:0], 1'b0};
                    clk_counter <= 0;
                    state <= SEND;
                end
                
                SEND: begin
                    clk_counter <= clk_counter + 1;
                    
                    if (shift_reg[23] == 1'b1) begin
                        if (clk_counter < T1H) begin
                            data_out <= 1;
                        end else if (clk_counter < T1H + T1L) begin
                            data_out <= 0;
                        end else begin
                            clk_counter <= 0;
                            if (bit_counter > 0) begin
                                bit_counter <= bit_counter - 1;
                                shift_reg <= {shift_reg[22:0], 1'b0};
                            end else begin
                                state <= NEXT_LED;
                                clk_counter <= 0;
                            end
                        end
                    end else begin
                        if (clk_counter < T0H) begin
                            data_out <= 1;
                        end else if (clk_counter < T0H + T0L) begin
                            data_out <= 0;
                        end else begin
                            clk_counter <= 0;
                            if (bit_counter > 0) begin
                                bit_counter <= bit_counter - 1;
                                shift_reg <= {shift_reg[22:0], 1'b0};
                            end else begin
                                state <= NEXT_LED;
                                clk_counter <= 0;
                            end
                        end
                    end
                end
                
                NEXT_LED: begin
                    if (led_index == 0) begin
                        shift_reg <= color_data_1;
                        bit_counter <= 23;
                        led_index <= 1;
                        state <= LOAD;
                    end else begin
                        state <= RESET;
						clk_counter <= 0;
                    end
                end
                
                RESET: begin
                    // Hold data line low for 50 �s to reset the LED strip
                    if (clk_counter < RESET_TIME) begin
                        data_out <= 0;
                        clk_counter <= clk_counter + 1;
                    end else begin
                        state <= IDLE;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule
