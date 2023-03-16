# WISmobDeviceLib 
- by Andreas Bergendal - WhenInSpace AB

The handlers in this library help identifying the iPhone/iPad model by using the LC 9.6.3+ function iphoneDeviceModel()
This function only gives the device code, which in itself tells nothing about the device. 
The code has to be mapped to data about the device, which LC does not do.
The library holds data in the script concerning which models need extra margins in the UI,
due to camera "notch" at the top and/or no physical button at the bottom.
The library currently also connects to an external data source that has additional info on the device name (a list too long to include in a script):
"https://github.com/wheninspace/WISmobDeviceLib/raw/main/WISmobDeviceLibData.lson" -- You may fetch this data and store it in a cProp in your app if you prefer (use arrayDecode to make it usable).
