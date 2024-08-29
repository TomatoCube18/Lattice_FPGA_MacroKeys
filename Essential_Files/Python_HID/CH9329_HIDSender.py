from tkinter import *
from tkinter import ttk
from tkinter import messagebox

# import threading
import hid as HID

root = Tk()
root.title("TomatoCube HID-CH9329 Sender")
root.geometry("450x200")


# send_data = [0] * 65

# devs = hid.enumerate()
device = HID.device()
devFound = ""

send_var=StringVar(root, "04 DE AD BE EF")


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

sendEntry = ttk.Entry(root, textvariable=send_var)
sendEntry.place(x=200, y=120)



 
# timer1()
root.mainloop()

# if __name__ == '__main__':
#     sys.exit(exit_code)
