function [ speech_new ] = vec2_to_vec1( speech )  % convert from 2 vector to 1 vector   

    [N,y_size] = size(speech); % N - number of samples 
    j=1;

    for i=1:N   
        speech_new(j,1)=speech(i,1);
        j=j+1;
        speech_new(j,1)=speech(i,2);
        j=j+1; 
    end
end