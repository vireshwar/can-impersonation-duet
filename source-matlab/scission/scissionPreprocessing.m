% Scission
clc;
clear;
close all;

addpath('../experiment/');
addpath('../sampling/');
addpath('../plot/');

% Other parameters
recessiveFrameMaxVal=0.5;
dominantFrameMinVal=1.5;
recessiveSymbolMaxVal=0.25;
dominantSymbolMinVal=1.25;

% Plot waveforms
lWidth=3;
mSize=10;
fSize=40;        
featuresNames={'mean-g00','std-g00','var-g00','skew-g00','kurt-g00','rms-g00','max-g00','energy-g00',...
               'mean-fft-g00','std-fft-g00','var-fft-g00','skew-fft-g00','kurt-fft-g00','rms-fft-g00','max-fft-g00','energy-fft-g00',...
               'mean-g01','std-g01','var-g01','skew-g01','kurt-g01','rms-g01','max-g01','energy-g01',...
               'mean-fft-g01','std-fft-g01','var-fft-g01','skew-fft-g01','kurt-fft-g01','rms-fft-g01','max-fft-g01','energy-fft-g01',...
               'mean-g10','std-g10','var-g10','skew-g10','kurt-g10','rms-g10','max-g10','energy-g10'...
               'mean-fft-g10','std-fft-g10','var-fft-g10','skew-fft-g10','kurt-fft-g10','rms-fft-g10','max-fft-g10','energy-fft-g10'};

% Control parameters
carExp=0;
iterationCount=1; 
corruption=1;
trainingPhase=1;
[victimID,attackerID,victimECU,attackerECU,accompECU,busSpeed,voltMult] = expInfo(carExp,iterationCount,trainingPhase);

dataHL=true;
Nwaveform=10;
corruptByte=2;
Fsamp=[12.5E6];
idLength=13;
%%
for countIDLen=1:length(idLength) 
    for countCL=1:length(corruptByte)
        corruptRate=corruptByte(countCL);
        for countSamp=1:length(Fsamp)
            FsampKS=Fsamp(countSamp)/1E3; 
            NsampSym=2*Fsamp(countSamp)/1E6; 
            NsampFrameMargin=round(1.1*NsampSym);
            NsampExtractMargin=floor(NsampSym/5);
            NsampDetectMargin=floor(NsampSym/5);
            NsampInterFrame=8*NsampSym;

            folderName=expGetFolderName(carExp,FsampKS,iterationCount,corruption,trainingPhase,corruptRate);

            acquisitionError=0;
            formatError=0;
            activeError=0;
            nEntry=0;
            countPlot=0;
            frameIDHex={};
            featuresTable=[];
            errorID={};
            for countWaveform=1:Nwaveform
                if(~dataHL)
                    waveformFileD=strcat(folderName,'waveformD', num2str(countWaveform), '.mat');
                    load(waveformFileD);
                    sampleData=waveformArrayD;
                else
                    waveformFileH=strcat(folderName,'waveformH', num2str(countWaveform), '.mat');
                    load(waveformFileH);
                    waveformFileL=strcat(folderName,'waveformL', num2str(countWaveform), '.mat');
                    load(waveformFileL);
                    sampleData=waveformArrayH-waveformArrayL;
                end
                if(1)
                    figure;
                    plot(sampleData);
                    grid on;
                end

                [frameStartIndex,frameEndIndex]=sampDetectFrame(sampleData,NsampInterFrame,dominantFrameMinVal,recessiveFrameMaxVal);
                if(~isempty(frameStartIndex))
                    frameStartIndex=frameStartIndex-NsampFrameMargin;
                    frameEndIndex=frameEndIndex+NsampFrameMargin;

                    for nFrame=1:length(frameStartIndex)          
                        frameData=sampleData(frameStartIndex(nFrame):frameEndIndex(nFrame));
                        [risingIndex,fallingIndex]=sampDetectTransitionIndex(frameData,NsampDetectMargin,dominantSymbolMinVal,recessiveSymbolMaxVal);
                        [frameBits,stuffID]=sampExtractFrameBits(NsampSym,risingIndex,fallingIndex); 
                        if(length(frameBits)>idLength(countIDLen))
                            if(sum(fallingIndex-risingIndex>5*NsampSym+NsampDetectMargin)==0)
                                nEntry=nEntry+1;
                                truncID=stuffID+idLength(countIDLen);
                                frameIDHex{nEntry,1}=binaryVectorToHex(frameBits(2:12));
                                [frameData_g00,frameData_g01,frameData_g10]=scissionExtractSample(frameData,NsampSym,NsampExtractMargin,risingIndex,fallingIndex,truncID);
                                featuresTable(nEntry,:)=[scissionComputeFeature(frameData_g00),scissionComputeFeature(frameData_g01),scissionComputeFeature(frameData_g10)];                                     
                                victimID='015';
                                if(0 && countPlot<100) % && strcmp(frameIDHex{nEntry},victimID))            
                                    countPlot=countPlot+1;                                   
                                    figure;
                                    plot(frameData);
                                    xlabel('Sample');
                                    ylabel('Differential voltage')
                                    set(gca,'FontSize',fSize);       
                                    title(strcat(num2str(nEntry),',',frameIDHex{nEntry}));
    
%                                     figure;
%                                     plot(frameData_g00,'-.');
%                                     ylim([-0.25,2.75]);
% 
%                                     figure;
%                                     plot(frameData_g01,'-.');
%                                     ylim([-0.25,2.75]);
% 
%                                     figure;
%                                     plot(frameData_g10,'-.');
%                                     ylim([-0.25,2.75]);
                                    
                                end
                            else
                                activeError=activeError+1;
                                errorID{activeError,1}=binaryVectorToHex(frameBits(2:12));                
                            end 
                        else
                            formatError=formatError+1;
                       end
                    end
                    acquisitionError=acquisitionError+1;
                end
            end
            %%      
            frameIDVar=frameIDHex;
            [numID_class,id_class] = unique(frameIDVar);
            frameECU = expId2ecu(frameIDVar,carExp,iterationCount,ideaExp);
            numECU_class = unique(frameECU);
            responseVar = frameECU;
            predictorVar = featuresTable;
            
            victimIDIndex=strcmp(frameIDVar,victimID);
            indexCorrupt=predictorVar(:,3)>0.001; % Consider a packet corrupted if variance>0.001 
            indexWrongCorrupt = find(and(~victimIDIndex, indexCorrupt));

            if(isempty(indexWrongCorrupt))
                corruptionError=0;
            else
                corruptionError=1;
            end

            victimIndexCorrupt = find(and(victimIDIndex, indexCorrupt));
            victimIndexBenign = find(and(victimIDIndex, ~indexCorrupt));
            corruptionRate=length(victimIndexCorrupt)/(length(victimIndexCorrupt)+length(victimIndexBenign));

            if(1)              
                figure;
                xlabel(featuresNames(1)); 
                ylabel(featuresNames(3));                       
                 
                predictorPlot=[predictorVar(:,1),predictorVar(:,3)];
                responsePlot=responseVar;
                hold on; 
                plotClass(predictorPlot',responsePlot',0);                                         
                hold off;
                set(gca,'FontSize',fSize-10);
                legend('Victim/Vic+Att/Acc+Att', 'Attacker','Accomplice');
                title('Scission Features');
            end

            featureFile=strcat(folderName,'scissionFeatureData.mat');            
            save(featureFile,'frameIDVar','responseVar','predictorVar');

            acquisitionError
            formatError
            activeError
            corruptionError
            corruptionRate
        end
    end
end
    
