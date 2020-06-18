function view_mfcc(app, audio_sample, config)
 
    % function handle for mean square error computation 
    MSE = @(x,y)(mean((x(:)-y(:)).^2));

    % function handle for newline display
    newline = @()( fprintf('\n') );
    
    
    %% MFCC TOOL (THIS IMPLEMENTATION)  ( mfcc/K-means/Kmeans/)

    % specify MFCC feature filename   
    mfcc_config = app.config.mfcc;

    audio_melfcc = 0.5 * melfcc( audio_sample, mfcc_config.Fs, 'wintime', mfcc_config.Tw * 1E-3, ...
            'hoptime', mfcc_config.Ts * 1E-3, 'preemph', 0.97, 'minfreq', mfcc_config.LF, ...
            'maxfreq', mfcc_config.HF, 'nbands', mfcc_config.M, 'numcep', mfcc_config.C+1, 'lifterexp', -mfcc_config.L, ...
            'dcttype', 3, 'fbtype', 'htkmel', 'sumpower', 0 );  
        
    % view simple mfcc 3-D
    [s_coef ] = ctl_mfcc_getmellcoef(app, audio_sample, mfcc_config);
    %mesh(s_coef);
    
    %% MFCC TOOL (THIS IMPLEMENTATION)

    % specify MFCC feature filename
%     this.feature_file = sprintf( '%s_mfcc.mfc', config.basemfc );

    % extract using the included mfcc(...) function (this implementation)
    audio_mfcc = mfcc( audio_sample, mfcc_config.Fs, mfcc_config.Tw, mfcc_config.Ts, ...
                        mfcc_config.alpha, @hamming, [mfcc_config.LF mfcc_config.HF], ...
                        mfcc_config.M, mfcc_config.C+1, mfcc_config.L );
    
    
    %% PLOT COMPARISONS

    % time vector (s) for frames or features
    time = [ 0:size(audio_mfcc, 2)-1 ] * mfcc_config.Ts * 1E-3 + 0.5 * mfcc_config.Tw * 1E-3; 

    figure(app.UI.figures.mfcc);
          
 % Look at its regular spectrogram
    subplot( 3, 1, 1);    
    title( 'Specgram' );
    specgram(audio_sample, 256, mfcc_config.Fs);
 
    subplot( 3, 1, 2 );    
    imagesc( time, [0:mfcc_config.M-1], audio_mfcc ); axis( 'xy' );
    xlim( [ min(time) max(time) ] );
    xlabel( 'Time (s)' ); 
    ylabel( 'Cepstrum index' );
    title( 'Mel frequency cepstrum: HTK' );
% 
%     subplot( 3,1,2 );    
%     imagesc( time, [0:mfcc_config.M-1], ellis.mfcc ); axis( 'xy' );
%     xlim( [ min(time) max(time) ] );
%     xlabel( 'Time (s)' ); 
%     ylabel( 'Cepstrum index' );
%     title( 'Mel frequency cepstrum: MELFCC' );
% 
%     subplot( 3,1,3 );    
%     imagesc( time, [0:mfcc_config.M-1], this.mfcc ); axis( 'xy' );
%     xlim( [ min(time) max(time) ] );
%     xlabel( 'Time (s)' ); 
%     ylabel( 'Cepstrum index' );
%     title( 'Mel frequency cepstrum: THIS' );

%     print('-dpdf', sprintf('%s.pdf', mfilename)); 
%     print('-dpng', sprintf('%s.png', mfilename));                     
end

