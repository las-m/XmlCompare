from xmlExtract import extractDataFromXML
from constructIdealSignal import *
from copy import deepcopy
from scipy.io import savemat
import sys
import re
from testIfDigital import testIfDigital



#This function generates the ideal signal based on the information saved in the control file.
#The function first extracts all the data from the xml-tree and then builds a numerical list of the ideal course of the relevant channels. This data gets saved in a .mat-file, which then can be read by Matlab.
#@param ctrFileName:    Name of the control file, including it's path. All the "\" must be replaced by "\\" so Python can read it.
#@param dataFileName:   Name of the data file, including it's path. Into this file the ideal signals get saved. All the "\"  in the path must be replaced by "\\" so Python can read it. The filename also must end with ".mat"
#@param relevantChannels:   List of the names of the relevant channels. As only a few channels get recoreded, also only these channels get reconstructed.
#TODO: Replace these default values for something that makes sense on the machine the code is running on
def generateIdealSignal(ctrFileName, dataFileName, varFileName, timingFileName):
    
    
    #Extract data from the control-file.
    #in der Liste kommen erst Variablen, dann Timing, dann Events
    dataList = extractDataFromXML(ctrFileName) #The filename needs to be valid, there is no security implemented here!
    vars = dataList[0]
    timing = dataList[1]
    events = dataList[2]
    keys = []
    newKey = ""
    for key in events:
        keys.append(key)

    relevantChannelNames = keys    
    #Create a dictionary with the relevant channels only.
    #We will later only replace the timestamps for the relevant channels, the rest is not interessting and would just take time.
    relevantEvents = {}
    notFound = []
    for chanName in relevantChannelNames:
        try:
            #use deepcopy for copying the list. Otherwise the original list will later be changed too.
            relevantEvents[chanName] = deepcopy(events[chanName])
        except KeyError:
            notFound.append(chanName)
    for chan in notFound:
        relevantChannelNames.remove(chan)

    #Replace the timestamp variables by the real times, rounded to milliseconds
    for chan in relevantEvents:
        eventList = relevantEvents[chan]
        for i in range(len(eventList)):
            timeStamp = timing[eventList[i][0]]
            eventList[i][0] = round(timeStamp,  3)
    #Assume the channel is analog
    isDigital = 0
    #construct the ideal signals of the relevant channels
    idealSignal = {}
    for chan in relevantChannelNames:
        #Some characters are not allowed as struct fieldnames in MatLab
        name =  re.sub(r"/","_slash_",chan)
        name =  re.sub(r"\s","_",name)
        name =  re.sub(r"\+","_plus_",name)
        name =  re.sub(r"\-","_minus_",name)
        #If relevantEvents[chan][1] is not a string, I assume that the channel is digital.
        #Test if the channel is digital. If it is add _Digital to the end of the name, so the user knows that the array data means on/off
        isDigital = testIfDigital(relevantEvents[chan])
        if isDigital == 1:
            name = name + "_Digital" 
            #Matlab cant handle variables starting with a numerical value, so i only allow variables starting with a letter.
            #If the name doesnt start with a letter, i put a "renamed_" in front of it, eg "renamed_2cakes" instead of "2cakes"
        if chan[0].isalpha():   
            idealSignal[name] = constructIdealSignal(relevantEvents[chan],  vars,  timing)
                
        else:
            name = "renamed_" + name 
            idealSignal[name] = constructIdealSignal(relevantEvents[chan],  vars,  timing)

    #Add the cycleduration to the vars dictionary.
    vars["Cycleduration"]=timing["end"]
    #save the data into .mat-Files.   
    savemat(dataFileName, idealSignal, long_field_names=True, do_compression=True) #scipy.io.savemat
    savemat(varFileName, vars) #scipy.io.savemat

#----------------------------------------------------------------------------------------------------------------------------------------------
if __name__ == '__main__':
    generateIdealSignal(sys.argv[1],  sys.argv[2],  sys.argv[3], sys.argv[4])
    sys.exit(0)

