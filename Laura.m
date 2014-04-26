%could be concern: number of windows, magnitude of fourier transform,
%should first column of feature matrix be ones?, you averaged over position
%rather than just down sampling, constraining endpoints on spline?, should
%be 400000 data points?


%Data Extraction
Patient1ECoG=IEEGSession('I521_A0009_D001','lstruz','lst_ieeglogin.bin')

for i=1:62
Patient1Channel(i,:)=Patient1ECoG.data.getvalues(1:399999,i);
end

Patient1Glove=IEEGSession('I521_A0009_D002','lstruz','lst_ieeglogin.bin')

for i=1:5
Patient1Fingers(i,:)=Patient1Glove.data.getvalues(1:399999,i);
end

Patient1Test=IEEGSession('I521_A0009_D003','lstruz','lst_ieeglogin.bin')

for i=1:62
Patient1ChannelTest(i,:)=Patient1Test.data.getvalues(1:199999,i);
end

%Step 1
%Input Paratmeters
Channel=Patient1Channel;
NumberofChannels=62;
ECoGLength=399999;
WindowLength=100;
Frequency=1000;
WindowDisplacement=50;
AvgVolt = @(input) mean(input);
nfft=pow2(nextpow2(WindowLength));


channelcount=[]
for i=1:NumberofChannels
    
[AverageVoltage, NumberofWindows] = MovingWinFeats(Channel(i,:),WindowLength,WindowDisplacement,AvgVolt);    

MeanVoltage(i,:)=AverageVoltage;

[S,F]=spectrogram(Channel(i,:),WindowLength,WindowDisplacement,nfft,Frequency);
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
FeatureMatrix5=[ones(7998,1) FeatureMatrix4];
f=mldivide((FeatureMatrix4'*FeatureMatrix4),(FeatureMatrix4'*MeanGlovePostion'));
Positionpredict=FeatureMatrix4*f; 
 

%Step 4
%middle point of window
Dataposition=(50:50:7998*50);
Expandedposition=(1:1:399999);

Positionpredict2=Positionpredict';

%add constraining end points
%Positionpredict3=[Positionpredict2(:,1) Positionpredict2 Positionpredict2(:,end)];

%cubiic interpolation
PP=spline(Dataposition,Positionpredict2,Expandedposition);

figure(1)
hold on
plot(Dataposition,Positionpredict(:,1))
plot(Expandedposition,PP(1,:),'k-')
hold off


Test accuracy
PP2=PP';
Patient1Fingers2=Patient1Fingers';

for i=1:5 
correlation(i)=corr(Patient1Fingers2(:,i),PP2(:,i));
end

rvalueontraining=mean(correlation)
