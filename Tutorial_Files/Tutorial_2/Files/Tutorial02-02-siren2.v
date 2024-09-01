/********************************Copyright Statement**************************************
**
** TomatoCube & Minoyo
**
**----------------------------------File Information--------------------------------------
** File Name: Tutorial02-02-siren.v
** Creation Date: 28th August 2024
** Function Description: Siren Warbling sound (Ramp) from the build in onBoard Speaker(2)
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
 
module SIREN (swA,swC,spk);
    input wire swA;	
	input wire swC;
	output reg spk;
   
    //Siren
	reg [22:0] tone;
	reg [13:0] counter;
	wire [6:0] ramp = (tone[22] ? tone[21:15] : ~tone[21:15]);
	wire [13:0] clkdivider = {2'b01, ramp, 5'b00000};
	
	reg [26:0] tone2;
	reg [13:0] counter2;
	wire [6:0] fastsweep = (tone2[22] ? tone2[21:15] : ~tone2[21:15]);
	wire [6:0] slowsweep = (tone2[25] ? tone2[24:18] : ~tone2[24:18]);
	wire [14:0] clkdivider2 = {2'b01, (tone2[26] ? slowsweep : fastsweep), 5'b00000};
   
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
			
		tone2 <= tone2+1;	
		if(counter2==0) counter2 <= clkdivider2; else counter2 <= counter2-1;
		
		
		if ((swA==1)&&(swC==1)) begin
			spk <= 0;
		end
		else begin
			if (swC==0) begin
				if (counter==0) begin
					spk <= ~spk;
				end
			end 
			else if (swA==0) begin
				if (counter2==0) begin
					spk <= ~spk;
				end
			end 
		end
		
		//if ((swA==1)&&(swC==1)) 
			//spk <= 0;
		//else begin
			//if ((swC==0)&&(counter==0)) 
				//spk <= ~spk;
			//else if ((swA==0)&&(counter2==0)) 
				//spk <= ~spk;	
			//else
				//spk <= 0;
		//end
		
		
		
	end
 
endmodule