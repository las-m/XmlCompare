from xml.dom import minidom, Node


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Reads a XML-Control-File and returns the Control-Node.
def einlesen(dateiname):
    root = minidom.parse(dateiname)
    control = root.childNodes[0]
    
    return control


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Parses a "low level node", ie a node only containing a name and a numerical value.
def parse_lowLevelNode(node,  daten):
    nameNode,  valueNode = None,  None
    for child in node.childNodes:
        if child.nodeType is not Node.ELEMENT_NODE: continue
        if child.tagName == "name":
            assert not nameNode
            nameNode = child
        elif child.tagName == "value":
            assert not valueNode
            valueNode = child
    
    #Extract the data froom the nodes
    name = nameNode.childNodes[0].data
    name = name.lower() #make everything case-insensitive
    text = valueNode.childNodes[0].data
    wert = float(text)
    
    #write the data into the dictionary
    daten[name] = wert

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Helperfunction for parsing the timing information.
#Timingedges can contain other timingedges, therefore one needs to find the lowest level, 
def parse_timing(timingNode,  daten):
    for edgeNode in timingNode.childNodes:
        if edgeNode.nodeType is Node.ELEMENT_NODE and edgeNode.tagName == "timingedge":
            edgeType = edgeNode.getAttribute("type") 
            if edgeType == "group":
                #When the edge is a group of timings, the function calls itself again to go into this deeper group.
                parse_timing(edgeNode,  daten)
            elif edgeType == "event":
                parse_lowLevelNode(edgeNode,  daten)

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Reads the timing values into a dictionary. Needs the ControlNode to work.
def timingEinlesen(controlNode):
    daten = {}
    timingNode = controlNode.getElementsByTagName("timing")[0] #Find the right Node to search in.
    parse_timing(timingNode,  daten)
    return daten

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Helperfunction for extracting data from a digital event
def eventHelpFuncDigital(eventNode,  daten):
    #Get all the relevant single nodes to channel, timing and so on
    channelNode,  edgeNode,  timingNode = None,  None,  None
    for child in eventNode.childNodes:
        if child.nodeType is not Node.ELEMENT_NODE: continue
        if child.tagName == "edge":
            assert not edgeNode
            edgeNode = child
        elif child.tagName == "channel":
            assert not channelNode
            channelNode = child
        elif child.tagName == "timing":
            assert not timingNode
            timingNode = child
    
    #Extract the data from the nodes.
    channel = channelNode.childNodes[0].data
    channel = channel.lower()
    timing = timingNode.childNodes[0].data
    timing = timing.lower()
    edgeText = edgeNode.childNodes[0].data #numerical, no lower() needed
    edge = float(edgeText)
    
    #Add the new information to the dictionary. Dont overwrite information for this channel that has been in there before.
    if channel in daten:
        temp = daten[channel]
        temp.append([timing,  edge])
        daten[channel] = temp
    else:
        daten[channel] = [[timing, edge]]

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Helperfunction for extracting data from an anolog event
def eventHelpFuncAnalog(eventNode,  daten):
    #Get all the relevant single nodes to channel, timing and so on
    channelNode,  timingNode,  formulaNode, timeDepNode = None,  None,  None,  None
    for child in eventNode.childNodes:
        if child.nodeType is not Node.ELEMENT_NODE: continue
        if child.tagName == "channel":
            assert not channelNode
            channelNode = child
        elif child.tagName == "timing":
            assert not timingNode
            timingNode = child
        elif child.tagName == "formula":
            assert not formulaNode
            formulaNode = child
        elif child.tagName == "timedependent":
            assert not timeDepNode
            timeDepNode = child
    
    #Extract the data from the nodes.
    channel = channelNode.childNodes[0].data
    channel = channel.lower()
    formula = formulaNode.childNodes[0].data
    formula = formula.lower()
    timing = timingNode.childNodes[0].data
    timing = timing.lower()
    timeDepText = timeDepNode.childNodes[0].data #numerical, no lower() needed
    timeDep = float(timeDepText)
    
    #Add the new information to the dictionary. Dont overwrite information for this channel that has been in there before.
    if channel in daten:
        temp = daten[channel]
        temp.append([timing,  formula,  timeDep])
        daten[channel] = temp
    else:
        daten[channel] = [[timing, formula, timeDep]]


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Reads the variables into a dictionary. Needs the ControlNode to work.
def variablenEinlesen(controlNode):
    daten = {}
    variablenNode = controlNode.getElementsByTagName("variables")[0] #Find the right Node to search in.
    for varNode in variablenNode.childNodes:
        #Skip all the nodes consisting of linebreaks
        if varNode.nodeType is Node.ELEMENT_NODE:
            parse_lowLevelNode(varNode,  daten)
    return daten

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Reads the event-data into a dictionary. Needs the controlNode to work.
def eventsEinlesen(controlNode):
    daten = {}
    eventsNode = controlNode.getElementsByTagName("events")[0]
    for eventNode in eventsNode.childNodes:
        #Check the node is empty or really contains an element
        if eventNode.nodeType is Node.ELEMENT_NODE:
            eventType = eventNode.getAttribute("type")
            if eventType == "output-digital":
                eventHelpFuncDigital(eventNode,  daten)
            elif eventType == "output-analog-formula":
                eventHelpFuncAnalog(eventNode,  daten)
    
    return daten



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#This is the most function that does all the small stuff for you. 
#It takes the xml-filename as a parameter. Default is "xmlFormatted.ctr" (just for convenience while developing).
#Returns a list of three dictionaries: the first one contains the variables, the second one the timings and the third one the event information.
#TODO: Take care of a wrong filename,  raise exception or so
def extractDataFromXML(filename):
    controlNode = einlesen(filename)
    datenVar = variablenEinlesen(controlNode)
    datenTime = timingEinlesen(controlNode)
    datenEve = eventsEinlesen(controlNode)
    dataList = [datenVar,  datenTime,  datenEve]
    return dataList

