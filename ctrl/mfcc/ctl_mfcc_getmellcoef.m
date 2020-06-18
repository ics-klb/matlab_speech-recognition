function [s_coef ] = ctl_mfcc_getmellcoef(app, audio_signal, config)

    Fs = app.options.Fs;
    freq2mel = @(freq) (1127*log(1 + freq./700));
    mel2freq = @(mel) (700*(exp(mel./1127) - 1));

    % Count mell filters
    M_num = 20;
    % make data length be integer multiplier of sample_sz
    sample_sz = 2048;
    y_sz = ceil(length(audio_signal) / sample_sz);
    
    
    
    audio_signal(y_sz*sample_sz) = 0;

    % sampling data
    % sampled_data = reshape(y, [sample_sz, y_sz]).';
    sample_num = y_sz*2 - 1;
    sampled_data = zeros(sample_num, sample_sz);
    start_ind = 1;
    end_ind = start_ind + sample_sz - 1;
    
    for i = 1:sample_num
        sampled_data(i, :) = audio_signal(start_ind:end_ind);
        start_ind = start_ind + sample_sz/2;
        end_ind = end_ind + sample_sz/2;

       % extract MFCCs using RASTAMAT tools [2] (not included)
%         sampled_melfcc(i, :) = 0.5 * melfcc( audio_signal, app.options.Fs, 'wintime', config.Tw*1E-3, ...
%             'hoptime', config.Ts*1E-3, 'preemph', 0.97, 'minfreq', config.LF, ...
%             'maxfreq', config.HF, 'nbands', config.M, 'numcep', config.C+1, 'lifterexp', -L, ...
%             'dcttype', 3, 'fbtype', 'htkmel', 'sumpower', 0 );
    end

    % apply hamming to each sample
    for i = 1:sample_num
        temp_vec = hamming(sample_sz).';
        sampled_data(i, :) = temp_vec.*sampled_data(i, :);
    end

    % Form array of requncies and compute into array of mels
    mel_low_bound = freq2mel(20);
    mel_high_bound = freq2mel(Fs);

    dm = (mel_high_bound - mel_low_bound)/(M_num + 1);
    arr = mel_low_bound : dm : mel_high_bound;
    arr = mel2freq(arr);

    arr = floor((sample_sz/2 + 1)*arr/Fs);

    % compute magnitude spectrums of fft on each sample
    spectrums = zeros(sample_num, sample_sz/2);
    for i = 1:sample_num
        temp_vec = abs(fft(sampled_data(i, :)));
        temp_vec = temp_vec./sample_sz;
        temp_vec = temp_vec(1:length(temp_vec)/2);
        temp_vec(2:end-1) = 2*temp_vec(2:end-1);
        spectrums(i, :) = temp_vec;
    end

    s_coef = zeros(sample_num,M_num);
    for i = 1:sample_num
       for j = 2:(M_num +1)
           temp_vec = ctl_mfcc_melfilter(j, arr, length(spectrums(i, :)));
           temp_vec = (spectrums(i, :).^2) .* temp_vec;
           temp_sum = sum(temp_vec);
           s_coef(i, j - 1) = log(temp_sum); 
       end
       s_coef(i, :) = dct(s_coef(i, :));
    end

%% local functions

    function [res] = ctl_mfcc_melfilter(m, f, range_max)
        % m - filter number within range [2, M_num+1]
        % f - position array
        % range_max - range for k indexes

        % due to different way of indexing in matlab (array starts with index
        % 1) i had to add some elseif statements for handling cases whrn m == 0
        % or m == length(f)

        res = zeros(1, range_max);

        m_min = m - 1;
        m_max = m + 1;
        for k = 1:range_max
            if k >= f(m_min) && k <= f(m)
                res(k) = (k - f(m_min))/(f(m) - f(m_min));
            elseif k >= f(m) && k <= f(m_max)
                res(k) = (f(m_max) - k)/(f(m_max) - f(m));
            end
        end
    end
end 
