### [4.4.1](#Chapter4_4_1) HDL Code Tutorial #4: Using Standard Serial Protocol to send a KeyStroke [UART TX to USB HID IC CH9329]

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

* Emulating pressing & releasing **"R-Shift"+"A"** Keys:

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



##### [Step 1:](#Chapter4_4_1_1) Importing the KeyStroke Sending Module Code into your project

Given the Chip-specific protocol information we read above, it makes sense to abstract the complexities of formatting the command frame to keep the Top-Level HDL code concise. Creating a dedicated module not only simplifies the code but also reduces redundancy, as each keystroke press will requires sending a similar command frame.
The KeyStroke sender module is designed to handle three primary tasks: (1) managing UART transmission signaling at a baud rate of 9600 bps, (2) constructing the command frames according to the CH9329 communication protocol, and (3) handling automatic key release when necessary.

###### CH9329 KeyStroke sender module file (\*.v):
Download the CH9329 KeyStroke sender source code from our [repository: ch9329_keystroke_sender.v](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_4_%26_5/Files/Tutorial04-02-ch9329_keystroke_sender.v) and place it into your Diamond project folder alongside your Top-Level Verilog file _(Which might not yet exist, if you are starting a brand new project )_.

To use the KeyStroke sender code, you only need to understand the Ports of our KeyStroker sender module & their respective functions. The port names are self-explanatory, and the source code is thoroughly commented, making it easy to follow.

```verilog
module ch9329_keystroke_sender #(
    parameter SYS_FREQ = 12_090_000,    	// System clock frequency (in Hz - Def:12.09 MHz)
    parameter BAUD_RATE = 9600,     		// UART baud rate
    parameter DELAY_CYCLES = SYS_FREQ / 4	// 0.25-second delay between keystroke and release
)(
    input wire clk,             // System clock
    input wire rst_n,           // Active low reset
    input wire start,           // Start signal to send keystroke
    input wire [7:0] modifier,  // Keycode modifier e.g. Shift, Alt...
    input wire [7:0] keycode,   // Keycode to send (HID code)
    input wire autorelease,     // Send a key-release after short delay
    output reg tx,              // UART transmit line
    output reg done             // Transmission complete
);
```

**State Machine:**

An inspection of the KeyStroke sender module reveals a straightforward operation consisting of a 7-state state machine.


```mermaid
stateDiagram-v2
    [*] --> IDLE
    IDLE --> START_BIT: start
    START_BIT --> SEND_BYTE: bit_index < 7
    SEND_BYTE --> START_BIT: byte_index < NUM_BYTES-1
    SEND_BYTE --> STOP_BIT: byte_index == NUM_BYTES-1
    STOP_BIT --> DELAY: Delay required
    DELAY --> RELEASE_KEY: Delay finished
    RELEASE_KEY --> START_BIT: byte_index < NUM_BYTES-1
    RELEASE_KEY --> DONE: byte_index == NUM_BYTES-1
    DONE --> IDLE: Transmission complete
    state IDLE {
        direction LR
        state "Idle, waiting for start signal" as IDLE_STATE
    }
    state START_BIT {
        direction LR
        state "Transmit start bit (0)" as START_BIT_STATE
    }
    state SEND_BYTE {
        direction LR
        state "Send each bit of the current byte" as SEND_BYTE_STATE
    }
    state STOP_BIT {
        direction LR
        state "Transmit stop bit (1)" as STOP_BIT_STATE
    }
    state DELAY {
        direction LR
        state "Wait for a delay period" as DELAY_STATE
    }
    state RELEASE_KEY {
        direction LR
        state "Send key release signal" as RELEASE_KEY_STATE
    }
    state DONE {
        direction LR
        state "Transmission complete" as DONE_STATE
    }

````

* **IDLE:** Waits for the `start` signal.

* **START_BIT:** Sends the start bit.

* **SEND_BYTE:** Sends each bit of the current byte.

* **STOP_BIT:** Sends the stop bit.

* **DELAY:** Adds a delay between sending the keystroke and the release command.

* **RELEASE_KEY:** Sends the key release sequence.

* **DONE:** Transmission is complete.

>**DELAY_CYCLES:**
You can adjust the `DELAY_CYCLES` parameter to control the delay between the key press and key release.


##### [Step 2:](#Chapter4_4_1_2) Creating the Key-Press Demo Source Code

Populate the code editor with the following Top-Level file implementation & hit **save**. This code will instantiate the CH9329 KeyStroke Sender module and send the desired HID KeyCode whenever a CherryMX switch/button is pressed.

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

    // Uart Debugger Output
    wire tx_wire;
    assign tx2 = tx_wire;	// Cloning the UART TX to CH9329 for External Watcher
    assign tx  = tx_wire;	

    // Flip Flop Key
    reg key_out_ff2;

    // Internal OSC setting (12.09 MHz)
    OSCH #( .NOM_FREQ("12.09")) IOSC (
        .STDBY		(1'b0	),
        .OSC		(clk	),
        .SEDSTDBY	(	)
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
        .clk		(clk	),	// System clock
        .rst_n		(swU	),     	// Active low reset
        .start		(uartStart),	// Start signal to send keystroke
        .modifier	(8'h02	),  	// Keycode modifier e.g. Shift, Alt...
        .keycode	(8'h04	),   	// Keycode to send (HID code)
        .autorelease	(1'b01	),	// Send a key-release after short delay
        .tx		(tx_wire),	// UART transmit line
        .done		(	)	// Transmission complete
    );

endmodule
```

The above code performs several functions: first, it detects the falling edge of **CherryMX Switch B**. Once triggered, a clock pulse is sent via `uartStart` to the `ch9329_keystroke_sender` module to begin UART transmission to the CH9329 IC. To keep the demo code simple, I have taken the liberty on a couple of things:

1. Detecting only the falling edge of the CherryMX switch.
2. Sending a fixed **"R-Shift" + "A"** key combination.
3. Utilizing the auto-release feature of the `ch9329_keystroke_sender` module.

> 🚓 Sometimes, it is really useful to be able to observe the UART transaction data when doing embedded development. The additional FPGA pin which is extended over our programming connector is there for that very reason. Using those pins, you can effectively clone & monitor the UART transaction over on your computer using a Serial/UART terminal program.
>
> One such example is a [Freeware CoolTerm](https://freeware.the-meiers.org) which is available for all major operating system. 



##### [Step 3:](#Chapter4_3_1_3) Observing the result on the Macro-KeyPad

After programming the generated JEDEC file into the FPGA, the HDL configuration will take effect. Ensure the micro-USB is connected to your computer. Upon pressing **CherryMX Switch B**, the Macro-KeyPad will send an **uppercase 'A'**to your computer.

> Please note that **CherryMX Switch A** is the top-right switch when you flip the Macro-KeyPad board around, and **CherryMX Switch B** is the middle switch on the top row.
> 

### [4.4.2](#Chapter4_4_2) Additional Challenge
Once you've confirmed that the above code works, please proceed with the following tasks:

1. Detect both rising and falling edges of the CherryMX key press.
2. Modify the code to send a key release only when the switch is released (instead of relying on a timer).
3. Map HID codes to all six CherryMX switches on your development board.
4. *(Optional)* Explore the possibility of sending multimedia/consumer UART command frames to the CH9329 IC.



[Lattice]:(https://www.latticesemi.com)
