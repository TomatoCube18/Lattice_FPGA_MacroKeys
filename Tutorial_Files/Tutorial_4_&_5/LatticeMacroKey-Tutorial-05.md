### [4.5.1](#Chapter4_5_1) HDL Code Tutorial #5: USB Custom HID upstream transfer using Python [UART RX from USB HID IC CH9329]

In our previous tutorial, we used the USB HID IC **CH9329** for its most obvious functions—as a USB keyboard or mouse. However, after thoroughly reviewing the functionality of the **CH9329** through the [CH9329 official data sheet](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Relevant_Docs_DataSheets/WCH-Ch9329_Datasheet.pdf) and the [CH9329 communication protocol specification](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Relevant_Docs_DataSheets/WCH-CH9329芯片串口通信协议-CommunicationProtocol.PDF) (available only in Chinese), we discovered that the **CH9329** IC has another skills up its sleeve: _it can receive data from the computer (Upstream transfer)_. And before you ask—**yes**, you will need a custom application running on your computer that can connect to a custom USB HID device and push data to it.

When deciding on how to write the USB HID sender, I considered a few modern programming languages, each with its pros and cons. I ultimately chose **Python**🐍 due to its popularity among the academia, vibrant and up-to-date library support, and lastly, the cross-platform compatibility.

The hardware setup for this tutorial remains the same. The Python software running on your computer will send a custom package of bytes through USB to the **CH9329** IC. The data will be encapsulated within the **CH9329** Data Frame format and passed to our FPGA via UART (RX). After decoding (stripping away the header), the message will reveal our **three-bytes** used to control the Red, Green, and Blue intensity of the NeoPixel LEDs (The goal of this tutorial).

