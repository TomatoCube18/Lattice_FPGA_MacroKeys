/********************************Copyright Statement**************************************
**
** TomatoCube & Minoyo
**
**----------------------------------File Information--------------------------------------
** File Name: Tutorial03-02-ws2812b_controller.v
** Creation Date: 28th August 2024
** Function Description: 2 Biji NeoPixel Controller code
** Operation Process:
** Hardware Platform: TomatoCube 6-Key Macro-KeyPad with MachXO2 FPGA
** Copyright Statement: This code is an IP of TomatoCube and can only for non-profit or
**                      educational exchange.
**---------------------------Related Information of Modified Files------------------------
** Modifier: Percy Chen
** Modification Date: 5th September 2024       
** Modification Content:
******************************************************************************************/

module ws2812b_controller #(
    parameter SYS_FREQ = 12_090_000    	// System clock frequency (in Hz - Def:12.09 MHz)
)(
    input clk,                      // System clock
    input rst_n,                    // Active low reset
    input [23:0] rgb_data_0,      // RGB color data for LED 0 (8 bits for each of R, G, B)
    input [23:0] rgb_data_1,      // RGB color data for LED 1
    input start_n,                    // Start signal to send data
    output reg data_out             // WS2812B data line
);

    // WS2812B timing parameters (in clock cycles)
    localparam T0H = (SYS_FREQ * 3) / 10000000;			// (SYS_FREQ * 0.3) / 1000000;  //  High time for "0" bit (0.3 µs)
    localparam T1H = (SYS_FREQ * 8) / 10000000;    		// (SYS_FREQ * 0.8) / 1000000;  //  High time for "1" bit (0.8 µs)
    localparam T0L = (SYS_FREQ * 8) / 10000000;    	    // (SYS_FREQ * 0.8) / 1000000; //  Low time for "0" bit (0.8 µs)
    localparam T1L = (SYS_FREQ * 3) / 10000000;     	// (SYS_FREQ * 0.3) / 1000000; //  Low time for "1" bit (0.3 µs)
    localparam RESET_TIME = (SYS_FREQ * 50) / 1000000; 	// (SYS_FREQ * 50) / 1000000;   //  Reset time (50 µs)
 
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
                    data_out <= 1;
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
                    // Hold data line low for 50 µs to reset the LED strip
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
