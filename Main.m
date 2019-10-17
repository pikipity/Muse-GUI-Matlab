function varargout = Main(varargin)
% MAIN MATLAB code for Main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Main

% Last Modified by GUIDE v2.5 08-Oct-2019 17:29:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Main_OpeningFcn, ...
                   'gui_OutputFcn',  @Main_OutputFcn, ...
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


% --- Executes just before Main is made visible.
function Main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Main (see VARARGIN)

% Choose default command line output for Main
handles.output = hObject;

% App Data

handles.fs=256;
handles.winlen=3;

bandpass_filter.en=0;
bandpass_filter.low_f=0.1;
bandpass_filter.high_f=40;
[bandpass_filter.b,bandpass_filter.a]=butter(4,[bandpass_filter.low_f bandpass_filter.high_f]/(handles.fs/2),'bandpass');
% bandpass_filter.bpfilter=designfilt('bandpassiir','FilterOrder',4, ...
%                                      'HalfPowerFrequency1',bandpass_filter.low_f,...
%                                      'HalfPowerFrequency2',bandpass_filter.high_f, ...
%                                      'SampleRate',handles.fs);
handles.bandpass_filter=bandpass_filter;

Fo = 50;
Q = 35;
BW = (Fo/(handles.fs/2))/Q;
[handles.notch_filter.notchB,handles.notch_filter.notchA] = iircomb(floor(handles.fs/Fo),BW,'notch');


ica_para.en=0;
ica_para.numic=4;
ica_para.removedic=1:2;
handles.ica_para=ica_para;

handles.connect_en=0;
handles.record_en=0;
handles.record_path=[];
handles.inlet=[];
handles.t_axis=[];
handles.timedata=[];
handles.init_time=0;
handles.channel_name={};
handles.timer=timer('timerfcn', {@TimeFun, hObject}, 'Period',0.1,...
                    'ExecutionMode','fixedRate');

% Update handles structure
guidata(hObject, handles);

start(handles.timer)

% UIWAIT makes Main wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in ConnectButton.
function ConnectButton_Callback(hObject, eventdata, handles)
% hObject    handle to ConnectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ConnectButton

stop(handles.timer)

if hObject.Value==1
    lib = lsl_loadlib();
    result = lsl_resolve_byprop(lib,'type','EEG',1,1);
    if isempty(result)
        handles.connect_en=0;
        handles.inlet=[];
        hObject.Value=0;
        handles.t_axis=[];
        handles.timedata=[];
        handles.init_time=0;    
        hObject.String='Connect';
    else
        handles.connect_en=1;
        handles.inlet=lsl_inlet(result{1});
        hObject.Value=1;
        hObject.String='Disconnect';
    end
else
    if handles.record_en
        warndlg('Please stop recording first','Warning');
        handles.connect_en=1;
        hObject.Value=1;
        hObject.String='Disconnect';
    else
        handles.connect_en=0;
        handles.inlet=[];
        hObject.Value=0;
        handles.t_axis=[];
        handles.timedata=[];
        handles.init_time=0;
        hObject.String='Connect';
    end
end

% Update handles structure
guidata(hObject, handles);

start(handles.timer)

% --- Executes on button press in RecordButton.
function RecordButton_Callback(hObject, eventdata, handles)
% hObject    handle to RecordButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

stop(handles.timer)

if hObject.Value==1
    if handles.connect_en==0
        warndlg('Please start connection first','Warning');
        handles.record_en=0;
        handles.record_path=[];
        hObject.Value=0;
        set(handles.path_text,'String',handles.record_path);
        hObject.String='Record';
    else
        [file, path] = uiputfile(['eeg_' char(datetime('now','Format','yy-MM-dd''T''HH-mm-ss')) '.csv']);
        if file 
            if ~strcmp(file(end-3:end),'.csv')
                file=[file '.csv'];
            end
        end
        if file
            handles.record_en=1;
            handles.record_path=[path file];
            if exist(handles.record_path,'file')
                delete(handles.record_path);
            end
            hObject.Value=1;
            set(handles.path_text,'String',handles.record_path);
            hObject.String='Stop Record';
        else
            handles.record_en=0;
            handles.record_path=[];
            hObject.Value=0;
            set(handles.path_text,'String',handles.record_path);
            hObject.String='Record';
        end
    end
else
    handles.record_en=0;
    handles.record_path=[];
    hObject.Value=0;
    set(handles.path_text,'String',handles.record_path);
    hObject.String='Record';
