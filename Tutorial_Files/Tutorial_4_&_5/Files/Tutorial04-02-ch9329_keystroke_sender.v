module ch9329_keystroke_sender (
    input wire clk,             // System clock
    input wire rst_n,           // Active low reset
    input wire start,           // Start signal to send keystroke
    input wire [7:0] keycode,   // Keycode to send (HID code)
    output reg tx,              // UART transmit line
    output reg done             // Transmission complete
);

    parameter SYS_FREQ = 12_090_000;  // System clock frequency (12.09 MHz)
    parameter BAUD_RATE = 9600;     // UART baud rate
    parameter DELAY_CYCLES = SYS_FREQ / 4; // 0.25-second delay between keystroke and release

    localparam BIT_PERIOD = SYS_FREQ / BAUD_RATE; // Clock cycles per UART bit
    localparam NUM_BYTES = 14;  // Number of bytes in the keystroke command

    // UART transmission states
    localparam IDLE        = 3'd0;
    localparam START_BIT   = 3'd1;
    localparam SEND_BYTE   = 3'd2;
    localparam STOP_BIT    = 3'd3;
    localparam DELAY       = 3'd4;
    localparam RELEASE_KEY = 3'd5;
    localparam DONE        = 3'd6;

    reg [2:0] state;        // State machine
    reg [15:0] clk_count;   // Clock counter for timing
    reg [7:0] shift_reg;    // Shift register for transmitting data
    reg [3:0] bit_index;    // Bit index within the byte being sent
    reg [3:0] byte_index;   // Index for the array of bytes to be sent
    reg [31:0] delay_counter; // Counter for delay
    reg [7:0] tx_data [NUM_BYTES-1:0]; // Array to hold the command sequence

		

    // Function to calculate checksum
    function [7:0] calculate_checksum(input in);
        integer i;
        begin
            calculate_checksum = 8'h00;
            for (i = 0; i < NUM_BYTES-1; i = i + 1) begin
                calculate_checksum = calculate_checksum + tx_data[i];
            end
            //calculate_checksum = ~calculate_checksum + 1; // Two's complement
        end
    endfunction


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            tx <= 1;
            done <= 0;
            clk_count <= 0;
            shift_reg <= 0;
            bit_index <= 0;
            byte_index <= 0;
            delay_counter <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1;
                    done <= 0;
                    if (start) begin
                        
						tx_data[0]  <= 8'h57;    // Start byte
						tx_data[1]  <= 8'hAB;    // Command identifier
						tx_data[2]  <= 8'h00;    // Reserved
						tx_data[3]  <= 8'h02;    // Reserved
						tx_data[4]  <= 8'h08;    // Report ID
						tx_data[5]  <= 8'h00;    // Reserved
						tx_data[6]  <= 8'h00;    // Reserved
						tx_data[7]  <= keycode;  // Keycode byte
						tx_data[8]  <= 8'h00;    // Reserved
						tx_data[9]  <= 8'h00;    // Reserved
						tx_data[10] <= 8'h00;    // Reserved
						tx_data[11] <= 8'h00;    // Reserved
						tx_data[12] <= 8'h00;    // Reserved
						
						
						state <= START_BIT;
                        clk_count <= 0;
                        bit_index <= 0;
						byte_index <= 0;
						
                    end
                end

                START_BIT: begin
                    if (clk_count < BIT_PERIOD - 1) begin
                        clk_count <= clk_count + 1;
                        tx <= 1; 
                    end else begin
						tx <= 0; // Start bit
                        clk_count <= 0;
                        state <= SEND_BYTE;
						
						tx_data[13] <= calculate_checksum(0); // Checksum
						shift_reg <= tx_data[byte_index];
                        
                    end
                end

                SEND_BYTE: begin
                    if (clk_count < BIT_PERIOD - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        tx <= shift_reg[0]; // Send the LSB of the byte
                        shift_reg <= {1'b1, shift_reg[7:1]}; // Shift the next bit into position
                        bit_index <= bit_index + 1;
                        if (bit_index == 8) begin	// Sending extra bit on purpose...
							state <= STOP_BIT;
                        end
                    end
                end

                STOP_BIT: begin
                    if (clk_count < BIT_PERIOD - 1) begin
                        clk_count <= clk_count + 1;
                        tx <= 1; // Stop bit
                    end else begin
						if (byte_index < NUM_BYTES-1) begin
							byte_index <= byte_index + 1;
							
							state <= START_BIT;
							shift_reg <= tx_data[byte_index + 1];	// Next Byte
							clk_count <= 0;
							bit_index <= 0;
						end else begin
							state <= DELAY;
							delay_counter <= 0;
						end
                    end
                end

                DELAY: begin
                    if (delay_counter < DELAY_CYCLES) begin
                        delay_counter <= delay_counter + 1;
                    end else begin
                        delay_counter <= 0;
						
						if (tx_data[7] != 8'h00) begin
							// Generate key release command (only checksum differs)
							tx_data[7] <= 8'h00; // No keycode
							
							byte_index <= 0;
							state <= RELEASE_KEY;
						end else begin
							byte_index <= 0;
							state <= DONE;
						end
                    end
                end

                RELEASE_KEY: begin
                    shift_reg <= tx_data[byte_index];
					state <= START_BIT;
					clk_count <= 0;
					bit_index <= 0;
                end

                DONE: begin
                    done <= 1; // Indicate the transmission is complete
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
