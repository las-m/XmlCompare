function varargout = OnlyInOneInfo(varargin)
% ONLYINONEINFO MATLAB code for OnlyInOneInfo.fig
%      ONLYINONEINFO, by itself, creates a new ONLYINONEINFO or raises the existing
%      singleton*.
%
%      H = ONLYINONEINFO returns the handle to a new ONLYINONEINFO or the handle to
%      the existing singleton*.
%
%      ONLYINONEINFO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ONLYINONEINFO.M with the given input arguments.
%
%      ONLYINONEINFO('Property','Value',...) creates a new ONLYINONEINFO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before OnlyInOneInfo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to OnlyInOneInfo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help OnlyInOneInfo

% Last Modified by GUIDE v2.5 07-Apr-2016 13:23:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OnlyInOneInfo_OpeningFcn, ...
                   'gui_OutputFcn',  @OnlyInOneInfo_OutputFcn, ...
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


% --- Executes just before OnlyInOneInfo is made visible.
function OnlyInOneInfo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to OnlyInOneInfo (see VARARGIN)

% Choose default command line output for OnlyInOneInfo
handles.output = hObject;

%varargin{1} contains the channels only in xml1, varargin{2} the channels
%only in xml2. Assing these arrays to the corresponding listboxes in the
%GUI
handles.Xml1Listbox.String = varargin{1};
handles.Xml2Listbox.String = varargin{2};

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes OnlyInOneInfo wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = OnlyInOneInfo_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in Xml1Listbox.
function Xml1Listbox_Callback(hObject, eventdata, handles)
% hObject    handle to Xml1Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Xml1Listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Xml1Listbox


% --- Executes during object creation, after setting all properties.
function Xml1Listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Xml1Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Xml2Listbox.
function Xml2Listbox_Callback(hObject, eventdata, handles)
% hObject    handle to Xml2Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Xml2Listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Xml2Listbox


% --- Executes during object creation, after setting all properties.
function Xml2Listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Xml2Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
