function varargout = Number_Plate_Reader(varargin)
clc;

% NUMBER_PLATE_READER MATLAB code for Number_Plate_Reader.fig
%      NUMBER_PLATE_READER, by itself, creates a new NUMBER_PLATE_READER or raises the existing
%      singleton*.
%
%      H = NUMBER_PLATE_READER returns the handle to a new NUMBER_PLATE_READER or the handle to
%      the existing singleton*.
%
%      NUMBER_PLATE_READER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NUMBER_PLATE_READER.M with the given input arguments.
%
%      NUMBER_PLATE_READER('Property','Value',...) creates a new NUMBER_PLATE_READER or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Number_Plate_Reader_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Number_Plate_Reader_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Number_Plate_Reader

% Last Modified by GUIDE v2.5 26-May-2013 01:14:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Number_Plate_Reader_OpeningFcn, ...
                   'gui_OutputFcn',  @Number_Plate_Reader_OutputFcn, ...
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

% --- Executes just before Number_Plate_Reader is made visible.
function Number_Plate_Reader_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Number_Plate_Reader (see VARARGIN)

% Choose default command line output for Number_Plate_Reader
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

initialize_gui(hObject, handles, false);

% UIWAIT makes Number_Plate_Reader wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Number_Plate_Reader_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.

% --- Executes on button press in calculate.

% --- Executes on button press in reset.

% --- Executes when selected object changed in unitgroup.
function initialize_gui(fig_handle, handles, isreset)
% If the metricdata field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.
if isfield(handles, 'metricdata') && ~isreset
    return;
end

% Update handles structure
guidata(handles.figure1, handles);


% --- Executes on button press in pushbutton10.
function[text1]= pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [baseFileName,folder]=uigetfile('*.*','Specify an image file','on');

    fullimageFileName=fullfile(folder,baseFileName);

    axes1=imread(fullimageFileName);

    axes(handles.axes1);

    image(axes1)
    prompt={'Enter the number of charcters to read:'};
    dlg_title = 'Number of Characters';
    num_lines = 1;
    def = {'0'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    no = str2num(answer{1});
    
    text1 = final(fullimageFileName,no);
    msgbox(text1,'Ouput');
 
