function view_simple(app)
 
    fs = app.options.Fs;
    % Matlab's spectrogram whith mean 
    audio_spectrogram = spectrogram(mean(app.audio_signal, 2), app.params.window_function, ...
                            app.params.window_length-app.params.step_length);
%     audio_spectrogram = spectrogram(app.audio_signal, 256, fs);
 
    % Number of time frames
    number_times = size(audio_spectrogram,2);

    % Magnitude spectrogram without DC component and mirrored frequencies
    audio_spectrogram = abs(audio_spectrogram(2:end,:));    
               
    % Plot the audio signal and make it unable to capture mouse clicks
    osX =  1/app.options.Fs : 1/app.options.Fs : app.options.number_samples/app.options.Fs;
    plot(app.axes.signal, osX, app.audio_signal, ...
        'PickableParts','none');

    % Plot the audio signal and make it unable to capture mouse clicks
    osX =  1/fs : 1/fs : app.options.number_samples/fs;
    plot(app.axes.fft, osX, app.audio_signal, ...
        'PickableParts','none');

    % Display the audio spectrogram (in dB)
    imagesc(app.axes.spectrogram, ...
        [1, number_times]/number_times * app.options.number_samples/fs, ...
        [1, app.params.window_length/2] / app.params.window_length*fs, ...
        db(audio_spectrogram));

end