```mermaid
flowchart LR
    A["Computer\n(Python Script)"] <--"USB"--> B
    subgraph "Macro-KeyPad"
        B["CH9329"] <--"UART"--> C["MachXO2"] --- D["NeoPixels\n(ws2812b)"]
    end
    
      
````

‼️ I’ll assume your development board is still using the default configuration, "Protocol Transmission Mode." Custom USB HID message passing is only possible in this mode.



#### To simplify matters, here is the UART communication transaction for HID reception:

##### Sequence for Reading HID Data:

| Frame Header | Address | Command ID | Data Length | Data Payload | Checksum |
|:------------:|:-------:|:------------:|:-----------:|:------------:|:-----------:|
| 0x57 0xAB | 0x00  | 0x87 | N (Max 64) | N Bytes | 0x?? |

##### Data Payload (Self-Defined - Percy's RGB LED Magic Header Signature)

The CH9329 doesn’t care what the Data Payload contains; it simply adds the prefixes, the N-length payload, and a calculated checksum before sending it through the UART. 

Below is a custom **"4-Magic Header Signature"** we designed to filter and easily locate the **three-bytes** needed for the NeoPixel LEDs.

* Byte 1: 0xDE
* Byte 2: 0xAD
* Byte 3: 0xBE
* Byte 4: 0xEF
* Byte 5: **0xRR** [Red intensity]
* Byte 6: **0xGG** (Green intensity)
* Byte 7: **0xBB** (Blue Intensity)
###### Example

* Sample transaction of sending a Red of 0x1F intensity + Blue of 0x0F intensity through the USB HID channel

  _(Computer→CH9329)_ 0x07 0xDE 0xAD 0xBE 0xEF **0x1F 0x00 0x0F**  

  _(CH9329→FPGA)_ 0x57 0xAB 0x00 0x87 0x07 0xDE 0xAD 0xBE 0xEF **0x1F 0x00 0x0F** 0xF6

  _(FPGA→ws2812b)_ **0x1F (Red), 0x00 (Green), 0x0F(Blue)**
  


##### Schematic of the CH9329 USB interface and its connection to the FPGA via the UART pins 

![CH9329 Schematic](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_4_&_5/Images/Tutorial04-01-USB_HID_CH9329.png?raw=true)



##### [Step 1:](#Chapter4_5_1_1) Importing the HID Receiving Module Code into your project

To keep things simple, my module code will ignore the CH9329’s Frame header and continuously receive & wait for the **4- Magic Header Signature 𐂌🥩 **(0xDE, 0xAD, 0xBE, 0xEF) to arrive through the UART. This will signal the FPGA to expect the subsequent three bytes as the color components for the NeoPixels.

###### CH9329 HID Receiver Module File (*.v):

Download the CH9329 HID receiver source code from our [repository: ch9329_HID_receiver.v](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_4_%26_5/Files/Tutorial04-04-ch9329_HID_receiver.v) and place it into your Diamond project folder alongside your Top-Level Verilog file _(Which might not yet exist, if you are starting a brand new project)_.

To use the HID receiver code, you only need to understand the ports of our HID receiver module and their respective functions. The port names are self-explanatory, and the source code is thoroughly commented, making it easy to follow.

```verilog
module ch9329_HID_receiver #(
    parameter SYS_FREQ = 12_090_000,		// System clock frequency (in Hz - Def:12.09 MHz)
    parameter BAUD_RATE = 9600     			// UART baud rate
)(
    input clk,                  // System clock
    input rst_n,                // Active low reset
    input rx,                   // UART receive pin
    output [7:0] data_byte1,    // Array to store 3 bytes of data
    output [7:0] data_byte2, 
    output [7:0] data_byte3, 
    output reg data_valid       // Flag to indicate valid data reception 
);
```



##### [Step 2:](#Chapter4_5_1_2) Importing the NeoPixel Library Code into your project

You’ll also need the NeoPixel Controller module code since our project will need to send the color data to the NeoPixels. You can find more information in:

HDL Code Tutorial #3: [Reading Third-Party Component Data-sheets & Driving Two NeoPixel LEDs ](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/tree/main/Tutorial_Files/Tutorial_3/LatticeMacroKey-Tutorial-03.md)

> **NeoPixels Controller Module File (\*.v):** Here is the NeoPixels Controller source code from our [repository: ws2812b_controller.v](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_3/Files/Tutorial03-02-ws2812b_controller.v) for your convenience.




##### [Step 3:](#Chapter4_5_1_3) Creating the USB controlled RGB Light Source Code

Populate the code editor with the following Top-Level file implementation and hit **save**. This code will instantiate both the CH9329 HID Receiver module and the NeoPixel Library Code, which together will decode the UART signals, decipher the RGB color intensity, and configure the NeoPixels accordingly.

###### Verilog Top-level file (\*.v):
```verilog
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
	wire data_valid;
	reg data_valid_prev;
  
  	// Neopixel
	reg neo_refresh;
    reg [23:0] test_color;	/// = 24'b000000000001111100000000;
    //reg [23:0] test_color2;

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
        .rgb_data_0	    (test_color),		// RGB color data for LED 0 (8 bits for R, G, B)
        .rgb_data_1	    (test_color),		// RGB color data for LED 1
        .start_n		(neo_refresh),	    // Start signal to send data
        .data_out		(neopixel)			// WS2812B data line        
    );

    // NeoPixel Control
    always @(posedge clk) begin	
    	if (!swU) begin		// Reset aka Button_U pressed
			data_valid_prev <= 0;
        end else begin
			data_valid_prev <= data_valid;
            neo_refresh <= !(data_valid && !data_valid_prev);
    		test_color <= {r_color[7:0], g_color[7:0], b_color[7:0]};
		end
    end
    
  	// UART Receiver	
    ch9329_HID_receiver #(SYS_FREQ) ch9329_HID_receiver_u (
        .clk		(clk	),      // System clock
        .rst_n	    (swU	),      // Active low reset
        .rx			(rx		),      // UART receive pin
        .data_byte1	(r_color	),	// Array to store 3 bytes of data
        .data_byte2	(g_color	), 
        .data_byte3	(b_color	), 
        .data_valid	(data_valid )	// Flag to indicate valid data reception 
    );

endmodule
```



##### [Step 4:](#Chapter4_5_1_4) Executing the Python Script/Program

You’ll need Python3 and its libraries for this step.

###### CH9329 HID Sender (\*.py):
Download the CH9329 HID Sender source code from our [repository: CH9329_HIDSender.py](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Essential_Files/Python_HID/CH9329_HIDSender.py) and execute it.



##### [Step 5:](#Chapter4_5_1_5) Observing the result on the Macro-KeyPad

After programming the generated JEDEC file into the FPGA, the HDL configuration will take effect. Ensure the micro-USB is connected to your computer. 

Using our **CH9329_HIDSender** Python script to the Macro-KeyPad. send the following string of bytes **0x07 0xDE 0xAD 0xBE 0xEF 0x1F 0x00 0x0F** which consists of (1) **N** Data payload Byte length, (2) the **"4-Magic Header Signature"** and lastly (3) the **three-bytes** color data information needed for the NeoPixel LEDs. Observe the color change on the NeoPixels whenever a new HID message is send to the Macro-KeyPad in accoring to the **three-bytes** data payload we sent.

![CH9329 HID Sender](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_4_&_5/Images/Tutorial04-03-CH9329_HIDSender_Py.png?raw=true)

### [4.5.2](#Chapter4_5_2) Additional Challenge
###### Converting Python script to executable (\*.exe):

Use [PyInstaller](https://pypi.org/project/pyinstaller/) to convert the Python script into an executable file if needed.



[Lattice]:(https://www.latticesemi.com)
