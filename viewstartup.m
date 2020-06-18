function viewstartup(app)

% +-------------------------------------------------------------------------+
% | Copyright (c) 2018 LLC ICS Development Center                           |
% | MATLAB  R2017b                                                          |
% | Version 1.0.1                                                           |
% | Created by D. Zherebyatyev                                              |
% +-------------------------------------------------------------------------+
%
%   Toolbar's toggle buttons:
%   
%   - Open:
%       - Select a WAVE or MP3 to open (the audio can be multichannel).
%       - Display the audio signal and the audio spectrogram (in dB); the 
%       horizontal limits of the signal and spectrogram axes will be 
%       synchronized (and will stay synchronized if a zoom or pan is 
%       applied on any of the axes).
%   
%   - Play/Stop:
%       - Play the audio if the playback is not in progress; stop the audio 
%       if the playback is in progress; a playback line will be displayed 
%       as the playback is in progress.
%       - If there is no selection line or region, the audio will be played 
%       from the start to the end; if there is a selection line, the audio 
%       will be played from the selection line to the end of the audio; if 
%       there is a selection region, the audio will be played from the 
%       start to the end of the selection region.
%   
%   - Select/Drag:
%       - If a left mouse click is done on the signal axes, a selection 
%       line is created; the audio will be played from the selection line 
%       to the end of the audio.
%       - If a left mouse click and drag is done on the signal axes or on a 
%       selection line, a selection region is created; the audio will be 
%       played from the start to the end of the selection region.
%       - If a left mouse click and drag is done on the left or right 
%       boundary of a selection region, the selection region is resized.
%       - If a right mouse click is done on the signal axes, any selection 
%       line or region is removed.
%       
%   - Zoom:
%       - Turn zooming on or off or magnify by factor 
%       (see https://mathworks.com/help/matlab/ref/zoom.html)
%       - If used on the signal axes, zoom horizontally only; the 
%       horizontal limits of the signal and spectrogram axes will stay 
%       synchronized.
%   
%   - Pan:
%       - Pan view of graph interactively 
%       (see https://www.mathworks.com/help/matlab/ref/pan.html)
%       - If used on the signal axes, pan horizontally only; the horizontal 
%       limits of the signal and spectrogram axes will stay synchronized.

    clc;
    addpath '../library/mfcc:../library/neuronet';
    addpath ctrl:ctrl/fft:ctrl/mfcc::ctrl/sign:ctrl/filter:ctrl/wavelet:gui:model:view;

    app.UI = {};

    if ~isfield(app.UI, 'figures') 
        app.UI.figures = {};
    end
    if ~isfield(app, 'options') 
        app.options.wavelet = {};
    end
    
    if ~isfield(app, 'functions') 
        app.functions = {};
    end
        
    % Get screen size
    screen_size = get(0,'ScreenSize');

    % Create figure window
    app.UI.figures.ctrl = figure( ...
        'Visible','off', ...
        'Position',[screen_size(3:4)/4+1, screen_size(3:4)/2], ...
        'Name', 'Recogbition Audio', ...
        'NumberTitle','off', ...
        'MenuBar','none');
    
   
    figure(app.UI.figures.ctrl);
    app = gui_initfigure(app);
 
    if isfield(app, 'audio_signal') 
        ctrl_core_common(app)
    end
    
    
%% function utils
    % Audio signal starting analiz 
    function ctrl_core_common(app)
        % Set a axes tool
        app = ctrl_core_init(app);
        app = gui_common_audio(app);   
               
        % Add close request callback function to the figure object
        app.UI.figures.ctrl.CloseRequestFcn  = {@gui_figurecloserequestfcn, app};
        
        % Add clicked callback function to the play toggle button
        app.UI.Play_toggle.ClickedCallback = {@gui_playclickedcallback, app};          
        
        % Enable the play, select, zoom, and pan toggle buttons
        app.UI.Play_toggle.Enable   = 'on';
        app.UI.Select_toggle.Enable = 'on';
        app.UI.ZoomIn_toggle.Enable = 'on';
        app.UI.Pan_toggle.Enable  = 'on';
        
        % Change the select toggle button states to on
        app.UI.Select_toggle.State = 'on';        
    end
    
     %Init tollvbar
    function app = gui_initfigure(app)

         app.playicon = playicon;
         app.stopicon = stopicon;
         app.func.playsample = @gui_playsample;

        % Create toolbar on figure
        app.UI.Toolbar = uitoolbar(app.UI.figures.ctrl);

        % Create open and play toggle buttons on toolbar
        app.UI.Open_toggle = uitoggletool(app.UI.Toolbar, ...
            'CData', iconread('file_open.png'), ...
            'TooltipString','Open', ...
            'Enable','on', ...
            'ClickedCallback',@ui_openclickedcallback);
        app.UI.Play_toggle = uitoggletool(app.UI.Toolbar, ...
            'CData', app.playicon, ...
            'TooltipString','Play', ...
            'Enable','off');

        % Create pointer, zoom, and hand toggle buttons on toolbar
        app.UI.Select_toggle = uitoggletool(app.UI.Toolbar, ...
            'Separator','On', ...
            'CData',iconread('tool_pointer.png'), ...
            'TooltipString','Select', ...
            'Enable','off');

        app.UI.ZoomIn_toggle = uitoggletool(app.UI.Toolbar, ...
            'CData',iconread('tool_zoom_in.png'), ...
            'TooltipString','Zoom', ...
            'Enable','off');

        app.UI.ZoomOut_toggle = uitoggletool(app.UI.Toolbar, ...
            'CData',iconread('tool_zoom_out.png'), ...
            'TooltipString','Zoom', ...
            'Enable','off');
        
        app.UI.Pan_toggle = uitoggletool(app.UI.Toolbar, ...
            'CData',iconread('tool_hand.png'), ...
            'TooltipString','Pan', ...
            'Enable','off');
                
            % Create signal and spectrogram axes
            app.axes.signal = axes( ...
                'Units','normalized', ...
                'Position',[0.05,0.75,0.93,0.2], ...
                'XTick',[], ...
                'YTick',[], ...
                'Box','on');

            app.axes.fft = axes( ...                
                'Units','normalized', ...
                'Position' ,[0.05 0.50 0.93 0.2], ...
                'XTick',[], ...
                'YTick',[], ...
                'Box','on'); 

            app.axes.spectrogram = axes( ...                
                'Units','normalized', ...
                'Position',[0.05,0.05,0.93,0.4], ...
                'XTick',[], ...
                'YTick',[], ...
                'Box','on');  
                      
            app.axes.sample = axes( ...                
                'Units','normalized', ...
                'Position' ,[0.5 0.10 0.49 0.3], ...
                'XTick',[], ...
                'YTick',[], ...
                'Box','on'); 

        % Synchronize the x-axis limits of the signal and spectrogram axes
        linkaxes([app.axes.signal, app.axes.spectrogram], 'x')

        % Change the pointer when the mouse moves over the signal axes
        enterFcn = @(figure_handle, currentPoint) set(figure_handle,'Pointer','ibeam');
        iptSetPointerBehavior(app.axes.signal, enterFcn);
        iptPointerManager(app.UI.figures.ctrl);

        % Make the figure visible
        app.UI.figures.ctrl.Visible = 'on';   
        
        % Add clicked callback functions to the select, zoom, and pan 
        % toggle buttons
        app.UI.Select_toggle.ClickedCallback  = @gui_select_clickedCallback;
        app.UI.ZoomIn_toggle.ClickedCallback  = @gui_zoomIn_clickedCallback;
        app.UI.ZoomOut_toggle.ClickedCallback = @gui_zoomOut_clickedCallback;
        app.UI.Pan_toggle.ClickedCallback     = @gui_pan_clickedCallback;      
        
  
    end

    % Clicked callback function for the open toggle button
    function ui_openclickedcallback(~,~)
        
        % Change toggle button state to off
        app.UI.Open_toggle.State = 'off';
        
        % Open file selection dialog box
        [app.audio_name, app.audio_path] = uigetfile({'*.wav';'*.mp3'}, ...
            'Select WAVE or MP3 File to Open');

        if isequal(app.audio_name, 0)
            return
        end

        app = ctrl_core_read(app);
              ctrl_core_common(app);
    end

    % Clicked callback function for the select toggle button
    function gui_select_clickedCallback(~,~)
        
        % Keep the select toggle button state to on and change the zoom and 
        % pan toggle button states to off
        app.UI.Select_toggle.State = 'on';
        app.UI.ZoomIn_toggle.State = 'off';
        app.UI.Pan_toggle.State = 'off';
        
        % Turn the zoom off
        zoom off
        
        % Turn the pan off
        pan off
        
    end

    % Clicked callback function for the zoom toggle button
    function gui_zoomIn_clickedCallback(~,~)
        
        % Keep the zoom toggle button state to on and change the select and 
        % pan toggle button states to off
        app.UI.Select_toggle.State = 'off';
        app.UI.ZoomIn_toggle.State = 'on';
        app.UI.Pan_toggle.State = 'off';
        
        % Make the zoom enable on the current figure
        zoom_object = zoom(gcf);
        zoom_object.Enable = 'on';
        
        % Set the zoom for the x-axis only in the signal axes
        setAxesZoomConstraint(zoom_object, app.axes.signal,'x');
        
        % Turn the pan off
        pan off
        
    end

    % Clicked callback function for the zoom out toggle button
    function gui_zoomOut_clickedCallback(~,~)
        % Keep the zoom toggle button state to on and change the select and 
        % pan toggle button states to off
        app.UI.Select_toggle.State = 'off';
        app.UI.ZoomIn_toggle.State = 'on';
        app.UI.ZoomOut_toggle.State  = 'off';
        app.UI.Pan_toggle.State = 'off';
        
        % Make the zoom enable on the current figure
        zoom_object = zoom(gcf);
        zoom_object.Enable = 'on';
        
        % Set the zoom for the x-axis only in the signal axes
        setAxesZoomConstraint(zoom_object, app.axes.signal,'x');
        
        % Turn the pan off
        pan off
    end

    % Clicked callback function for the pan toggle button
    function gui_pan_clickedCallback(~,~)
        
        % Keep the pan toggle button state to on and change the select and 
        % zoom toggle button states to off
        app.UI.Select_toggle.State = 'off';
        app.UI.ZoomIn_toggle.State  = 'off';
        app.UI.ZoomOut_toggle.State = 'off';
        app.UI.Pan_toggle.State = 'on';
        
        % Turn the zoom off
        zoom off
        
        % Make the pan enable on the current figure
        pan_object = pan(gcf);
        pan_object.Enable = 'on';
        
        % Set the pan for the x-axis only in the signal axes
        setAxesPanConstraint(pan_object,app.axes.signal,'x');
        
    end

end


% Create play icon
function image_data = playicon

    % Create the upper-half of a black play triangle with NaN's everywhere 
    % else
    image_data = [nan(2,16);[nan(6,3),kron(triu(nan(6,5)),ones(1,2)),nan(6,3)]];

    % Make the whole black play triangle image
    image_data = repmat([image_data;image_data(end:-1:1,:)],[1,1,3]);

end
 
% Create stop icon
function image_data = stopicon

    % Create a black stop square with NaN's everywhere else
    image_data = nan(16,16);
    image_data(4:13,4:13) = 0;

    % Make the black stop square an image
    image_data = repmat(image_data,[1,1,3]);

end

% Read icon from Matlab
function image_data = iconread(icon_name)

    % Read icon image from Matlab ([16x16x3] 16-bit PNG) and also return 
    % its transparency ([16x16] AND mask)
    [image_data,~,image_transparency] ...
        = imread(fullfile(matlabroot,'toolbox','matlab','icons', icon_name),'PNG');

    % Convert the image to double precision (in [0,1])
    image_data = im2double(image_data);

    % Convert the 0's to NaN's in the image using the transparency
    image_data(image_transparency==0) = NaN;

end

% Close request callback function for the figure
function gui_figurecloserequestfcn(~, ~, app)

    % If the playback is in progress
    if isplaying(app.player.audio)
        % Stop the audio
        stop(app.player.audio);
    end

    % Delete the current figure
    delete(gcf);
    delete(app.UI.figures.mfcc);
end

function gui_playsample(app, audio_sample, ampl )

    % If the playback of the audio player is in progress
    if isplaying(app.player.audio)
        % Stop the playback
        stop(app.player.audio);
    end

    ctrl_core_play(app, audio_sample, ampl);
end

% Clicked callback function for the play toggle button
function gui_playclickedcallback(object_handle, ~, app)

    % Change the toggle button state to off
    object_handle.State = 'off';

    % If the playback of the audio player is in progress
    if isplaying(app.player.audio)

        % Stop the playback
        stop(app.player.audio)
    else
   
        % Get the sample range of the audio player from its user data 
        sample_range = app.player.audio.UserData;
        % Play the audio given the sample range
        play(app.player.audio, sample_range);
        % add sample analiz 
        ctrl_core_sample(app);
    end

end

% [EOF]