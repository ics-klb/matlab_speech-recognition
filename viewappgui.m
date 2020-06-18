function  viewappgui(app)
  
        app.options.Fs = app.Fs;

        % Number of samples
        app.options.number_samples = size(app.audio_signal,1);

        % Window length in samples (audio stationary around 40 ms and power 
        % of 2 for fast FFT and constant overlap-add)
        app.params.window_length = 2.^nextpow2(0.04* app.options.Fs);

        % Window function ('periodic' Hamming window for constant 
        % overlap-add)
        app.params.window_function = hamming(app.params.window_length, 'periodic');

        % Step length (half the (even) window length for constant 
        % overlap-add)
        app.params.step_length = app.params.window_length/2;
        
    % Matlab's spectrogram
    audio_spectrogram = spectrogram(mean(app.audio_signal, 2), app.params.window_function, app.params.window_length-app.params.step_length);

    % Number of time frames
    number_times = size(audio_spectrogram,2);

    % Magnitude spectrogram without DC component and mirrored 
    % frequencies
    audio_spectrogram = abs(audio_spectrogram(2:end,:));    
       
    % Plot the audio signal and make it unable to capture mouse clicks
    osX =  1/app.options.Fs : 1/app.options.Fs : app.options.number_samples/app.options.Fs;
    plot(app.axes.signal, osX, app.audio_signal, ...
        'PickableParts','none');

    % Display the audio spectrogram (in dB)
    imagesc(app.axes.spectrogram, ...
        [1, number_times]/number_times*app.options.number_samples/app.options.Fs, ...
        [1, app.params.window_length/2]/app.params.window_length*app.options.Fs, ...
        db(audio_spectrogram));
    
end