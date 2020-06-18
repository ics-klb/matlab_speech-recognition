function view_sign(app, audio_sample)


    fs = app.options.Fs;
    L = app.config.signal.length;
    T = 1/fs;
    t = (0:L-1)*T;

    % testing signal
%     audio_sample =  cos ( 1550 * t + pi/2);
    
    
    sign_config = app.config.sign;

    audio_sign = ctl_sign_code(app, audio_sample, sign_config.porog, sign_config.step);

if app.config.sign.figs == 1    

%    figure; 
%     subplot( 1, 2, 1);  histogram(audio_sample, 5);
%     subplot( 1, 2, 2);  histogram(audio_sign.signsign, 5);
        
    % Generate plots / Plot results
    sigfig =  figure('Position', [60 100 800 600], 'PaperPositionMode', 'auto', ... 
      'Name', 'Signum signal', ...
      'color', 'w', 'PaperOrientation', 'landscape', 'Visible', 'on' ); 

    osT =  1/app.options.Fs : 1 /app.options.Fs : app.config.signal.length / app.options.Fs;   
    axes_signal  = subplot( 3, 1, 1);  
       stairs(osT, audio_sign.sign * audio_sign.maxabs * 0.4, '-.b' ), hold on,
       plot(osT, audio_sample, 'b',  ... 
            audio_sign.time, audio_sign.signdiff * 5 , 'c'); % , audio_sign.time, audio_sign.signsum  * 0.5  + 0.2, 'r' ); 
       grid(axes_signal, 'on'),
       title('Original signal of S(t)'); xlabel('t (c)');
    axes_signsum  = subplot( 3, 1, 2);  
       stem(audio_sign.time, audio_sign.signdiff), hold on,
       plot(osT, audio_sample, '--c');
       title('sign signal of S(t)'); xlabel('t (c)')
    axes_signdiff =  subplot( 3, 1, 3); 
       stem(audio_sign.time, audio_sign.signsign);  hold on,
       plot(osT, audio_sample, '--c');
       title('sign signal of S(t)'); xlabel('t (c)')
    
    % Synchronize the x-axis limits of the signal and spectrogram axes
    linkaxes([axes_signal, axes_signsum, axes_signdiff], 'x');
end    

% [EOF]


