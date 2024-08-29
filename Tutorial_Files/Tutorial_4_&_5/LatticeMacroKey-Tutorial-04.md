### [4.4.1](#Chapter4_4_1) HDL Code Tutorial #4: Using Standard Serial Protocol to send a KeyStroke [UART TX to USB HID IC interfacing CH9329

When we last checked the marketing brochure, the Lattice MachXO2 Family of FPGA chips doesn't come with any peripherals for USB interfacing. So, how are we interfacing our FPGA through USB & sending keystrokes to our computers or smart devices? 
The solution lies in the use of a specialized USB interfacing IC, the **CH9329** from WCH. This chip allows any device capable of Serial/UART communication to be recognized as a standard USB keyboard, mouse, or custom HID device when plugged into a USB port of a HID-capable device or computer.

```mermaid
flowchart LR
    A["Computer"] <--"USB"--> B
    subgraph "Macro-KeyPad"
        B["CH9329"] <--"UART"--> C["MachXO2"] --- D["CherryMX\nSwitches"]
    end
    
      
````

The CH9329 supports several modes of communication, but we highly recommend sticking with the development board's default configuration, "Protocol Transmission Mode". Although this mode is more complex compared to the "ASCII Mode", it allows the Macro-KeyPad to send special key presses and even mouse operations. 

> Soldering set is necessary to fuse the on-board solder jumpers if you need to switch to an alternative mode of communication.

To understand more about the various modes supported by the CH9329 IC, you can refer to the [CH9329 official data-sheet](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Relevant_Docs_DataSheets/WCH-Ch9329_Datasheet.pdf). Additionally, the [CH9239 comunication protocol specification](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Relevant_Docs_DataSheets/WCH-CH9329芯片串口通信协议-CommunicationProtocol.PDF) (available only in Chinese), provides guidance on how to perform various operations under the "Protocol Transmission Mode" detailing how to contruct the correct sequence of bytes that must be transmitted via Serial/UART from our FPGA to the CH9329 in order to perform the various USB keyboard/mouse operations.

#### To simplify matters, here are some of the UART communication transaction:

##### Sequence for General Keyboard Operation:

| Frame Header | Address | Command ID | Data Length | Data Payload | Checksum |
|:------------:|:-------:|:------------:|:-----------:|:------------:|:-----------:|
| 0x57 0xAB | 0x00  | 0x02  | 0x08 | 8 Bytes | 0x?? |

##### Data Payload
* Byte 1:
	Modifier Keys:
	| Bit 7 | Bit 6 | Bit 5 | Bit 4 | Bit 3 | Bit 2 | Bit 1 | Bit 0 |
	|:-----: |:------:|:------:|:------:|:-----:|:------:|:------:|:------:|
	| R-Win | R-ALT | R-SHIFT | R-CTRL | L-Win | L-ALT | L-SHIFT | L-CTRL | 
* Byte 2:
	0x00
* Byte 3~8:
	HID Code for each Key, Max of 6 simultaneous Keys.
	
	> Refer to **Page 15** of the [CH9239 comunication protocol specification](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Relevant_Docs_DataSheets/WCH-CH9329芯片串口通信协议-CommunicationProtocol.PDF)
###### Example

* Emulating pressing & releasing the **"A"** Key:

  [-Press-]
  _(FPGA→CH9329)_ 0x57 0xAB 0x00 0x02 0x08 0x00 0x00 **0x04** 0x00 0x00 0x00 0x00 0x00 **0x10** 
  _(FPGA←CH9329)_ 0x57 0xAB 0x00 0x82 0x01 0x00 0x85
  [-Release-]
  _(FPGA→CH9329)_ 0x57 0xAB 0x00 0x02 0x08 0x00 0x00 **0x00** 0x00 0x00 0x00 0x00 0x00 **0x0C** 
  _(FPGA←CH9329)_ 0x57 0xAB 0x00 0x82 0x01 0x00 0x85

* Emulating pressing & releasing **"R-Shift"+"A"** Key:

  [-Press-]
  _(FPGA→CH9329)_ 0x57 0xAB 0x00 0x02 0x08 **0x02** 0x00 **0x04** 0x00 0x00 0x00 0x00 0x00 **0x12** 
  _(FPGA←CH9329)_ 0x57 0xAB 0x00 0x82 0x01 0x00 0x85
  [-Release-]
  _(FPGA→CH9329)_ 0x57 0xAB 0x00 0x02 0x08 **0x00** 0x00 **0x00** 0x00 0x00 0x00 0x00 0x00 **0x0C** 
  _(FPGA←CH9329)_ 0x57 0xAB 0x00 0x82 0x01 0x00 0x85

##### Sequence for Media Keyboard Operation:

| Frame Header | Address | Command code | Data Length | Data Payload | Checksum |
|:------------:|:-------:|:------------:|:-----------:|:------------:|:-----------:|
| 0x57 0xAB | 0x00  | 0x03  | 0x04 | 4 Bytes | 0x?? |

##### Data Payload
> Refer to **Page 17** of the [CH9239 comunication protocol specification](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Relevant_Docs_DataSheets/WCH-CH9329芯片串口通信协议-CommunicationProtocol.PDF)

###### Example

* Emulating pressing & releasing Multimeter **"Mute"** Key:

  [-Press-]
  _(FPGA→CH9329)_ 0x57 0xAB 0x00 0x03 0x04 **0x02 0x04** 0x00 0x00 **0x0F** 
  _(FPGA←CH9329)_ 0x57 0xAB 0x00 0x83 0x01 0x00 0x86
  [-Release-]
  _(FPGA→CH9329)_ 0x57 0xAB 0x00 0x03 0x04 **0x02 0x00** 0x00 0x00 **0x0B** 
  _(FPGA←CH9329)_ 0x57 0xAB 0x00 0x83 0x01 0x00 0x86



##### Schematic of the CH9329 USB interface and its connection to the FPGA via the UART pins 

![Speaker_Driver](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_4_&_5/Images/Tutorial04-01-USB_HID_CH9329.png?raw=true)



##### [Step 1:](#Chapter4_4_1_1) Importing the KeyStroke Library Code into your project

...

###### CH9329 KeyStroke Sender module file (\*.v):
Grab the CH9329 Keystroke Sender source code from our [repository: ch9329_keystroke_sender.v](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_4_%26_5/Files/Tutorial04-02-ch9329_keystroke_sender.v), place it into your Diamond project folder together with your Top-Level verilog file.

To use the KeyStroke Sender code, you only need to know the Ports of our controller module & its respective functions. The names of the ports are chosen to be self-explanatory,  furthermore the source code is also heavily commented making it rather easy to follow.

```verilog
module ch9329_keystroke_sender (
    input wire clk,             // System clock
    input wire rst_n,           // Active low reset
    input wire start,           // Start signal to send keystroke
    input wire [7:0] modifier,  // Keycode modifier e.g. Shift, Alt...
    input wire [7:0] keycode,   // Keycode to send (HID code)
    input wire autorelease,     // Send a key-release after short delay
    output reg tx,              // UART transmit line
    output reg done             // Transmission complete
);

