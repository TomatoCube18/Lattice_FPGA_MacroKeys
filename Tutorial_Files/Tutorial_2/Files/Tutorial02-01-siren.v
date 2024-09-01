/********************************Copyright Statement**************************************
**
** TomatoCube & Minoyo
**
**----------------------------------File Information--------------------------------------
** File Name: Tutorial02-01-siren.v
** Creation Date: 28th August 2024
** Function Description: Siren Warbling sound (Ramp) from the build in onBoard Speaker
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
 
module SIREN (swA,spk);
	input wire swA;	
	output reg spk;
   
	//Siren
	reg [22:0] tone;
	reg [13:0] counter;
	wire [6:0] ramp = (tone[22] ? tone[21:15] : ~tone[21:15]);
	wire [13:0] clkdivider = {2'b01, ramp, 5'b00000};
   
  // Internal OSC setting (12.09 MHz)
  OSCH #( .NOM_FREQ("12.09")) IOSC
      (
        .STDBY(1'b0),
        .OSC(clk),
        .SEDSTDBY()
  );
   
    
	//// Siren Control
	always @(posedge clk) begin
		
		tone <= tone+1;

		if(counter==0) counter <= clkdivider; else counter <= counter-1;
		
		if (swA==1) begin
			spk <= 0;
		end
		else if (counter==0) begin
			spk <= ~spk;
		end 
		
	end
 
endmodule