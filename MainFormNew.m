function varargout = MainFormNew(varargin)
% MAINFORMNEW MATLAB code for MainFormNew.fig
%      MAINFORMNEW, by itself, creates a new MAINFORMNEW or raises the existing
%      singleton*.
%
%      H = MAINFORMNEW returns the handle to a new MAINFORMNEW or the handle to
%      the existing singleton*.
%
%      MAINFORMNEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINFORMNEW.M with the given input arguments.
%
%      MAINFORMNEW('Property','Value',...) creates a new MAINFORMNEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MainFormNew_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MainFormNew_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MainFormNew

% Last Modified by GUIDE v2.5 15-Aug-2016 13:47:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MainFormNew_OpeningFcn, ...
                   'gui_OutputFcn',  @MainFormNew_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before MainForm is made visible.
%Load the configuration files and display config data on GHU
function MainFormNew_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MainForm (see VARARGIN)

% Choose default command line output for MainForm
handles.output = hObject;    


%Load the stored paths to the xml files to compare (from the last session)
try
    xmlPath = loadXmlSettings();
catch
    warndlg('Could not load xml settings')
    xmlPath = cell(2);
    xmlPath{1} = '';
    xmlPath{2} = '';
end

%Display the chosen xml files in gui
handles.xml1pathBox.String = xmlPath{1};
handles.xml2pathBox.String = xmlPath{2};

