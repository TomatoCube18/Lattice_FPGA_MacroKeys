//
// CH9329 3 Bytes HID Receiver for TomatoCube 6-Key Macro-KeyPad
// Author: Percy Chen
// Last Updated: 28th August 2024
//

module ch9329_HID_receiver (
    input clk,                  // System clock
    input rst_n,                // Active low reset
    input rx,                   // UART receive pin
    output [7:0] data_byte1,    // Array to store 3 bytes of data
    output [7:0] data_byte2, 
    output [7:0] data_byte3, 
    output reg data_valid       // Flag to indicate valid data reception 
);

    parameter SYS_FREQ = 12_090_000;    // System clock frequency (12.09 MHz)
    parameter BAUD_RATE = 9600;         // Baud rate for UART

    localparam BAUD_TICK_CNT = SYS_FREQ / BAUD_RATE;

    reg [15:0] baud_counter;
    reg [3:0] bit_counter;
    reg [2:0] byte_counter;
    reg [2:0] flag_byte_counter;
    reg [7:0] rx_data;
    reg [7:0] shift_reg;
    reg receiving;
    reg flag_detected;

	reg [7:0] data_out [0:2];
	assign data_byte1 = data_out[0];
	assign data_byte2 = data_out[1];
	assign data_byte3 = data_out[2];
	
    // Flag sequence to detect
	reg [7:0] FLAG_SEQ [0:3];// = {8'hDE, 8'hAD, 8'hBE, 8'hEF};
    
    // UART receive process
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            baud_counter <= 0;
            bit_counter <= 0;
            byte_counter <= 0;
            flag_byte_counter <= 0;
            receiving <= 0;
            flag_detected <= 0;
            data_valid <= 0;
        end else begin
            if (receiving) begin
                if (baud_counter < BAUD_TICK_CNT - 1) begin
                    baud_counter <= baud_counter + 1;
                end else begin
                    baud_counter <= 0;
                    bit_counter <= bit_counter + 1;

                    case (bit_counter)
                        0: ; // Start bit, do nothing
                        1: rx_data[0] <= rx;
                        2: rx_data[1] <= rx;
                        3: rx_data[2] <= rx;
                        4: rx_data[3] <= rx;
                        5: rx_data[4] <= rx;
                        6: rx_data[5] <= rx;
                        7: rx_data[6] <= rx;
                        8: rx_data[7] <= rx;
                        9: begin
                            bit_counter <= 0;
                            receiving <= 0;
                            if (flag_detected) begin
                                data_out[byte_counter] <= rx_data;
                                byte_counter <= byte_counter + 1;
                                if (byte_counter == 2) begin
                                    data_valid <= 1;
                                    flag_detected <= 0;
                                    byte_counter <= 0;
                                end
                            end else begin
                                if (rx_data == FLAG_SEQ[flag_byte_counter]) begin
                                    flag_byte_counter <= flag_byte_counter + 1;
                                    if (flag_byte_counter == 3) begin
                                        flag_detected <= 1;
                                        flag_byte_counter <= 0;
                                    end
                                end else begin
                                    flag_byte_counter <= 0;
                                end
                            end
                        end
                    endcase
                end
            end else begin
                if (!rx) begin // Detect start bit
                    receiving <= 1;
                    baud_counter <= BAUD_TICK_CNT / 2; // Start mid-bit for better sampling
					
					// Construct Pattern
					FLAG_SEQ [0] <= 8'hDE;
					FLAG_SEQ [1] <= 8'hAD;
					FLAG_SEQ [2] <= 8'hBE;
					FLAG_SEQ [3] <= 8'hEF;
					
					
                end
            end
        end
    end
endmodule
