script "WISmobDeviceLib"
##############################################################################################################################################
# WISmobDeviceLib - by Andreas Bergendal - WhenInSpace AB - Updated 2023-09-30
#
# The handlers in this library help identifying the iPhone/iPad model by using the LC 9.6.3+ function iphoneDeviceModel()
# This function only gives the device code, which in itself tells nothing about the device. 
# The code has to be mapped to data about the device, which LC does not do.
# The library holds data in the script concerning which models need extra margins in the UI,
# due to camera "notch" at the top and/or no physical button at the bottom.
# The library currently also connects to an external data source that has additional info on the device name (a list too long to include in a script):
# "https://github.com/wheninspace/WISmobDeviceLib/raw/main/WISmobDeviceLibData.lson" -- You may fetch this data and store it in a cProp in your app if you prefer.
##############################################################################################################################################

### WISgetMobileMarginData ###
## This function is the only thing you need if all you want is to know the margins needed to calculate the "safe area" for your UI
## The function can be copied to your stack, so you don't even need to use it as a library. It needs no external data source.

function WISgetMobileMarginData pDeviceCode ## Parameter optional, normally just used to test the function in the IDE, where iphoneDeviceModel() does not work
   ## The "Lookup tables" - Updated 4 Oct 2021 - This needs to be updated when Apple releases new models
   ## You can also put these constants as an array in a cProp of your stack, and modify the script accordingly, to shorten it
   constant kIphone44= "10,3 10,6 11,2 11,4 11,6 12,3 12,5"
   constant kIphone47= "13,2 13,3 13,4 14,2 14,3 14,5 14,7 14,8"
   constant kIphone48= "11,8 12,1"
   constant kIphone50= "13,1 14,4"
   constant kIphone59= "15,2 15,3 15,4 15,5 16,1 16,2"
   constant kIpad20=   "8 13 14"
   local tReturn,tCode
   
   ## This requires LC 9.6.3 or later
   if pDeviceCode is empty then put iphoneDeviceModel() into pDeviceCode
   
   ## Default value, modified below for relevant device models
   put 0 into tReturn["notchMargin"]
   put 0 into tReturn["portraitBottomMargin"]
   put 0 into tReturn["landscapeBottomMargin"]
   
   ### Case iPad ###
   if pDeviceCode begins with "iPad" then
      put char 5 to 6 of pDeviceCode into tCode
      replace comma with empty in tCode
      if tCode is among the words of kIpad20 then ## These models have no physical button at the bottom, so a margin is needed for UI elements
         put 20 into tReturn["portraitBottomMargin"]
         put 20 into tReturn["landscapeBottomMargin"]
      end if
      return tReturn
   end if
   
   ### Case iPhone ###
   replace "iPhone" with empty in pDeviceCode ## Since we already know it's not an iPad, we remove the iPhone prefix for easier handling
   
   ## Default values, modified below for relevant device models
   put 34 into tReturn["portraitBottomMargin"]
   put 21 into tReturn["landscapeBottomMargin"]
   
   switch 
      case pDeviceCode is among the words of kIphone44
         put 44 into tReturn["notchMargin"]
         break
      case pDeviceCode is among the words of kIphone47
         put 47 into tReturn["notchMargin"]
         break
      case pDeviceCode is among the words of kIphone48
         put 48 into tReturn["notchMargin"]
         break
      case pDeviceCode is among the words of kIphone50
         put 50 into tReturn["notchMargin"]
         break
      case pDeviceCode is among the words of kIphone59
         put 59 into tReturn["notchMargin"]
         break
      default
         ## The model has no notch and thus needs no extra margins
         put 0 into tReturn["notchMargin"]
         put 0 into tReturn["portraitBottomMargin"]
         put 0 into tReturn["landscapeBottomMargin"]
   end switch
   
   return tReturn
end WISgetMobileMarginData

##############################################################################################################################################

### WISgetMobDeviceData ###
## These functions check an extended lookup table, stored externally, that also gives the device name.

local sMobDeviceDataA

function WISgetMobDeviceData pDeviceCode
   if pDeviceCode is empty then put getCurrentDeviceCode() into pDeviceCode
   
   if sMobDeviceDataA is not an array then 
      WISupdateSourceData
      if the result is not empty then ## Something went wrong when updating the data source
         answer the result
         return "unknown"
      end if
   end if
   
   if pDeviceCode is among the keys of sMobDeviceDataA then return sMobDeviceDataA[pDeviceCode]
   if pDeviceCode is "all" then return sMobDeviceDataA ## Return the entire array of all iOS devices
   if pDeviceCode is not among the keys of sMobDeviceDataA then return "unknown"
end WISgetMobDeviceData

command WISupdateSourceData
   local tSourceDataA,tDataA
   
   put URL "https://github.com/wheninspace/WISmobDeviceLib/raw/main/WISmobDeviceLibData.lson" into tDataA
   put arrayDecode(tDataA) into tSourceDataA ## Change to your own method if you prefer
   
   if tSourceDataA is not an array then return "No source data available" for error
   
   put tSourceDataA into sMobDeviceDataA
end WISupdateSourceData 

function getCurrentDeviceCode
   ## Just wraps iphoneDeviceModel() in a try structure to prevent an error when used in non-mobile environment
   local tDeviceCode
   
   try
      put iphoneDeviceModel() into tDeviceCode
   catch tError ## Error may be: not an iOS device, or LC engine < 9.6.3
      return "Probably not an iOS device"
   end try
   
   return tDeviceCode
end getCurrentDeviceCode
