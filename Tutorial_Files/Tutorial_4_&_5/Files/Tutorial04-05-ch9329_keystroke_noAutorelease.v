/********************************Copyright Statement**************************************
**
** TomatoCube & Minoyo
**
**----------------------------------File Information--------------------------------------
** File Name: Tutorial04-01-macrokey_demo.v
** Creation Date: 5th August 2024
** Function Description: Simple Macro-Key Demo by Sending A,b,C on Button-C,B,A Press
** Operation Process:
** Hardware Platform: TomatoCube 6-Key Macro-KeyPad with MachXO2 FPGA
** Copyright Statement: This code is an IP of TomatoCube and can only for non-profit or
**                      educational exchange.
**---------------------------Related Information of Modified Files------------------------
** Modifier: Percy Chen
** Modification Date: 5th September 2024       
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
  reg uartStart;

  // Uart KeyStroke
  reg [7:0] hidCode;
  reg [7:0] modifierCode;
  
  // Flip Flop Key
  reg key_out_ff1;
  reg key_out_ff2;
  reg key_out_ff3;
    
  // Internal OSC setting (12.09 MHz)
  OSCH #( .NOM_FREQ("12.09")) IOSC (
      .STDBY	(1'b0	),
      .OSC		(clk	),
      .SEDSTDBY	(		)
  );

  // CH9329 KeyStroke Sender (UART)
  always @(posedge clk or negedge swU) begin
      if(swU == 0) begin
		  key_out_ff1 <= 0;
          key_out_ff2 <= 0;
		  key_out_ff3 <= 0;
		  hidCode <= 8'h00;
		  modifierCode <= 8'h00;
      end else begin
          key_out_ff1 <= swA;
		  key_out_ff2 <= swB;
		  key_out_ff3 <= swC;
		  // Send Write Pulse on either-Edge detected on CherryMX Switch A, B & C
		  uartStart <= (swA ^ key_out_ff1) 
						|| (swB ^ key_out_ff2) 
						|| (swC ^ key_out_ff3);
		  
		  if (swA && swB && swC) begin
			  hidCode <= 8'h00;
			  modifierCode <= 8'h00;
		  end
		  else if (swA == 0) begin	// Switch A -> Send C
			  hidCode <= 8'h06;
			  modifierCode <= 8'h02;
		  end 
		  else if (swB == 0) begin	// Switch B -> Send b
			  hidCode <= 8'h05;
			  modifierCode <= 8'h00;
		  end 
		  else if (swC == 0) begin	// Switch C -> Send A
			  hidCode <= 8'h04;
			  modifierCode <= 8'h02;
		  end 
      end
  end
  
  
  ch9329_keystroke_sender #(SYS_FREQ) ch9329_keystroke_sender_u (
      .clk			(clk			),	// System clock
      .rst_n		(swU			),	// Active low reset
      .start		(uartStart		),	// Start signal to send keystroke
      .modifier		(modifierCode	),  // Keycode modifier e.g. Shift, Alt...
      .keycode		(hidCode		),	// Keycode to send (HID code)
      .autorelease	(1'b00			),	// Send a key-release after short delay
      .tx			(tx_wire		),	// UART transmit line
      .done			(				)	// Transmission complete
  );
 
endmodule