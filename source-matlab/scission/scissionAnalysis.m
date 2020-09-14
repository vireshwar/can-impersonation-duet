clear;
clc;
close all;
addpath('../experiment/');
addpath('../sampling/');
addpath('../learning/');

%% Parameters
scissionFeatures=[39,48,8,7,33,1,47,41,36,45,37,43,44,20,21,28,29,19];
mlTechArray={'logReggMatlab','ecocSVM','naive','knn','RandForest'};
limitNumClass = 90;
mlAlgo=mlTechArray{5};
featureSet=0; % 0-full, 1-scission, 2-adaptive
 
carExp=0; % 0 for testbed, 11 Cruze-Bus-1, 12 Cruze-Bus-2, 21 Impala-Bus
corruption=1; % 0 for no corruption, 1 for corruption

Fsampling = [12.5E6];
adjustFCR = 0; % Adjust frame corruption rate
frameCorruptRatio = 1;%0:0.1:1;
corruptByteLimitTrain = [2]; % Corurption in bytes
corruptByteLimitTest = [2];
expIter = 1;
NrandIter = 1;
idLength=13;

%% Analysis
attackSuccess=zeros(NrandIter,length(expIter),length(Fsampling),length(frameCorruptRatio),length(corruptByteLimitTrain),length(corruptByteLimitTest),2);
trainError=zeros(NrandIter,length(expIter),length(Fsampling),length(frameCorruptRatio),length(corruptByteLimitTrain));

for countExpIter=1:length(expIter)
    iterationCount=expIter(countExpIter);
    trainingPhase=1;
    [victimID,attackerID,victimECU,attackerECU,accompECU] = expInfo(carExp,iterationCount,trainingPhase);
    for countSample=1:length(Fsampling)  
        Fsamp=Fsampling(countSample);
        FsampKS=Fsamp/1E3; 
        NsampSym=2*Fsamp/1E6; 
        for countFCR=1:length(frameCorruptRatio)           
            for countCLTrain=1:1:length(corruptByteLimitTrain)   
                for countIDLenTrain=1:length(idLength) 
                    %% Load train data 
                    trainingPhase=1;
                    corruptByte=corruptByteLimitTrain(countCLTrain);
                    folderNameTrain=expGetFolderName(carExp,FsampKS,iterationCount,corruption,trainingPhase,corruptByte);
                    featureFile=strcat(folderNameTrain,'scissionFeatureData.mat');
                    load(featureFile); % loads responseVar and predictorVar 
                    responseVictimLoad=responseVar; %
                    predictorVictimLoad=predictorVar;
                    if(exist('frameIDHex','var'))
                        frameIDVar=frameIDHex;
                    elseif(exist('frameIDVar','var'))
                    else
                        frameIDVar=zeros(size(responseVar));
                    end
                    frameIDVictimLoad=frameIDVar;
                    
                    numClass = (1:max(responseVictimLoad))';
                    countTotalClassTrain = zeros(length(numClass),1);
                    for nClass = 1:length(numClass)
                        countTotalClassTrain(nClass) = sum(responseVictimLoad==numClass(nClass));
                    end
                    %%

                    for countRandIter=1:1:NrandIter
                        %% Randomize and sort training data
%                         iterationCount
%                         countSample
%                         countFCR
%                         countCLTrain
%                         countRandIter                   
                        randIndexClass=zeros(length(numClass),limitNumClass);
                        for nClass = 1:length(numClass)            
                            indexClassShort=find(responseVictimLoad==numClass(nClass));
                            randIndexClass(nClass,:)=indexClassShort(1:limitNumClass);                   
                        end
                        sortIndexTotal=reshape(randIndexClass,limitNumClass*length(numClass),1);
                        responseVictim=responseVictimLoad(sortIndexTotal);
                        predictorVictim=predictorVictimLoad(sortIndexTotal,:);
                        frameIDVictim=frameIDVictimLoad(sortIndexTotal);

                        %%  Run training 
                        meanTrain = mean(predictorVictim);
                        stdTrain = std(predictorVictim);
                        predictorVictimNorm=(predictorVictim-meanTrain)./stdTrain;

                        if(featureSet==0)
                            NumFeatures = 1:48;
                        elseif(featureSet==1)
                            NumFeatures = scissionFeatures;
                        elseif(featureSet==2)
                            [featureRanks,featureWeights] = relieff(predictorVictimNorm,responseVictim,10,'method','classification'); 
                            NumFeatures = featureRanks(1:18);
                        end

                        predictorTrain=predictorVictimNorm(:,NumFeatures);
%                         predictorTrain=predictorVictim(:,NumFeatures);
                        responseTrain = responseVictim;

                        mlModel= mlTrain(mlAlgo,predictorTrain,responseTrain);   

                        %%
                        for countCLTest=1:1:length(corruptByteLimitTest)
                            for countIDLenTest=1:length(idLength) 
                                %% Load test data
                                trainingPhase=0;
                                corruptByte=corruptByteLimitTest(countCLTest);
                                folderNameTest=expGetFolderName(carExp,FsampKS,iterationCount,corruption,trainingPhase,corruptByte);
                                featureFileAttacker=strcat(folderNameTest,'scissionFeatureData.mat');
                                load(featureFileAttacker); % loads responseVar and predictorVar
                                responseAttackerLoad=responseVar; %
                                predictorAttackerLoad=predictorVar;                                
                                if(exist('frameIDHex','var'))
                                    frameIDVar=frameIDHex;
                                elseif(exist('frameIDVar','var'))
                                else
                                    frameIDVar=zeros(size(responseVar));
                                end
                                frameIDAttackerLoad=frameIDVar;
                                
                                countTestClassTotal = zeros(length(numClass),1);
                                for nClass = 1:length(numClass)                            
                                    countTestClassTotal(nClass) = sum(responseAttackerLoad==numClass(nClass));                            
                                end
                                predictorAttacker=predictorAttackerLoad;
                                responseAttacker=responseAttackerLoad;
                                frameIDAttacker=frameIDAttackerLoad;                              

                                %% Run test
                                predictorAttackerNorm=(predictorAttacker-meanTrain)./stdTrain;
                                predictorTest = predictorAttackerNorm(:,NumFeatures);
%                                 predictorTest = predictorAttacker(:,NumFeatures);
                                responseTest = responseAttacker; 

                                [predictedECU,ypred]= mlTest(mlAlgo,mlModel,predictorTest,responseTest);

                                testError=(predictedECU~=responseTest);
                                errorIndex=find(testError);
                                errorECUavg=mean(testError);

                                % Confusion matrix
                                countTestClass = zeros(length(numClass),1);
                                errorClass = zeros(length(numClass),1);
                                mapClass = zeros(length(numClass));
                                for nClass = 1:length(numClass)
                                    indexClass = find(responseTest(:)==numClass(nClass));
                                    if(~isempty(indexClass))
                                        countTestClass(nClass) = length(indexClass); 
                                        for dClass = 1:length(numClass)
                                            mapClass(nClass,dClass) = mean(predictedECU(indexClass)==numClass(dClass));
                                        end
                                    end
                                end
                                attackSuccess(countRandIter,countExpIter,countSample,countFCR,countCLTrain,countCLTest,1)=mapClass(victimECU,victimECU);
                                mapClass
                            end
                        end
                    end
                end
            end
        end
    end
end

attackSuccess 

scissionPlotWaveform; 
