/********************************Copyright Statement**************************************
**
** TomatoCube & Minoyo
**
**----------------------------------File Information--------------------------------------
** File Name: Tutorial04-01-macrokey_demo.v
** Creation Date: 28th August 2024
** Function Description: Simple Macro-Key Demo by Sending Shift+A on Button-B Press
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
 
module MacroKeyDemo(swA,swB,swC,swD,swE,swF,swU,rx,tx,tx2);
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

  parameter SYS_FREQ = 12_090_000;

  // Uart Debugger Output
  wire tx_wire;
  assign tx2 = tx_wire;	// Cloning the UART TX to CH9329 for External Watcher
  assign tx  = tx_wire;	
  wire uartStart;

  // Flip Flop Key
  reg key_out_ff2;
    
  // Internal OSC setting (12.09 MHz)
  OSCH #( .NOM_FREQ("12.09")) IOSC (
      .STDBY(1'b0),
      .OSC(clk),
      .SEDSTDBY()
  );

  // CH9329 KeyStroke Sender (UART)
  always @(posedge clk or negedge swU) begin
      if(swU == 0)
          key_out_ff2 <= 0;
      else
          key_out_ff2 <= swB;
  end
  // Send Write Pulse when Falling-Edge detected on CherryMX Switch B
  assign uartStart = !swB && key_out_ff2;			

  ch9329_keystroke_sender #(SYS_FREQ) ch9329_keystroke_sender_u (
      .clk	(clk	),						// System clock
      .rst_n	(swU	),     			// Active low reset
      .start	(uartStart	),		// Start signal to send keystroke
      .modifier	(8'h02	),  		// Keycode modifier e.g. Shift, Alt...
      .keycode	(8'h04	),   		// Keycode to send (HID code)
      .autorelease	(1'b01	),	// Send a key-release after short delay
      .tx		(tx_wire		),			// UART transmit line
      .done	(	)            			// Transmission complete
  );
 
endmodule