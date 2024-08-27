### [4.3.1](#Chapter4_3_1) HDL Code Tutorial #3: Reading Third-Party Component Data-sheets & Driving two Neopixel LEDs [WS2812b]

Coming from an embedded design background focused on low-cost & low-power microcontrollers, one of the thing I recognized that FPGA can do way better than your typical run-of-the-mill microcontroller is "Paralism" - runnning lots of state-machine in parallel. Having more than one state machine in your typical embedded software running on a single-core microcontroller could quickly brought it to its knees, RTOS would sometimes alleviate such problem giving us the illusion of having psudo-parallism, but who are we kidding here, we can't push the poor microcontroller to use the only core it has to perform multiple task at the same time! (jokes aside, timing would be off if you push RTOS into driving a timing critical signaling, as explained below - the protocol)

In this tutorial, we'll work with a type of individually-addressable RGB LED known as **NeoPixels (WS2812b)**, which are popular in the maker community. These LEDs have a small amount of built-in intelligence (Tiny Brain 🧠), allowing them to be daisy-chained running off a single data line while displaying a wide range of colors 🌈. The NeoPixel's asynchronous data input requires a timing-based protocol that is, in my opinion, both efficient and robust, especially considering it's all driven by a single GPIO pin.

One can read more about the data protocol from the [WS2812b official data-sheet](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Relevant_Docs_DataSheets/WorldSemi-WS2812B.pdf)

#### Here is the gist of the protocol specification:

Each **WS2812b** LED (which incorporates a WS2811 chip within each LED), requires 24-bits of color data per pixel along the chain: _8-bits_ for the **Green** component , _8-bits_ for **Red** component, and lastly _8-bits_ for **Blue** component. These bits are transmitted as pulses coded at approximately _1.25 µS_ long, alternating between **High** and **Low** signal-levels. A bit is interpreted as a **Zero(0)** if the signal is high for around _350 nS_ and low for about _900 nS_. Conversely, it is a **One(1)** if the signal is high for about _900 nS_ and low for around _350 nS_.

Once an LED receives the full _24-bits_ of color data through its Data Input pin (DIN), it shifts any subsequent bits to its Data Output pin (DOUT), functioning like a [serial shift register](https://en.wikipedia.org/wiki/Shift_register#Serial-in_serial-out_(SISO)). This mechanism allows the transmission of color data along a chain of LEDs, with the last color sent being displayed on the first LED.

After transmitting the desired color data to the entire LED chain, a "latch" signal is required to make each LED display the color currently held in its shift register. This latch signal is sent by holding the data line low for at least 80 µS.

##### Schematic of the Neopixel and its signal level shifting circuit 

![Speaker_Driver](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_3/Images/Tutorial03-01-Neopixel.png?raw=true)



##### [Step 1:](#Chapter4_3_1_1) Importing the NeoPixel Library Code into your project

As we approach components which requires communication beyond the basic On/Off or PWM signal, it is recommended to split the source code into multiple files within the project, effectively abstracting the component specific code away from the main Top-Level HDL file. That is precisely what we would be doing with our NeoPixels components.

Grab the NeoPixels source code from our repository.



##### [Step 2:](#Chapter4_3_1_2) Creating the NeoPixel Driving Source Code

Populate the code editor with the following Top-Level file implementation & hit **save**.

#### Verilog Top-level file (\*.v):
```verilog
`timescale 1ns / 1ps
 
module SIREN (swA,spk);
	input wire swA;	
	output reg spk;
   
	// Siren
	reg [22:0] tone;
	reg [13:0] counter;
	wire [6:0] ramp = (tone[22] ? tone[21:15] : ~tone[21:15]);
	wire [13:0] clkdivider = {2'b01, ramp, 5'b00000};
   
  // Internal OSC setting (12.09 MHz)
  OSCH #( .NOM_FREQ("12.09")) IOSC
      (
        .STDBY(1'b0),
        .OSC(clk),
        .SEDSTDBY()
  );
   
	// Siren Control
	always @(posedge clk) begin
		
		tone <= tone+1;

		if(counter==0) counter <= clkdivider; else counter <= counter-1;
		
		if (swA==1) begin
			spk <= 0;
		end
		else if (counter==0) begin
			spk <= ~spk;
		end 
		
	end
 
endmodule
```

In order to generate the desired ramp output (SawTooth), we take 8 most significant bits (22:15) from a counter register and use the top-most significant bit (22) to determine whether the next 7 bits (21:15) to be either counting up or down; This will give us an effective output value of a ramp as 0 →127 → 0.

Next, we feed the ramp register as the input into a clock divider, forming a clock divider effective output of 4096 →8160 → 4096. By doing simple maths with an input clock frequency of 12.09 MHz, we will achieve a frequency output of 741Hz → 1476Hz → 741Hz.

Lastly, we gatekeep the counter output to the Speaker via the **CherryMX Switch A**; if the switch is in the released state, the output to the Speaker remains LOW (0) effectively turning the Speaker output Off.



##### [Step 3:](#Chapter4_3_1_3) Observing the result on the Macro-KeyPad
After the generated JEDEC has been programmed into the FPGA, the HDL configuration will take into effect. Pressing the **CherryMX Switch A** with activate the Siren.

> Please rememberl that the **CherryMX Switch A** will be the top-right switch as you flip the Macro-KeyPad board around!

![user LED & Button Location](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_2/Images/Tutorial02-03-CherryMX_Speaker_Location.png?raw=true)

### [4.3.2](#Chapter4_3_2) Additional Challenge
* ...



[Lattice]:(https://www.latticesemi.com)