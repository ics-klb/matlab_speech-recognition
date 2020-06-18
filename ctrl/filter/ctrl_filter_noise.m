[y, Fs] = audioread('phone_aru_on.wav');
y = y(:, 1);


%%
[y, Fs] = audioread('phone_aru_on.wav');
y = y(:, 1);

%plot autocorrelation of initial signal
corr_mat = ctrl_corr_mat(y);

X = -size(corr_mat, 2)/2:size(corr_mat, 2)/2-1;
Y = 1:size(corr_mat, 1);

figure
contour(X, Y, corr_mat)
title('Autocorrelation of initial signal')

%filter sound
tic
[work_arr, arr1] = ctrl_fourier_filter(y);
time1 = toc

% sound(10*work_arr, Fs);

figure
subplot(2, 1, 1)
plot(y)

subplot(2, 1, 2)
plot(work_arr)

%generate x-axis for plots
y_x = (-length(y)/2:length(y)/2 - 1)*Fs/length(y);
work_x = (-length(work_arr)/2:length(work_arr)/2 - 1)*Fs/length(work_arr);

figure
subplot(2, 1, 1)
plot(y_x, abs(fftshift(fft(y))))
title('Spectrum of initial signal')
xlim([-Fs/2 Fs/2])

subplot(2, 1, 2)
plot(work_x, abs(fftshift(fft(work_arr))))
title('Spectrum of filtered signal')
xlim([-Fs/2 Fs/2])

%plot autocorrelation of filtered signal
corr_mat = ctrl_corr_mat(y);

X = -size(corr_mat, 2)/2:size(corr_mat, 2)/2-1;
Y = 1:size(corr_mat, 1);

figure
contour(X, Y, corr_mat)
title('Autocorrelation of filtered signal')

%save spectrum for following processing
work_arr = abs(fftshift(fft(work_arr)));
save('filtered_phone.mat', 'work_arr');

%%
load('den_phone.mat');

spectr_arr = work_arr.^2;
[temp_arr, d_arr, d_arr_old] = model_max_values_freq(spectr_arr, 2500);
temp_arr(length(spectr_arr)) = 0;

%remove all values < lim samples
lim = 600;
d_arr(d_arr < lim) = 0;
d_arr_old(d_arr_old < lim) = 0;

%length in samples -> length in herz
d_arr = d_arr;
d_arr_old = d_arr_old;

figure
subplot(2, 1, 1)
plot(work_x, spectr_arr)
xlim([-Fs/2 Fs/2])
hold on
stem(work_x, temp_arr, 'Marker', 'none')
xlim([-Fs/2 Fs/2])
title('Max values in interval with length == 2500')

subplot(2, 1, 2)
stem(work_x, d_arr, 'Marker', 'none')
xlim([-Fs/2 Fs/2])
title('Distance to last maximum')
ylabel('Number of samples') 

table = d_arr_old(length(d_arr_old)/2 + 2:end);
table = round(table.');

freq_table = work_x(d_arr > 0);
freq_table = freq_table(floor(length(freq_table)/2) + 1:end);
freq_table = round(freq_table.');










