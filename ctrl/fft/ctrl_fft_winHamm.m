function [plotMass, res_val, f] = ctrl_fft_winHamm(audio_signal, Fs, degreeOfOverlap)

    startSemple=1;
    endSemple = length(audio_signal);
    hammingWindow = hamming(sampleSize, 'symmetric');
    hammingWindow = hammingWindow';
    
arrayOfPlots=[];

new_wector = get_norm_vektor(audio_signal,sampleSize);%returns an array of multiples of "sampleSize"

lenghtSig=length(new_wector);
endIterator = lenghtSig / (sampleSize/2);

% proz=[15 25 35 45 55 65 75 85 95 100];
% otchet=proz.*512/100;
% otchet=[];
%25%=128
%50%=256
%75%=384
% degreeOfOverlap=sampleSize/2;%50 - % overlap factor for sample/overlap between two adjacent(neighboring) samples
     
    arrayOfPlots(a,:) = new_wector(startSemple:endSemple);
    startSemple  = 0;

 plotMass = arrayOfPlots;
 arrayOfPlot = arrayOfPlots.* hammingWindow;
 
 res_val = zeros(endIterator,sampleSize,'double');
[res_val, f]= ctrl_fft_furier(arrayOfPlots, sampleSize, Fs, lenghtSig);
while a <= endIterator
    
    if endSemple==lenghtSig
        startSemple=startSemple-degreeOfOverlap;
        endSemple=endSemple-degreeOfOverlap;
        arrayOfPlots(a,:)=new_wector(startSemple:endSemple-1);
        plotMass(a,:)=arrayOfPlots(a,:);
        arrayOfPlots(a,:)=arrayOfPlots(a,:).* hammingWindow;
        [res, f]= window_furier(arrayOfPlots(a,:),sampleSize,Fs,lenghtSig);
        res_val(a,:)=res;
        
        break;
        
    end
    
    if a > 1

        startSemple=startSemple-degreeOfOverlap;
        endSemple=endSemple-degreeOfOverlap;
        arrayOfPlots(a,:)=new_wector(startSemple:endSemple-1);
        plotMass(a,:)=arrayOfPlots(a,:);
        arrayOfPlots(a,:)=arrayOfPlots(a,:).* hammingWindow;
        [res, f]= window_furier(arrayOfPlots(a,:),sampleSize,Fs,lenghtSig);
        res_val(a,:)=res;
        
    end
    
    if startSemple==1
        startSemple=0;
    end
    
    startSemple = startSemple + sampleSize;
    
    endSemple = endSemple + sampleSize;
    
    a=a+1;
    
end