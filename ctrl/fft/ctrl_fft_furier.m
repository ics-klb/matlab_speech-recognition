function   [res_val,f]= ctrl_fft_furier(input_signal,N,Fs,lenghtAllSignal)

% входной участок сигнала input_signa
% Число N кратное степени 2 
% К примеру 64, 128, 256, 512
% det_t=info.Duration/A1;
% fix_vector=mass_res(250,:);



% T = 1/Fs;             % Sampling period(преиод одного семпла сигнала)       
L = N;             % Length of signal (длина одной выборки для преобразования)

Y = fft(input_signal,N);%преобразование фурье
P2 = abs(Y/lenghtAllSignal);%,берем АЧХ и нормируем
% P1 = P2(1:L/2);% Реальная часть спектра
P1 = P2(1:L/2);% Реальная часть спектра
P1(2:end-1) = 2*P1(2:end-1); % умножаем все на 2 кроме первой постоянной составляющей
% for k=1:1:N%hamming wondow
% h(k)=0.54-0.46*cos(2*pi*k/(512-1));
% end

% res_val=P1.*h(N/2:N);
res_val=P1;
f = Fs*(0:(L/2-1))/L;%массив частот

end