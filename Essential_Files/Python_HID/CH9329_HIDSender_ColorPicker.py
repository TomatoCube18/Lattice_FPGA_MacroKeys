# ********************************Copyright Statement**************************************
# 
#  TomatoCube & Minoyo
# 
# ----------------------------------File Information--------------------------------------
#  File Name: CH9329_HIDSender_ColorPicker.py
#  Creation Date: 28th August 2024
#  Function Description: CH9329 HIDSender Python Script with Color Picker Modification
#  Operation Process:
#  Hardware Platform: TomatoCube 6-Key Macro-KeyPad with MachXO2 FPGA
#  Copyright Statement: This code is an IP of TomatoCube and can only for non-profit or
#                       educational exchange.
# ---------------------------Related Information of Modified Files------------------------
#  Modifier: Percy Chen
#  Modification Date: 31st August 2024       
#  Modification Content:
# ******************************************************************************************

from tkinter import *
from tkinter import ttk
from tkcolorpicker import askcolor

# import threading
import hid as HID

root = Tk()
root.title("TomatoCube HID-CH9329 Sender")
root.geometry("465x220")

# devs = hid.enumerate()
device = HID.device()
devFound = ""

redVal = "2F"
greenVal = "10"
blueVal = "00"
send_var=StringVar(root, "08 07 DE AD BE EF 2F 10 00")

# send_var=StringVar()

def openHID():
    global devFound
    if devFound != "":
        # device.open(0x1a86,0xe129)
        device.open_path(devFound)
        connResult.config(text="- Connected -")
    else:
        print("No Device Found")


     
def scanHID():
    global devFound
    devs = HID.enumerate()
    for d in devs:
        str = f"{d['manufacturer_string']} {d['product_string']}  vid/pid:{d['vendor_id']}/{d['product_id']} usage:{d['usage_page']}/{d['usage']} "
        if (d['vendor_id'] == 0x1a86) and (d['usage_page'] > 100):
            print(str)
            devFound=d['path']
            return d['product_string']
    return 0

def closeHID():
    device.close()
    connResult.config(text="---")

def sendHID():
    # device.write(bytearray([0x12, 0x34, 0x56, 0xAB, 0xCD]))
    print(type(sendEntry.get()))
    bytes_result = bytearray.fromhex(sendEntry.get())
    print(type(bytes_result))
    print("".join([f"\\x{u:02x}" for u in bytes_result]))
    device.write(bytearray.fromhex(sendEntry.get()))

def chooseColor():
    global redVal
    global greenVal
    global blueVal
    # variable to store hexadecimal code of color
    color_code = askcolor((int(redVal, 16),int(greenVal, 16),int(blueVal, 16)), title ="Choose color") 
    print (color_code[1])
    if color_code[1] is not None:
        chosenColor.config(text=str("Selected Color: " + color_code[1] ))
        redVal = color_code[1][1:3]
        greenVal = color_code[1][3:5]
        blueVal = color_code[1][5:7]
        print("red: " + redVal + "\n" + "green: " + greenVal + "\n" "blue: " + blueVal)
        send_var.set("08 07 DE AD BE EF " + redVal + " " + greenVal + " " + blueVal)

# def timer1():
#     t = threading.Timer(1.0, timer1)
#     t.start()

#     try:
#         device.read(0)
#     except ValueError:
#         print ("Not Connected")

def scanCallBack():
    deviceStrFound = scanHID()
    scanResult.config(text="None")
    if deviceStrFound != 0:
        # msg=messagebox.showinfo( "Device Found", "Found: " + deviceStrFound)
        scanResult.config(text=str(deviceStrFound))
   
scanButton = ttk.Button(root, text ="Rescan", width=10 , command = scanCallBack)
scanButton.place(x=50,y=20)

scanResult = ttk.Label(root, text="None")
scanResult.place(x=200,y=25)

connButton = ttk.Button(root, text ="Connect", width=10 , command = openHID)
connButton.place(x=50,y=50)

connResult = ttk.Label(root, text="---")
connResult.place(x=200,y=55)

disconnButton = ttk.Button(root, text ="Disconnect", width=10 , command = closeHID)
disconnButton.place(x=50,y=80)


sendButton = ttk.Button(root, text ="Send HID", width=10 , command = sendHID)
sendButton.place(x=50,y=120)

sendEntry = ttk.Entry(root, textvariable=send_var, width=23)
sendEntry.place(x=200, y=120)


chosenColor = ttk.Label(root, text="Selected Color: None")
chosenColor.place(x=200,y=165)

choose_button = ttk.Button(root, text="Choose Color", width=10 , command=chooseColor)
choose_button.place(x=50,y=160)

 
# timer1()
root.mainloop()

# if __name__ == '__main__':
#     sys.exit(exit_code)