%Create preferences if they do not exist already to get the path to the xml
%files. I just look for the last '\' in the path string and cut it and
%everything after it off. Idk if this could lead to problems.
try
    path1 = xmlPath{1};
    index1 = strfind(xmlPath{1},'\');
    index1 = index1(end);
    relevantPart1 = path1(1:index1-1);
    path2 = xmlPath{2};
    index2 = strfind(xmlPath{2},'\');
    index2 = index2(end);
    relevantPart2 = path2(1:index2-1);
catch
    warndlg('It seems like one xml path is inaccurate.')
    relevantPart1 = '';
    relevantPart2 = '';
end

%If the preferences for storage of xml1 path name and xml2 path name do not
%exist create them (The preferences do not expire after the specific matlab
%session or the program run)
if ~ispref('XmlPath','Xml1')
    addpref('XmlPath','Xml1','');
end
if ~ispref('XmlPath','Xml2')
    addpref('XmlPath','Xml2','');
end

%Set the preferences
setpref('XmlPath','Xml1',relevantPart1); 
setpref('XmlPath','Xml2',relevantPart2);

%Try to get the variable and channel Data from the xmls gets saved as 
%.mat files. To get the data python modules are used.
try 
    getDataFromXml(xmlPath);
catch
    warndlg('Was not able to retrieve data from the xml files.')
end

%Reduce the number of channels in the .mat file saved by the python modules
%to those channels that appear in both xmls. I only need the data of
%those because only the data of these channels can be compared 
[onlyIn1, onlyIn2] = reduceFiles();

%Generate the file with the preferences for plotting
generateConfig();

%Test if the cycletime of the ctr files is the same. If not throw warning
%that the data arrays of the channels assocoated woth the ctr with the 
%shorter cycle time get extended to fit the size of the arrays of the other 
%ctr.
if isCycleTimeDifferent()
    warndlg('The cycledurations for the xml files differ. The channel data associated with the xml with the shorter cycle duration gets padded with zeros till the arrays have the same length')
end

%Initialize objects of the class channels representing the channels that
%appear in both xmls
handles = initializeChannels(handles);

%Save the diverging channels in the handles structure
handles = getDivergentChannels(handles);

%Display all the channels with divergent data a the listbox
set(handles.divChanListbox, 'string',handles.divchan);

%Populate a uitable with the names of the variables that appear in bot xmls
%and their values
[varsOnlyIn1, varsOnlyIn2] = setDivVarsTable(handles);

%Disable the buttons to display the variables and channels that only appear
%in one of the xmls if there are no such variables or channels,
%to have a graphical indicator if such variables/channels exist. 
%Otherwise enable, in case it was disabled before
if numel(onlyIn1) == 0 && numel(onlyIn2) == 0
    set(handles.notCompareableChannelButton,'Enable','off') 
else
    set(handles.notCompareableChannelButton,'Enable','on') 
end
if numel(varsOnlyIn1) == 0 && numel(varsOnlyIn2) == 0
    set(handles.showNotCompVarsButton,'Enable','off') 
else
    set(handles.showNotCompVarsButton,'Enable','on') 
end

%Remember in handles structure which channels and variables only exist in
%one of the ctr files
handles.onlyIn1 = onlyIn1;
handles.onlyIn2 = onlyIn2;
handles.varsOnlyIn1 = varsOnlyIn1;
handles.varsOnlyIn2 = varsOnlyIn2;

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = MainFormNew_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in chooseXml1Button.
function chooseXml1Button_Callback(hObject, eventdata, handles)
% hObject    handle to chooseXml1Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get the current xml path from the preferences
currentPath = getpref('XmlPath','Xml1');

%If currentPath is not a string an error occurs when the uigetfile function
%is called. Therefore just assign the empty string. In this case the
%starting directory is the current one.
if ~ischar(currentPath)
    currentPath = '';
end
%Get name and path of the file
[FileName, PathName] = uigetfile({'*.xml;*.ctr','XML File (*.xml,*.ctr)';'*.*','All files (*.*)'},'Choose a file',currentPath);

%Update the preferences with the new xml path
setpref('XmlPath','Xml1',PathName(1:end-1));

%Show chosen file in GUI
if PathName
    handles.xml1pathBox.String = [PathName FileName];
    xml1 = handles.xml1pathBox.String;
    xml2 = handles.xml2pathBox.String;
    
    %Save the xml file settings in config xml
    save('xmlsettingsconfig','xml1','xml2')
end

%Reset all the GUI stuff because the xml possibly changed.
handles.Legend = legend('none');
set(handles.Legend,'Visible','Off');
handles = resetPlots(handles);
handles.channels = cell(0);
set(handles.divChanListbox, 'string','');

%Get the new paths to the xmls
xmlPath = loadXmlSettings();

%Call the python modules to extract the data from the xml files. If it
%fails notify the user
try
    %The variable and channel Data from the xmls gets saved as .mat files. 
    getDataFromXml(xmlPath);
catch
    warndlg('Was not able to retrieve data from the xml files.')
end

%Analogous to the functions called on opening the form
[onlyIn1, onlyIn2]= reduceFiles();
generateConfig();
if isCycleTimeDifferent()
    warndlg('The cycledurations for the xml files differ. The channel data associated with the xml with the shorter cycle duration gets padded with zeros till the arrays have the same length')
end
handles = initializeChannels(handles);
handles = getDivergentChannels(handles);

%Set value of listbox showing the divergent channels to one in case there
%are less divergent channels compared to the old xml
handles.divChanListbox.Value = 1;
%Populate the listbox with the divergent channels
set(handles.divChanListbox, 'string',handles.divchan);

%Process the variables and disable/enable the press buttons
%analogous to the opening function
[varsOnlyIn1, varsOnlyIn2] = setDivVarsTable(handles);

if numel(onlyIn1) == 0 && numel(onlyIn2) == 0
    set(handles.notCompareableChannelButton,'Enable','off') 
else
    set(handles.notCompareableChannelButton,'Enable','on') 
end
if numel(varsOnlyIn1) == 0 && numel(varsOnlyIn2) == 0
    set(handles.showNotCompVarsButton,'Enable','off') 
else
    set(handles.showNotCompVarsButton,'Enable','on') 
end

handles.onlyIn1 = onlyIn1;
handles.onlyIn2 = onlyIn2;
handles.varsOnlyIn1 = varsOnlyIn1;
handles.varsOnlyIn2 = varsOnlyIn2;

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Similar to the callback fo chooseXml1Button
% --- Executes on button press in chooseXml2Button.
function chooseXml2Button_Callback(hObject, eventdata, handles)
% hObject    handle to chooseXml2Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get the current xml path from the preferences
currentPath = getpref('XmlPath','Xml2');

%If currentPath is not a string an error occurs when the uigetfile function
%is called. Therefore just assign the empty string. In this case the
%starting directory is the current one.
if ~ischar(currentPath)
    currentPath = '';
end

%Set name of and path to the file
[FileName, PathName] = uigetfile({'*.xml;*.ctr','XML File (*.xml,*.ctr)';'*.*','All files (*.*)'},'Choose a file',currentPath);

%Update the preferences
setpref('XmlPath','Xml2',PathName(1:end-1));

%Show chosen file in GUI
if PathName
    handles.xml2pathBox.String = [PathName FileName];
    xml1 = handles.xml1pathBox.String;
    xml2 = handles.xml2pathBox.String;
    
    %Save the xml file settings in config xml
    save('xmlsettingsconfig','xml1','xml2')
end

%Reset all the GUI stuff because the xml possibly changed. 
handles.Legend = legend('none');
set(handles.Legend,'Visible','Off');
handles = resetPlots(handles);
handles.channels = cell(0);
set(handles.divChanListbox, 'string','');


xmlPath = loadXmlSettings();
%Call the python modules to extract the data from the xml files. If it
%fails notify the user
try
    %The variable and channel Data from the xmls gets saved as .mat files.
    getDataFromXml(xmlPath);
catch
    warndlg('Was not able to retrieve data from the xml files.')
end

%Analogous to the functions called on opening the form
[onlyIn1, onlyIn2] = reduceFiles();
generateConfig();
if isCycleTimeDifferent()
    warndlg('The cycledurations for the xml files differ. The channel data associated with the xml with the shorter cycle duration gets padded with zeros till the arrays have the same length')
end
handles = initializeChannels(handles);
handles = getDivergentChannels(handles);

%Set value of listbox showing the divergent channels to one in case there
%are less divergent channels compared to the old xml
handles.divChanListbox.Value = 1;
%Populate the listbox with the divergent channels
set(handles.divChanListbox, 'string',handles.divchan);


%Process the variables and disable/enable the press buttons
%analogous to the opening function
[varsOnlyIn1, varsOnlyIn2] = setDivVarsTable(handles);

if numel(onlyIn1) == 0 && numel(onlyIn2) == 0
    set(handles.notCompareableChannelButton,'Enable','off') 
else
    set(handles.notCompareableChannelButton,'Enable','on') 
end
if numel(varsOnlyIn1) == 0 && numel(varsOnlyIn2) == 0
    set(handles.showNotCompVarsButton,'Enable','off') 
else
    set(handles.showNotCompVarsButton,'Enable','on') 
end

handles.onlyIn1 = onlyIn1;
handles.onlyIn2 = onlyIn2;
handles.varsOnlyIn1 = varsOnlyIn1;
handles.varsOnlyIn2 = varsOnlyIn2;

% Update handles structure
guidata(hObject, handles);



% --- Executes on selection change in divChanListbox.
function divChanListbox_Callback(hObject, eventdata, handles)
% hObject    handle to divChanListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns divChanListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from divChanListbox

%Check if there are items (divergent channels) in the ListBox. If so proceed
if size(handles.divChanListbox.String)>0
    
    %Reset the legend because a channel will be plotted/a plot will be
    %deleted
    handles.Legend = legend('none');
    set(handles.Legend,'Visible','Off');
    
    %Get the selected item (channel) of the listbox
    index_selected = handles.divChanListbox.Value;
    channel_selected = handles.divChanListbox.String{index_selected};
    
    %Get the index of the selected channel in the channels cell array
    index = 0;
    for i = 1:numel(handles.channels)
        if strcmp(channel_selected,handles.channels{i}.Name)
            index = i;
        end
    end
    
    %Get the channel name
    channelToPlot = {handles.channels{index}.Name};
    
    %If the channel is already plotted delete the plot (By using the
    %associated method of the channel class). If it is not plotted yet
    %create the plot. In both cases set a new legend.
    if ~ handles.channels{index}.IsPlotted
        handles = makePlots(handles, channelToPlot);
        handles = makeLegend(handles);
    else
        handles.channels{index}.deletePlots();
        handles.channels{index}.setIsPlotted(0);
        handles = makeLegend(handles);
    end
    
    
    %Throw warning if no divergent channels are displayed in listbox and the
    %user clicks it
else
    warndlg(strcat('There are no divergent channels to plot.'));
    
end
% Update handles structure
guidata(hObject, handles);


% --------------------------------------------------------------------
function settings_Callback(hObject, eventdata, handles)
% hObject    handle to settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function channelsettings_Callback(hObject, eventdata, handles)
% hObject    handle to channelsettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fig = channelSettings;
%Pause program till the settings window is closed
uiwait(fig);

%Appply the settings after closign the channels settings form
%Remember which channels were plotted (By making use og the IsPlotted
%property)
channelsToPlot = rememberPlottedChannels(handles);

%Reset plots, legend and the channels cell array
handles = resetPlots(handles);
handles.Legend = legend('none');
set(handles.Legend,'Visible','Off');
handles.channels = [];
%Initialize the channel objects and get the divergent channels 
handles = initializeChannels(handles);
handles = getDivergentChannels(handles);
%Plot the channels that were plotted before the plots were resetted by
%making use of the output of the rememberPlottedChannels() function
handles = makePlots(handles, channelsToPlot);
%Make a legend
handles = makeLegend(handles);
%Populate the listbox with the divergent channels
set(handles.divChanListbox, 'string',handles.divchan);

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function divChanListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to divChanListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Loads the paths to the xml files that get compared to the workspace
function xmlPath = loadXmlSettings()
%Get the path to the config file that stores the paths to the xml files 
if isdeployed
    xmlconfigPath = which('xmlsettingsconfig.mat');
else
    xmlconfigPath = strcat(pwd,'\xmlsettingsconfig.mat');
end
%Load the file with xml (.ctr) file configuration and get the saved paths
try
    xmlconfig = load(xmlconfigPath);
catch
    warndlg('Could not load xmlpath configuration')
end
%Save the paths to the xml files
xmlPath{1} = xmlconfig.xml1;
xmlPath{2} = xmlconfig.xml2;

%Uses the python modules to extract the channels and variables of the ctr files
%to .mat files
function getDataFromXml(xmlPath)
%Get the path to the python scripts
if isdeployed
    pythonPath = fullfile(ctfroot,'Pythonscripts','generateIdealSignal.py');
    tempPath = [ctfroot '\temp'];
else
    pythonPath = strcat(pwd,'\Pythonscripts\generateIdealSignal.py');
    tempPath = [pwd '\temp'];
end 

%Create a temporary directory to store the data the python modules extract
%in
if ~(exist(tempPath,'dir')==7)
    try
        mkdir(tempPath)
    catch
        wanrdlg(['Could not create directory',' ',tempPath])
    end
end

%Set names for the .mat files the data gets extracted to
variablePath1 = strrep([tempPath '\vars1.mat'], '\', '\\');
channelPath1 = strrep([tempPath '\channels1.mat'], '\', '\\');
variablePath2 = strrep([tempPath '\vars2.mat'], '\', '\\');
channelPath2 = strrep([tempPath '\channels2.mat'], '\', '\\');
timingPath1 = strrep([tempPath '\timing1.mat'], '\', '\\');
timingPath2 = strrep([tempPath '\timing2.mat'], '\', '\\');

%Try to call the python modules
try
    python(pythonPath, xmlPath{1},channelPath1, variablePath1, timingPath1);
    python(pythonPath, xmlPath{2}, channelPath2, variablePath2, timingPath2);
catch
    warndlg('Python Error!')
end


function [onlyIn1, onlyIn2] = reduceFiles()


%Get the path to the stored data
if isdeployed
    tempPath = fullfile(ctfroot, '\temp');
else
    tempPath = strcat(pwd,'\temp');
end 

%Get names for the .mat files the data is stored in
channelPath1 = [tempPath '\channels1.mat'];
channelPath2 = [tempPath '\channels2.mat'];
%Try to load the channeldata
try
    channels1 = load(channelPath1);
    channels2 = load(channelPath2);
catch
    warndlg('Could not load the channel data from .mat file')
    %Assign dummy value so the program does not crash
    channels1 = struct();
    channels2 = struct();
end

%Get the channel names in seperate variables
fields1 = fieldnames(channels1);
fields2 = fieldnames(channels2);

%Initialize vector that is used for logical indexing
cmpvec = [];

%Test which channel names only appear in xml1
for i=1:numel(fields1)
    currentField = fields1{i};
    for j = 1:numel(fields2)
        if strcmp(currentField,fields2{j})
            cmpvec(end + 1) = 0;            
        end
    end
    if size(cmpvec) < i
        cmpvec(end + 1) = 1;
    end
end
onlyIn1 = fields1(logical(cmpvec));

%Reset the vector for logical indexing
cmpvec = [];

%Test which channel names only appear in xml2
for i=1:numel(fields2)
    currentField = fields2{i};
    for j = 1:numel(fields1)
        if strcmp(currentField,fields1{j})
            cmpvec(end + 1) = 0;            
        end
    end
    if size(cmpvec) < i
        cmpvec(end + 1) = 1;
    end
end

onlyIn2 = fields2(logical(cmpvec));

%Remove all fields from the variable that stores the channels from xml1 
%that correspond to a channels that only exists in xml1
for i =  1:numel(onlyIn1)
    channels1 = rmfield(channels1,onlyIn1(i));
end

%Remove all fields from the variable that stores the channels from xml2 
%that correspond to a channels that only exists in xml2
for i =  1:numel(onlyIn2)
    channels2 = rmfield(channels2,onlyIn2(i));
end

%Rearrange channels1 such that the fields have the same order as the fields
%of channels2
channels1 = orderfields(channels1, channels2);

%Set paths to store the information for the channels that actually get compared 
channelPath1Reduced = [tempPath '\channels1reduced.mat'];
channelPath2Reduced = [tempPath '\channels2reduced.mat'];

%Save the data
try
    save(channelPath1Reduced,'-struct','channels1')
    save(channelPath2Reduced,'-struct','channels2')
catch
    warndlg('Could not save reduced data.')
end

%Generates a .mat file that contains the channel settings 
function generateConfig()

%Get the path to the stored data
if isdeployed
    tempPath = fullfile(ctfroot, '\temp');
    chConfigPath = which('chconfig.mat');
else
    tempPath = strcat(pwd,'\temp');
    chConfigPath = strcat(pwd,'\chconfig.mat');
end 

channelPath = [tempPath '\channels1reduced.mat'];

%Try to load the channeldata
try
    channels = load(channelPath);
catch
    warndlg('Could not load the channel data from .mat file')
    %dummy value so the program does not fail
    channels = struct();
end

%I only need the fieldnames here, not the data
fields = fieldnames(channels);

%Set default values
Offsets = num2cell(zeros(numel(fields),1));
plotSelect = num2cell(logical(ones(numel(fields),1)));
Factors = num2cell(ones(numel(fields),1));
DiffValues = num2cell(ones(numel(fields),1));

%Create a vector with some default colors
allColors = cell(7);
allColors{1} = 'Black'; 
allColors{2} = 'Green'; 
allColors{3} = 'Red'; 
allColors{4} = 'Blue'; 
allColors{5} = 'Yellow'; 
allColors{6} = 'Cyan'; 
allColors{7} = 'Magenta';
emptyCells = cellfun('isempty', allColors); 
allColors(emptyCells) = [];
allColors = transpose(allColors);
%Append to a new vector the vector with the default colors as long as this 
%vector has fewer components than there are relevant channels
colors = cell(0);
while numel(colors) < numel(fields)
    colors = [colors; allColors];
end
%The vector might be too long now. Reduce its length as long as it has more
%components than there are relevant channels 
while numel(fields) < numel(colors)
    colors(end) = [];
end


%create a cell that contains all the channel settings
channelconfig(:,1) = fields;
channelconfig(:,2) = plotSelect;
channelconfig(:,3) = colors;
channelconfig(:,4) = Offsets;
channelconfig(:,5) = Factors;
channelconfig(:,6) = DiffValues;


%save the cell
save(chConfigPath, 'channelconfig')
 
%Test if the cycle durations differ
function isDifferent = isCycleTimeDifferent()

%Get the path to the stored data
if isdeployed
    tempPath = fullfile(ctfroot, '\temp');
else
    tempPath = strcat(pwd,'\temp');
end 

%I append the cycletime to the variables dictionary in the python modules.
%Therefore it is saved in the mat files containing the variables
varPath1 = [tempPath '\vars1.mat'];
varPath2 = [tempPath '\vars2.mat'];

%Try to load the file with the variables. If it fails notify the user.
try
    vars1 = load(varPath1);
    vars2 = load(varPath2);
catch
    warndlg('Was not able to load the variable data from the .mat file')
    vars1 = struct();
    vars2 = struct();
end

%Assume that the cycle lengths are the same
cycleTimeDiff = 0;

%Get the cycle durations.
try
    cycleduration1 = vars1.('Cycleduration');
    cycleduration2 = vars2.('Cycleduration');
catch
    warndlg('Was not able to get cycleduration from variables.')
    cycleduration1 = 0;
    cycleduration2 = 0;
end
    
%If the durations differ assign true to the the variable representing if
%the cycle times difference
if abs(cycleduration1-cycleduration2)
    cycleTimeDiff = logical(1);
end
%Return if the durations differ(1) or not(0)
 isDifferent = cycleTimeDiff;

%Constructs all the channels objects and assigns an array containing them
%to the handles structure
function handles = initializeChannels(handles)

%Get the path to the stored data
if isdeployed
    tempPath = fullfile(ctfroot, '\temp');
    chConfigPath = which('chconfig.mat');
else
    tempPath = strcat(pwd,'\temp');
    chConfigPath = strcat(pwd,'\chconfig.mat');
end 

channelPath1 = [tempPath '\channels1reduced.mat'];
channelPath2 = [tempPath '\channels2reduced.mat'];

%Try to load the .mat files containing the data for the differing channels
try
    channels1 = load(channelPath1);
    channels2 = load(channelPath2);
catch
    warndlg('Was not able to load the file containing the data of the differing channels')
end

%Check if the cycle time differs for the ctr files
cycleTimeDiff = isCycleTimeDifferent();

try
    chConfig = load(chConfigPath);
catch
    warndlg('Was not able to load the channel configuration data.')
end

chConfig = chConfig.('channelconfig');

%Get the channels that are desired to be compared by logical indexing
bools = logical(cell2mat(chConfig(:,2)));
channels = chConfig(:,1);
channels = channels(bools);
colors = chConfig(:,3);
colors = colors(bools);
offsets = chConfig(:,4);
offsets = offsets(bools);
factors = chConfig(:,5);
factors = factors(bools);
diffValues = chConfig(:,6);
diffValues = diffValues(bools);

%Logical indexing is not possible for structs. Therefore first get the
%names in a cell array and then use logical indexing
channels1fields = fields(channels1);
channels1fields = channels1fields(bools);
channels1raw = cell(numel(channels1fields));
for i=1:numel(channels1fields)
    channels1raw{i} = channels1.(channels1fields{i});
end

%Logical indexing is not possible for structs. Therefore first get the
%names in a cell array and then use logical indexing
channels2fields = fields(channels2);
channels2fields = channels2fields(bools);
channels2raw = cell(numel(channels2fields));
for i=1:numel(channels2fields)
    channels2raw{i} = channels2.(channels2fields{i});
end

%Initialize cell array to store channels in
handles.channels = cell(0);

%Loop through all channels the user is intereseted in 
for i = 1:size(channels)
    name = channels{i};
    color = colors{i};
    offset = offsets{i};
    scale = factors{i};
    diffValue = diffValues{i};
    data1 = double(channels1raw{i});
    data2 = double(channels2raw{i});
    handles.channels{i} = Channel(name,color,offset,scale, diffValue, data1, data2, cycleTimeDiff);
end

%Assigns an array containing the channels with diverging data
function handles = getDivergentChannels(handles)
handles.divchan = cell(0);
%Loop through all channels the user is intereseted in
for i = 1:numel(handles.channels)
    if handles.channels{i}.IsDivergent
        handles.divchan{end+1} = handles.channels{i}.Name;
    end
end

%When new settings are applied the Plots must be resettet. It is important
%to know which channles were plotted before. This gives back an array with
%the plotted channels.
function plottedChannels = rememberPlottedChannels(handles)

%Loop through all channels and if the property IsPlotted is true add the
%channel to the array
plottedChannels = cell(0);
for i = 1:numel(handles.channels)
    if handles.channels{i}.IsPlotted
        plottedChannels{end+1} = handles.channels{i}.Name;
    end
end

%Deleted all plots, using the associated method of the channels class and
%sets the IsPlotted property to false
function handles = resetPlots(handles)

for i=1:numel(handles.channels)
    handles.channels{i}.deletePlots;
    handles.channels{i}.setIsPlotted(0);
end

%Takes an array with the channels deried to be plotted as an argument and
%plots these. It also sets the axis limits and lables the axes. 
function handles = makePlots(handles, channelToPlot)

%Prevent that the prior plots are deleted when the next channel gets plotted.
hold on;
%Loops through the array passed as an argument and finds for each iteration
%the channel in the channels array and plots it.
for i = 1:numel(channelToPlot)
    for j = 1:numel(handles.channels)
        if strcmp(channelToPlot{i},handles.channels{j}.Name)
            handles.channels{j}.createPlots()
        end
    end
end
%Set some defaults for the axes 
ylim([0 50])
xlabel('Time [ms]')
ylabel('Signal')

%Tests if there are any plots currently. If so the function makes a legend.
function handles = makeLegend(handles)

%To set the legend need the names of the plotted channels and the plots to figure
%out the color of the lines
namesForLegend = cell(0);
plotsForLegend = [];

%Figure out which channles are plotted currently and save the plot and the
%channelname locally
for i = 1:numel(handles.channels)
    name = handles.channels{i}.Name;
    if handles.channels{i}.IsPlotted
        namesForLegend{end+1} = name;
        plotsForLegend(end+1) = handles.channels{i}.Plot1;
    end
end

%if there are any plots set the legend
if numel(plotsForLegend)
    handles.Legend = legend(plotsForLegend, namesForLegend{:});
    %I don't want the tex interpreter to do strange things to the names
    set(handles.Legend, 'Interpreter', 'none');
    %position the legend next to the axes on the right side
    pos = get(handles.Legend,'Position');
    pos(1) = pos(1)+0.13;
    pos(2) = 0.95*pos(2)-0.01;
    pos(3) = pos(3)+0.047;
    pos(4) = pos(4)+0.047;
    set(handles.Legend, 'Position', pos);
    %Make the size of the names a bit bigger
    set(handles.Legend,'fontsize',12);
end


% --- Executes on button press in notCompareableChannelButton.
function notCompareableChannelButton_Callback(hObject, eventdata, handles)
% hObject    handle to notCompareableChannelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fig = OnlyInOneInfo(handles.onlyIn1, handles.onlyIn2);
uiwait(fig);


%Displays the variable names and their values in each ctr in a uitalbe if 
%the variable values differ
function [varsOnlyIn1, varsOnlyIn2] = setDivVarsTable(handles)

%Get the directory with where the variable data is stored. The
%method of getting it depends on the way the program is executed - compiled
%or interpreted
if isdeployed
    tempPath = fullfile(ctfroot, '\temp');
    var1Path = fullfile(ctfroot, '\temp','\vars1.mat');
    var2Path = fullfile(ctfroot, '\temp','\vars2.mat');
else
    tempPath = strcat(pwd,'\temp');
    var1Path = strcat(pwd,'\temp\vars1.mat');
    var2Path = strcat(pwd,'\temp\vars2.mat');
end 
 %Try to load the data. If it fails notify the user
try 
    vars1 = load(var1Path);
    vars2 = load(var2Path);
catch
    warndlg('Could not load files, containing the variables')
    vars1 = struct();
    vars2 = struct();
end

%var1 and var 2 are structs. Get the fieldnames in the structs.
fields1 = fields(vars1);
fields2 = fields(vars2);

%Initialize vector for logical indexing
bools = [];
%Populate bools: bools(i) is 1 if the i-th fieldname of var1 does not
%appear in var2. Otherwise it is 0
for i = 1:numel(fields1)
    for j =1:numel(fields2)
        if strcmp(fields1(i),fields2(j))
            bools(i) = 0;
        end
    end
    if numel(bools) < i
        bools(i) = 1;
    end
end

%Get the names of the variables that only appear in xml1
varsOnlyIn1 = fields1(logical(bools));

%analogous to the above
bools = [];
for i = 1:numel(fields2)
    for j =1:numel(fields1)
        if strcmp(fields2(i),fields1(j))
            bools(i) = 0;
        end
    end
    if numel(bools) < i
        bools(i) = 1;
    end
end
varsOnlyIn2 = fields2(logical(bools));


%Remove all fields from the variable that stores the channels from xml1 
%that correspond to a channels that only exists in xml1
for i =  1:numel(varsOnlyIn1)
    vars1 = rmfield(vars1,varsOnlyIn1(i));
end

%Remove all fields from the variable that stores the channels from xml2 
%that correspond to a channels that only exists in xml2
for i =  1:numel(varsOnlyIn2)
    vars2 = rmfield(vars2,varsOnlyIn2(i));
end

%Rearrange channels1 such that the fields have the same order as the fields
%of channels2
vars1 = orderfields(vars1, vars2);

%Get the data for the channels as cell array
data1 = struct2cell(vars1);
data2 = struct2cell(vars2);

%Get the channels names. I can use vars1 because I removed all the channles
%from the structs that only appear in one of the fiels and ordered them in 
%the same way 
fields1 = fields(vars1);

%I only need the variables with the same name but diverging values. I get
%them by logical indexing
bools = [];
for i = 1:numel(fields1)
    if abs(double(vars1.(fields1{i}))-double(vars2.(fields1{i})))
        bools = [bools; 1];
    end
    if numel(bools)<i
        bools = [bools; 0];
    end
end
divFields = fields1(logical(bools));
varsDiv1 = data1(logical(bools));
varsDiv2 = data2(logical(bools));
    
%Create a table that displays the variable names and their values in each
%xml file
colnames = {'xml1', 'xml2'};   
rownames = divFields;
set(handles.varDivTable,'data',[varsDiv1, varsDiv2],'RowName', rownames, 'ColumnName',colnames)

% --- Executes on button press in showNotCompVarsButton.
function showNotCompVarsButton_Callback(hObject, eventdata, handles)
% hObject    handle to showNotCompVarsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Open the GUI containing the the variables only present in one ctr
fig = varsOnlyInOneInfo(handles.varsOnlyIn1, handles.varsOnlyIn2);
%Wait till the user closes the GUI
uiwait(fig);


% --------------------------------------------------------------------
function info_Callback(hObject, eventdata, handles)
% hObject    handle to info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Open the infobox GUI in extra window
fig = infobox;
%Pause program till the infobox window is closed
uiwait(fig);


% --- Executes on button press in deleteAllPlots_Button.
function deleteAllPlots_Button_Callback(hObject, eventdata, handles)
% hObject    handle to deleteAllPlots_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Reset plots, legend and the channels cell array
handles = resetPlots(handles);
handles.Legend = legend('none');
set(handles.Legend,'Visible','Off');
handles.channels = [];
%Initialize the channel objects and get the divergent channels 
handles = initializeChannels(handles);
handles = getDivergentChannels(handles);
% Update handles structure
guidata(hObject, handles);


% --- Executes during object deletion, before destroying properties.
function XmlCompare_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to XmlCompare (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clear;
if isdeployed
    tempPath = [ctfroot '\temp'];
else
    tempPath = [pwd '\temp'];
end 

cmd_rmdir(tempPath);
