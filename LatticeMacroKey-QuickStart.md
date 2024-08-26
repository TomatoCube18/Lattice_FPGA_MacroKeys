# Lattice MachXO2 6-Key Macro-KeyPad Development Board - QuickStart Guide
## [ [Chapter 1](#Chapter1): Introduction ]

The 6-Key FPGA Macro-Keypad Development Board is a compact, dual-purpose device designed to boost productivity and serve as an entry point into FPGA development.

Featuring six customizable keys & various peripherals, it streamlines your workflow while also providing a powerful platform for learning **Hardware Description Languages (HDLs)** like _Verilog_ and _VHDL_. 

Ideal for tech enthusiasts, students, and professionals, this macropad enables hands-on exploration of digital design, offering a practical pathway to understanding silicon architecture and advancing into complex hardware engineering.

![Development-Board Overview](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter01-01-KeyPad_Overview.png?raw=true)



## \[ [Chapter 2](#Chapter2): Hardware \]

### [2.1](#Chapter2_1) Chosen FPGA Chip/Device & its data-sheet
This development board features the Lattice [MachXO2-1200HC](https://www.latticesemi.com/en/Products/FPGAandCPLD/MachXO2) FPGA which offer internal clock generation & embedded Flash technology thus achieving a non-volatile boot-up self configurating operation in a single chip. 

![MachXO2 Fpga Chips](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter02-01-LatticeChip.png?raw=true)

> You can find out more information about the FPGA in the official [MachXO2 Family Data-Sheet](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Relevant_Docs_DataSheets/FPGA-DS-02056-4-3-MachXO2-Family-Data-Sheet.pdf)



### [2.2](#Chapter2_2) On-Board Peripherals

Shown in the following diagrams is the Top & Bottom view of the board. The call-out indicates the locations of the various on-board peripherals we have on our development board.

#### [2.2.1](#Chapter2_2_1) Macro-KeyPad PCB Top Layer:

![Top View](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter02-02-TopLayer.png?raw=true)
**Peripherals**

1. micro-USB Connection
2. Lattice MachxO2 FPGA
3. FPGA JTAG connection
4. i2C QWiic Connection
5. OnBoard Passive Buzzer
6. Indicator LEDs
7. i2C EEPROM IC
8. OnBoard 3v3 LDO Regulator
9. USB HID Interface IC
10. Cherry MX Switch Holder
11. Crystal Clock [ Optional ]
12. i2C Temperature Sensor
13. User OnBoard Tactile Button



#### [2.2.2](#Chapter2_2_2) Macro-KeyPad PCB Bottom Layer:

![Bottom View](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter02-03-BottomLayer.png?raw=true)
**Peripherals**

14. NeoPixels



#### [2.2.3](#Chapter2_2_3) Macro-KeyPad With Enclosure:

And here is the completed KeyPad with 3 layers of acrylic forming the enclosure needed to protect the electronics.

![KeyPad with Enclosure](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter02-04-EnclosureKeyPad.png?raw=true)



### [2.3](#Chapter2_3) Macro-Keypad Onboard Peripherals Pin Assignments

| Funtions/Peripherals | MachXO2-1200 FPGA Pin | TQFP100 Pin |
|:--------------------:|:---------------------:|:-----------:|
| UART (TX) - CH9329                 | PL3B  | 4  |
| UART (RX) - CH9329                 | PL3A  | 3  |
| I2C (SDA)                          | PT12D | 85 |
| I2C (SCL)                          | PT12C | 86 |
| User LED                           | PL10C | 24 |
| OnBoard Speaker                    | PL3D  | 8  |
| WS2812b/NeoPixels                  | PL3C  | 7  |
| Cherry MX Key #1                   | PB15A | 40 |
| Cherry MX Key #2                   | PB15B | 41 |
| Cherry MX Key #3                   | PB18A | 42 |
| Cherry MX Key #4                   | PB18B | 43 |
| Cherry MX Key #5                   | PB18C | 45 |
| Cherry MX Key #6                   | PB18D | 47 |
| User Button                        | PR2A  | 75 |
| Programming Pins (TX) [ _Optional_ ] | PT10A | 97 |
| Programming Pins (RX) [ _Optional_ ] | PT9A  | 99 |
| Crystal (OSC_IN) [ _Optional_ ]      | PL9A  | 20 |
| Crystal (OSC_OUT) [ _Optional_ ]     | PL9B  | 21 |



### [2.4](#Chapter2_4) FPGA JTAG Programming Hardware Dongles

The KeyPad Dev Board utilize a modified JTAG connector to allow both programming & UART debugging option to greatly enhance experience of using the FPGA dev board.
We have created 2 different dongles to caters to various seriousness of HDL develompent.

* USB Programmer Module/Jig & Cable Harness
    -  *Low-Cost Programming Dongle* (Single-Channel using FTDI FT232H Module)
        -  Slider switch is use for toggling between JTAG/Programming Mode & UART/Communication Mode.
    -  *Deluxe Programming Dongle* (Dual-Channel using FTDI FT2232H Module)
        -  Channel A is use for JTAG/Programming while Channel B is use for UART/Communication Mode.

![Programming Dongles](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter02-05-ProgrammingDongles.png?raw=true)

1. *Low-cost TomatoCube FPGA Programming Dongle* with FTDI FT232H Module
2. *Deluxe TomatoCube FPGA Programming Dongle* with FTDI FT2232H Module
3. *Programming 10-Way 1.27mm Harness*



### [2.5](#Chapter2_5) Programming Connector & Pins Specification

![Programming Pin](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter02-06-ProgrammingPins.png?raw=true)


## \[ [Chapter 3](#Chapter3): Software - Lattice Development Tool - Diamond ]
### [3.1](#Chapter3_1) Installation of Diamond 3.13 in Windows
> If you failed to install Lattice Diamond on your windows machine after following the steps listed in this guide, you may refer to the official [Lattice Diamond 3.13 Installation notice for Windows](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Relevant_Docs_DataSheets/Diamond_3_13_Install_Guide_Windows.pdf) 

In order to generate the bitstream file require to configure the FPGA chip on the Macro KeyPad, we will require the Lattice Diamond Tools, installation couldn't be more straight forward on a Windows 64-bits machine. 
As of this writing, the latest tested version of the *Lattice Diamond Tools is Version 3.13*.

The Lattice Diamond software is available for download from the [Lattice Diamond Downloads & Licensing web page](http://www.latticesemi.com/latticediamond). Scroll down to the download section for the Windows Operating System & click on the [Diamond 3.13 64-bit for Windows](https://www.latticesemi.com/FileExplorer?media=%7BC65720E8-FD80-40F6-AB76-90B775AF6E44%7D&document_id=54009) download link.

> If download link is not visible/listed on the page, please (create &) log in to your Lattice account.

Once download is completed, *Double-click* on the Diamond installer you downloaded to launch the installation process. Folowing through each of the steps & choose the default selections if possible to prevent unnecessary headache. 

(Future Technology Devices International) FTDI USB drivers supports both the low-cost & deluxe programming dongle from TomatoCube & is required to program bitstream into our FPGA chip. 
*To install the drivers, administrative privileges is required.*

In the *Programmer Download Parallel/USB Port Driver* dialog box, one must select the radio button *Yes* before proceeding to click *Next*.

### [3.2](#Chapter3_2) Getting the License for your Diamond Software
After the installation, visit [Lattice website-based licensing](https://www.latticesemi.com/license) to request a working license for your Lattice Diamond software. Scroll towards the middle of the page & select Lattice Diamond & click on *Request Node-locked License*.

Again, scroll towards the middle of the page & enter your Host NIC (Physical Address) into the text field, put a check on the verification checkbox then *Generate License* button.
> Each computer would have a unique NIC (Physical Address), to get yours, launch your *Command Prompt `cmd`* and run the following command `ipconfig /all`

Check your Email & place the attached _license.dat_ file in the `<path>\license` directory of your Lattice Diamond Software installation.

> If you want to modify the path to the _license.dat_ file, change the *Environment Variable* that points to *LM_LICENSE_FILE*.

### [3.3](#Chapter3_3) Running your Diamond Software

After the installation and the license configuration, choose `Apps > Lattice Diamond 3.13 > Lattice Diamond` to launch Lattice Diamond Software.

## \[ [Chapter 4](#Chapter4): Writing Code & Programming your FPGA ]
### **[4.1](#Chapter4_1) HDL Code Tutorial #1**: Creating your first Lattice Diamond Project
#### [4.1.1](#Chapter4_1_1) Reading Button Input & Driving Simple Output Device [Button & LED]
We'll start our journey with a straightforward Verilog project to ensure that everything is set up and connected correctly up to this point, this includes verifying the software installation, software license, FPGA programming dongle + harness, and lastly the Macro-Keypad FPGA board are all set up correctly. 
If all goes smoothly, the code will make the user LED flash at roughly one-second intervals, and anytime the user press the user button swith, this will cause the LED to stop flashing. 

Below is the schematic for the user LED & Switch which we would be using in our HDL code. One will quickly realize that both peripherals are asserted-low & connected to a unique pin of the FPGA. 

_The LED jumper is shorted by default, thus can be assumed as connected directly to the FPGA. HDL debouncing of the user Switch is not absolutely nescessary for our application & the 0.1µF capacitor should do a good enough job of cleaning up noise from the tactile switch _

![User_LED_Switch](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-01-UserSwitch_LED.png?raw=true)

#### [4.1.2](#Chapter4_1_2) Creating a new Project
Launch the Lattice Diamond Software if it is not already running. Click on the *Project: New* option found in the *Start Page* panel.

![Diamond Main Screen](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-02-Diamond_mainWindow.png?raw=true)

Hit **Next >** in the *New Project* Dialog window.

![Diamond New Project Window](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-03-Diamond_newProject.png?raw=true)

In the second *New Project - Project Name* Dialog window, populate the fields with the following information:
- Project:
    - Name: _Tutorial1_
    - Location: _Folder of your choice, e.g. \<Path\>/tutorials/_
- Implementation:
    - Name: _LED_

![Diamond Project File Name](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-04-Diamond_FileName.png?raw=true)

Hit **Next >** and since we are not importing any existing source code, we will  Hit **Next >** again.

In the *New Project - Select Device* Dialog window, populate the fields with the following information:
- Select Device:
    - Family: _MachXO2_
    - Device: _LCXO2-1200HC_
    - Package Type: _TQFP100_
    - Performance Grade: _4_
    - Operating Condition: _Commercial_

![Diamond Select FPGA device](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-06-Diamond_SelectDevice.png?raw=true)

Verify the derrived Part number is _LCMXO2-1200HC-4TG100C_ which correspond to the printing on the FPGA on our Macro-KeyPad. Hit **Next >** 

![Diamond Select Synthesis Tool](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-07-Diamond_SynthesisTool.png?raw=true)

Leave the Systhesis Tool as _Lattice LSE_ when prompted by the *New Project - Select Synthesis Tool* Dialog window. Hit **Next >**

![Diamond New Project Summary](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-08-Diamond_ProjectSummary.png?raw=true)

In the final dialog window *New Project - Project Information*, verify that all the information are entered correctly. Hit **Finish** & our new skeleton project is created targetting our exact FPGA.

#### [4.1.3](#Chapter4_1_3) Creating & Editing the Source Code

With the Project created, we are now going to create our Top-level verilog file. Select *[Menu]File > New > File*, Choose _Verilog Files_ as the *Source File* type. 

![Diamond New Verilog File](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-09-Diamond_NewVerilog.png?raw=true)

Give our file the name _LED_, verify the check-box on the _Add to Implementation_ is checked and Hit **New**.

Populate the code editor with the following Top-Level file implementation & hit save.

#### Verilog Top-level file (\*.v):
```verilog
`timescale 1ns / 1ps
 
module LED (swU,led);
    input wire swU;                        
    output reg led;
   
    reg [31:0]count;
   
    // Internal OSC setting (12.09 MHz)
    OSCH #( .NOM_FREQ("12.09")) IOSC
        (
          .STDBY(1'b0),
          .OSC(clk),
          .SEDSTDBY()
        );
   
    always @(posedge clk or negedge swU) begin
        if (swU == 0) begin
            led <= 1;
        end else if(count == 9999999) begin //Time is up = 9999999/12.09MHz = 0.82s
            count <= 0;             //Reset count register
            led <= ~led;            //Toggle led (in each second)
        end else begin
            count <= count + 1;     //Counts 12.09MHz clock
        end
 
    end
 
endmodule
```

> For all availble output frequency of MachXO2's Internal Oscillator, Please refer to **Table 20.3** in the following Lattice Technical Note: [FPGA-TN-02157](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Relevant_Docs_DataSheets/FPGA-TN-02157-3-0-MachXO2-sysCLOCK-PLL-Design-and-User-Guide.pdf)

#### Logical preference file (\*.lpf):
Open the single file named _Tutorial1.lpf_ under the _LPF Contrained Files_ tree drop-down list, overwrite the file with the content from the following [Predefined board file](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Essential_Files/macrokeys.lpf). 

> To connect our top-level verilog file (consisting of one push-button switch & an LED) to the real world, we would normally go through *"Synthesis"* once & pop into spreadsheet view `([Menu]Tools > Spreadsheet View)` in order to assign each of the input & output bit from the top-level verilog file to a physical pins. But for simplicity sack, we just edited the _Logical preference file (\*.lpf)_ manually. 

![Diamond LPF File](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-11-Diamond_LPF_File.png?raw=true)

#### [4.1.4](#Chapter4_1_4) Synthesis & Generating Configuration Bitstream

Move on over from the *File List* tab to the *Process* tab. Put on check box on both `Place & Route Design > Place & Route Trace` & `Export Files > JEDEC File`. 
Verify all the check-box selection, follow by **Right-Clicking** on **JEDEC File** and choose **Rerun All** from the pop-up menu.

![Diamond Synthesis & Generating](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-12-Diamond_ProcessTab.png?raw=true)

#### [4.1.5](#Chapter4_1_5) Programming/Writing JEDEC file to FPGA's Flash

With the JEDEC File sucessfully generated, it is now time to *Burn* the configuration into the FPGA's Flash memory.

Click on  `([Menu]Tools > Programmer)`, in the *Programmer: Getting Started* dialog window, verify that the correct Cable is selected then Hit *Detect Cable*

> When using the *Deluxe programming Dongle*, always pick *Cable A* when prompted about *Multiple Cable Detected*.

![Diamond Select Programmer](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-12-Diamond_SelectingProgrammer.png?raw=true)

Verify that *Import file to current implementation* is selected, then Hit **OK**.

Once we are back in Diamond's main Window, it will show the programming interface window *after much thinking*, 

> If *Device* (FPGA Chip model) is not detected correctly, manually click the drop-down box & reselect the correct device. And if the programming _JEDEC file_ is not populated, click on the **...** button under the **File Name** column & choose the **.JED** file & Hit **Open**.

![Diamond Burning Program](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-12-Diamond_JedecProgramming.png?raw=true)

Hit the Green *Program* button in the *Programming window's ToolBar*. 
Observe the Output Log window and check for the message *Info - Operation: sucessful.* 

> Hint: Speed up the programming process? In development phase, it is possible to speed up the programming process by using *Bitstream File* (Instead of JEDEC) & choose Access Mode as _Static RAM Cell Mode_ under the *Operation* configuration.

#### [4.1.6](#Chapter4_1_6) Observing the result on the Macro-KeyPad
After the JEDEC has been programmed into the FPGA, the HDL configuration will take into effect. You will be able to see the user LED flashing periodically & upon pressing on the user Button, the LED will switched off.

Below is the location of the user LED & Switch on the Macro-KeyPad.

![user LED & Button Location](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-13-UserButton_LED_Location.png?raw=true)

## \[ [Chapter 5](#Chapter5): Software - SOC Development Tool - LatticeMico System]
### [5.1](#Chapter5_1) Installation of LatticeMico System in Windows
~~The Lattice MicoSystem software is available for download from the [LatticeMico System Development Tools web page](https://www.latticesemi.com/Products/DesignSoftwareAndIP/EmbeddedDesignSoftware/LatticeMicoSystem).  Scroll down to the download section for the Windows Operating System &~~ Click on the [LatticeMico System for Diamond 3.13 Windows](https://www.latticesemi.com/FileExplorer?media=%7B958D44F3-065D-4BB4-81B4-3F4002E2791E%7D&document_id=54020) download link.

Once download is completed, *Double-click* on the LatticeMico System installer you downloaded to launch the installation process. Folowing through each of the steps & choose the default selections if possible to prevent unnecessary headache. 

### [5.2](#Chapter5_2) Running your LatticeMico System Software

After the installation, choose `Apps > Lattice Diamond 3.13 > LMS 1.1 for Diamond 3.12` to launch LatticeMico System Software.

[Lattice]:(https://www.latticesemi.com)