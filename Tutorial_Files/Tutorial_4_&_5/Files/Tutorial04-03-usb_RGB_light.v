`timescale 1ns / 1ps
 
module USB_RGB_Light(swA,swB,swC,swD,swE,swF,swU,rx,tx,tx2,neopixel);
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

    parameter SYS_FREQ = 12_090_000;

    //Uart Receiver
    wire [7:0] r_color;
    wire [7:0] g_color;
    wire [7:0] b_color;
  
  	// Neopixel
    reg [11:0]neo_count;
    wire neo_refresh = neo_count[11];
    reg [23:0] test_color;	/// = 24'b000000000001111100000000;
    reg [23:0] test_color2;

    // Internal OSC setting (12.09 MHz)
    OSCH #( .NOM_FREQ("12.09")) IOSC (
        .STDBY		(1'b0	),
        .OSC		(clk	),
        .SEDSTDBY	(	    )
    );

  	// Instatiate NeoPixel Controller
    ws2812b_controller #(SYS_FREQ) ws2812b_controller_u (
        .clk     		(clk    ), 
        .rst_n   		(swU    ),
        .rgb_data_0	    (test_color),		// RGB color data for LED 0 (8 bits for each of R, G, B)
        .rgb_data_1	    (test_color),		// RGB color data for LED 1
        .start_n		(neo_refresh),	    // Start signal to send data
        .data_out		(neopixel)			// WS2812B data line        
    );

    // NeoPixel Control
    always @(posedge clk) begin			// Stupid Code just to refresh the color!!
    		neo_count <= neo_count + 1;	// Proper way would be do detect State Trasition
    		test_color <= {r_color[7:0], g_color[7:0], b_color[7:0]};
    end
    
  	// UART Receiver	
    ch9329_HID_receiver #(SYS_FREQ) ch9329_HID_receiver_u (
        .clk		(clk	),      // System clock
        .rst_n	    (swU	),      // Active low reset
        .rx			(rx		),      // UART receive pin
        .data_byte1	(r_color	),	// Array to store 3 bytes of data
        .data_byte2	(g_color	), 
        .data_byte3	(b_color	), 
        .data_valid	(       )       // Flag to indicate valid data reception 
    );

endmodule