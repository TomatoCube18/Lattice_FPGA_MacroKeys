/********************************Copyright Statement**************************************
**
** TomatoCube & Minoyo
**
**----------------------------------File Information--------------------------------------
** File Name: Tutorial06-01-memory_demo.v
** Creation Date: 28th August 2024
** Function Description: 
** Operation Process:
** Hardware Platform: TomatoCube 6-Key Macro-KeyPad with MachXO2 FPGA
** Copyright Statement: This code is an IP of TomatoCube and can only for non-profit or
**                      educational exchange.
**---------------------------Related Information of Modified Files------------------------
** Modifier: Percy Chen
** Modification Date: 31st August 2024       
** Modification Content:
******************************************************************************************/

`timescale 1ns / 1ps
 
module Memory_Demo(swA,swB,swC,swD,swE,swF,swU,rx,tx,tx2,neopixel,scl,sda);
    input wire swA;	
    input wire swB;
    input wire swC;
    input wire swD;
    input wire swE;
    input wire swF;	
    input wire swU;

    input wire rx;
    output wire tx;
    output wire tx2;
  
  	output wire neopixel;
	
	output wire scl;
	inout wire sda;

    parameter SYS_FREQ = 12_090_000;
	
	// I2C Memory
	reg start;
    reg rw;                    // 0 = Write, 1 = Read
    reg [7:0] data_in;
    reg [7:0] address;
    wire [7:0] data_out;
	wire done;
    reg [3:0] state;
    reg [1:0] byte_counter;   // To keep track of the 3 bytes
	reg [7:0] r_color_reg;
	reg [7:0] g_color_reg;
	reg [7:0] b_color_reg;
	
    reg btn1_prev, btn2_prev, data_valid_prev;

    // States
    localparam IDLE = 4'd0;
    localparam WRITE = 4'd1;
    localparam READ = 4'd2;
    localparam DISPLAY = 4'd3;

	// Uart Receiver
	wire [7:0] r_color;
	wire [7:0] g_color;
	wire [7:0] b_color;
	wire data_valid;
  
  	// Neopixel
    reg [11:0]neo_count;
    wire neo_refresh = neo_count[11];
    reg [23:0] test_color;	/// = 24'b000000000001111100000000;
    reg [23:0] test_color2;

    // Internal OSC setting (12.09 MHz)
    OSCH #( .NOM_FREQ("12.09")) IOSC (
        .STDBY		(1'b0	),
        .OSC		(clk	),
        .SEDSTDBY	(	)
    );
	
	// Instatiate i2c Memory Controller
	i2c_eeprom #(SYS_FREQ) eeprom_u (
        .clk		(clk	),		// System clock
        .rst_n		(swU	),		// Active low reset
        .start		(start	),		// Start signal
        .rw			(rw		),		// Read/Write signal (1 = Read, 0 = Write)
        .address	(address),		// EEPROM memory address
        .data_in	(data_in	),	// Data to write
		.data_out	(data_out	),	// Data read from EEPROM
		.done		(done	),		// Operation complete signal	
        .scl		(scl	),		// I2C clock line
		.sda		(sda	)		// I2C data line
        
    );
	
	
	// i2c Memory Demo Code
	always @(posedge clk or negedge swU) begin
        if (!swU) begin		// Reset aka Button_U pressed
            state <= IDLE;
            start <= 0;
            rw <= 0;
            data_in <= 8'h00;
            address <= 8'h00;
            byte_counter <= 0;
            btn1_prev <= 1;
            btn2_prev <= 1;
			data_valid_prev <= 0;
        end else begin
            btn1_prev <= swC;
            btn2_prev <= swA;
			data_valid_prev <= data_valid;
			
			if (data_valid && !data_valid_prev) begin
				r_color_reg <= r_color[7:0];
				g_color_reg <= g_color[7:0];
				b_color_reg <= b_color[7:0];
				
			//	test_color <= {r_color[7:0], g_color[7:0], b_color[7:0]};
			//end else begin
			//	test_color <= {r_color_reg, g_color_reg, b_color_reg};	
			end
			test_color <= {r_color_reg, g_color_reg, b_color_reg};

            case (state)
                IDLE: begin
                    if (!swC && btn1_prev) begin
                        address <= 8'h01; // Set EEPROM address to 0x01
                        data_in <= r_color;  // First byte to write, Red Intensity
                        rw <= 0;           // Write operation
                        start <= 1;
                        state <= WRITE;
                        byte_counter <= 0;
                    end else if (!swA && btn2_prev) begin
                        address <= 8'h01; // Start reading from address 0x01
                        rw <= 1;          // Read operation
                        start <= 1;
                        state <= READ;
                        byte_counter <= 0;
						
                    end
                end

                WRITE: begin
                    start <= 0;
                    if (done) begin
                        byte_counter <= byte_counter + 1;
                        if (byte_counter == 2) begin
                            state <= IDLE;
                        end else begin
                            case (byte_counter)
                                1: data_in <= g_color;  // Second byte to write, Green
                                2: data_in <= b_color;  // Third byte to write, Blue
                            endcase
                            address <= address + 1;
                            start <= 1;
                        end
                    end
                end

                READ: begin
                    start <= 0;
                    if (done) begin
                        case (byte_counter)
								0: r_color_reg <= data_out;  // First byte to read, Red
                                1: g_color_reg <= data_out;  // Second byte to write, Green
                                2: b_color_reg <= data_out;  // Third byte to write, Blue
						endcase
                        byte_counter <= byte_counter + 1;
                        if (byte_counter == 2) begin
                            state <= DISPLAY;
                        end else begin
                            address <= address + 1;
                            start <= 1;
                        end
                    end 
                end

                DISPLAY: begin
                    //if (swC || swA) state <= IDLE; // Return to IDLE on button press
					//led <= data_out;  // Display the read data on LEDs
					state <= IDLE; // Return to IDLE on button press
					
                end

                default: state <= IDLE;
            endcase
        end
    end
	

  	// Instatiate NeoPixel Controller
    ws2812b_controller #(SYS_FREQ) ws2812b_controller_u (
        .clk     		(clk    ), 
        .rst_n   		(swU    ),
        .rgb_data_0	(test_color),		// RGB color data for LED 0 (8 bits for each of R, G, B)
        .rgb_data_1	(test_color),		// RGB color data for LED 1
        .start_n		(neo_refresh),	// Start signal to send data
				.data_out		(neopixel)			// WS2812B data line        
    );

    // NeoPixel Control
    always @(posedge clk) begin			// Stupid Code just to refresh the color!!
    		neo_count <= neo_count + 1;	// Proper way would be do detect State Trasition
			//test_color <= {r_color[7:0], g_color[7:0], b_color[7:0]};	// Test_color to be handled by memory Test Code
    end
    
  	// UART Receiver	
	ch9329_HID_receiver #(SYS_FREQ) ch9329_HID_receiver_u (
        .clk		(clk	),					// System clock
        .rst_n		(swU	),					// Active low reset
        .rx			(rx		),					// UART receive pin
        .data_byte1	(r_color	),				// Array to store 3 bytes of data
        .data_byte2	(g_color	), 
        .data_byte3	(b_color	), 
        .data_valid	(data_valid	)		// Flag to indicate valid data reception 
	);

	
	
endmodule