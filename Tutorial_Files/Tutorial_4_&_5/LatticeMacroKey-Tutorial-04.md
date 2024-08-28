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

| Frame Header | Address | Command code | Data Length | Data Payload | Checksum |
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
	Refer to **Page 15** of the [CH9239 comunication protocol specification](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Relevant_Docs_DataSheets/WCH-CH9329芯片串口通信协议-CommunicationProtocol.PDF)
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
Refer to **Page 17** of the [CH9239 comunication protocol specification](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Relevant_Docs_DataSheets/WCH-CH9329芯片串口通信协议-CommunicationProtocol.PDF)
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
    input wire [7:0] keycode,   // Keycode to send (HID code)
    output reg tx,              // UART transmit line
    output reg done             // Transmission complete
);

parameter SYS_FREQ = 12_090_000; 
```

inspective the controller reveals that, the whole operation is rather trivial & it consists nothing more than a 7 States state-machine.




* **IDLE** : 

* **START_BIT**: 

* **SEND_BYTE**: 

* **STOP_BIT**: 

* **DELAY**: 

* **RELEASE_KEY**: 

* **DONE**:



##### [Step 2:](#Chapter4_4_1_2) Creating the NeoPixel Driving Source Code

Populate the code editor with the following Top-Level file implementation & hit **save**. The code will instantiate the NeoPixels controller module & in trurn send out data signal to drive our 2 NeoPixels on the Development board.

###### Verilog Top-level file (\*.v):
```verilog
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
			test_color <= 24'b0;	//Black -> Off
		end 

	end
 
endmodule
```

> NeoPixels are capable of shining super bright light, but just like everything in this universe, 'The flame that burns Twice as bright burns half as long.' Try not to use full-intensity on any of the color channel. And if you are diplaying white (or Grey), try to lower the combined intensity.



##### [Step 3:](#Chapter4_3_1_3) Observing the result on the Macro-KeyPad
After the generated JEDEC has been programmed into the FPGA, the HDL configuration will take into effect. Pressing the **CherryMX Switch A-C, E & F** with change the color of NeoPixel #1; Pressing the **CherryMX Switch D** with copy the color of NeoPixel #1 → NeoPixel #2

> Please rememberl that the **CherryMX Switch A** will be the top-right switch as you flip the Macro-KeyPad board around!

![user LED & Button Location](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_3/Images/Tutorial03-02-Neopixel_Location.png?raw=true)

### [4.4.2](#Chapter4_4_2) Additional Challenge
* ...



[Lattice]:(https://www.latticesemi.com)