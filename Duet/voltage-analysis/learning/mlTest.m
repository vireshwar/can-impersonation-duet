function [predictedECU,ypred]= testML(mlAlgo,mlModel,predictorTest,responseTest)
    
probLow=0.2;
probHigh=0.6;
if(strcmp(mlAlgo,'logReggMatlab'))
    ypred = mnrval(mlModel,predictorTest,'model','nominal','interactions','on','confidence',0.99); 
    [maxValProb,indexMaxProb] = max(ypred,[],2);
    if(~isempty(responseTest))
        predictedECU=zeros(length(responseTest),1);
        countSuspect=0;
        for count=1:length(responseTest)
            if(ypred(count,responseTest(count))<probLow)
                predictedECU(count) = indexMaxProb(count);
                if(maxValProb(count)>probHigh)
                   countSuspect=countSuspect+1;
                end
            else
                predictedECU(count) = responseTest(count);
            end
        end
    else
        predictedECU = indexMaxProb;
    end  
elseif(strcmp(mlAlgo,'ecocSVM'))
    predictedECU = predict(mlModel,predictorTest);
    ypred=[];
elseif(strcmp(mlAlgo,'naive'))
    [predictedECU,ypred,~] = predict(mlModel,predictorTest);
elseif(strcmp(mlAlgo,'knn'))
    [predictedECU,ypred,~] = predict(mlModel,predictorTest);
elseif(strcmp(mlAlgo,'RandForest'))
    [predictedECUcell,ypred,~] = predict(mlModel,predictorTest);
    predictedECU=str2double(predictedECUcell);
end




