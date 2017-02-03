function varargout = Custom_OptionsGUI(varargin)
% Custom_OPTIONSGUI MATLAB code for Custom_OptionsGUI.fig
% ----------------------------------------------------------------------------------------------------
% Written by: Jean-Fran�ois Cabana, 2016
% ----------------------------------------------------------------------------------------------------
% If you use qMTLab in your work, please cite :

% Cabana, J.-F., Gu, Y., Boudreau, M., Levesque, I. R., Atchia, Y., Sled, J. G., Narayanan, S.,
% Arnold, D. L., Pike, G. B., Cohen-Adad, J., Duval, T., Vuong, M.-T. and Stikov, N. (2016),
% Quantitative magnetization transfer imaging made easy with qMTLab: Software for data simulation,
% analysis, and visualization. Concepts Magn. Reson.. doi: 10.1002/cmr.a.21357
% ----------------------------------------------------------------------------------------------------


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OptionsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @OptionsGUI_OutputFcn, ...
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


% --- Executes just before Custom_OptionsGUI is made visible.
function OptionsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
handles.root = fileparts(which(mfilename()));
handles.CellSelect = [];
handles.caller = [];            % Handle to caller GUI
if (~isempty(varargin))         % If called from GUI, set position to dock left
    handles.caller = varargin{1};
    CurrentPos = get(gcf, 'Position');
    CallerPos = get(handles.caller, 'Position');
    NewPos = [CallerPos(1)+CallerPos(3), CallerPos(2)+CallerPos(4)-CurrentPos(4), CurrentPos(3), CurrentPos(4)];
    set(gcf, 'Position', NewPos);
end

% Load model parameters
Model = varargin{2};
setappdata(0,'Model',Model);
Nparam=length(Model.xnames);
Model.Prot=[];
FitOptTable(:,1)=Model.xnames(:);
FitOptTable(:,2)=mat2cell(logical(Model.fx(:)),ones(Nparam,1));
FitOptTable(:,3)=mat2cell(Model.st(:),ones(Nparam,1));
FitOptTable(:,4)=mat2cell(Model.lb(:),ones(Nparam,1));
FitOptTable(:,5)=mat2cell(Model.ub(:),ones(Nparam,1));
set(handles.FitOptTable,'Data',FitOptTable)
set(handles.ProtFormat,'String',strjoin(Model.ProtFormat))
set(handles.tableProt,'ColumnName',Model.ProtFormat(:))

% Load model specific options
opts=Model.buttons;

if ~isempty(opts)
    N = length(opts)/2;
    nboptions = max(25,N);
    [I,J]=ind2sub([1 nboptions],1:2*N); Iw = 0.8/max(I); I=(0.1+0.8*(I-1)/max(I)); Jh = 0.1; J=(J-1)/nboptions; J=1-J-Jh;
    for i = 1:N
        if isfield(Model.options,matlab.lang.makeValidName(opts{2*i-1})), val = Model.options.(matlab.lang.makeValidName(opts{2*i-1})); else val = opts{2*i}; end % retrieve previous value
        if islogical(opts{2*i})
            OptionsPanel_handle(i) = uicontrol('Style','checkbox','String',opts{2*i-1},...
                'Parent',handles.OptionsPanel,'Units','normalized','Position',[I(2*i-1) J(2*i-1) Iw Jh/2],...
                'Value',val,'HorizontalAlignment','center');
        elseif isnumeric(opts{2*i})
            uicontrol('Style','Text','String',[opts{2*i-1} ':'],...
                'Parent',handles.OptionsPanel,'Units','normalized','HorizontalAlignment','left','Position',[I(2*i-1) J(2*i-1) Iw/2 Jh/2]);
            OptionsPanel_handle(i) = uicontrol('Style','edit',...
                'Parent',handles.OptionsPanel,'Units','normalized','Position',[(I(2*i-1)+Iw/2) J(2*i-1) Iw/2 Jh/2],'String',val);
        elseif iscell(opts{2*i})
            uicontrol('Style','Text','String',[opts{2*i-1} ':'],...
                'Parent',handles.OptionsPanel,'Units','normalized','HorizontalAlignment','left','Position',[I(2*i-1) J(2*i-1) Iw/3 Jh/2]);
            if iscell(val), val = 1; else val =  find(cell2mat(cellfun(@(x) strcmp(x,val),opts{2*i},'UniformOutput',0))); end % retrieve previous value
            OptionsPanel_handle(i) = uicontrol('Style','popupmenu',...
                'Parent',handles.OptionsPanel,'Units','normalized','Position',[(I(2*i-1)+Iw/3) J(2*i-1) 2.2*Iw/3 Jh/2],'String',opts{2*i},'Value',val);
            
        end
    end
    
    
    % Create CALLBACK for buttons
    setappdata(0,'Model',Model);
    handles.OptionsPanel_handle=OptionsPanel_handle;
    for ih=1:length(OptionsPanel_handle)
        set(OptionsPanel_handle(ih),'Callback',@(src,event) ModelOptions_Callback(handles))
    end
    ModelOptions_Callback(handles);
