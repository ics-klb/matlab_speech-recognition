function appOut = gui_common_audio(app)
                           
        % Create object for playing audio
        app.player.audio = audioplayer(app.audio_signal, app.options.Fs);
        
        % Store the sample range in the user data of the audio player
        app.player.audio.UserData = [1, app.options.number_samples];
       
        % Update the signal axes properties
        app.axes.signal.XLim = [1, app.options.number_samples]/app.options.Fs;
        app.axes.signal.YLim = [-1,1];
        app.axes.signal.XGrid = 'on';
        app.axes.signal.Title.String = app.audio_name;
        app.axes.signal.Title.Interpreter = 'None';
        app.axes.signal.XLabel.String = 'Time (s)';
        app.axes.signal.Layer = 'top';
               
        % Update the spectrogram axes properties
%       app.axes.spectrogram.Colormap = jet;
        app.axes.spectrogram.YDir = 'normal';
        app.axes.spectrogram.XGrid = 'on';
        app.axes.spectrogram.Title.String = 'Spectrogram (dB)';
        app.axes.spectrogram.XLabel.String = 'Time (s)';
        app.axes.spectrogram.YLabel.String = 'Frequency (Hz)';
                             
        app = ctrl_audio_common(app);

        % Set a select audio tool on the signal axes using the audio player
        gui_selectaudiotool(app);

        % Set a play audio tool on the signal axes using the audio player
        gui_playaudiotool(app);
        
    appOut = app;
end

