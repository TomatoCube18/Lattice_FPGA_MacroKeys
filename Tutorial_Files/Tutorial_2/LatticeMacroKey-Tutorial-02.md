### [4.2.1](#Chapter4_2_1) HDL Code Tutorial #2: Making a audible Warbling Siren [CherryMX Switch, Buzzer]

In this tutorial, we will try to play sound using our FPGA. We will mimic the Warbling Siren of a Police patrol car. We can toggle a pin (Square wave) rapidly at a constant rate to create a desired frequency, which is the fundamental basis when it comes to sound generation. But we are not going to do something basic 🤩; we will spice things up a bit by generating a ramp output frequency (Variable SawTooth frequency) from our internal oscilator by using HDL code logic.

We will also use a CherryMX switch as the activation mechanism. We will use **CherryMX Switch A**

Below are the schematics for the on-board Speaker & CherryMX Switch, which we will be using in our HDL code. CherryMX schematic configuration looks similar to the user Switch; thus, it is asserted-low with a hardware capacitor base debouncing circuitry. As for the speaker, it is driven through a simple NPN transistor-based circuitry to prevent overloading the FPGA; we have also added a fly-back diode in parallel to the speaker to avoid killing our NPN transistor pre-maturely.

##### Schematic of the Speaker and its driver circuit 

![Speaker_Driver](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_2/Images/Tutorial02-01-Speaker.png?raw=true)

##### Schematic of the CherryMX Switches

![CherryMX_Switch](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_2/Images/Tutorial02-02-CherryMX.png?raw=true)



##### [Step 1:](#Chapter4_2_1_1) Creating the Siren Source Code

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



##### [Step 2:](#Chapter4_2_1_2) Observing the result on the Macro-KeyPad
After the generated JEDEC has been programmed into the FPGA, the HDL configuration will take into effect. Pressing the **CherryMX Switch A** with activate the Siren.

> Please rememberl that the **CherryMX Switch A** will be the top-right switch as you flip the Macro-KeyPad board around!

![user LED & Button Location](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_2/Images/Tutorial02-03-CherryMX_Speaker_Location.png?raw=true)

### [4.2.2](#Chapter4_2_2) Additional Challenge
* ...



[Lattice]:(https://www.latticesemi.com)