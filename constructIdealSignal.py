from math import exp,  cos,  pi,  log
from expConFunctions import *
import re
import sys


#Identify ln with log. The ctr-file uses "ln()" as natural logarithm, but python uses "log()". 
#I dont wanna replace it in the formula text in case this letter combination occurs accidentally in a name.
def ln(arg):
    return log(arg)


#Constructs the ideal signal for one channel.
#This method needs a list containing the event-information for this channel, a dictionary with the variables and a dictionary with the timing values.
#@Return:   list with the ideal course of the signal.
def constructIdealSignal(eventList, vars, timing):
    #Get the cycle length
    cycleEndIndex = round(timing["end"]*1000)
    #Create an empty list with the length of the cycle
    idealSignal = [0]*(cycleEndIndex)
    #load all the variables and timings into the namespace so the program knows them and their values
    locals().update(vars)
    locals().update(timing)
           
    #Try-block in case a variable is unknown. If one variable is unknown, a list only containing zeros will be returned.
    try:
        #Go through all events for this channel
        for index in range(len(eventList)):
            #Formula is passed as a string. Only do something if there is a formula. Otherwise assume the channel is digital
            if isinstance(eventList[index][1], str):
                #if there is an if-condition in the Experiment-Control-syntax, one needs to rewrite it.
                if eventList[index][1][0:2] == "if":                
                    #split the text in parts
                    parts = re.split(";",  eventList[index][1])
                    #Since in functions the arguments are seperated by ; as well, not only the conditions and the associated formulas, we need to rebuild the formulas.
                    #But since there can be more than one condition first we need to figure out which one is satisfied.
                    i=0 #initialize some loop variables
                    j = 0
                    length = len(parts) 
                    temp = ""
                    conditionPositions = []
                    k = 0
                    #This loop gives the positions of the the conditions, i.e. the if statements in the array with the text parts
                    while j < length:
                        if re.sub(r'\s+' , '', parts[j])[0:2] == "if":
                            conditionPositions.append(j)
                        j = j+1
                     
                    #Gives the number of if statements in the original string
                    numberOfIf = len(conditionPositions)
                    #This loop tests which of the conditions is satisfied. I assume here that only one condition can be satisfied at once. Then it rebuilds the formula that is supposed to be evaluated
                    #if the conditions is satisfied.
                    while k < numberOfIf:
                        condition = re.sub(r'\s+' , '', parts[conditionPositions[k]])[3:].replace("=","==") #ignore "if(" at the beginning & replace the "=" with "==" to make it work with the python syntax
                        if eval(condition):
                            i = conditionPositions[k] +1
                            while not (re.sub(r'\s+' , '', parts[i+1])[0:2] == "if" or i >= length-2):
                                temp = temp + parts[i] + "," 
                                i += 1
                        
                            temp = temp + parts[i]
                        
                        k += 1

                    #Assign the formula that is supposed to be evaluated back to the eventList array..
                    eventList[index][1] = temp
                    
                #Python works with "**" instead of "^" as notation for "to the power of"
                eventList[index][1] = eventList[index][1].replace("^",  "**")
                #Python also wants arguments to be separated by "," and not ";"
                eventList[index][1] = eventList[index][1].replace(";",  ", ")

                #Get the time the event starts
                eventStartIndex = round(eventList[index][0]*1000)
                #Get the time where the next event happens or the cycle is over.
                if index < (len(eventList)-1):
                    eventEndIndex = round(eventList[index+1][0]*1000)
                else:
                    eventEndIndex = cycleEndIndex
            
                #In case of a time-dependent formula:
                if eventList[index][2]:
                    for i in range(eventStartIndex,  eventEndIndex):
                        t = i/1000 #t is for time in milliseconds, needs to be in the namespace here!
                        idealSignal[i] = eval(eventList[index][1])
                #In case of a time-independent formula:
                else:
                    value = eval(eventList[index][1])
                    for i in range(eventStartIndex,  eventEndIndex):
                        idealSignal[i] = value
            #I assume if there is no formula that the channel is digital. Digital channeles are on(1) or off(0) for certain times.
            else:
                #Get the time the event starts
                eventStartIndex = round(eventList[index][0]*1000)
                #Get the time where the next event happens or the cycle is over.
                if index < (len(eventList)-1):      
                    eventEndIndex = round(eventList[index+1][0]*1000)
                else:
                    eventEndIndex = cycleEndIndex
                #Put 1 as ideal signal value, if the channel is on (in this case eventList[index][1] == 1), otherwise put a zero (in this case eventList[index][1] == 0)
                for i in range(eventStartIndex,  eventEndIndex):
                    idealSignal[i] = eventList[index][1]

    
    #Handle a NameError
    except NameError:
        #In case of a nameerror assign a 0-array.
        idealSignal = [0]*cycleEndIndex



    #Return the array with the ideal signal
    return idealSignal
