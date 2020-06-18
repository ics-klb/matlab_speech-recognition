function [res,f]= ctrl_winFfftHamm(inputSignal,Fs,sampleSize)
%Autor Starokozhev S.V. 08.05.18
% here we estimate FFT transform with multiplication on hamming window
hammingWindow = hamming(sampleSize,'symmetric');
hammingWindow = hammingWindow';
arrayOfPlots=[];
lenghtSig=length(inputSignal);
        arrayOfPlots=inputSignal.* hammingWindow;
        [res, f]= window_furier(arrayOfPlots,sampleSize,Fs,lenghtSig);

end