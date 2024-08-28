### [4.3.1](#Chapter4_3_1) HDL Code Tutorial #3: Reading Third-Party Component Data-sheets & Driving two Neopixel LEDs [WS2812b]

Coming from an embedded design background focused on low-cost & low-power microcontrollers, one of the thing I recognized that FPGA can do way better than your typical run-of-the-mill microcontroller is "Paralism" - runnning lots of state-machine in parallel. Having more than one state machine in your typical embedded software running on a single-core microcontroller could quickly brought it to its knees, RTOS would sometimes alleviate such problem giving us the illusion of having psudo-parallism, but who are we kidding here, we can't push the poor microcontroller to use the only core it has to perform multiple task at the same time! (jokes aside, timing would be off if you push RTOS into driving a timing critical signaling, as explained below - the protocol)

In this tutorial, we'll work with a type of individually-addressable RGB LED known as **NeoPixels (WS2812b)**, which are popular in the maker community. These LEDs have a small amount of built-in intelligence (Tiny Brain 🧠), allowing them to be daisy-chained running off a single data line while displaying a wide range of colors 🌈. The NeoPixel's asynchronous data input requires a timing-based protocol that is, in my opinion, both efficient and robust, especially considering it's all driven by a single GPIO pin.

One can read more about the data protocol from the [WS2812b official data-sheet](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Relevant_Docs_DataSheets/WorldSemi-WS2812B.pdf)

#### Here is the gist of the protocol specification:

Each **WS2812b** LED (which incorporates a WS2811 chip within each LED), requires 24-bits of color data per pixel along the chain: _8-bits_ for the **Green** component , _8-bits_ for **Red** component, and lastly _8-bits_ for **Blue** component. These bits are transmitted as pulses coded at approximately _1.25 µS_ long, alternating between **High** and **Low** signal-levels. A bit is interpreted as a **Zero(0)** if the signal is high for around _400 nS_ and low for about _850 nS_. Conversely, it is a **One(1)** if the signal is high for about _800 nS_ and low for around _450 nS_.

Once an LED receives the full _24-bits_ of color data through its Data Input pin (DIN), it shifts any subsequent bits to its Data Output pin (DOUT), functioning like a [serial shift register](https://en.wikipedia.org/wiki/Shift_register#Serial-in_serial-out_(SISO)). This mechanism allows the transmission of color data along a chain of LEDs, with the last color sent being displayed on the first LED.

After transmitting the desired color data to the entire LED chain, a "latch" signal is required to make each LED display the color currently held in its shift register. This latch signal is sent by holding the data line low for at least 50 µS.

##### Schematic of the Neopixel and its signal level shifting circuit 

![Speaker_Driver](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_3/Images/Tutorial03-01-Neopixel.png?raw=true)



##### [Step 1:](#Chapter4_3_1_1) Importing the NeoPixel Library Code into your project

As we approach components which requires communication beyond the basic On/Off or PWM signal, it is recommended to split the source code into multiple files within the project, effectively abstracting the component specific code away from the main Top-Level HDL file. That is precisely what we would be doing with our NeoPixels components.

Grab the NeoPixels Controller source code from our [repository: ws2812b_controller.v](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_3/Files/Tutorial03-02-ws2812b_controller.v), place it into your Diamond project folder together with your Top-Level verilog file.

To use the NeoPixels Controller code, you only need to know the Ports of our controller module & its respective functions. The names of the ports are chosen to be self-explanatory,  furthermore the source code is also heavily commented making it rather easy to follow.

```verilog
module ws2812b_controller (
    input clk,                      // System clock
    input rst_n,                    // Active low reset
    input [23:0] rgb_data_0,      	// RGB color data for LED 0 (8 bits for each of R, G, B)
    input [23:0] rgb_data_1,      	// RGB color data for LED 1
  	input start_n,                	// Start signal to send data
    output reg data_out             // WS2812B data line
);

parameter SYS_FREQ = 12_090_000; 
```

inspective the controller reveals that, the whole operation is rather trivial & it consists nothing more than a 5 States state-machine.

* **IDLE** : Initial State of the controller. When **start_n** is triggered, load the 1st set of RGB data into the Shift-register & move to **LOAD**

* **LOAD**: Load 1st bit of the Shift-register into the output Pin.

* **SEND**: Traverse through the shift-register & sending Pulse in accordance to WS2812b signalling requirments.

* **NEXT_LED**: Load in the 2nd set of RGB data & return to **LOAD**, else go to **IDLE**

* **RESET**



##### [Step 2:](#Chapter4_3_1_2) Creating the NeoPixel Driving Source Code

Populate the code editor with the following Top-Level file implementation & hit **save**. The code will instantiate the NeoPixels controller module & in trurn send out data signal to drive our 2 NeoPixels on the Development board.

#### Verilog Top-level file (\*.v):
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

### [4.3.2](#Chapter4_3_2) Additional Challenge
* ...



[Lattice]:(https://www.latticesemi.com)