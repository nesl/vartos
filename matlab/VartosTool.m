function varargout = VartosTool(varargin)
% VARTOSTOOL MATLAB code for VartosTool.fig
%      VARTOSTOOL, by itself, creates a new VARTOSTOOL or raises the existing
%      singleton*.
%
%      H = VARTOSTOOL returns the handle to a new VARTOSTOOL or the handle to
%      the existing singleton*.
%
%      VARTOSTOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VARTOSTOOL.M with the given input arguments.
%
%      VARTOSTOOL('Property','Value',...) creates a new VARTOSTOOL or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VartosTool_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VartosTool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VartosTool

% Last Modified by GUIDE v2.5 24-May-2013 15:56:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @VartosTool_OpeningFcn, ...
    'gui_OutputFcn',  @VartosTool_OutputFcn, ...
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

% --- Executes just before VartosTool is made visible.
function VartosTool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VartosTool (see VARARGIN)

% Choose default command line output for VartosTool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

initialize_gui(hObject, handles, false);

% UIWAIT makes VartosTool wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = VartosTool_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function density_CreateFcn(hObject, eventdata, handles)
% hObject    handle to density (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function density_Callback(hObject, eventdata, handles)
% hObject    handle to density (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of density as text
%        str2double(get(hObject,'String')) returns contents of density as a double
density = str2double(get(hObject, 'String'));
if isnan(density)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

% Save the new density value
handles.metricdata.density = density;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function volume_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function volume_Callback(hObject, eventdata, handles)
% hObject    handle to volume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of volume as text
%        str2double(get(hObject,'String')) returns contents of volume as a double
volume = str2double(get(hObject, 'String'));
if isnan(volume)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

% Save the new volume value
handles.metricdata.volume = volume;
guidata(hObject,handles)

% --- Executes on button press in calculate.
function calculate_Callback(hObject, eventdata, handles)
% hObject    handle to calculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mass = handles.metricdata.density * handles.metricdata.volume;
set(handles.mass, 'String', mass);

% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

initialize_gui(gcbf, handles, true);

% --- Executes when selected object changed in unitgroup.
function unitgroup_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in unitgroup
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (hObject == handles.english)
    set(handles.text4, 'String', 'lb/cu.in');
    set(handles.text5, 'String', 'cu.in');
    set(handles.text6, 'String', 'lb');
else
    set(handles.text4, 'String', 'kg/cu.m');
    set(handles.text5, 'String', 'cu.m');
    set(handles.text6, 'String', 'kg');
end

% --------------------------------------------------------------------
function initialize_gui(fig_handle, handles, isreset)
% If the metricdata field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.
if isfield(handles, 'metricdata') && ~isreset
    return;
end

% load the temperature files into the menu
handles.temperature.path = '../weather-multiple/data/';
handles.temperature.bins = 20;

all_files = dir(handles.temperature.path);
good_files = {};

for i = 1:length(all_files)
    str = all_files(i).name;
    match_str = ['.*2011.*'];
    if ~isempty(regexp(str,match_str,'match'))
        good_files = [good_files; str];
    end
end

set(handles.list_temps, 'String',good_files);

% set num tasks to 0
handles.tasks.list = {};
handles.tasks.objects = [];

% default specs
handles.specs.E = 12960;
handles.specs.L = 8760;
handles.specs.clock = 8;

% set(handles.density, 'String', handles.metricdata.density);
% set(handles.volume,  'String', handles.metricdata.volume);
% set(handles.mass, 'String', 0);
%
% set(handles.unitgroup, 'SelectedObject', handles.english);
%
% set(handles.text4, 'String', 'lb/cu.in');
% set(handles.text5, 'String', 'cu.in');
% set(handles.text6, 'String', 'lb');

% Update handles structure
guidata(handles.figure1, handles);



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function box_kmin_Callback(hObject, eventdata, handles)
% hObject    handle to box_kmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of box_kmin as text
%        str2double(get(hObject,'String')) returns contents of box_kmin as a double


% --- Executes during object creation, after setting all properties.
function box_kmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to box_kmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function box_kmax_Callback(hObject, eventdata, handles)
% hObject    handle to box_kmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of box_kmax as text
%        str2double(get(hObject,'String')) returns contents of box_kmax as a double


% --- Executes during object creation, after setting all properties.
function box_kmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to box_kmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function box_pi_Callback(hObject, eventdata, handles)
% hObject    handle to box_pi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of box_pi as text
%        str2double(get(hObject,'String')) returns contents of box_pi as a double


% --- Executes during object creation, after setting all properties.
function box_pi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to box_pi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_task_create.
function button_task_create_Callback(hObject, eventdata, handles)
% hObject    handle to button_task_create (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.specs.clock ~= 0
    % grab the task info
    task_name = get(handles.box_task_name, 'String');
    task_kmin = str2num(get(handles.box_kmin, 'String'));
    task_kmax = str2num(get(handles.box_kmax, 'String'));
    task_pi = str2num(get(handles.box_pi, 'String'));
    task_offset = str2num(get(handles.box_inst_offset, 'String'));
    task_slope = str2num(get(handles.box_inst_slope, 'String'));
    % create object
    task_obj = VartosTask(task_name, task_kmin, task_kmax, task_pi,...
        task_offset, task_slope, handles.specs.clock);
    % append to all_tasks list
    handles.tasks.objects = [handles.tasks.objects; task_obj];
    % append the task to the creation list
    tname = sprintf('%s  knob:[%d,%d]  pi:%0.2f', task_name, task_kmin, task_kmax, task_pi);
    handles.tasks.list = [handles.tasks.list; tname];
    set(handles.list_tasks,'String',handles.tasks.list);
    
end
% update handles
guidata(hObject,handles)


function box_task_name_Callback(hObject, eventdata, handles)
% hObject    handle to box_task_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of box_task_name as text
%        str2double(get(hObject,'String')) returns contents of box_task_name as a double


% --- Executes during object creation, after setting all properties.
function box_task_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to box_task_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function box_inst_offset_Callback(hObject, eventdata, handles)
% hObject    handle to box_inst_offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of box_inst_offset as text
%        str2double(get(hObject,'String')) returns contents of box_inst_offset as a double


% --- Executes during object creation, after setting all properties.
function box_inst_offset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to box_inst_offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function box_inst_slope_Callback(hObject, eventdata, handles)
% hObject    handle to box_inst_slope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of box_inst_slope as text
%        str2double(get(hObject,'String')) returns contents of box_inst_slope as a double


% --- Executes during object creation, after setting all properties.
function box_inst_slope_CreateFcn(hObject, eventdata, handles)
% hObject    handle to box_inst_slope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in list_tasks.
function list_tasks_Callback(hObject, eventdata, handles)
% hObject    handle to list_tasks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns list_tasks contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list_tasks


% --- Executes during object creation, after setting all properties.
function list_tasks_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list_tasks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in list_temps.
function list_temps_Callback(hObject, eventdata, handles)
% hObject    handle to list_temps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns list_temps contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list_temps


% --- Executes during object creation, after setting all properties.
function list_temps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list_temps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function box_energy_Callback(hObject, eventdata, handles)
% hObject    handle to box_energy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of box_energy as text
%        str2double(get(hObject,'String')) returns contents of box_energy as a double


% --- Executes during object creation, after setting all properties.
function box_energy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to box_energy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function box_lifetime_Callback(hObject, eventdata, handles)
% hObject    handle to box_lifetime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of box_lifetime as text
%        str2double(get(hObject,'String')) returns contents of box_lifetime as a double


% --- Executes during object creation, after setting all properties.
function box_lifetime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to box_lifetime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function box_freq_Callback(hObject, eventdata, handles)
% hObject    handle to box_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.specs.clock = str2num(get(handles.box_freq,'String'));

% Hints: get(hObject,'String') returns contents of box_freq as text
%        str2double(get(hObject,'String')) returns contents of box_freq as a double

% update handles
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function box_freq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to box_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_apply.
function button_apply_Callback(hObject, eventdata, handles)
% hObject    handle to button_apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------- TEMPERATURE --------
% load data
index_selected = get(handles.list_temps,'Value');
file_list = get(handles.list_temps,'String');
filename = file_list{index_selected};
handles.temperature.fname = filename;
data = csvread([handles.temperature.path filename]);
% plot
axes(handles.axes_temps);
[f,x]=hist(data,20);
% normalize by area
bar(x,f/trapz(x,f));

% ------------ SYS SPECS -----------
handles.specs.E = str2num(get(handles.box_energy,'String'));
handles.specs.L = str2num(get(handles.box_lifetime,'String'));
handles.specs.clock = str2num(get(handles.box_freq,'String'));

% ------------ POWER CHOICE --------
pnl = handles.panel_radio;
power_choice = get( get(pnl, 'SelectedObject'), 'Tag');
handles.power.path = 'pm/';
switch(power_choice)
    case 'radio_bc'
        handles.power.inst = 'bc';
    case 'radio_nc'
        handles.power.inst = 'nc';
    case 'radio_wc'
        handles.power.inst = 'wc';
end
% load power data
handles.power.data = csvread([handles.power.path handles.power.inst]);

% get optimal DC
handles.optimize.dc = energyFileToDC(handles.specs.E,...
    [handles.temperature.path handles.temperature.fname],...
    [handles.power.path handles.power.inst], 10000, 0);

set(handles.text_dc,'String',num2str(handles.optimize.dc));
if handles.optimize.dc <= 0
    set(handles.text_dc,'BackgroundColor',[1 0.7 0.7]);
else
    set(handles.text_dc,'BackgroundColor',[0.7 1 0.7]);
end

if ~isempty(handles.tasks.objects) && handles.optimize.dc > 0
    % find optimal duty cycles for these tasks
    dc_i = getOptimalTaskDCs(handles.tasks.objects,handles.optimize.dc);
    % convert duty cycles to knobs
    k_i = [];
    for t = 1:length(handles.tasks.objects)
        k_i = [k_i; handles.tasks.objects(t).DCtoKnob(dc_i(t))];
    end
    dc_i
    
    % plot results
    axes(handles.axes_utils);
    cla(handles.axes_utils);
    hold on;
    colors = lines(length(handles.tasks.objects));
    % dc / util curves
    dcs = 0:0.01:0.5;
    
    for t=1:length(handles.tasks.objects)
        task = handles.tasks.objects(t);
        utils = task.dcToUtil(dcs);
        plot(dcs, utils,'Color',colors(t,:));
        % add optimal point
        plot(dc_i(t), task.dcToUtil(dc_i(t)), 's',...
            'Color',colors(t,:),'MarkerFaceColor',colors(t,:),...
            'MarkerSize',15,'LineWidth',2);
        ylim([0 2]);
        % add textual info
        text(dc_i(t)+0.01, 0.2+task.dcToUtil(dc_i(t)),...
            sprintf('knob: %d',k_i(t)));
        text(dc_i(t)+0.01, 0.35+task.dcToUtil(dc_i(t)),...
            task.name);
        xlabel('Duty Cycle','FontSize',12);
        
    end
    
end


% update handles
guidata(hObject,handles)
