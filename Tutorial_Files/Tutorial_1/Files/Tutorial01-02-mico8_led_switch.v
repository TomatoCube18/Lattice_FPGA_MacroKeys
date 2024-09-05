/********************************Copyright Statement**************************************
**
** TomatoCube & Minoyo
**
**----------------------------------File Information--------------------------------------
** File Name: Tutorial01-02-mico8_led_switch.v
** Creation Date: 28th August 2024
** Function Description: mico8 SoC Top-Level File
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
`include "../soc/platform1.v"
 
module platform1_top
(
    input swA,
    input swB,
    input swC,
    input swD,
    input swE,
    input swF,
    input swU,
    input rx,
    output tx,
    output led
);
 
    wire [6:0] button_in = {swU,swF,swE,swD,swC,swB,swA};
 
    // MachX02 internal oscillator generates platform clock
    wire clk;
    // Internal OSC setting (12.09 MHz)
    OSCH #( .NOM_FREQ("12.09")) IOSC
    (
        .STDBY		(1'b0),
        .OSC		(clk),
        .SEDSTDBY	(		)
    );
    
 
    platform1 platform1_u
    (
        .clk_i 		    (clk),
        .reset_n 		(swU	),
        .LEDPIO_OUT 	(led	),
        .BUTTONPIO_IN   (button_in),
        .uartSIN 		(rx		),
        .uartSOUT 		(tx		)
    );
 
endmodule