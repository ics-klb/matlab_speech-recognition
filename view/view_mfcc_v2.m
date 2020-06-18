function view_mfcc_v2(app, audio_sample, config)

% +-------------------------------------------------------------------------+
% | Copyright (c) 2018 LLC ICS Development Center                           |
% | Project:  LICENSE                                                       |
% | Version 1.0.1                                                           |
% | Created by D. Zherebyatyev & C. Starakozhev                             |
% +-------------------------------------------------------------------------+
%  This script is a step by step walk-through of computation of the
%  mel frequency cepstral coefficients (MFCCs) from a speech signal
%  using the MFCC routine.
%  See also MFCC, COMPARE.
%  Author: Kamil Wojcicki, September 2011
   
    % Define variables
    mfcc_config = app.config.mfcc;    
%     mfcc_config.Tw = 25;       % analysis frame duration (ms)
%     mfcc_config.Ts = 10;       % analysis frame shift (ms)
%     mfcc_config.alpha = 0.97;  % preemphasis coefficient
%     mfcc_config.M = 20;        % number of filterbank channels 
%     mfcc_config.C = 12;        % number of cepstral coefficients 
%     mfcc_config.L = 22;        % cepstral sine lifter parameter
%     mfcc_config.LF = 10;       % lower frequency limit (Hz)
%     mfcc_config.HF = 3700;     % upper frequency limit (Hz)

    mfcc_config.Fs = app.options.Fs;
    fs = mfcc_config.Fs;
    
    lenspeech = length(audio_sample);
    % Feature extraction (feature vectors as columns)
    [ MFCCs, FBEs, frames ] = ...
                    mfcc( audio_sample, mfcc_config.Fs, mfcc_config.Tw, mfcc_config.Ts, ...
                    mfcc_config.alpha, @hamming, [mfcc_config.LF mfcc_config.HF], ...
                    mfcc_config.M, mfcc_config.C+1, mfcc_config.L );


    % Generate data needed for plotting 
    [ Nw, NF ] = size( frames );                      % frame length and number of frames
    time_frames = [0:NF-1] * mfcc_config.Ts * 0.001+0.5*Nw / fs;  % time vector (s) for frames 
    time = [ 0:lenspeech-1 ] / fs;                    % time vector (s) for signal samples 
    logFBEs = 20*log10( FBEs );                       % compute log FBEs for plotting
    logFBEs_floor = max(logFBEs(:))-50;               % get logFBE floor 50 dB below max
    logFBEs( logFBEs<logFBEs_floor ) = logFBEs_floor; % limit logFBE dynamic range


 if mfcc_config.figs == 1
    % Generate plots
    mfccv2 = figure('Position', [30 30 800 600], 'PaperPositionMode', 'auto', ... 
              'Name', 'MFCC Kamil Wojcicki', ...
              'color', 'w', 'PaperOrientation', 'landscape', 'Visible', 'on' ); 

    subplot( 411 );
    plot( time, audio_sample, 'k' );
    xlim( [ min(time_frames) max(time_frames) ] );
    xlabel( 'Time (s)' ); 
    ylabel( 'Amplitude' ); 
    title( 'Speech waveform'); 

    subplot( 412 );
    imagesc( time_frames, [1:mfcc_config.M], logFBEs ); 
    axis( 'xy' );
    xlim( [ min(time_frames) max(time_frames) ] );
    xlabel( 'Time (s)' ); 
    ylabel( 'Channel index' ); 
    title( 'Log (mel) filterbank energies'); 

    subplot( 413 );
    imagesc( time_frames, [1:mfcc_config.C], MFCCs(2:end,:) ); % HTK's TARGETKIND: MFCC
    %imagesc( time_frames, [1:mfcc_config.C+1], MFCCs );       % HTK's TARGETKIND: MFCC_0
    axis( 'xy' );
    xlim( [ min(time_frames) max(time_frames) ] );
    xlabel( 'Time (s)' ); 
    ylabel( 'Cepstrum index' );
    title( 'Mel frequency cepstrum' );

   % Look at its regular spectrogram
    subplot( 414);    
    specgram(audio_sample, 256, fs);
    title( 'Look at its regular spectrogram' );
    
    % Set color map to grayscale
%     colormap( 1-colormap('gray') ); 

    % Print figure to pdf and png files
%     print('-dpdf', sprintf('%s.pdf', mfilename)); 
%     print('-dpng', sprintf('%s.png', 
 end
end

