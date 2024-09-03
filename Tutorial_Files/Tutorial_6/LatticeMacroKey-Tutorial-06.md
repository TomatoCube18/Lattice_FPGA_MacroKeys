### [4.6.1](#Chapter4_6_1) HDL Code Tutorial #6: Reading & Writing of I2C EEPROM Memory [i2C EEPROM]

In the world of digital design, the ability to use of I2C communication (protocol) with FPGA opens up a realm of possibilities, particularly in the context of sensors & non-volatile memory like EEPROM. I2C (Inter-Integrated Circuit) is a versatile protocol that allows multiple devices to communicate over just two wires, making it ideal for interfacing with peripheral devices when you need to hook up a variety of them when PCB board size is a limited & available IO pins from the main controller is a premium (Which is definitely not the case for us). 

In this tutorial, we’ll explore how to leverage I2C with our FPGA to perform both read and write operations on an I2C EEPROM. The ability to store and retrieve data is crucial in many applications, from configuration settings to user data, making EEPROM a valuable addition to your FPGA project.

The hardware setup for this tutorial more or less remains the same as the previous tutorial. All the I2C EEPROM memory we will be using is found on board our Macro-KeyPad. We will again be using a Python software running on your computer to send custom package of bytes through USB to the **CH9329** IC & the data will be encapsulated within the **CH9329** Data Frame format and passed to our FPGA via UART (RX). No Surprises there 🫨.

```mermaid
flowchart LR
		A["Computer\n(Python Script)"] <--"USB"--> B
    subgraph "Macro-KeyPad"
        C["MachXO2"] --- E["NeoPixels\n(ws2812b)"]
        C["MachXO2"] --- I["CherryMX\nSwitches"]
        B["CH9329"] <--"UART"--> C["MachXO2"] --- D["I2C"]
        D["I2C"] --- F["EEPROM\n(AT24C04)"]
        D["I2C"] --- G["Temperature\nSensor\n(TMP100)"]
        D["I2C"] --- H["QWIIC\n(Expansion)"]
    end
    
      
````

‼️ I’ll assume your development board is still using the default configuration, "Protocol Transmission Mode." Custom USB HID message passing is only possible in this mode.



##### Schematic of the I2C Devices  & Peripherals including its connection to the FPGA via the I2C pins 

![I2C Devices](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_6/Images/Tutorial06-01-I2C.png?raw=true)



##### [Step 1:](#Chapter4_5_1_1) Importing the HID Receiving Module Code into your project

To get started, we need to import the I2C Memory Controller module, which will handle the low-level communication between the FPGA and the EEPROM. This module abstracts the complexities of I2C signaling, allowing us to focus on higher-level operations.

###### I2C Memory Controller Module File (*.v):

Download the I2C Memory Controller source code from our [repository: i2c_controller.v](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_6/Files/Tutorial06-01-i2c_controller.v) and add it to your project folder alongside your Top-Level Verilog file.

This module takes care of generating the I2C clock, managing data transfers, and handling start/stop conditions—all essential components of I2C communication, on top of that, the module will also be responsible for sending the correct sequence of I2C commands to access the EEPROM's memory, abstracting away the intricacies of the I2C protocol. With that said, It is not going to be a universal I2C Master controller like the others in the market as this code is designed with the purpose of keeping it consise & specific to our EEPROM in order to keep it simple for our digital design tutorial. 

```verilog
module i2c_eeprom (
    input wire clk,            	// System clock
    input wire rst_n,          	// Active low reset
    input wire start,          	// Start signal
    input wire rw,             	// Read/Write signal (1 = Read, 0 = Write)
    input wire [7:0] address,  	// EEPROM memory address
    input wire [7:0] data_in,  	// Data to write
    output wire [7:0] data_out, // Data read from EEPROM
    output reg done,           	// Operation complete signal
    inout wire sda,            	// I2C data line (bidirectional)
    output wire scl             // I2C clock line
);

parameter SYS_FREQ = 12_090_000;    // System clock frequency (12.09 MHz)
parameter I2C_FREQ = 100_000      	// I2C clock frequency (in Hz)
```

Now that we have our I2C Master controller  and EEPROM Interface modules, we can write the Top-Level HDL code that ties everything together. This code will instantiate the necessary modules and orchestrate the reading and writing of data to the EEPROM.

> **I2C 24C0X EEPROM:** Here is the I2C EEPROM Datasheet from our [repository: Microchip_Atmel-doc0180-AT24C04_Datasheet.pdf](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Relevant_Docs_DataSheets/Microchip_Atmel-doc0180-AT24C04_Datasheet.pdf) for your convenience.



##### [Step 2:](#Chapter4_6_1_2) Importing the NeoPixel Library Code into your project

You’ll also need the NeoPixel Controller module code since our project will need to send the color data to the NeoPixels. You can find more information in:

HDL Code Tutorial #3: [Reading Third-Party Component Data-sheets & Driving Two NeoPixel LEDs ](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/tree/main/Tutorial_Files/Tutorial_3/LatticeMacroKey-Tutorial-03.md)

> **NeoPixels Controller Module File (\*.v):** Here is the NeoPixels Controller source code from our [repository: ws2812b_controller.v](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_3/Files/Tutorial03-02-ws2812b_controller.v) for your convenience.



##### [Step 3:](#Chapter4_6_1_3) Importing the CH9329 HID Receiver Module Library Code into your project

On top of the NeoPixel Library code, you’ll also need the CH9329 HID Receiver Module code & the HID Sender Python script since our project will need to receive data payload from the Computer via the Python Script. You can find more information in:

HDL Code Tutorial #5: [USB Custom HID upstream transfer using Python ](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/tree/main/Tutorial_Files/Tutorial_4_&_5/LatticeMacroKey-Tutorial-05.md)

> **NeoPixels Controller Module File (\*.v):** Here is the NeoPixels Controller source code from our [repository: ws2812b_controller.v](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_3/Files/Tutorial03-02-ws2812b_controller.v) for your convenience.

And here is the Python script that goes along with it.

> **CH9329 HID Sender (\*.py):** Here is the CH9329 HID Sender source code from our [repository: CH9329_HIDSender.py](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Essential_Files/Python_HID/CH9329_HIDSender.py) for your convenience.



##### [Step 4:](#Chapter4_5_1_4) Creating the ???

???.

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





##### [Step 5:](#Chapter4_6_1_5) Testing the Design & observing the result on the Macro-KeyPad

After programming the generated JEDEC file into the FPGA, the HDL configuration will take effect. Ensure the micro-USB is connected to your computer. 

We will not proceed toverify that the EEPROM is correctly storing and retrieving data as expected. This step is crucial to ensure that your I2C communication is functioning correctly.

By the end of this tutorial, you'll have a functional FPGA design capable of reading from and writing to an I2C EEPROM, providing your project with the ability to retain data even when powered off (Hint: KeyPad Macro Settings & User Configuration). This is a powerful capability that enhances the versatility and functionality of your FPGA-based systems.

![CH9329 HID Sender](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_4_&_5/Images/Tutorial04-03-CH9329_HIDSender_Py.png?raw=true)

### [4.6.2](#Chapter4_6_2) Additional Challenge
...



[Lattice]:(https://www.latticesemi.com)
