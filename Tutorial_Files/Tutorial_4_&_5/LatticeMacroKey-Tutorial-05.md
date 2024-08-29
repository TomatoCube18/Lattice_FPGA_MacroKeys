### [4.5.1](#Chapter4_4_1) HDL Code Tutorial #5: USB Custom HID upstream transfer using Python Code [UART RX from USB HID IC CH9329]

In the previous tutorial, we use the USB HID IC **CH9329** in the obvious purpose - as a USB keyboard or mouse. Little did we know, after reading through the [CH9329 official data-sheet](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Relevant_Docs_DataSheets/WCH-Ch9329_Datasheet.pdf) and the [CH9239 comunication protocol specification](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Relevant_Docs_DataSheets/WCH-CH9329芯片串口通信协议-CommunicationProtocol.PDF) (available only in Chinese), the **CH9329** IC has a secret skills up its sleeve. It is capable of receiving bytes of data from the computer (Upstream transfer). And before you ask, the answer is **"YES"**, you will need a custom apps running on your computer capable of connecting to a custom USB HID device & pushing custom bytes of data towards the USB device.

A couple of modern programming language comes to mind when deciding on which path to take to write the USB HID sender, each with the pros & cons. I finally settled on using Python, mainly due to the popularity among students, its vibrant and up-to-date library support & needless to say the ability to run across multiple platforms. 

The hardware configuration for this tutorial remains the same. The Python software running on the computer will send custom  package of bytes through the USB to the **CH9329** IC, the data will be encapsulated within **CH9329** Data Frame format to pass on towards our FPGA via the UART (RX). Finally after decoding (Stripping away of the header signature), the message will reveal 3 bytes which would be used to control the intensity of the Red, Green & Blue components to drive the NeoPixel LEDs.

```mermaid
flowchart LR
    A["Computer\n(Python Script)"] <--"USB"--> B
    subgraph "Macro-KeyPad"
        B["CH9329"] <--"UART"--> C["MachXO2"] --- D["NeoPixels\n(ws2812b)"]
    end
    
      
````

I will assume, your development board is still staying on the default configuration, "Protocol Transmission Mode". Custom USB HID message passing is only possible using the "Protocol Transmission Mode". 



#### To simplify matters, here is the UART communication transaction for HID reception:

##### Sequence for Reading HID Data:

| Frame Header | Address | Command ID | Data Length | Data Payload | Checksum |
|:------------:|:-------:|:------------:|:-----------:|:------------:|:-----------:|
| 0x57 0xAB | 0x00  | 0x87 | N (Max 64) | N Bytes | 0x?? |

##### Data Payload (Self Defined - Percy's RGB LED Magic Header Signature)

CH9329 doesn't care what the Data Payload holds, it just deligently add in the Prefixes and N-lenght Bytes payload with a calculated CheckSum and happily send it off through the UART. The following is just a special Magic header Signature we designed to help with filtering & locating the 3 bytes we need for the NeoPixel LEDs.

* Byte 1: 0xDE
* Byte 2: 0xAD
* Byte 3: 0xBE
* Byte 4: 0xEF
* Byte 5: **0xRR**
* Byte 6: **0xGG**
* Byte 7: **0xBB**
###### Example

* Sending a Red of 0x1F intensity + Blue of 0x0F intensity through the USB HID channel

  _(Computer→CH9329)_ 0x07 0xDE 0xAD 0xBE 0xEF **0x1F 0x00 0x0F**  

  _(CH9329→FPGA)_ 0x57 0xAB 0x00 0x87 0x07 0xDE 0xAD 0xBE 0xEF **0x1F 0x00 0x0F** 0xF6

  _(FPGA→ws2812b)_ **0x1F (Red), 0x00 (Green), 0x0F(Blue)**
  


##### Schematic of the CH9329 USB interface and its connection to the FPGA via the UART pins 

![Speaker_Driver](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_4_&_5/Images/Tutorial04-01-USB_HID_CH9329.png?raw=true)



##### [Step 1:](#Chapter4_5_1_1) Importing the HID Receiving Module Code into your project

To keep things simple, my code will ignore CH9329's Frame header and continuously wait for the 4 Magic Bytes 𐂌🥩 (0xDE, 0xAD, 0xBE, 0xEF) to arrive through the UART to signal our FPGA to expect the subsequence 3 bytes as the color components for the NeoPixels.

###### CH9329 KeyStroke sender module file (\*.v):
Download the CH9329 HID receiver source code from our [repository: ch9329_HID_receiver.v](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_4_%26_5/Files/Tutorial04-04-ch9329_HID_receiver.v) and place it into your Diamond project folder alongside your Top-Level Verilog file _(Which might not yet exist, if you are starting a brand new project )_.

To use the HID receiver code, you only need to understand the Ports of our HID receiver module & their respective functions. The port names are self-explanatory, and the source code is thoroughly commented, making it easy to follow.

```verilog
module ch9329_HID_receiver (
    input clk,                  // System clock
    input rst_n,                // Active low reset
    input rx,                   // UART receive pin
    output [7:0] data_byte1,    // Array to store 3 bytes of data
    output [7:0] data_byte2, 
    output [7:0] data_byte3, 
    output reg data_valid       // Flag to indicate valid data reception 
);

