/********************************Copyright Statement**************************************
**
** TomatoCube & Minoyo
**
**----------------------------------File Information--------------------------------------
** File Name: Tutorial01-01-led.v
** Creation Date: 28th August 2024
** Function Description: Blinking of the User LED while Reading the USER Button Activity
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
 
module LED (swU,led);
    input wire swU;                        
    output reg led;
   
    reg [31:0]count;
   
    // Internal OSC setting (12.09 MHz)
    OSCH #( .NOM_FREQ("12.09")) IOSC
        (
          .STDBY(1'b0),
          .OSC(clk),
          .SEDSTDBY()
        );
   
    always @(posedge clk or negedge swU) begin
        if (swU == 0) begin
            led <= 1;
        end else if(count == 9999999) begin //Time is up = 9999999/12.09MHz = 0.82s
            count <= 0;             //Reset count register
            led <= ~led;            //Toggle led (in each second)
        end else begin
            count <= count + 1;     //Counts 12.09MHz clock
        end
 
    end
 
endmodule