function mlModel= trainML(mlAlgo,predictorTrain,responseTrain)
    

if(strcmp(mlAlgo,'logReggMatlab'))
    mlModel = mnrfit(predictorTrain,responseTrain,'model','nominal','interactions','on');
elseif(strcmp(mlAlgo,'ecocSVM'))
    mlModel = fitcecoc(predictorTrain,responseTrain);
elseif(strcmp(mlAlgo,'naive'))
    mlModel = fitcnb(predictorTrain,responseTrain);
elseif(strcmp(mlAlgo,'knn'))
    mlModel = fitcknn(predictorTrain,responseTrain,'NumNeighbors',10,'Standardize',true);
elseif(strcmp(mlAlgo,'RandForest'))
    NumTrees=200;
    mlModel = TreeBagger(NumTrees,predictorTrain,responseTrain);
end