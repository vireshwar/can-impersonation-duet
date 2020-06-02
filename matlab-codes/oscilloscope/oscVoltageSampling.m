% Sample data using oscilloscope

clc;
clear;
close all;

addpath('../Experiment/');

% Collect new data with a new iteration
iterationCount=1; 
Nwaveform=10;

% Load parameters for Scission
carExp=0;
Fsamp=12.5E6;
FsampKS=Fsamp/1E3; 
NsampSym=2*Fsamp/1E6; 

corruption=1;
trainingPhase=0;
corruptByte=2;
ideaExp='Duet';

folderName=exp_getFolderName(carExp,FsampKS,iterationCount,corruption,trainingPhase,corruptByte,ideaExp);
mkdir(folderName);

myScope = oscilloscope(); % Create instance
availableResources = resources(myScope); % Find resources
myScope.Resource = 'USB::0x0699::0x0373::C011681::INSTR'; % Allot ID
connect(myScope); % Connect to the instrument
set (myScope, 'TriggerMode','auto');
pause(1);
get(myScope); % Examine the scope


for countWaveform=1:Nwaveform          
    remainingWaveforms=Nwaveform-countWaveform+1
    set (myScope, 'TriggerMode','normal');
    [waveformArrayH,waveformArrayL] = readWaveform(myScope); % Get the waveform
    set (myScope, 'TriggerMode','auto');
    pause(1);
    waveformFileH=strcat(folderName,'waveformH', num2str(countWaveform), '.mat');
    save(waveformFileH,'waveformArrayH');

    waveformFileL=strcat(folderName,'waveformL', num2str(countWaveform), '.mat');
    save(waveformFileL,'waveformArrayL');
end

disconnect(myScope);
clear myScope;

figure;
plot(waveformArrayL);
xlabel('Samples');
ylabel('Voltage');
title('CAN-L');

figure;
plot(waveformArrayH);
xlabel('Samples');
ylabel('Voltage');
title('CAN-H');

figure;
plot(waveformArrayH-waveformArrayL);
xlabel('Samples');
ylabel('Differential Voltage');
title('CAN-Bus');