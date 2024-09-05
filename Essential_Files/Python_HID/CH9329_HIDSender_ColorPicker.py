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
# import colorsys

# import threading
import hid as HID

root = Tk()
root.title("TomatoCube HID-CH9329 Color Sender")
root.geometry("465x260")

# devs = hid.enumerate()
device = HID.device()
devFound = ""

redVal = "2F"
greenVal = "10"
blueVal = "00"
send_var=StringVar(root, "08 07 DE AD BE EF 2F 10 00")
brightness_value = IntVar(root,100)

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
        print("Brightness %: " + str(brightness_value.get()))
        updateSendHIDValue()

def slider_changed(event):  
    # print(brightness_slider.get())
    chosenBrightness.config(text=str("Brightness [" + str(int(round(brightness_slider.get()))) + "] %: "))
    updateSendHIDValue()

def updateSendHIDValue():
    (redVal_adj,greenVal_adj,blueVal_adj) = adjust_brightness(int(redVal, 16),int(greenVal, 16),int(blueVal, 16),(brightness_value.get()/100))
    send_var.set("08 07 DE AD BE EF " + format(redVal_adj,'02X') + " " + format(greenVal_adj,'02X') + " " + format(blueVal_adj,'02X'))

def adjust_brightness(r, g, b, brightness):
    # Ensure the brightness factor is between 0.0 and 1.0
    brightness = max(0.0, min(1.0, brightness))
    
    # Adjust the RGB values by the brightness factor
    r_new = int(r * brightness)
    g_new = int(g * brightness)
    b_new = int(b * brightness)
    
    # Ensure values are clamped to the 0-255 range
    r_new = max(0, min(255, r_new))
    g_new = max(0, min(255, g_new))
    b_new = max(0, min(255, b_new))
    
    return r_new, g_new, b_new

# def adjust_brightness_hsv(r, g, b, brightness_factor):
#     # Convert RGB (0-255 range) to HSV (0.0-1.0 range)
#     r_norm, g_norm, b_norm = r / 255.0, g / 255.0, b / 255.0
#     h, s, v = colorsys.rgb_to_hsv(r_norm, g_norm, b_norm)
#    
#     # Adjust the brightness (value)
#     v_new = max(0.0, min(1.0, v * brightness_factor))
#    
#     # Convert back to RGB
#     r_new, g_new, b_new = colorsys.hsv_to_rgb(h, s, v_new)
#    
#     # Convert RGB values back to 0-255 range
#     return int(r_new * 255), int(g_new * 255), int(b_new * 255)


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


chosenColor = ttk.Label(root, text="Selected Color: #" + redVal + greenVal + blueVal)
chosenColor.place(x=200,y=165)

choose_button = ttk.Button(root, text="Choose Color", width=10 , command=chooseColor)
choose_button.place(x=50,y=160)

chosenBrightness = ttk.Label(root, text="Brightness %: ")
chosenBrightness.place(x=200,y=200)

brightness_slider = ttk.Scale(root, from_=0, to=100, orient='horizontal', command=slider_changed, variable=brightness_value)
brightness_slider.place(x=325,y=200)
 
# timer1()
root.mainloop()

# if __name__ == '__main__':
#     sys.exit(exit_code)
