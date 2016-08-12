function varargout = channelSettings(varargin)
% CHANNELSETTINGS MATLAB code for channelSettings.fig
%      CHANNELSETTINGS, by itself, creates a new CHANNELSETTINGS or raises the existing
%      singleton*.
%
%      H = CHANNELSETTINGS returns the handle to a new CHANNELSETTINGS or the handle to
%      the existing singleton*.
%
%      CHANNELSETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHANNELSETTINGS.M with the given input arguments.
%
%      CHANNELSETTINGS('Property','Value',...) creates a new CHANNELSETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before channelSettings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to channelSettings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help channelSettings

% Last Modified by GUIDE v2.5 09-Aug-2016 16:42:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @channelSettings_OpeningFcn, ...
                   'gui_OutputFcn',  @channelSettings_OutputFcn, ...
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


% --- Executes just before channelSettings is made visible.
function channelSettings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to channelSettings (see VARARGIN)

% Choose default command line output for channelSettings
handles.output = hObject;

%Set the default data for the uitable
columnnames = {'Channelname', 'Select', 'Color', 'Offset', 'Scale',...
    'Diff Value'};

colorOptions = {'Off' 'Black' 'Green' 'Red' 'Blue' 'Yellow' 'Cyan'...
    'Magenta'};

%Get the path to the config file
if isdeployed
    configPath = which('chconfig.mat');
else
    configPath = strcat(pwd,'\chconfig.mat');
end

%Try to load the config file. If this fails notify the user.
try
    tabledata = load(configPath);
catch
    warndlg('Was not able to load channel settings')
end

%Assign the stored data to the handles structure
handles.tableData = tabledata.channelconfig;

%Assign the data to the uitable
set(handles.uitable, 'rowname', [], 'columnname', columnnames, ...
    'data', handles.tableData, ...
    'columnformat', {'char', 'logical', colorOptions, 'numeric', 'numeric', 'numeric'},...
    'columneditable', [false true true true true true], ...
    'columnwidth', {110 80 100 80 80 80}, ...
    'celleditcallback', @uitable_Callback);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes channelSettings wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = channelSettings_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on change in uitable
function uitable_Callback(hObject, eventdata)
handles = guidata(hObject);

%Assume everything is fine
isValueOkay = true;
%Check if the entered value is okay
switch eventdata.Indices(2)
    case {1, 2, 3}
        %do nothing as nothing can go wrong here
    case {4, 5, 6}
        %Check if it is a real number
        if (isnan(eventdata.NewData) || (eventdata.NewData == 1i))
            isValueOkay = false;
        end
end

if isValueOkay
    %Update the tableData with the new entered value
    handles.tableData{eventdata.Indices(1), eventdata.Indices(2)} = ...
        eventdata.NewData;
else
    %reset to old values
    set(handles.uitable, 'data', handles.tableData);
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Save the data entered by the user, if the user presses the apply button
channelconfig = handles.uitable.Data;
try
    save chconfig channelconfig;
catch
    warndlg('Was not able to save channel settings')
end
delete(handles.figure1)



function search_editBox_Callback(hObject, eventdata, handles)
% hObject    handle to search_editBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of search_editBox as text
%        str2double(get(hObject,'String')) returns contents of search_editBox as a double


% --- Executes during object creation, after setting all properties.
function search_editBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to search_editBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in startSearch_Button.
function startSearch_Button_Callback(hObject, eventdata, handles)
% hObject    handle to startSearch_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

boxHandle = handles.search_editBox;

%Get the string in the user entered into the textfield
lookedFor = boxHandle.String;

%Get all the channel names in the table
names = handles.uitable.Data(:,1);
%Initialize row with 0; Changes later
row = 0;
%Initialize column with 1, since this is the column containing the channel
%name
col = 1;

%Get the row the name entered by the user is in
for i = 1:length(names)
    if strcmp(names{i},lookedFor) 
        row = i;
    end
end
%If the row is still zero the algorithm was not able to find the string
%enterd by the user (The first component of a MatLab array is referenced by
%1) Empty the editbox and set the focus on it so the user can type in what
%he/she really wanted to type.
if row == 0
    warndlg(strcat({'Was not able to find channel '},lookedFor));
    set(boxHandle,'String','');
     uicontrol(boxHandle);
%If the string exists in the first column use a hanlde to the java object,
%since MatLab does not allow setting a focus on a certain column. finjobj
%is a custom function by some MatLab user to get the handle to the java 
%object. Look into the file for further information.
else
    jUIScrollPane = findjobj(handles.uitable);
    jUITable = jUIScrollPane.getViewport.getView;
    jUITable.setRowSelectionAllowed(0);
    jUITable.setColumnSelectionAllowed(0);
    jUITable.changeSelection(row-1,col-1, false, false);
end
