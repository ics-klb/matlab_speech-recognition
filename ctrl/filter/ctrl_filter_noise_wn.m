clc
[y, Fs] = audioread('phone_aru_on.wav');

splited_arr = model_split_sound_wn(y);

fy = cell(1, length(splited_arr));
work_arr = cell(1, length(splited_arr));
mean_arr = zeros(1, length(splited_arr));
max_arr = zeros(1, length(splited_arr));
for i = 1:length(splited_arr)
    fy{i} = fft(splited_arr{i});
    work_arr{i} = abs(fy{i});
    mean_arr(i) = mean(work_arr{i});
    max_arr(i) = max(work_arr{i});
end

K = 0.3;
for i = 1:length(splited_arr)
   
    mat = fy{i};
    %это неправильно, тут вычитается среднее по интервалу, а не по отсчету,
    %не смотреть сюда
    bool_mat = abs(mat) < K*max_arr(i);
    mat( bool_mat ) = mat(bool_mat) - mean_arr(i);
    mat(real(mat) < 0) = real(mat(real(mat) < 0)) - real(mat(real(mat) < 0));
    fy{i} = mat;
    
end

for i = 1:length(fy)
   
    work_arr{i} = ifft(fy{i});
    
end

work_arr = cell2mat(work_arr);
sound(work_arr, Fs)


figure
subplot(2,1,1)
plot(abs(fft(work_arr)))
subplot(2,1,2)
plot(abs(fft(y)))














