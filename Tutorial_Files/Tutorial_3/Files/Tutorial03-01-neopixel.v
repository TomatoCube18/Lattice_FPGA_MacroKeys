`timescale 1ns / 1ps
 
module NeoPixel(swA,swB,swC,swD,swE,swF,swU,neopixel);
  input wire swA;	
  input wire swB;
  input wire swC;
  input wire swD;
  input wire swE;
  input wire swF;	
  input wire swU;
  
  output wire neopixel;
  
  parameter SYS_FREQ = 12_090_000;
   
	// Neopixel
  reg [11:0]neo_count;
  wire neo_refresh = neo_count[11];
  reg [23:0] test_color;/// = 24'b000000000001111100000000;
  reg [23:0] test_color2;
   
  // Internal OSC setting (12.09 MHz)
  OSCH #( .NOM_FREQ("12.09")) IOSC (
        .STDBY(1'b0),
        .OSC(clk),
        .SEDSTDBY()
  );
  
  // Instatiate NeoPixel Controller
  ws2812b_controller #(SYS_FREQ) ws2812b_controller_u (
        .clk     	(clk    ), 
    		.rst_n   	(swU    ),
        .rgb_data_0	(test_color),		// RGB color data for LED 0 (8 bits for each of R, G, B)
    		.rgb_data_1	(test_color2),	// RGB color data for LED 1
				.start_n	(neo_refresh	),	// Start signal to send data
				.data_out	(neopixel)				// WS2812B data line        
  );
  
	// NeoPixel Control
  always @(posedge clk) begin				// Stupid Code just to refresh the color!!
			neo_count <= neo_count + 1;		// Proper way would be do detect Trasition of Switch State
	end
  
	always @(posedge clk) begin
    if (swD == 0) begin							//Pressing Switch-D will Copy Color from LED 0 -> LED 1
			test_color2 <= test_color;		
		end 
		
		if (swA == 0) begin
			test_color <= 24'h00_00_3F;	//Blue		
		end 
    else if (swB == 0) begin
			test_color <= 24'h00_3F_00;	//Green			
		end 
    else if (swC == 0) begin
			test_color <= 24'h3F_00_00;	//Red 	
		end 
		else if (swE == 0) begin
			test_color <= 24'h3F_00_3F;	//Red + Blue
		end 
    else if (swF == 0) begin
			test_color <= 24'b0;	//Off
		end 

	end
 
endmodule