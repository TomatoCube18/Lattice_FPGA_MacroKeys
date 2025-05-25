# Lattice MachXO2 6-Key Macro-KeyPad Development Board - QuickStart Guide

## [ [Chapter 1](#Chapter1): Introduction ]

The 6-Key FPGA Macro-Keypad Development Board is a compact, dual-purpose device designed to boost productivity and serve as an entry point into FPGA development.

Featuring six customizable keys & various peripherals, it streamlines your workflow while providing a powerful platform for learning **Hardware Description Languages (HDLs)** like _Verilog_ and _VHDL_. 

Ideal for tech enthusiasts, students, and professionals, this Macro-KeyPad enables hands-on exploration of digital design, offering a practical pathway to understanding silicon architecture and advancing into complex hardware engineering.

![Development-Board Overview](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter01-01-KeyPad_Overview.png?raw=true)



## \[ [Chapter 2](#Chapter2): Hardware \]

### [2.1](#Chapter2_1) Chosen FPGA Chip/Device & its data-sheet
This development board features the Lattice [MachXO2-1200HC](https://www.latticesemi.com/en/Products/FPGAandCPLD/MachXO2) FPGA, which offers internal clock generation & embedded Flash technology, thus achieving a non-volatile boot-up self-configuring operation in a single chip. 

![MachXO2 Fpga Chips](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter02-01-LatticeChip.png?raw=true)

> You can find out more information about the FPGA in the official [MachXO2 Family Data-Sheet](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Relevant_Docs_DataSheets/FPGA-DS-02056-4-3-MachXO2-Family-Data-Sheet.pdf)



### [2.2](#Chapter2_2) On-Board Peripherals

The following diagrams show the Top & Bottom layer view of the Macro-KeyPad PCB. The call-out indicates the locations of the various on-board peripherals on our development board.

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

> Click here for the [assembly guide](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Assembly_Guide/MacroKeyPad_AssemblyGuide.md) 🪛

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

The Macro-KeyPad Dev Board utilizes a modified/proprietary JTAG connector that allows both JTAG programming & UART debugging options to greatly enhance the experience of using the FPGA dev board. 
We have created 2 different dongles to cater to various seriousness of HDL development.

* USB Programmer Module/Jig & Cable Harness
    -  *Low-Cost Programming Dongle* (Single-Channel using FTDI FT232H Module)
        -  A Slider switch is used for toggling between JTAG/Programming Mode & UART/Communication Mode.
    -  *Deluxe Programming Dongle* (Dual-Channel using FTDI FT2232H Module)
        -  Channel A is used for JTAG/Programming, while Channel B is used for UART/Communication Mode.

![Programming Dongles](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter02-05-ProgrammingDongles.png?raw=true)

1. *Low-cost TomatoCube FPGA Programming Dongle* with FTDI FT232H Module
2. *Deluxe TomatoCube FPGA Programming Dongle* with FTDI FT2232H Module
3. *Programming 10-Way 1.27mm Harness* (align the horn of the mini IDC connectors when attaching harness to board)

> Note: When using Low-cost TomatoCube FPGA Programming Dongle, you are required to manually toggle the mode switch on the Programming Dongle corresponding to the task you are trying to perform.
> e.g. Push the slider switch towards **JTAG** when you are trying to configure/program the FPGA as illustrated below.
>
> ![Low-Cost Dongle JTAG Mode](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-14-Low_Cost_JTAG_Mode.png?raw=true)



### [2.5](#Chapter2_5) Programming Connector & Pins Specification

![Programming Pin](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter02-06-ProgrammingPins.png?raw=true)


## \[ [Chapter 3](#Chapter3): Software - Lattice Development Tool - Diamond ]
### [3.1](#Chapter3_1) Installation of Diamond 3.13 in Windows
> If you failed to install Lattice Diamond on your Windows machine after following the steps listed in this guide, you may refer to the official [Lattice Diamond 3.13 Installation notice for Windows](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Relevant_Docs_DataSheets/Diamond_3_13_Install_Guide_Windows.pdf) 

In order to generate the bitstream file required to configure the FPGA chip on the Macro KeyPad, we will need the Lattice Diamond Tools; installation couldn't be more straightforward on a Windows 64-bit machine. 
As of this writing, the latest tested version of the *Lattice Diamond Tools is Version 3.13*.

The Lattice Diamond software is available from the [Lattice Diamond Downloads & Licensing web page](http://www.latticesemi.com/latticediamond). Scroll down to the download section for the Windows Operating System & click on the [Diamond 3.13 64-bit for Windows](https://www.latticesemi.com/FileExplorer?media=%7BC65720E8-FD80-40F6-AB76-90B775AF6E44%7D&document_id=54009) download link.

> If the download link is not visible/listed on the page, please (create &) log in to your Lattice account.

Once the download is completed, *Double-click* on the Diamond installer you downloaded to launch the installation process. Following through each of the steps & choose the default selections if possible to prevent unnecessary headaches.

(Future Technology Devices International) FTDI USB drivers support both the low-cost & deluxe programming dongle from TomatoCube & is required to program bitstream into our FPGA chip. 
*Administrative privileges is required to install the Windows drivers.*

In the *Programmer Download Parallel/USB Port Driver* dialog box, one must select the radio button **Yes** before clicking **Next**.

### [3.2](#Chapter3_2) Getting the License for your Diamond Software
After the installation, visit [Lattice website-based licensing](https://www.latticesemi.com/license) to request a working license for your Lattice Diamond software. Scroll towards the middle of the page & select Lattice Diamond & click on *Request Node-locked License*.

Again, scroll towards the middle of the page & enter your Host NIC (Physical Address) into the text field, check the verification checkbox, and then clicking on the *Generate License* button.
> Each computer would have a unique NIC (Physical Address). To get yours, launch your *Command Prompt `cmd`* and run the following command `ipconfig /all`

Check your Email & place the attached _license.dat_ file in the `<path>\license` directory of your Lattice Diamond Software installation.

> If you want to modify the path to the _license.dat_ file, change the *Environment Variable* that points to *LM_LICENSE_FILE*.

### [3.3](#Chapter3_3) Running your Diamond Software

After the installation and the license configuration, choose `Apps > Lattice Diamond 3.13 > Lattice Diamond` to launch Lattice Diamond Software.

> Note: If your Diamond Software fails to access/verify the `license.dat` file despite being configured correctly within the _Windows Environment Variables_. Restart your system & try again🤯.
>
> ![Failed License](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter03-01-License_Failed.jpg?raw=true)

## \[ [Chapter 4](#Chapter4): Writing Code & Programming your FPGA ]
### [4.1](#Chapter4_1) Creating your first Lattice Diamond Project
#### [4.1.1](#Chapter4_1_1) HDL Code Tutorial #1**: Reading Button Input & Driving LED Output [Button & LED]**
We'll start our journey with a straightforward Verilog project to ensure that everything is set up and connected correctly up to this point. This includes verifying the software installation, software license, FPGA programming dongle + harness, and lastly, the Macro-Keypad FPGA board are all set up correctly. 
If all goes smoothly, the code will make the user LED flash at roughly one-second intervals, and anytime the user presses the user button switch, this will cause the LED to stop flashing.

Below is the schematic for the user LED & Switch which we would be using in our HDL code. One will quickly realize that both peripherals are asserted-low & connected to a unique pin of the FPGA. 

_The on-board LED jumper is shorted by default and thus can be assumed to be connected directly to the FPGA. HDL debouncing of the user Switch is not absolutely necessary for our application as the 0.1µF capacitor should do a good enough job of cleaning up noise coming from the tactile switch._

![User_LED_Switch](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Tutorial_Files/Tutorial_1/Images/Tutorial01-01-UserSwitch_LED.png?raw=true)

##### [Step 1:](#Chapter4_1_1_1) Creating a new Project
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
    - Device: _LCMXO2-1200HC_
    - Package Type: _TQFP100_
    - Performance Grade: _4_
    - Operating Condition: _Commercial_

![Diamond Select FPGA device](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-06-Diamond_SelectDevice.png?raw=true)

Please verify that the derived Part number is _LCMXO2-1200HC-4TG100C_, corresponding to the printing on the FPGA on our Macro-KeyPad. Hit **Next >** 

![Diamond Select Synthesis Tool](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-07-Diamond_SynthesisTool.png?raw=true)

Leave the option on the Systhesis Tool as _Lattice LSE_ when prompted by the *New Project - Select Synthesis Tool* Dialog window. Hit **Next >**

![Diamond New Project Summary](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-08-Diamond_ProjectSummary.png?raw=true)

In the final dialog window *New Project - Project Information*, verify that all the information are entered correctly. Hit **Finish** & our new skeleton project is created targetting our exact FPGA.

##### [Step 2:](#Chapter4_1_1_2) Creating & Editing the Source Code

With the Project created, we are now going to create our Top-level Verilog file. Select *[Menu]File > New > File*, and choose _Verilog Files_ as the *Source File* type. 

![Diamond New Verilog File](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-09-Diamond_NewVerilog.png?raw=true)

Give our file the name _LED_, verify that the _Add to Implementation_ checkbox is checked, and Hit **New**.

Populate the code editor with the following Top-Level file implementation & hit save.

###### Verilog Top-level file (\*.v):
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

> For all available output frequencies of MachXO2's Internal Oscillator, Please refer to **Table 20.3** in the following Lattice Technical Note: [FPGA-TN-02157](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Relevant_Docs_DataSheets/FPGA-TN-02157-3-0-MachXO2-sysCLOCK-PLL-Design-and-User-Guide.pdf)

###### Logical preference file (\*.lpf):
Open the single file named _Tutorial1.lpf_ under the _LPF Contrained Files_ tree drop-down list, overwrite the file with the content from the following [Predefined board file](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Essential_Files/macrokeys.lpf). 

> To connect our top-level Verilog file (consisting of one push-button switch & an LED) to the real world, we would normally go through *"Synthesis"* once & pop into spreadsheet view `([Menu]Tools > Spreadsheet View)` in order to assign each of the input & output bit from the top-level verilog file to a physical pins. But for simplicity sack, we just edited the _Logical preference file (\*.lpf)_ manually. 

![Diamond LPF File](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-11-Diamond_LPF_File.png?raw=true)

##### [Step 3:](#Chapter4_1_1_3) Synthesis & Generating Configuration Bitstream

Move on over from the *File List* tab to the *Process* tab. Put a tick on both `Place & Route Design > Place & Route Trace` & `Export Files > JEDEC File` checkboxes. 
Verify all the check-box selections, followed by **Right-Clicking** on **JEDEC File** and choosing **Rerun All** from the pop-up menu.

![Diamond Synthesis & Generating](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-12-Diamond_ProcessTab.png?raw=true)

##### [Step 4:](#Chapter4_1_1_4) Programming/Writing JEDEC file to FPGA's Flash

With the JEDEC File sucessfully generated, it is now time to *Burn* the configuration into the FPGA's Flash memory.

Click on  `([Menu]Tools > Programmer)`, in the *Programmer: Getting Started* dialog window, verify that the correct Cable is selected then Hit *Detect Cable*

> When using the *Deluxe programming Dongle*, always pick *Cable A* when prompted about *Multiple Cable Detected*.

![Diamond Select Programmer](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-12-Diamond_SelectingProgrammer.png?raw=true)

Verify that *Import file to current implementation* is selected, then Hit **OK**.

Once we are back in Diamond's main Window, it will show the programming interface window *after much thinking*, 

> If *Device* (FPGA Chip model) is not detected correctly, manually click the drop-down box & reselect the correct device. And if the programming _JEDEC file_ is not populated, click on the **...** button under the **File Name** column & choose the **.JED** file & Hit **Open**.

![Diamond Burning Program](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-12-Diamond_JedecProgramming.png?raw=true)

Hit the Green *Program* button in the *Programming window's ToolBar*. 
Observe the Output Log window and check for the message *Info - Operation: successful.* 

> Hint: Speed up the FPGA programming process? In the development phase, it is possible to speed up the programming process by using *Bitstream File* (Instead of JEDEC) & choosing Access Mode as _Static RAM Cell Mode_ under the *Operation* configuration.



##### [Step 5:](#Chapter4_1_1_5) Observing the result on the Macro-KeyPad

After the JEDEC has been programmed into the FPGA, the HDL configuration will take into effect. You will be able to see the user LED flashing periodically & upon pressing on the user Button, the LED will switched off.

Below is the location of the user LED & Switch on the Macro-KeyPad.

![user LED & Button Location](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-13-UserButton_LED_Location.png?raw=true)

### [4.2](#Chapter4_2) Additional HDL Code Tutorial : Using the other peripherals onboard the Macro-KeyPad
Tutorials to control the other components found onboard the Macro-Key have been spread out into their respective folder in the repository.
* HDL Code Tutorial #2: [Making a audible Warbling Siren [CherryMX Switch, Buzzer]](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/tree/main/Tutorial_Files/Tutorial_2/LatticeMacroKey-Tutorial-02.md)
* HDL Code Tutorial #3: [Reading Third-Party Component Data-sheets & Driving two Neopixel LEDs [WS2812b]](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/tree/main/Tutorial_Files/Tutorial_3/LatticeMacroKey-Tutorial-03.md)
* HDL Code Tutorial #4: [Using Standard Serial Protocol to send a KeyStroke [UART TX to USB HID IC CH9329]](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/tree/main/Tutorial_Files/Tutorial_4_&_5/LatticeMacroKey-Tutorial-04.md)
* HDL Code Tutorial #5: [USB Custom HID upstream transfer using Python Code [UART RX from USB HID IC CH9329]](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/tree/main/Tutorial_Files/Tutorial_4_&_5/LatticeMacroKey-Tutorial-05.md)
* HDL Code Tutorial #6: [Reading & Writing of I2C EEPROM Memory [i2C EEPROM]](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/tree/main/Tutorial_Files/Tutorial_6/LatticeMacroKey-Tutorial-06.md)



### [4.3](#Chapter4_3) Final Project: Completing a Consumer-Ready Macro-Keypad with Reconfigurable Key Mapping using the onBoard EEPROM memory

In this final HDL section, you'll integrate everything you've learned to complete a fully functional Macro-Keypad device that behaves like a consumer product. Users won't need to tinker with HDL code - they can easily reconfigure key mappings using a simple Python application, with the custom settings stored in the onboard EEPROM memory.

#### 🧠 Project Objective Summary

**Enable the Macro-Keypad to:**

* Store custom key mappings in the onboard I2C EEPROM.
* Allow key-mapping configurations to be reprogrammed via a Python utility on a host computer.
* Use the CH9329 USB HID upstream interface to receive key-mapping configuration data from the PC.
* When a key is pressed, retrieve and process key mappings via the FPGA (MachXO2).
* Use the CH9329 USB HID interface to send key commands to the PC.

Completing these objectives makes the Macro-Keypad flexible and user-friendly, allowing non-technical users to personalize their macros without editing HDL code or using Lattice Diamond. This transforms the Macro-Keypad development board into a practical, customizable, and end-user-ready hardware product.

```mermaid

flowchart LR
    PC["Computer\n(Python Tool)"] <--"USB/Write Config"--> HID
    subgraph "Macro-KeyPad"
        HID["CH9329"] <--"UART"--> FPGA["MachXO2"]
        FPGA <-- GPIO --> SCAN["Key Matrix"]
        FPGA <-- I2C --> EEPROM["AT24C04\n(EEPROM)"]
    end

````


#### 🧩 How It should ideally works 

* On power-up, the FPGA continuously scans the key matrix to detect any pressed key.
* When a key is detected, the FPGA retrieves the corresponding command code from the EEPROM over I2C.
* The command is then sent via UART to the CH9329, which emulates a USB keyboard and sends the key event to the host PC.
* To change the key mappings, the user simply runs a Python configuration tool, which uses the CH9329's HID upstream transfer capability to receive & ultimately update the EEPROM with new key macros.


## \[ [Chapter 5](#Chapter5): Software - SoC Development Tool - LatticeMico System]
### [5.1](#Chapter5_1) Installation of LatticeMico System in Windows
~~The Lattice MicoSystem software is available for download from the [LatticeMico System Development Tools web page](https://www.latticesemi.com/Products/DesignSoftwareAndIP/EmbeddedDesignSoftware/LatticeMicoSystem).  Scroll down to the download section for the Windows Operating System &~~ Click on the [LatticeMico System for Diamond 3.13 Windows](https://www.latticesemi.com/FileExplorer?media=%7B958D44F3-065D-4BB4-81B4-3F4002E2791E%7D&document_id=54020) download link.

Once download is completed, *Double-click* on the LatticeMico System installer you downloaded to launch the installation process. Following through each of the steps & choose the default selections if possible to prevent unnecessary headaches. 

> 🐧 If you are running on Linux & having a hard time locating the LatticeMico Installer, here s the link to it. [LatticeMico System for Diamond 3.13 Linux](https://www.latticesemi.com/FileExplorer?media=%7B9FAD2513-DF9A-4DBD-8575-B438139D03CB%7D&document_id=54021) download link.



### [5.2](#Chapter5_2) Running your LatticeMico System Software

After the installation, choose `Apps > Lattice Diamond 3.13 > LMS 1.2 for Diamond 3.13` to launch LatticeMico System Software.


## \[ [Chapter 6](#Chapter6): Creating a SoC using LatticeMico System ]
### [6.1](#Chapter6_1) Creating your first SoC system using Lattice Mico8



Lattice offers two excellent soft-core processors: the Mico8 (8-bit CPU) and Mico32 (32-bit CPU), both of which are compatible with the MachXO2 family of FPGAs. And it doesn't stop there, they also provide a fantastic tool that allows you to design, architect and build your own SoC (System on Chip) running of either Mico8 or Micro32 with minimal effort. In this tutorial, we'll guide you through the steps to create a basic system using the Macro-KeyPad.

This tutorial will walk you through the essentials of using the LatticeMico System software to implement the **LatticeMico8** microcontroller. We’ll also show you how to add some modules to support the connected components, starting with GPIO (General Purpose Input Output), driving the LEDs, Buttons as well as the On-Board buzzer of our Macro-KeyPad.

The LatticeMico System includes three main tools:

- **Mico System Builder (MSB):** Helps you design an embedded microcontroller system on a single FPGA.
- **C/C++ Software Project Environment (C/C++ SPE):** Allows you to write and debug software or firmware for your new soft processor.
- **Debugger:** Assists in troubleshooting your embedded software and refining your design.

Using such design methodology & tools, you can build a microcontroller system directly on your FPGA, reducing cost by minimizing the need for additional board space & FPGA development time.

To get started with this tutorial, you'll need both Lattice Diamond and the "LatticeMico System for Diamond" installed on your computer.



#### [6.1.1](#Chapter6_1_1) Mico8 Tutorial #1**: Reading Button Input & Driving LED Output with a C program [Button & LED]**

> 💡The following tutorial loosely follows the official guide/tutorial from Lattice Semi, with modifications made to suit our specific hardware. For a more detailed understanding, it's recommended to also read through the official [LatticeMico8 Tutorial - Dec 2013](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Relevant_Docs_DataSheets/LatticeMico8Tutorial-2013-12.pdf).

##### [Step 1:](#Chapter6_1_1_1) Creating a new Project

Launch the Lattice Diamond Software if it is not already running. Click on the *Project: New* option found in the *Start Page* panel.

![Diamond Main Screen](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-02-Diamond_mainWindow.png?raw=true)

Hit **Next >** in the *New Project* Dialog window.

![Diamond New Project Window](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-03-Diamond_newProject.png?raw=true)

In the second *New Project - Project Name* Dialog window, populate the fields with the following information:

- Project:
  - Name: _platform1_
  - Location: _Folder of your choice, e.g. \<Path\>/mico8_blink_
- Implementation:
  - Name: _platform1_
  - Location: _Folder of your choice, e.g. \<Path\>/mico8_blink/platform1_

![MSB_Diamond Project File Name](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter06-01-MSB_Diamond_Project_File_Name.png?raw=true)

Hit **Next >** and since we are not importing any existing source code, we will  Hit **Next >** again.

In the *New Project - Select Device* Dialog window, populate the fields with the following information:

- Select Device:
  - Family: _MachXO2_
  - Device: _LCXO2-1200HC_
  - Package Type: _TQFP100_
  - Performance Grade: _4_
  - Operating Condition: _Commercial_

![Diamond Select FPGA device](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-06-Diamond_SelectDevice.png?raw=true)

Please verify that the derived Part number is _LCMXO2-1200HC-4TG100C_, corresponding to the printing on the FPGA on our Macro-KeyPad. Hit **Next >** 

![Diamond Select Synthesis Tool](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-07-Diamond_SynthesisTool.png?raw=true)

Leave the option on the Systhesis Tool as _Lattice LSE_ when prompted by the *New Project - Select Synthesis Tool* Dialog window. Hit **Next >**

![Diamond New Project Summary](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-08-Diamond_ProjectSummary.png?raw=true)

In the final dialog window *New Project - Project Information*, verify that all the information are entered correctly. Hit **Finish** & our new skeleton project is created targetting our exact FPGA.



[Step 2:](#Chapter6_1_2_1) Creating a LatticeMico8 SoC Platform

In Step 1, you created a blank Diamond project, which serves as a placeholder for our LatticeMico8 microcontroller platform. Now, we'll use the **LatticeMico System Builder (MSB)** to design the microcontroller system and add the necessary components. The final output from MSB is a bunch of generated Verilog code needed to create a System-on-a-Chip (SoC) for your FPGA. Finally, you'll build this Verilog HDL code in Diamond to produce the bitstream that configures the MachXO2 FPGA.

Launch the LatticeMicoSystem Builder, **LMS 1.2**. Since this tool is build on top of the Eclipse IDE, a lot of you might be familiar with the flow involved.

To get started, launch the **LatticeMico System Builder (LMS 1.2)**. If you're familiar with the Eclipse IDE, you'll find the interface and workflow similar. When prompted for an Eclipse Workspace, you can leave the default setting. However, if you're using other Eclipse-based tools, like Android Studio, I would recommed choosing a different path to avoid conflicts between the environments.

In the *Workspace Launcher* Dialog window, populate the fields with the following information:

- Workspace: _Folder of your choice, e.g. \<Path\>/mico8_blink/MSBEnvironment_

![MSB_MSBEnvironment](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter06-02-MSB_MSBEnvironment.png?raw=true)

Hit **OK** to launch us to the LatticeMico System interface.



In the LatticeMico System interface, ensure **LMS 1.0 D3.11** is selected in the upper left-hand corner (not **C/C++**) to access the MSB perspective.

![MSB_MSBWindow_MSB_Perspective](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter06-02-MSB_MSBWindow_MSB_Perspective.png?raw=true)



Choose `[Menu]File > New Platform`, In the **New Platform Wizard** dialog box, populate the textbox with the following:

- Platform Name: _platform1_
- Directory: _Folder of your choice, e.g. \<Path\>/mico8_blink_
- Processor: _LM8_
- Board Frequency: _12.09_
- Arbitration Scheme: _Shared Bus_ [verify]
- Family: _MachXO2_
- Device: _LCXO2-1200HC_
- Performance Grade: _4_
- Package Type: _TQFP100_
- Platform Templates: _blank_ [verify]

![MSB_NewPlatform Wizard](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter06-02-MSB_NewPlatformWizard.png?raw=true)

Hit **Finish** , The MSB perspective now appears, with a bunch of selections to construct your Mico8 SoC.

Let's add the most essential component, our microcontroller core. In the **Available Components** tab under **CPU**, double-click **LatticeMico8**. Double-click **LatticeMico8** to bring up the configuration needed for our microcontroller core. For ease of completing this tutorial, in the **Add LatticeMico8** dialog pop-up, please populate the textfields with the following information.

PROM Settings

- PROM Size: _2048_

Scratchpad Settings

-  Internal ScratchPad:  _Checked ✔︎_
- Size: _0x0000800_

![MSB_NewLatticeMico8](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter06-02-MSB_NewLatticeMico8.png?raw=true)

Hit **OK** to add our component with the desired configuration into our skeleton system, When you are back in the MSB main window, You'll see the new **LM8** component appear under the **platform1** tab.

![MSB_LatticeMico8_LM8](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter06-02-MSB_LatticeMico8_LM8.png?raw=true)

Now we proceed to add the peripheral components to our mico8 SoC. First, we will add the memory-mapped WISHBONE based **GPIO**(general-purpose I/O) for driving the LED through our microcontroller into our system. To add the **GPIO** to the platform, In the **Available Components** tab under **IO**, double-click **GPIO**. When prompted with the **Add GPIO** dialog pop-up, please populate the textfields with the following information. 

-  Instance Name:  _LED_
-  Port Type: _Output Port Only_
-  Data Width: _1_
-  WISHBONE Data Bus Width: _8_

![MSB_GPIO WishBone](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter06-02-MSB_GPIO%20WishBone.png?raw=true)

Hit **OK** to allow MSB to add the GPIO Module to our system configuration. Now I want you to add 2 additional **GPIO** modules, one for our on-board buttons & another for our on-board speaker. Lastly, we will also add in an **UART** core while we are at it. 

Use the following configuration to complete those components/modules.

**Button GPIO Module**

-  Instance Name:  _BUTTON_
-  Port Type: _Input Port Only_
-  Data Width: _6_
-  WISHBONE Data Bus Width: _8_

**Speaker GPIO Module**

-  Instance Name:  _SPEAKER_
-  Port Type: _Output Port Only_
-  Data Width: _1_
-  WISHBONE Data Bus Width: _8_

**UART GPIO Module**

-  Stick with Default

After completing these components, the MSB system should look like this:

![MSB_Completed_b4_connection](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter06-02-MSB_Completed_b4_connection.png?raw=true)

Next, you need to connect the **master** and **slave** ports between your components in your SoC:

1. **LED, Button, Speaker** - Connect the data port of the LatticeMico8 microcontroller to the LatticeMico LED, Button & Speaker slave port by clicking the circle in the WISHBONE Connection column of the GPIO Port row.
2. **UART** - The same, connect the data port of the LatticeMico8 microcontroller to the LatticeMico UART slave port by clicking the circle in the WISHBONE Connection column of the UART Port row.

Once done, the MSB should appear as follows:

![MSB_Completed_after_connection](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter06-02-MSB_Completed_after_connection.png?raw=true)

Now instead of manually setting all the connection parameters between Master & Slave, you can streamline the process using MSB's automatic generation/assignment feature. At the top of the MSB interface, below the menu bar, you will find four buttons labeled **A**, **I**, **D**, and **G**. These are located at the end of the row of graphical menu buttons.

 The four graphical button tools are:

- **A:** Address Generation tool.
- **I:** Interrupt request priority Generation tool.
- **D:** Perform a Design rule check, it is for verifying that components in the platform have valid base addresses & interrupt request values, which they most definitely are.
- **G**: Generate the microcontroller SoC Platform.

Click the buttons  in the following sequence **A**→ **I**→ **D**→ **G**, and you are all good to go! (Well, at least check the **Console** tab to verify that the generation is completed sucessfully with the following message, **Finish Generator**)

Let's take a peek at the generated HDL for our mico8 SoC system. Navigate to the following folder on your computer
`Folder of your choice, e.g. \<Path\>/mico8_blink/platform1/soc` locate a file call `platform1.v` that will be the entry point to your mico8 SoC.



[Step 3:](#Chapter6_1_3_1) Creating the software Application code

Return to the LatticeMico System interface and switch from the **LMS** perspective to the **C/C++** perspective. This allows you to access the tools needed for C/C++ software development. You can find the perspective selection in the upper left-hand corner of the MSB main interface.

![MSB_MSBWindow_MSB_Perspective](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter06-03-MSB_MSBWindow_MSB_Perspective.png?raw=true)

To create a new **C**/C++ project, choose `[Menu]File > New > Mico Managed Make C Project`, In the New Project dialog box, make the following selections:

New Project:

- Project Name: _LEDTest_
- Location: _<Folder>\mico8_blink\LEDTest_
- MSB System: _<Folder>\mico8_blink\platform1\soc\platform1.msb_
- Select Project Template: _LM8 LEDTest_

![MSB_NewC_Project](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter06-03-MSB_NewC_Project.png?raw=true)

Click **Finish**. A basic template code will appear in the center pane. You'll need to replace this code with the source code that matches the hardware you're using. Paste your C source code into the editor and save the file.

###### new LM8_LEDTest file (\*.c):

```c
/**************************************************************
 * This example Blink LED on 6-Key Macro-KeyPad Development   *
 * board.                                                     *
 --------------------------------------------------------------
 * PREREQUISITES:                                             *
 * - GPIO with 1-bit output named LED connected to the        *
 *   board's LED pins.                                        *
 *                                                            *       
 **************************************************************/
#include "MicoUtils.h"
#include "MicoGPIO.h"
#include "DDStructs.h"
 
int main(void)
{
   unsigned char ledVal = 0x01;
   unsigned char buttonsVal = 0x00;
 
   /* Fetch GPIO instance named "LED" */
   MicoGPIOCtx_t *led = &gpio_LED;
   if(led == 0){
      return(0);
   }
   /* Fetch GPIO instance named "BUTTON" */
 	 MicoGPIOCtx_t *buttons = &gpio_BUTTON;
   if(buttons == 0){
       return(0);
   }
    
   /* Blink the LEDs, every 100 or 250 msecs controlled by Button_U forever */
   while(1){
          MICO_GPIO_WRITE_DATA_BYTE0 (led->base, ledVal);
          MICO_GPIO_READ_DATA_BYTE0 (buttons->base, buttonsVal);
     
          MicoSleepMilliSecs((buttonsVal & 0x20)?100:250);

          ledVal = (ledVal == 0x01) ? 0x00 : 0x01;
   }
   
   /* all done */
   return(0);
}
```

Next, it's time to build the project. This step involves compiling, assembling, and linking your application code using the Mico8 GCC compiler toolchain. Choose `[Menu]Project > Build Project`. 

If the build is successful, the output will be an **executable linked format (ELF)** file named `LEDTest`. This ELF file will then be converted in to hexadecimal initialization files, one each for code and data. The initialization file that contains **LEDTest** code is called **prom_init.hex** and is used to initialize the LatticeMico8 PROM. The initialization file that contains LEDTest data is called **scratchpad_init.hex** and is used to initialize the LatticeMico8 Scratchpad.

[Step 4:](#Chapter6_1_4_1) Deploy the software to our SoC

In the C/C++ perspective, select **LEDTest** and choose `[Menu]Tools > Software Deployment`. When the Software Deployment Tools dialog box appears, Select **Mico8 Memory Deployment**, and click on **New** button.

![MSB_SoftwareDeploymentsTool](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter06-04-MSB_SoftwareDeploymentsTool.png?raw=true)

When the **Software Deployment Tools** dialog now displays a Mico8 memory deployment configuration in the right pane, populate the textfields with the following.

* Name: _LEDTest_
* Save Memory Initialization Files...: _<Folder>\mico8_blink\LEDTest_

Hit on **Apply** follow with **Start**. The two initialization files **prom_init.mem** and **scratchpad_init.mem** should now be saved within the output folder specified. We will now initialize LatticeMico8 with **LEDTest** initialization files. 

Return to the **LMS** perspective & Double-click on **LM8** instance within the platform. In the **Modifiy LatticeMico8** dialog box window, make changes to the PROM & Scratchpad settings as follows.

PROM Settings

* Initialization File Name: _<Folder>\mico8_blink\LEDTest\prom_init.mem_

Scratchpad Settings

*  Initialization File Name: _<Folder>\mico8_blink\LEDTest\scratchpad_init.mem_

![MSB_Modify Mico8 System](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter06-04-MSB_Modify%20Mico8%20System.png?raw=true)

Regenerate the hardware platform by clicking on the graphical **G** (Generate) button. The LatticeMico8 Verilog source code is now configured to use the **prom_init.mem** and **data_init.mem** files that implement **LEDTest**.



[Step 5:](#Chapter6_1_5_1) Creating a user Top level Module for our SoC

The next step is to generate the micro8 SoC bitstream from our verilog HDL Implementation using Lattice Diamond Tool. This bitstream will then pogrammed to the FPGA on the Macro-KeyPad. Return to the Lattice Diamond tool & click on `[Menu]File > New > SourceFile > Verilog` & Populate the dialog box will the following.

* Name: _platform1_top_
* Location: _<Folder>\mico8_blink\platform1\soc_

Click **New**. Populate the code editor with the following Top-Level file implementation & hit **save**.

###### Verilog Top-level file - platform1_top (\*.v):

```verilog
`timescale 1ns / 1ps
`include "../soc/platform1.v"
 
module platform1_top
(
    input swA,
    input swB,
    input swC,
    input swD,
    input swE,
    input swF,
    input swU,
    input rx,
    output tx,
    output led
);
 
    wire [5:0] button_in = {swF,swE,swD,swC,swB,swA};
 
    // MachX02 internal oscillator generates platform clock
    wire clk;
    // Internal OSC setting (12.09 MHz)
    OSCH #( .NOM_FREQ("12.09")) IOSC
    (
        .STDBY      (1'b0    ),
        .OSC        (clk     ),
        .SEDSTDBY   (        )
    );
    
 
    platform1 platform1_u
    (
        .clk_i          (clk        ),
        .reset_n        (swU        ),
        .LEDPIO_OUT     (led        ),
        .BUTTONPIO_IN   (button_in  ),
        .uartSIN        (rx         ),
        .uartSOUT       (tx         )
    );
 
endmodule
```

###### Logical preference file (\*.lpf):

Open the single file named _platform1.lpf_ under the _LPF Contrained Files_ tree drop-down list, overwrite the file with the content from the following [Predefined board file](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Essential_Files/macrokeys.lpf). 

Move on over from the *File List* tab to the *Process* tab. Put a tick on both `Place & Route Design > Place & Route Trace` & `Export Files > JEDEC File` checkboxes. 
Verify all the check-box selections, followed by **Right-Clicking** on **JEDEC File** and choosing **Rerun All** from the pop-up menu.

![MSB-Diamond Synthesis & Generating](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter06-05-MSB-Diamond%20SynthesisGenerating.png?raw=true)



[Step 6:](#Chapter6_1_6_1) Programming/Writing JEDEC file to FPGA's Flash

With the JEDEC File sucessfully generated, it is now time to *Burn* the configuration into the FPGA's Flash memory.

Click on  `([Menu]Tools > Programmer)`, in the *Programmer: Getting Started* dialog window, verify that the correct Cable is selected then Hit *Detect Cable*

![MSB-Burning JED](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter06-06-MSB-BurningJED%20Cable.png?raw=true)

After the JEDEC has been programmed into the FPGA, the HDL configuration will take into effect. You will be able to see the user LED flashing periodically & upon pressing on the **CherryMx Switch F**, the rate of the User LED flashes will change.

Below is the location of the user LED & Switch on the Macro-KeyPad.

![user LED & Button Location](https://github.com/TomatoCube18/Lattice_FPGA_MacroKeys/blob/main/Images/Chapter04-15-UserButton_MXF_LED_Location.png?raw=true)

### [6.2](#Chapter6_2) Additional Mico8 Tutorial: Using the other peripherals onboard the Macro-KeyPad

More tutorial around mico8 in the pipe-line, stay tuned 📣

* Mico8 Code Tutorial #2: Recreating the Warbling siren tutorial but using mico8 SoC [CherryMX Switch, Buzzer]
* Mico8 Code Tutorial #3: Using UART component in mico8 to send a KeyStroke [UART TX to USB HID IC CH9329]
* Mico8 Code Tutorial #4: Using EFB & the other peripherals onboard the Macro-KeyPad [I2C EEPROM & I2C Temperature Sensor]
* Mico8 Code Tutorial #5: Making a WISHBONE compatible NeoPixel Module & interface with mico8 SoC [WS2812b]

[Lattice]:(https://www.latticesemi.com)
