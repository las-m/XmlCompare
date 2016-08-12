import re
import sys


#Tests if a channel is digital.
#This method needs a list containing the event-information for this channel
#@Return:   true(1)/false(0) 
def testIfDigital(eventList):

    #I need this array to test if every event of the channel gives the same result
    #concerning the question if the channel is digital/not digital
    consistencyTest = []       
    #Try Block in case if a nameerror
    try:
        #Go through all events for this channel
        for index in range(len(eventList)):
            #Formula is passed as a string which is usually in eventList[index][1].
            #If there is no formula I assume the channel is Digital
            if isinstance(eventList[index][1], str):
                isDigital = 0
            else:
                isDigital = 1
                
                
        #Check if the different events give an consistent result.
        #If not they do not return -1 as error value. This needs to be handled in generareIdealSignal.py
        consistencyTest.append(isDigital)
        for i in range(len(consistencyTest)-1):
            if consistencyTest[1] != consistencyTest[i]:
                isDigital = -1
                
    
    
    #Handle a NameError. In case of a NameError return error value 
    except NameError:
        isDigital = -1

    return isDigital
