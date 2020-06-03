%Viden analysis
clc;
clear;
close all;

addpath('../experiment/');
addpath('../learning/');

% Control parameters
carExp=0;
FsampKS=50;
expIter=[1];
corruption=1;
dataCorruptLimitTrain = [2]; % Corurption in bytes
dataCorruptLimitTest = [2];
idLength=13;

mlTechArray={'logReggMatlab','ecocSVM','naive','knn','RandForest'};
mlAlgo=mlTechArray{1};
limitNumClass=200;
limitNumClassTest=200;

attackSuccess=zeros(length(expIter),length(dataCorruptLimitTrain),length(dataCorruptLimitTest));
trainError=zeros(length(expIter),length(dataCorruptLimitTrain));
attackSuccessViden=zeros(length(idLength),length(idLength));

%%
for countExpIter=1:length(expIter)
    iterationCount=expIter(countExpIter);
    numClass=[1,2,3];
    victimECU=3;
    for countCLTrain=1:1:length(dataCorruptLimitTrain)
        for countIDLenTrain=1:length(idLength) 
            countIDLenTrain
            withAttacker=0;
            corruptByte=dataCorruptLimitTrain(countCLTrain);
            folderNameTrain=expGetFolderName(carExp,FsampKS,iterationCount,corruption,withAttacker,corruptByte);
            videnFile=strcat(folderNameTrain,'videnFeatureData.mat');           
            load(videnFile); 
            responseVictimLoad=responseVar;
            predictorVictimLoad=predictorVar;
%             numClass=unique(responseVictimLoad);
            
            sortIndexTotal=[];
            for countID=1:1:length(numClass)
                indexFind=find(responseVictimLoad==numClass(countID));
                responseVictimLoad(indexFind)=countID;
                sortIndexTotal=[sortIndexTotal;indexFind(1:limitNumClass)];                   
            end
%             sortIndexTotal=reshape(sortIndexClass,limitNumClass*length(numClass),1);
            responseVictim=responseVictimLoad(sortIndexTotal);
            predictorVictim=predictorVictimLoad(sortIndexTotal,:);

            NumFeature=1:1:6;
            predictorTrain=predictorVictim(:,NumFeature);
            responseTrain = responseVictim;

            mlModel= mlTrain(mlAlgo,predictorTrain,responseTrain); 

%             mlValidation;    
%             mapValidateClass;
%             trainError(countExpIter,countCLTrain)=mean(trainErrorSamp);

            for countCLTest=1:1:length(dataCorruptLimitTest)
                for countIDLenTest=1:length(idLength)
                    countIDLenTest
                    withAttacker=1;
                    corruptByte=dataCorruptLimitTest(countCLTest);
                    folderNameTest=expGetFolderName(carExp,FsampKS,iterationCount,corruption,withAttacker,corruptByte);
                    videnFileAttacker=strcat(folderNameTest,'videnFeatureData.mat');
                    load(videnFileAttacker); % loads responseVar and predictorVar
                    responseAttacker=responseVar;
                    predictorAttacker=predictorVar;
                    sortIndexTotalTest=[];
                    for countID=1:1:length(numClass)
                        indexFind=find(responseAttacker==numClass(countID));
                        responseAttacker(indexFind)=countID;
                        maxLen=min(length(indexFind),limitNumClassTest);
                        sortIndexTotalTest=[sortIndexTotalTest;(indexFind(1:maxLen))];                   
                    end
                    responseAttacker=responseAttacker(sortIndexTotalTest);
                    predictorAttacker=predictorAttacker(sortIndexTotalTest,:);

            
                    predictorTest=predictorAttacker(:,NumFeature);
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
                        indexClass = find(responseTest(:)==nClass);
                        if(~isempty(indexClass))
                            countTestClass(nClass) = length(indexClass); 
                            for dClass = 1:length(numClass)
                                mapClass(nClass,dClass) = mean(predictedECU(indexClass)==dClass);
                            end
                        end
                    end
                    attackSuccess(countExpIter,countCLTrain,countCLTest)=mapClass(victimECU,victimECU);
                    attackSuccessViden(countIDLenTrain,countIDLenTest)=mapClass(victimECU,victimECU);
                    
                    mapClass
                end
            end
        end
    end
end
attackSuccess
        

       




