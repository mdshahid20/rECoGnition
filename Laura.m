%I averaged finger position within each window, rather than downsampling

%Data Extraction
Patient1ECoG=IEEGSession('I521_A0011_D001','lstruz','lst_ieeglogin.bin')

for i=1:64
Patient1Channel(i,:)=Patient1ECoG.data.getvalues(1:400000,i);
end

Patient1Glove=IEEGSession('I521_A0011_D002','lstruz','lst_ieeglogin.bin')

for i=1:5
Patient1Fingers(i,:)=Patient1Glove.data.getvalues(1:400000,i);
end

Patient1Test=IEEGSession('I521_A0011_D003','lstruz','lst_ieeglogin.bin')

for i=1:64
Patient1ChannelTest(i,:)=Patient1Test.data.getvalues(1:200000,i);
end

clearvars -except Patient1ECoG Patient1Glove Patient1Test Patient1Channel Patient1Fingers Patient1ChannelTest

%Step 1
%Input Parameters
Channel=Patient1Channel;
NumberofChannels=64;
ECoGLength=400000;
WindowLength=175;
Frequency=1000;
WindowDisplacement=50; %50
AvgVolt = @(input) mean(input);
nfft=pow2(nextpow2(600)); %5000
Overlap=WindowLength-WindowDisplacement


channelcount=[]
for i=1:NumberofChannels
    
[AverageVoltage, NumberofWindows] = MovingWinFeats(Channel(i,:),WindowLength,WindowDisplacement,AvgVolt);    

MeanVoltage(i,:)=AverageVoltage;

[S,F]=spectrogram(Channel(i,:),WindowLength,Overlap,nfft,Frequency);
S=S.*conj(S)/nfft;
band1indices=find(F>=5 & F<=15);
band2indices=find(F>=20 & F<=25);
band3indices=find(F>=75 & F<=115);
band4indices=find(F>=125 & F<=160);
band5indices=find(F>=160 & F<=175);

for j=1:NumberofWindows

band1mag(i,j)=mean(S(band1indices,j));
band2mag(i,j)=mean(S(band2indices,j));
band3mag(i,j)=mean(S(band3indices,j));
band4mag(i,j)=mean(S(band4indices,j));
band5mag(i,j)=mean(S(band5indices,j));

end

clear S F band1indices band2indices band3indices band4indices band5indices AverageVoltage
channelcount(i)=i

end


%Step 2
Glovepos = @(input) mean(input);

for i=1:5
    
[Gloveposition, NumberofWindows] = MovingWinFeats(Patient1Fingers(i,:),WindowLength,WindowDisplacement,Glovepos);

MeanGlovePostion(i,:)=Gloveposition;

end

%Step 3
start(1)=1;

for i=1:NumberofChannels

for j=1:NumberofWindows-2
    
    FeatureMatrix3(j,start(i):start(i)+2)=MeanVoltage(i,j:j+2);
    FeatureMatrix3(j,start(i)+3:start(i)+5)=band1mag(i,j:j+2);
    FeatureMatrix3(j,start(i)+6:start(i)+8)=band2mag(i,j:j+2);
    FeatureMatrix3(j,start(i)+9:start(i)+11)=band3mag(i,j:j+2);
    FeatureMatrix3(j,start(i)+12:start(i)+14)=band4mag(i,j:j+2);
    FeatureMatrix3(j,start(i)+15:start(i)+17)=band5mag(i,j:j+2);

end

start(i+1)=start(i)+18;
end

start(1)=1;

for i=1:NumberofChannels

for j=1:1
    
    FeatureMatrix1(j,start(i):start(i)+2)=MeanVoltage(i,j);
    FeatureMatrix1(j,start(i)+3:start(i)+5)=band1mag(i,j);
    FeatureMatrix1(j,start(i)+6:start(i)+8)=band2mag(i,j);
    FeatureMatrix1(j,start(i)+9:start(i)+11)=band3mag(i,j);
    FeatureMatrix1(j,start(i)+12:start(i)+14)=band4mag(i,j);
    FeatureMatrix1(j,start(i)+15:start(i)+17)=band5mag(i,j);

end

start(i+1)=start(i)+18;
end
    
start(1)=1;

for i=1:NumberofChannels

for j=1:1
    
    FeatureMatrix2(j,start(i):start(i)+1)=MeanVoltage(i,j);
    FeatureMatrix2(j,start(i)+2)=MeanVoltage(i,j+1);
    FeatureMatrix2(j,start(i)+3:start(i)+4)=band1mag(i,j);
    FeatureMatrix2(j,start(i)+5)=band1mag(i,j+1);
    FeatureMatrix2(j,start(i)+6:start(i)+7)=band2mag(i,j);
    FeatureMatrix2(j,start(i)+8)=band2mag(i,j+1);
    FeatureMatrix2(j,start(i)+9:start(i)+10)=band3mag(i,j);
    FeatureMatrix2(j,start(i)+11)=band3mag(i,j+1);
    FeatureMatrix2(j,start(i)+12:start(i)+13)=band4mag(i,j);
    FeatureMatrix2(j,start(i)+14)=band4mag(i,j+1);
    FeatureMatrix2(j,start(i)+15:start(i)+16)=band5mag(i,j);
    FeatureMatrix2(j,start(i)+17)=band5mag(i,j+1);


end

start(i+1)=start(i)+18;
end  
  

FeatureMatrix4=[FeatureMatrix1 ; FeatureMatrix2 ; FeatureMatrix3];
FeatureMatrix5=[ones(NumberofWindows,1) FeatureMatrix4];
f=mldivide((FeatureMatrix5'*FeatureMatrix5),(FeatureMatrix5'*MeanGlovePostion'));
Positionpredict=FeatureMatrix5*f; 
 

%Step 4
%middle point of window
last=WindowLength/2+((NumberofWindows-1)*WindowDisplacement)
Dataposition1=(WindowLength/2+.5:WindowDisplacement:last+.5);
Expandedposition=(1:1:400000);

Positionpredict2=Positionpredict';

%add constraining end points
Positionpredict3=[zeros(5,1) Positionpredict2 zeros(5,1)];

%cubic interpolation
PP=spline(Dataposition1,Positionpredict3,Expandedposition);

close all
figure(1)
hold on
plot(Dataposition1,Positionpredict(:,1))
plot(Expandedposition,PP(2,:),'k-')
hold off


%Testaccuracy
PP2=PP';
Patient1Fingers2=Patient1Fingers';

for i=1:5 
correlation(i)=corr(Patient1Fingers2(:,i),PP2(:,i));
end

rvalueontrainingpatient1=(correlation(1)+correlation(2)+correlation(3)+correlation(5))/4

%Extract Features From Testing Data