parameter SYS_FREQ = 12_090_000;  			// System clock frequency (12.09 MHz)
parameter BAUD_RATE = 9600;     				// UART baud rate
parameter DELAY_CYCLES = SYS_FREQ / 4;	// 0.25-second delay between keystroke and release
```


* Blah blah blah blah 🧛🏻



##### [Step 2:](#Chapter4_4_1_2) Creating the Key-Press Demo Source Code

Populate the code editor with the following Top-Level file implementation & hit **save**. The code will instantiate the CH9329 KeyStroke Sender module & send the desired HID KeyCode whenever a CherryMX Switch/Button is pressed.

###### Verilog Top-level file (\*.v):
```verilog
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
   
	//Uart Debugger Output
  wire tx_wire;
  assign tx2 = tx_wire;	// Cloning the UART TX to CH9329 for External Watcher
  assign tx  = tx_wire;	
  
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
```





##### [Step 3:](#Chapter4_3_1_3) Observing the result on the Macro-KeyPad
After the generated JEDEC has been programmed into the FPGA, the HDL configuration will take into effect. Pressing the **CherryMX Switch A-C, E & F** with change the color of NeoPixel #1; Pressing the **CherryMX Switch D** with copy the color of NeoPixel #1 → NeoPixel #2

> Please rememberl that the **CherryMX Switch A** will be the top-right switch as you flip the Macro-KeyPad board around!

![user LED & Button Location](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_3/Images/Tutorial03-02-Neopixel_Location.png?raw=true)

### [4.4.2](#Chapter4_4_2) Additional Challenge
* ...



[Lattice]:(https://www.latticesemi.com)