parameter SYS_FREQ = 12_090_000;    // System clock frequency (12.09 MHz)
parameter BAUD_RATE = 9600;         // Baud rate for UART
```



##### [Step 2:](#Chapter4_5_1_2) Importing the NeoPixel Library Code into your project

We also need the Neopixel Controller module code as our project will need to send the color data to our NeoPixels. You can read more about it in:
HDL Code Tutorial #3: [Reading Third-Party Component Data-sheets & Driving two Neopixel LEDs [WS2812b]](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/tree/main/Tutorial_Files/Tutorial_3/LatticeMacroKey-Tutorial-03.md)

>**NeoPixels Controller module file (\*.v):**
Here is the NeoPixels Controller source code from our [repository: ws2812b_controller.v](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_3/Files/Tutorial03-02-ws2812b_controller.v) for your convenience.




##### [Step 3:](#Chapter4_5_1_3) Creating the USB controlled RGB Light Source Code

Populate the code editor with the following Top-Level file implementation & hit **save**. This code will instantiate both the CH9329 HID Receiver module and NeoPixel Library Code which together will decode the UART signals, decipher the RGB color intesity & configure the Neopixels accordingly.

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
  
  	// Neopixel
    reg [11:0]neo_count;
    wire neo_refresh = neo_count[11];
    reg [23:0] test_color;	/// = 24'b000000000001111100000000;
    reg [23:0] test_color2;

    // Internal OSC setting (12.09 MHz)
    OSCH #( .NOM_FREQ("12.09")) IOSC (
        .STDBY		(1'b0	),
        .OSC		(clk	),
        .SEDSTDBY	(	)
    );

  	// Instatiate NeoPixel Controller
    ws2812b_controller #(SYS_FREQ) ws2812b_controller_u (
        .clk     		(clk    ), 
        .rst_n   		(swU    ),
        .rgb_data_0	(test_color),		// RGB color data for LED 0 (8 bits for each of R, G, B)
        .rgb_data_1	(test_color),		// RGB color data for LED 1
        .start_n		(neo_refresh),	// Start signal to send data
				.data_out		(neopixel)			// WS2812B data line        
    );

    // NeoPixel Control
    always @(posedge clk) begin			// Stupid Code just to refresh the color!!
    		neo_count <= neo_count + 1;	// Proper way would be do detect State Trasition
    		test_color <= {r_color[7:0], g_color[7:0], b_color[7:0]};
    end
    
  	// UART Receiver	
		ch9329_HID_receiver #(SYS_FREQ) ch9329_HID_receiver_u (
        .clk		(clk	),					// System clock
        .rst_n	(swU	),					// Active low reset
        .rx			(rx		),					// UART receive pin
        .data_byte1	(r_color	),	// Array to store 3 bytes of data
        .data_byte2	(g_color	), 
        .data_byte3	(b_color	), 
        .data_valid	(					)		// Flag to indicate valid data reception 
		);

endmodule
```



##### [Step 4:](#Chapter4_5_1_4) Executing the Python Script/Program

Python3 & its library will be needed for this step.

###### CH9329 HID Sender (\*.py):
Download the CH9329 HID Sender source code from our [repository: CH9329_HIDSender.py](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Essential_Files/Python_HID/CH9329_HIDSender.py) and execute it.

###### Converting Python script to executable (\*.exe):

[PyInstaller](https://pypi.org/project/pyinstaller/)

##### [Step 5:](#Chapter4_5_1_5) Observing the result on the Macro-KeyPad

After programming the generated JEDEC file into the FPGA, the HDL configuration will take effect. Ensure the micro-USB is connected to your computer. Send the following string of text **0x07 0xDE 0xAD 0xBE 0xEF 0x1F 0x00 0x0F** after connecting to the Macro-KeyPad & observe the color change on the NeoPixels. 

![CH9329 HID Sender](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_4_&_5/Images/Tutorial04-03-CH9329_HIDSender_Py.png?raw=true)

### [4.5.2](#Chapter4_5_2) Additional Challenge
....



[Lattice]:(https://www.latticesemi.com)