end

guidata(hObject, handles);





function varargout = OptionsGUI_OutputFcn(hObject, eventdata, handles) 
%varargout{1} = handles.output;



% #########################################################################
%                           SIMULATION PANEL
% #########################################################################


% ############################ PARAMETERS #################################


% ########################## SIM OPTIONS ##################################



% #########################################################################
%                           FIT OPTIONS PANEL
% #########################################################################

% GETFITOPT Get Fit Option from table
function Model = SetOpt(handles)
% fitting options
fittingtable = get(handles.FitOptTable,'Data'); % Get options
Model = getappdata(0,'Model');
Model.xnames = fittingtable(:,1)';
Model.fx = cell2mat(fittingtable(:,2)');
Model.st = cell2mat(fittingtable(:,3)');
Model.lb = cell2mat(fittingtable(:,4)');
Model.ub = cell2mat(fittingtable(:,5)');
% check that starting point > lb and < ub
Model.st = max([Model.st; Model.lb],[],1);
Model.st = min([Model.st; Model.ub],[],1);
fittingtable(:,3) = mat2cell(Model.st(:),ones(length(Model.st),1));
set(handles.FitOptTable,'Data',fittingtable);
% ModelOptions
opts = Model.buttons;
N=length(opts)/2;
for i=1:N
    if islogical(opts{2*i})
        optionvalue = get(handles.OptionsPanel_handle(i),'Value');
    elseif isnumeric(opts{2*i})
        optionvalue = str2num(get(handles.OptionsPanel_handle(i),'String'));
    elseif iscell(opts{2*i})
        optionvalue = opts{2*i}{get(handles.OptionsPanel_handle(i),'Value')};
    end
    Model.options.(matlab.lang.makeValidName(opts{2*i-1}))=optionvalue;
end
setappdata(0,'Model',Model);


% FitOptTable CellEdit
function FitOptTable_CellEditCallback(hObject, eventdata, handles)
SetOpt(handles);

function FitOptTable_CreateFcn(hObject, eventdata, handles)

% #########################################################################
%                           PROTOCOL PANEL
% #########################################################################

% LOAD
function ProtLoad_Callback(hObject, eventdata, handles)
[FileName,PathName,filterindex] = uigetfile({'*.mat';'*.xls;*.xlsx';'*.txt;*.scheme'},'Load Protocol Matrix');
if PathName == 0, return; end
switch filterindex
    case 1
        Prot = load(fullfile(PathName,FileName));
    case 2
        Prot = xlsread(fullfile(PathName,FileName));
    case 3
        Prot = txt2mat(fullfile(PathName,FileName));
end
Model = getappdata(0,'Model');
Model.Prot = Prot;
setappdata(0,'Model',Model);
set(handles.tableProt,'Data',Prot)
set(handles.ProtFileName,'String',FileName);

% #########################################################################
%                           MODEL OPTIONS PANEL
% #########################################################################

function ModelOptions_Callback(handles)
SetOpt(handles);