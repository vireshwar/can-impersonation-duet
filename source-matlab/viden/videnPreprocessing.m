%Viden sampling
clc;
clear;
close all;
fileListOpen=fopen('all');
for i=1:length(fileListOpen) 
    fclose(fileListOpen(i)); 
end

addpath('../experiment/');

% Control parameters
carExp=0;
FsampKS=50;
iterationCount=1; 
corruption=1;
trainingPhase=1;
corruptByte=2;

folderName=expGetFolderName(carExp,FsampKS,iterationCount,corruption,trainingPhase,corruptByte);

%% Load Data
fileName=strcat(folderName,'arduinoData.txt');  
fileID=fopen(fileName);

msgID={'001','00b','015'};
testIDindex=3;
videnData={};
for count=1:length(msgID)
    videnData{count,1}=msgID{count};
    videnData{count,2}=[];
    videnData{count,3}=[];
end

while(~feof(fileID))
    tline = fgetl(fileID);
    imported_data = textscan(tline,'%s  %s  %s');
    if(~isempty(imported_data{1,1}) && ~isempty(imported_data{1,2}) && ~isempty(imported_data{1,3}))
        frame_id=imported_data{1,1}{1};
        frame_canH=str2double(imported_data{1,2}{1});
        frame_canL=str2double(imported_data{1,3}{1});
        if(sum(strcmp(frame_id,msgID))>0 && frame_canH>400 && frame_canH<1024 && frame_canL>0 && frame_canL<600)
            idIndex=find(strcmp(frame_id,msgID)); 
            videnData{idIndex,2}=[videnData{idIndex,2},frame_canH*5/1024];
            videnData{idIndex,3}=[videnData{idIndex,3},frame_canL*5/1024];
        else
            disp('Data Error');
            disp([frame_id, '  ', num2str(frame_canH), '  ',num2str(frame_canL)]);
        end
    else
        disp('Read Error');
        disp([imported_data{1,1}, imported_data{1,2}, imported_data{1,3}]);
    end
end
fclose(fileID);
videnDataFile=strcat(folderName,'videnData.mat');          
save(videnDataFile,'videnData');

%% Load previoulsy saved data
%load(videnDataFile); 

%%
applyThres=1;
updateDispersion=2; %0 - no update, 1 - dispersion update algorithm, 2 - average over Rround
Mbuffer=30;
Kbuffer=15;
Rround=10;

videnThreshH=2.75;
videnThreshL=2.25;

responseVar=[];
predictorVar=[];
ackThresH=zeros(size(videnData,1),1);
ackThresL=zeros(size(videnData,1),1);
for countID=1:size(videnData,1)
    dataH=videnData{countID,2};
    dataL=videnData{countID,3}; 
    dataH=dataH(dataH>videnThreshH);
    dataL=dataL(dataL<videnThreshL);
    if(applyThres)
        [dataRefH,dataRefL,ackThresH(countID),ackThresL(countID)]=videnAckThres(dataH,dataL,Mbuffer,countID);
    else
        dataRefH=dataH;
        dataRefL=dataL;
    end
    features=videnComputeFeature(dataRefH,dataRefL,Kbuffer,Rround,updateDispersion);
    predictorVar=[predictorVar;features'];
    responseVar=[responseVar;countID*ones(size(features,2),1)];
    
    
    if(1)% && countID==testIDindex)
        figure;
        subplot(1,2,1);
        hold on;
        histogram(dataH,'BinWidth',0.01,'BinLimits',[1 4]);
        histogram(dataL,'BinWidth',0.01,'BinLimits',[1 4]);
        legend('CANH','CANL');
        title(strcat("All data, ID: ",num2str(countID)));
        hold off;

        subplot(1,2,2);
        hold on;
        histogram(dataRefH,'BinWidth',0.01,'BinLimits',[1 4]);
        histogram(dataRefL,'BinWidth',0.01,'BinLimits',[1 4]);
        legend('CANH','CANL');
        title(strcat("Refined data, ID: ",num2str(countID)));
        hold off;
    end
    
end

videnFeatureFile=strcat(folderName,'videnFeatureData.mat');          
save(videnFeatureFile,'responseVar','predictorVar');

%%

if(1)
    plotMarkerOnly={'bo','gs','kv','m^','y+','r*','rs','b+','g*','k+','mv','y^'};
    for countFeature=1:6
        figure;
        hold on;
        for countID=1:size(videnData,1)
            indexFind=find(responseVar==countID);
            predictorPlot=predictorVar(indexFind,countFeature);
            plot(predictorPlot,plotMarkerOnly{countID});            
        end
        hold off;
        title(strcat("Feature: ",num2str(countFeature)));
    end
end






