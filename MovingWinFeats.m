function [FeatureOutput, NumWins]=MovingWinFeats(x, winLen, winDisp, featFn)
%This function takes signal, frequency, window length, window displacement,
%and any feature as inputs. This function calculates the feature for each
%of the sliding windows

NumWins=floor(((length(x))-(winLen))/(winDisp))+1; 
%Calculate the number of windows

startindex(1)=1;
endindex(1)=winLen;
%Initial window indices

for i=1:NumWins 
%Finds the moving indices of the window and calculates the feature in that window
    
    currentwindow=x(startindex(i):endindex(i));
    
    FeatureOutput(i)=featFn(currentwindow);
    %Uses anonymous functions to calculate the feature
    
    startindex(i+1)=startindex(i)+(winDisp);
    endindex(i+1)=endindex(i)+(winDisp);
end;
