### [4.3.1](#Chapter4_3_1) HDL Code Tutorial #3: Reading Third-Party Component Data-sheets & Driving two Neopixel LEDs [WS2812b]

Coming from an embedded design background focused on low-cost & low-power microcontrollers, one of the thing I recognized that FPGA can do way better than your typical run-of-the-mill microcontroller is "Paralism" - runnning lots of state-machine in parallel. Having more than one state machine in your typical embedded software running on a single-core microcontroller could quickly brought it to its knees, RTOS would sometimes alleviate such problem giving us the illusion of having psudo-parallism, but who are we kidding here, we can't push the poor microcontroller to use the only core it has to perform multiple task at the same time! (jokes aside, timing would be off if you push RTOS into driving a timing critical signaling, as explained below - the protocol)

In this tutorial, we'll work with a type of individually-addressable RGB LED known as **NeoPixels (WS2812b)**, which are popular in the maker community. These LEDs have a small amount of built-in intelligence (Tiny Brain 🧠), allowing them to be daisy-chained running off a single data line while displaying a wide range of colors 🌈. The NeoPixel's asynchronous data input requires a timing-based protocol that is, in my opinion, both efficient and robust, especially considering it's all driven by a single GPIO pin.

One can read more about the data protocol from the [WS2812b official data-sheet](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Relevant_Docs_DataSheets/WorldSemi-WS2812B-Mini.pdf)

#### Here is the gist of the protocol specification:

Each **WS2812b** LED (which incorporates a WS2811 chip within each LED), requires 24-bits of color data per pixel along the chain: _8-bits_ for the **Green** component , _8-bits_ for **Red** component, and lastly _8-bits_ for **Blue** component. These bits are transmitted as pulses coded at approximately _1.25 µS_ long, alternating between **High** and **Low** signal-levels. A bit is interpreted as a **Zero(0)** if the signal is high for around _400 nS_ and low for about _850 nS_. Conversely, it is a **One(1)** if the signal is high for about _800 nS_ and low for around _450 nS_.

Once an LED receives the full _24-bits_ of color data through its Data Input pin (DIN), it shifts any subsequent bits to its Data Output pin (DOUT), functioning like a [serial shift register](https://en.wikipedia.org/wiki/Shift_register#Serial-in_serial-out_(SISO)). This mechanism allows the transmission of color data along a chain of LEDs, with the last color sent being displayed on the first LED.

After transmitting the desired color data to the entire LED chain, a "latch" signal is required to make each LED display the color currently held in its shift register. This latch signal is sent by holding the data line low for at least 50 µS.

##### Schematic of the Neopixel and its signal level shifting circuit 

![Speaker_Driver](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_3/Images/Tutorial03-01-Neopixel.png?raw=true)



##### [Step 1:](#Chapter4_3_1_1) Importing the NeoPixel Library Code into your project

As we approach components that require communication beyond the basic On/Off or PWM signal, it's advisable to organize your source code by splitting it into multiple files within the project. This approach helps abstract the component-specific code from the main Top-Level HDL file, making the design more modular and easier to manage. This is precisely the approach we'll take with our NeoPixels component.

###### NeoPixels Controller module file (\*.v):
Download the NeoPixels Controller source code from our [repository: ws2812b_controller.v](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_3/Files/Tutorial03-02-ws2812b_controller.v) and place it into your Diamond project folder alongside your Top-Level Verilog file _(Which might not yet exist, if you are starting a brand new project )_.

To use the NeoPixels Controller code, you only need to understand the Ports of our controller module & their respective functions. The port names are intentionally descriptive, and the source code is heavily commented, making it easy to follow.

```verilog
module ws2812b_controller #(
    parameter SYS_FREQ = 12_090_000    	// System clock frequency (in Hz - Def:12.09 MHz)
)(
    input clk,			// System clock
    input rst_n,		// Active low reset
    input [23:0] rgb_data_0,	// RGB color data for LED 0 (8 bits for each of R, G, B)
    input [23:0] rgb_data_1,	// RGB color data for LED 1
    input start_n,		// Start signal to send data
    output reg data_out		// WS2812B data line
);
```

**State Machine:**

inspective the controller reveals a straightforward operation consisting of a 5-state state machine.


````mermaid
stateDiagram-v2
    RESET --> IDLE
    IDLE --> START: start_n==0
    START --> LOAD
    LOAD --> SEND
    SEND --> NEXT_LED: shift-reg content \nexhausted
    state LED_INDEX <<choice>>
    NEXT_LED --> LED_INDEX
    LED_INDEX --> IDLE: led_index > 0
    LED_INDEX --> LOAD: led_index==0
    %%direction LR
   

    state IDLE {
    		state "Waiting for start signal (start_n)" as IDLE_STATE   
    }
    
    state START {
    		state "led_index=0" as RESETLEDCNT_STATE 
    		state "reset shift-reg counter" as RESETSR_STATE
    		RESETLEDCNT_STATE --> RESETSR_STATE
    }
    
    state LOAD {
    		state "Check led_index & Push rgb_data_0 \nor rgb_data_1 into shift-reg" as LOAD_STATE   
    }
    
    state SEND {
    		state "Generate pulses & Pop shift-reg content \naccording to WS2812b timing requirements" as SEND_STATE   
        state "Check if we have send all content of ShiftRegister" as CHECKSR_STATE
        SEND_STATE --> CHECKSR_STATE
        CHECKSR_STATE --> SEND_STATE
        
    }
    
    
    

````

* **IDLE** : Waits for the start signal. Once received, it loads the color data for the first LED (color_data_0).

* **LOAD**: Loads the most significant bit (MSB) of the color data into the data_out line and prepares to send the rest.

* **SEND**: Sends out the color data bit by bit, following the timing protocol for 1 and 0 bits.

* **NEXT_LED**: After finishing the transmission for the first LED, it loads the color data for the second LED (color_data_1) and repeats the process. If both LEDs have been handled, it moves to the RESET state.

* **RESET**: After all data is sent, it holds the data_out line low for at least 50 µs to reset the LEDs.

**Usage:**

- Provide `color_data_0` and `color_data_1` (each a 24-bit RGB value) for the two LEDs.
- Assert the `start` signal, and the module will send the data to the two WS2812B LEDs sequentially.
- The `data_out` line should be connected to the data input of the first LED in the strip.

##### [Step 2:](#Chapter4_3_1_2) Creating the NeoPixel Driving Source Code

Populate the code editor with the following Top-Level file implementation & hit **save**. The code will instantiate the NeoPixels controller module &, in turn, send out data signals needed to drive the two NeoPixels on the development board.

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
  reg [11:0] neo_count;
  reg neo_refresh;
  reg [23:0] test_color;
  reg [23:0] test_color2;
   
  // Internal OSC setting (12.09 MHz)
  OSCH #( .NOM_FREQ("12.09")) IOSC (
        .STDBY		(1'b0	),
        .OSC			(clk	),
        .SEDSTDBY	(			)
  );
  
  // Instatiate NeoPixel Controller
  ws2812b_controller #(SYS_FREQ) ws2812b_controller_u (
        .clk     		(clk    ), 
    		.rst_n   		(swU    ),
        .rgb_data_0	(test_color),			// RGB color data for LED 0 (8 bits for each of R, G, B)
    		.rgb_data_1	(test_color2),		// RGB color data for LED 1
				.start_n		(!neo_refresh	),	// Start signal to send data
				.data_out		(neopixel)				// WS2812B data line        
  );
  
	// NeoPixel Control
  always @(posedge clk or negedge swU) begin	 
		if(swU == 0) begin
			neo_refresh <= 0;
			neo_count <= 0;
		end else begin			
			neo_count <= neo_count + 1;		
			if(neo_count == 0)
				neo_refresh <= 1;
			else
				neo_refresh <= 0;
		end
  end
  
	always @(posedge clk) begin
    if (swD == 0) begin							//Pressing Switch-D will Copy Color from LED 0 -> LED 1
			test_color2 <= test_color;		
		end 
		
		if (swA == 0) begin
			test_color <= 24'h00_00_7F;	//Blue		
		end 
    else if (swB == 0) begin
			test_color <= 24'h00_7F_00;	//Green			
		end 
    else if (swC == 0) begin
			test_color <= 24'h7F_00_00;	//Red 	
		end 
		else if (swE == 0) begin
			test_color <= 24'h7F_00_7F;	//Red + Blue
		end 
    else if (swF == 0) begin
			test_color <= 24'b0;	//Off
		end 

	end
 