end

% Update handles structure
guidata(hObject, handles);

start(handles.timer)



function win_len_text_Callback(hObject, eventdata, handles)
% hObject    handle to win_len_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of win_len_text as text
%        str2double(get(hObject,'String')) returns contents of win_len_text as a double
    set(hObject,'String',num2str(floor(str2double(get(hObject,'String'))*handles.fs)/handles.fs))
    if str2double(get(hObject,'String'))<1
        warndlg('Window length should be larger than or equal to 1','Warning');
        set(hObject,'String','1')
    end
    guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function win_len_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to win_len_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% function samplerate_text_Callback(hObject, eventdata, handles)
% % hObject    handle to samplerate_text (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: get(hObject,'String') returns contents of samplerate_text as text
% %        str2double(get(hObject,'String')) returns contents of samplerate_text as a double


% --- Executes during object creation, after setting all properties.
function samplerate_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to samplerate_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cutofffreq1_text_Callback(hObject, eventdata, handles)
% hObject    handle to cutofffreq1_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cutofffreq1_text as text
%        str2double(get(hObject,'String')) returns contents of cutofffreq1_text as a double
    if str2double(get(hObject,'String'))<=0
        warndlg('Lower cutoff frequency should be larger than 0','Warning');
        set(hObject,'String','0.1')
    end
    if str2double(get(hObject,'String'))>=str2double(get(handles.cutofffreq2_text,'String'))
        warndlg('Lower cutoff frequency should be smaller than higher cutoff frequency','Warning');
        set(hObject,'String',num2str(str2double(get(handles.cutofffreq2_text,'String'))/2))
    end 
    guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function cutofffreq1_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cutofffreq1_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cutofffreq2_text_Callback(hObject, eventdata, handles)
% hObject    handle to cutofffreq2_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cutofffreq2_text as text
%        str2double(get(hObject,'String')) returns contents of cutofffreq2_text as a double
    if str2double(get(hObject,'String'))<=str2double(get(handles.cutofffreq1_text,'String'))
        warndlg('Higher cutoff frequency should be larger than lower cutoff frequency','Warning');
        set(hObject,'String',num2str((str2double(get(handles.cutofffreq1_text,'String'))+str2double(get(handles.samplerate_text,'String'))/2)/2))
    end
    if str2double(get(hObject,'String'))>str2double(get(handles.samplerate_text,'String'))/2
        warndlg('Higher cutoff frequency should be smaller than half of sampling rate','Warning');
        set(hObject,'String',num2str(str2double(get(handles.samplerate_text,'String'))/2-0.001))
    end 
    guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function cutofffreq2_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cutofffreq2_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% % --- Executes on button press in Recording_digital.
% function Recording_digital_Callback(hObject, eventdata, handles)
% % hObject    handle to Recording_digital (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: get(hObject,'Value') returns toggle state of Recording_digital



function removedic_1_text_Callback(hObject, eventdata, handles)
% hObject    handle to removedic_1_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of removedic_1_text as text
%        str2double(get(hObject,'String')) returns contents of removedic_1_text as a double
    set(hObject,'String',num2str(floor(str2double(get(hObject,'String')))))
    if str2double(get(hObject,'String'))<=0
         warndlg('Smallest level should be higher than 0','Warning');
         set(hObject,'String','1');
    end
    if str2double(get(hObject,'String'))>str2double(get(handles.removedic_2_text,'String'))
        warndlg('Smallest level should be lower or equal to highest level','Warning');
        set(hObject,'String',get(handles.removedic_2_text,'String'));
    end
    guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function removedic_1_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to removedic_1_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numofic_text_Callback(hObject, eventdata, handles)
% hObject    handle to numofic_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numofic_text as text
%        str2double(get(hObject,'String')) returns contents of numofic_text as a double
    set(hObject,'String',num2str(floor(str2double(get(hObject,'String')))))
    if str2double(get(hObject,'String'))<2
        warndlg('Number of IC should be larger than or equal to 2','Warning');
        set(hObject,'String','2')
    end
    if str2double(get(hObject,'String'))>4
        warndlg('Number of IC should be smaller than or equal to 4','Warning');
        set(hObject,'String','4')
    end
    set(handles.removedic_1_text,'String','1')
    set(handles.removedic_2_text,'String','2')
    guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function numofic_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numofic_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function removedic_2_text_Callback(hObject, eventdata, handles)
% hObject    handle to removedic_2_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of removedic_2_text as text
%        str2double(get(hObject,'String')) returns contents of removedic_2_text as a double
    set(hObject,'String',num2str(floor(str2double(get(hObject,'String')))))
    if str2double(get(hObject,'String'))<str2double(get(handles.removedic_2_text,'String'))
         warndlg('Highest level should be higher or equal to smallest level','Warning');
         set(hObject,'String',get(handles.removedic_2_text,'String'));
    end
    if str2double(get(hObject,'String'))>str2double(get(handles.numofic_text,'String'))
        warndlg('Highest level should be lower or equal to number of IC','Warning');
        set(hObject,'String',get(handles.numofic_text,'String'));
    end
    guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function removedic_2_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to removedic_2_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ApplyParaButton.
function ApplyParaButton_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyParaButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    get_app_data(hObject,handles);


% --- Executes on button press in icaenable_check.
function icaenable_check_Callback(hObject, eventdata, handles)
% hObject    handle to icaenable_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of icaenable_check
    ica_para.en=get(handles.icaenable_check,'Value');
    ica_para.numic=str2double(get(handles.numofic_text,'String'));
    ica_para.removedic=str2double(get(handles.removedic_1_text,'String')):str2double(get(handles.removedic_2_text,'String'));
    handles.ica_para=ica_para;
    guidata(hObject, handles);


% --- Executes on button press in bandpass_check.
function bandpass_check_Callback(hObject, eventdata, handles)
% hObject    handle to bandpass_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bandpass_check
    bandpass_filter.en=get(handles.bandpass_check,'Value');
    bandpass_filter.low_f=str2double(get(handles.cutofffreq1_text,'String'));
    bandpass_filter.high_f=str2double(get(handles.cutofffreq2_text,'String'));
    [bandpass_filter.b,bandpass_filter.a]=butter(4,[bandpass_filter.low_f bandpass_filter.high_f]/(handles.fs/2),'bandpass');
%     bandpass_filter.bpfilter=designfilt('bandpassiir','FilterOrder',4, ...
%                                          'HalfPowerFrequency1',bandpass_filter.low_f,...
%                                          'HalfPowerFrequency2',bandpass_filter.high_f, ...
%                                          'SampleRate',handles.fs);
    handles.bandpass_filter=bandpass_filter;
    guidata(hObject, handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
stop(handles.timer);
delete(handles.timer);
delete(hObject);

function get_app_data(hObject,handles)
    current_timer_state=get(handles.timer,'Running');
    stop(handles.timer);
    
    handles.fs=str2double(get(handles.samplerate_text,'String'));
    handles.winlen=str2double(get(handles.win_len_text,'String'));

    bandpass_filter.en=get(handles.bandpass_check,'Value');
    bandpass_filter.low_f=str2double(get(handles.cutofffreq1_text,'String'));
    bandpass_filter.high_f=str2double(get(handles.cutofffreq2_text,'String'));
    [bandpass_filter.b,bandpass_filter.a]=butter(4,[bandpass_filter.low_f bandpass_filter.high_f]/(handles.fs/2),'bandpass');
%     bandpass_filter.bpfilter=designfilt('bandpassiir','FilterOrder',4, ...
%                                          'HalfPowerFrequency1',bandpass_filter.low_f,...
%                                          'HalfPowerFrequency2',bandpass_filter.high_f, ...
%                                          'SampleRate',handles.fs);
    handles.bandpass_filter=bandpass_filter;

    ica_para.en=get(handles.icaenable_check,'Value');
    ica_para.numic=str2double(get(handles.numofic_text,'String'));
    ica_para.removedic=str2double(get(handles.removedic_1_text,'String')):str2double(get(handles.removedic_2_text,'String'));
    handles.ica_para=ica_para;

    handles.connect_en=get(handles.ConnectButton,'Value');
    handles.record_en=get(handles.RecordButton,'Value');
    handles.record_path=get(handles.path_text,'String');
    %handles.inlet=[];
    handles.t_axis=[];
    handles.timedata=[];
    handles.init_time=0;
    %handles.timer=timer('timerfcn', {@TimeFun, hObject}, 'Period',0.1,...
    %                    'ExecutionMode','fixedRate');
                    
    guidata(hObject, handles);
    if strcmp(current_timer_state,'on')
        start(handles.timer);
    end
