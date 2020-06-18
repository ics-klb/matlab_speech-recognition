function view_fft(app, audio_sample)

    fs = app.options.Fs;
    L = app.config.signal.length;
    T = 1 / fs;
    t = (0:L-1)*T;

%% take fourier transform and plot single sided spectrum
    NFFT = 2 ^ nextpow2(L);
    f =  fs / 2 * linspace(0, 1, NFFT/2+1);

    endOs = round(NFFT/20);

    winh = hamming(L)';
    speech = winh .* audio_sample;
    

%         xf = abs(fft(speech, NFFT));   
%         subplot(2,1,1);plot(speech);title('Input Speech Signal');
%         subplot(2,1,2);plot(f, xf(1:endOs)),title('Single Sided Spectrum of the Speech Signal');

%         % plot PSD (using welch method)
%         h = pwelch; % create welch spectrum object
%         d = psd(h, data,'Fs', fs);
%         figure;
%         plot(d);
% 
%         % Plot PSD (From FFT)
%         % single sided PSD
%         Hpsd = dspdata.psd(xf(1:length(xf)/2),'Fs',fs);
%         figure;plot(Hpsd);

%         % Periodogram Based PSD estimate
%         figure;
%         [psdestx,Fxx] = periodogram(speech,rectwin(length(speech)),length(speech),fs);
%         plot(Fxx,10*log10(psdestx)); grid on;
%         xlabel('Hz'); ylabel('Power/Frequency (dB/Hz)');
%         title('Periodogram Power Spectral Density Estimate');


    
    Y = fft( speech, NFFT);
    P2 = abs(Y/L);
    
    osY = P2(1:floor(L/2+1));
    osY(2:end-1) =  2 * osY(2:end-1);

    osX = fs / L * (0:(L/2));
   
    osYGI  = osY(1:endOs) .^ 2;
    osYmax = max(osY(1:endOs));    
    osYmaxI = max(osYGI) ;
    plot(app.axes.fft, ...
         osX(1:endOs), osY(1:endOs), 'k', ...
         osX(1:endOs), osYmax / osYmaxI * osYGI, 'g', ...         
         osX(1:endOs), medfilt1( osY(1:endOs), 3), 'r', ...
        'PickableParts','none'); 

    title('Single-Sided Amplitude Spectrum of hammming * X(t)')
    xlabel('f (Hz)'),  ylabel('|P1(f)|')

end