endmodule
```

> 💡NeoPixels are capable of shining super bright light, but just like everything in this universe, 'The flame that burns Twice as bright burns half as long.' Try not to use full-intensity on any of the color channel. And if you are diplaying white (or Grey), try to lower the combined intensity.



##### [Step 3:](#Chapter4_3_1_3) Setting Top-Level Unit

As your design grew, it will inherently expand to include several modules within the project folder. While Lattice Diamond will try its best to automatically select the most appropriate(likely) Top-Level Unit/Module, this process can be hit or miss. If you're fortunate, your project will work fine, but occasionally, Lattice Diamond might choose the wrong Verilog file/module as the Top-Level Unit, leading to confusion and many hours of lost troubleshooting time.

To avoid this, it's good practice to manually set the **Top-Level Unit** through the _Project properties_. Open the Project properties dialog window through the `[Menu]Project > Property Pages ` , select your Implementation name _(mine is LED)_ and choose the correct Top-Level Module from the drop-down box next to **Top-Level Unit**. Click **OK** when you're done.

![Choosing Top-level Unit](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_3/Images/Tutorial03-03-Neopixel_TopLevel.png?raw=true)

Proceed to generate your JEDEC file.




##### [Step 4:](#Chapter4_3_1_3) Observing the result on the Macro-KeyPad
After programming the generated JEDEC file into the FPGA, the HDL configuration will take effect. Pressing **CherryMX Switches A-C, E & F** will change the color of NeoPixel #1, while pressing the **CherryMX Switch D** with copy the color of NeoPixel #1 → NeoPixel #2

> Please rememberl that the **CherryMX Switch A** will be the top-right switch as you flip the Macro-KeyPad board around!

###### Component-side View:
![user LED & Button Location](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_3/Images/Tutorial03-02-Neopixel_Location.png?raw=true)

###### CherryMX-side View:
![user LED & Button Location 2](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_3/Images/Tutorial03-02-Neopixel_Location2.png?raw=true)


### [4.3.2](#Chapter4_3_2) Additional Challenge
* ...



[Lattice]:(https://www.latticesemi.com)
