% Set a play audio tool on the signal axes using the audio player
function gui_playaudiotool(app)

    % Add callback functions to the audio player
    app.player.audio.StartFcn      = @audioplayerstartfcn;
    app.player.audio.StopFcn       = @audioplayerstopfcn;
    app.player.audio.TimerFcn      = @audioplayertimerfcn;
   

    % Sample rate in Hz from the audio player
    app.options.Fs = app.player.audio.SampleRate;

    % Initialize the audio line
    audio_line = [];
    
    % Function to execute one time when the playback starts
    function audioplayerstartfcn(~,~)
        
        % Change the play toggle button icon to a stop icon and the tool
        % tip text to 'Stop'
        app.UI.Play_toggle.CData = app.stopicon;
        app.UI.Play_toggle.TooltipString = 'Stop';
        
        % Sample range in samples from the audio player
        sample_range = app.player.audio.UserData;
        
        % Create an audio line on the audio signal axes
        audio_line = line(app.axes.signal, sample_range(1)/app.options.Fs*[1,1], [-1,1]);
        
    end
    
    % Function to execute one time when playback stops
    function audioplayerstopfcn(~,~)
        
        % Change the play toggle button icon to a play icon and the tool
        % tip text to 'Play'
        app.UI.Play_toggle.CData = app.playicon;
        app.UI.Play_toggle.TooltipString = 'Play';
        
        % Delete the audio line
        delete(audio_line)
        
    end
    
    % Function to execute repeatedly during playback
    function audioplayertimerfcn(~,~)
        
        % Current sample and sample range from the audio player
        current_sample = app.player.audio.CurrentSample;
        sample_range = app.player.audio.UserData;
        
        % Make sure the current sample is greater than the start sample (to
        % prevent the audio line from showing up at the start at the end)
        if current_sample > sample_range(1)
        
            % Update the audio line
            audio_line.XData = current_sample/app.options.Fs*[1,1];
            
        end
        
    end

end