% Set a select audio tool on the signal axes using the audio player
function gui_selectaudiotool(app)

    % Add mouse-click callback function to the audio signal axes
    app.axes.signal.ButtonDownFcn = @signalaxesbuttondownfcn;

    % Initialize the audio line and the audio patch with its two audio lines
    audio_line  = [];
    audio_patch = [];
    audio_line1 = [];
    audio_line2 = [];

    % toogle play/stop
    function gui_audioplayersampleplay(app)

        if isplaying(app.player.audio)
            % Stop the playback
            stop(app.player.audio)
        end

        % Get the sample range of the audio player from its user data 
        sample_range = app.player.audio.UserData;
        % Play the audio given the sample range
        play(app.player.audio, sample_range);
        
        ctrl_core_sample(app);
    end

    % Mouse-click callback function for the signal axes
    function signalaxesbuttondownfcn(~,~)
        
        % Location of the mouse pointer
        current_point = app.axes.signal.CurrentPoint;
        
        % Minimum and maximum x and y-axis limits
        x_lim = app.axes.signal.XLim;
        y_lim = app.axes.signal.YLim;
        
        % If the current point is out of the axis limits, return
        if current_point(1,1) < x_lim(1) || current_point(1,1) > x_lim(2) || ...
                current_point(1,2) < y_lim(1) || current_point(1,2) > y_lim(2)
            return
        end
        
        % Current figure handle
        app.UI.figures.ctrl = gcf;
        
        % Mouse selection type
        selection_type = app.UI.figures.ctrl.SelectionType;
        
        % Sample rate and number of samples from the audio player
        app.options.Fs = app.player.audio.SampleRate;
        app.options.number_samples = app.player.audio.TotalSamples;
        
        % If click left mouse button
        if strcmp(selection_type,'normal')
            
            % If not empty, delete the audio line
            if ~isempty(audio_line)
                delete(audio_line)
            end
            
            % If not empty, delete the audio patch and its two audio lines
            if ~isempty(audio_patch)
                delete(audio_line1)
                delete(audio_line2)
                delete(audio_patch)
            end
            
            % Create an audio line on the signal axes
            audio_line = line(app.axes.signal, current_point(1,1)*[1,1],[-1,1]);
            
            % Make the audio line not able to capture mouse clicks
            audio_line.PickableParts  = 'none';
            
            % Create an audio patch with two audio lines on the signal axes
            color_value = 0.75*[1,1,1];
            audio_patch = patch(app.axes.signal, ...
                current_point(1)*[1,1,1,1],[-1,1,1,-1], color_value,'LineStyle','none');
            audio_line1 = line(app.axes.signal, ...
                current_point(1,1)*[1,1],[-1,1],'Color',color_value);
            audio_line2 = line(app.axes.signal, ...
                current_point(1,1)*[1,1],[-1,1],'Color',color_value);
            
            % Shift the patch and its two audio lines under the signal axes 
            uistack(audio_patch,'bottom')
            uistack(audio_line1,'bottom')
            uistack(audio_line2,'bottom')
            
            % Make the audio patch not able to capture mouse clicks
            audio_patch.PickableParts = 'none';
            
            % Add mouse-click callback function to the two audio lines of
            % the audio patch
            audio_line1.ButtonDownFcn = @audiolinebuttondownfcn;
            audio_line2.ButtonDownFcn = @audiolinebuttondownfcn;
            
            % Change the pointer to a hand when the mouse moves over the 
            % audio lines of the audio patch and the audio signal axes
            enterFcn = @(figure_handle, currentPoint) set(figure_handle,'Pointer','hand');
                iptSetPointerBehavior(audio_line1, enterFcn);
                iptSetPointerBehavior(audio_line2, enterFcn);
                iptSetPointerBehavior(app.axes.signal, enterFcn);
                iptPointerManager(app.UI.figures.ctrl);
            
            % Add window button motion and up callback functions to the 
            % figure
            app.UI.figures.ctrl.WindowButtonMotionFcn = {@figurewindowbuttonmotionfcn,audio_line2};
            app.UI.figures.ctrl.WindowButtonUpFcn     = @figurewindowbuttonupfcn;
            
            % Update the start sample of the audio player in its user data 
            app.player.audio.UserData(1) = round(current_point(1,1) * app.options.Fs);
            
        % If click right mouse button
        elseif strcmp(selection_type,'alt')
            
            % If not empty, delete the audio line
            if ~isempty(audio_line)
                delete(audio_line)
            end
            
            % If not empty, delete the audio patch and its two audio lines
            if ~isempty(audio_patch)
                delete(audio_line1)
                delete(audio_line2)
                delete(audio_patch)
            end
            
            % Update the sample range of the audio player in its user data 
            app.player.audio.UserData = [1, app.options.number_samples];
            
        end
        
        % Mouse-click callback function for the audio lines of the audio patch
        function audiolinebuttondownfcn(object_handle,~)
            
            % Mouse selection type
            selection_type = app.UI.figures.ctrl.SelectionType;
            
            % If click left mouse button
            if strcmp(selection_type,'normal')
                
                % Change the pointer to a hand when the mouse moves over
                % the signal axes
                enterFcn = @(figure_handle, currentPoint) set(figure_handle,'Pointer','hand');
                iptSetPointerBehavior(app.axes.signal, enterFcn);
                iptPointerManager(app.UI.figures.ctrl);
                
                % Add window button motion and up callback functions to 
                % the figure
                app.UI.figures.ctrl.WindowButtonMotionFcn = {@figurewindowbuttonmotionfcn, object_handle};
                app.UI.figures.ctrl.WindowButtonUpFcn = @figurewindowbuttonupfcn;
                
            % If click right mouse button
            elseif strcmp(selection_type,'alt')
                
                % Delete the audio line and the audio patch with its two 
                % audio lines
                delete(audio_line)
                delete(audio_line1)
                delete(audio_line2)
                delete(audio_patch)
                
                % Update the sample range of the audio player in its user 
                % data
                app.player.audio.UserData = [1,app.options.number_samples];
                
            end
            
        end
        
        % Window button motion callback function for the figure
        function figurewindowbuttonmotionfcn(~,~, audio_linei)
            
            % Location of the mouse pointer on the signal axes
            current_point = app.axes.signal.CurrentPoint;
            
            % If the current point is out of the x-axis limits, return
            if current_point(1,1) < x_lim(1) || current_point(1,1) > x_lim(2)
                return
            end
            
            % Update the coordinates of the audio line of the audio patch 
            % that has been clicked and the coordinates of the audio patch
            audio_linei.XData = current_point(1,1)*[1,1];
            audio_patch.XData = [audio_line1.XData,audio_line2.XData];
            
            % If the two audio lines of the audio patch are at different 
            % coordinates and the audio patch is a full rectangle
            if audio_line1.XData(1) ~= audio_line2.XData(1)
                
                % Hide the audio line without deleting it
                audio_line.Visible = 'off';
                
            % If the two audio lines of the audio patch are at the same 
            % coordinates and the audio patch is a vertical line
            else
                
                % Update the coordinates of the audio line and display it
                audio_line.XData = current_point(1,1)*[1,1];
                audio_line.Visible = 'on';
            end
            
        end
        
        % Window button up callback function for the figure
        function figurewindowbuttonupfcn(~,~)
            
            % Change the pointer to a ibeam when the mouse moves over the 
            % signal axes in the figure
            enterFcn = @(figure_handle, currentPoint) set(figure_handle,'Pointer','ibeam');
            iptSetPointerBehavior(app.axes.signal, enterFcn);
            iptPointerManager(app.UI.figures.ctrl);
            
            % Coordinates of the two audio lines of the audio patch
            x_value1 = audio_line1.XData(1);
            x_value2 = audio_line2.XData(1);
            
            % If the two audio lines of the audio patch are at the same
            % coordinates
            if x_value1 == x_value2
                
                % Update the sample range of the audio player in its user
                % data
                app.player.audio.UserData = [round(x_value1*app.options.Fs), app.options.number_samples];
                
            % If audio_line1 is on the left side of audio_line2
            elseif x_value1 < x_value2
                
                % Update the sample range of the audio player in its user
                % data
                app.player.audio.UserData = round([x_value1, x_value2] * app.options.Fs);
            
            % If audio_line1 is on the right side of audio_line2
            else
                
                % Update the sample range of the audio player in its user
                % data (reversed)
                app.player.audio.UserData = round([x_value2,x_value1] * app.options.Fs);
                
            end
                        
            % Remove the window button motion and up callback functions of
            % the figure
            app.UI.figures.ctrl.WindowButtonMotionFcn = '';
            app.UI.figures.ctrl.WindowButtonUpFcn = '';
            
            gui_audioplayersampleplay(app);
        end
        
    end          

end
