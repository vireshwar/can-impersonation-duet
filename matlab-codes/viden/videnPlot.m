

% Plot waveforms
lWidth=3;
mSize=25;
fSize=36;

plotMarker={'-r*','-bo','-gs','-kv','-m^','-y+','-r*','-bo','-gs','-kv','-m^','-y+'};
plotMarkerOnly={'bo','gs','kv','m^','b+','r*','rs','b+','g*','k+','mv','y^'};
featuresNames={'CAN-H 50%','CAN-L 50%','CAN-H 75%','CAN-L 25%','CAN-H 90%','CAN-L 10%'};
NumFeatures=1:6;

% Define the ranges of the grid
limValMin=-3; 
limValMax=5; 

%u = linspace(limValMin, limValMax, length(NumFeature)*limitNumClass);
%predictorGridNorm = reshape(u,limitNumClass,length(NumFeature));
%[responseGridNorm,~]= testML(mlAlgo,mlModel,predictorGridNorm,responseTrain);
ylimL=[3.0,1.4,3.0,1.4,3.0,1.4];
ylimH=[3.6,1.8,3.6,1.8,3.6,1.8];
if(1)
    close all;
    for countFeature=1:length(NumFeature)
        figure;
        subplot(1,2,1);
        title(strcat("Training,  Feature: ",num2str(NumFeature(countFeature))));
        hold on;
        for countID=1:length(numClass)
            indexFind=find(responseTrain==countID);
            predictorPlot=predictorTrain(indexFind,countFeature);
            plot(predictorPlot,plotMarkerOnly{countID}); 
            
%             indexFindGrid=find(responseGridNorm==countID);
%             predictorPlotGrid=predictorTrain(indexFind,countFeature);
%             plot(predictorPlotGrid,plotMarkerOnly{countID},'MarkerSize',1);
            
        end
        %ylim([ylimL(NumFeature(countFeature)),ylimH(NumFeature(countFeature))]);
        hold off;
        subplot(1,2,2);
        title(strcat("Test,  Feature: ",num2str(NumFeature(countFeature))));
        hold on;
        for countID=1:length(numClass)
            indexFind=find(responseTest==countID);
            predictorPlot=predictorTest(indexFind,countFeature);
            plot(predictorPlot,plotMarkerOnly{countID});            
        end
        %ylim([ylimL(NumFeature(countFeature)),ylimH(NumFeature(countFeature))]);
        hold off;        
    end
end

if(0)
    close all;                  
    for countFeature=length(NumFeatures)/2:-1:1
        NumFeaturesPlot=NumFeatures(2*(countFeature-1)+(1:2));
        figure(countFeature); 
        xlabel(featuresNames(NumFeaturesPlot(1))); 
        ylabel(featuresNames(NumFeaturesPlot(2)));                       
        hold on;
        predictorTrainPlot=predictorTrain(:,NumFeaturesPlot);
        plotClass(predictorTrainPlot',responseTrain',0);                     

        %plotModel=scission_trainML(mlAlgo,predictorTrainPlot,responseTrain);
        %[predictedResponsePlot,~] = scission_testML(mlAlgo,plotModel,predictorGridNorm,[]);                    
        %plotClass(predictorGridNorm',predictedResponsePlot',1);  
        %xlim([-limVal,limVal]);ylim([-limVal,limVal]);
        hold off;                                                              
    end
end

if(0)
    close all;     
    NumFeaturesPlot=1:18;
    numClassPlot=[victimECU,victimECU-1,victimECU-2,attackerECU,accompECU];
    figure; 
    hold on;
    for nClass = 1:length(numClassPlot)
        predictorMean=mean(predictorTrain(responseTrain==numClassPlot(nClass),NumFeaturesPlot));
        predictorStd=std(predictorTrain(responseTrain==numClassPlot(nClass),NumFeaturesPlot));
        plot(NumFeaturesPlot,predictorMean,plotMarkerOnly{nClass},'LineWidth',lWidth,'MarkerSize',mSize); 
    end
    predictorMean=mean(predictorTest(responseTest==victimECU,NumFeaturesPlot));
    predictorStd=std(predictorTest(responseTest==victimECU,NumFeaturesPlot));
    plot(NumFeaturesPlot,predictorMean,plotMarkerOnly{nClass+1},'LineWidth',lWidth,'MarkerSize',mSize); 
    
    hleg=legend('Victim + Att', 'ECU-2', 'ECU-3','Attacker','Accomplice','Acc + Att');
    set(hleg,'Location','NorthEast','FontSize',fSize);
    xlabel('Features'); 
    ylabel('Mean of standardized values');  
    set(gca,'FontSize',fSize)
    grid on;
    hold off;
end

if(0)
    %%
    close all;
    countFeature=1;
    %for countFeature=length(NumFeatures)/2:-1:1
        NumFeaturesPlot=NumFeatures(2*(countFeature-1)+(1:2));
        meanTrainPlot=meanTrain(2*(countFeature-1)+(1:2));
        stdTrainPlot=stdTrain(2*(countFeature-1)+(1:2));
        predictorGrid=meanTrainPlot+predictorGridNorm.*stdTrainPlot;
        figure(countFeature); 
        subplot(1,2,1); 
        hold on;  
        predictorTrainPlot=predictorTrain(:,NumFeaturesPlot);
        plotClass(predictorTrainPlot',responseTrain',0);                     
       
        predictorTrainPlotNorm=predictorVictimNorm(:,NumFeaturesPlot);
        plotModel=scission_trainML(mlAlgo,predictorTrainPlotNorm,responseTrain);
        [predictedResponsePlot,~] = scission_testML(mlAlgo,plotModel,predictorGridNorm,[]);                    
        plotClass(predictorGrid',predictedResponsePlot',1);  
        
        %xlabel(featuresNames(NumFeaturesPlot(1))); 
        %ylabel(featuresNames(NumFeaturesPlot(2)));  
        xlabel('Mean');
        ylabel('Standard deviation');
        title({'Training set'},'FontWeight','normal');
        xlim([meanTrainPlot(1)+limValMin*stdTrainPlot(1),meanTrainPlot(1)+limValMax*stdTrainPlot(1)]);
        ylim([meanTrainPlot(2)+limValMin*stdTrainPlot(2),meanTrainPlot(2)+limValMax*stdTrainPlot(2)]);
        daspect([1 0.1 1]);
        hleg=legend('Victim + Att', 'ECU-2', 'ECU-3','ECU-4','Attacker','Accomplice');
        set(hleg,'Location','NorthEast','FontSize',fSize-5);
        set(gca,'FontSize',fSize);
        grid on;  
        hold off; 
        
        

        subplot(1,2,2);
        %figure;
        hold on;                       
        %predictorTestPlot=predictorAttackerNorm(:,NumFeaturesPlot);
        predictorTestPlot=predictorAttacker(:,NumFeaturesPlot);
        plotClass(predictorTestPlot',responseTest',0);
        plotClass(predictorGrid',predictedResponsePlot',1);  
        
        %xlabel(featuresNames(NumFeaturesPlot(1)));
        %ylabel(featuresNames(NumFeaturesPlot(2)));
        xlabel('Mean');
        ylabel('Standard deviation');
        title({'Test set'},'FontWeight','normal');
        xlim([meanTrainPlot(1)+limValMin*stdTrainPlot(1),meanTrainPlot(1)+limValMax*stdTrainPlot(1)]);
        ylim([meanTrainPlot(2)+limValMin*stdTrainPlot(2),meanTrainPlot(2)+limValMax*stdTrainPlot(2)]);
        daspect([1 0.1 1]);
        hleg=legend('Acc + Att', 'ECU-2', 'ECU-3','ECU-4','Attacker','Accomplice');
        set(hleg,'Location','NorthEast','FontSize',fSize-5);
        set(gca,'FontSize',fSize);
        grid on;
        hold off;       

    %end
end  


 %%
if(0)
    close all;
    labelSuccess='Probability of impersonation';
    expIter1=[1,2];
    meanDiff=1:2;%[-2,-1,-0.5,+2,3,4];
    %legendIter={'Iteration = 1','Iteration = 3','Iteration = 4','Iteration = 5','Iteration = 6'};
    legendIter={'Iteration = 1','Iteration = 4'};
    labelIter='Difference of mean voltage between victim and attacker (%)';
    legendFCR={'Ratio of corrupted frames = 0','Ratio of corrupted frames = 0.25','Ratio of corrupted frames = 0.50','Ratio of corrupted frames = 0.75','Ratio of corrupted frames = 1'};
    legendFCR=[legendFCR,legendFCR,legendFCR];
    labelFCR='Ratio of corrupted frames';
    dataCorruptByte=dataCorruptLimitTrain/100*64/8;
    legendCLTrain={'Manipulated data = 0 byte','Manipulated data = 1 byte','Manipulated data = 2 bytes'};
    legendCLTrain=legendCLTrain(1:length(dataCorruptLimitTrain));
    labelCLTrain='Manipulated data of victim (bytes)';
    attackSuccessMean=mean(attackSuccess,1);
    attackSuccessStd=std(attackSuccess,0,1); 
    attackSuccessPlot=zeros(length(expIter1),length(frameCorruptRatio),length(dataCorruptLimitTrain));
    for countExpIter=1:length(expIter1)
        iterationCount=expIter1(countExpIter);
        for countFCR=1:length(frameCorruptRatio)
            for countCLTrain=1:length(dataCorruptLimitTrain)         
                attackSuccessPlot(countExpIter,countFCR,countCLTrain)=0.92*max(attackSuccessMean(1,iterationCount,1,countFCR,countCLTrain,:));
            end   
        end                            
    end

    
    for countExpIter=1:length(expIter1)   
        iterationCount=expIter1(countExpIter);
        figure;
        hold on; 
        for countFCR=1:length(frameCorruptRatio)
            plot(dataCorruptByte,squeeze(attackSuccessPlot(countExpIter,countFCR,:)),plotMarker{countFCR},'LineWidth',lWidth,'MarkerSize',mSize);
        end
        title(legendIter(countExpIter));
        xlabel(labelCLTrain);
        ylabel(labelSuccess);
        hleg=legend(legendFCR);
        set(hleg,'Location','NorthEast');
        set(gca,'FontSize',fSize-20);
        ylim([0,1]);
        grid on;
        hold off;  
    end
    
    for countExpIter=1:length(expIter1)  
        iterationCount=expIter1(countExpIter);
        figure;
        hold on;
        for countCLTrain=1:length(dataCorruptLimitTrain)
            plot(frameCorruptRatio,squeeze(attackSuccessPlot(countExpIter,:,countCLTrain)),plotMarker{countCLTrain},'LineWidth',lWidth,'MarkerSize',mSize);
        end
        title(legendIter(countExpIter));
        xlabel(labelFCR);
        ylabel(labelSuccess);
        hleg=legend(legendCLTrain);
        set(hleg,'Location','NorthEast');
        set(gca,'FontSize',fSize-20);
        ylim([0,1]);
        grid on;
        hold off;   
    end
    
    for countCLTrain=1:length(dataCorruptLimitTrain)  
        figure;
        hold on;
        for countFCR=1:length(frameCorruptRatio)
            plot(meanDiff,squeeze(attackSuccessPlot(:,countFCR,countCLTrain)),plotMarker{countFCR},'LineWidth',lWidth,'MarkerSize',mSize);
        end
        title(legendCLTrain(countCLTrain));
        xlabel(labelIter);
        ylabel(labelSuccess);
        hleg=legend(legendFCR);
        set(hleg,'Location','NorthEast');
        set(gca,'FontSize',fSize-20);
        ylim([0,1]);
        grid on;
        hold off;   
    end
    
    for countCLTrain=1:length(dataCorruptLimitTrain)  
        figure;
        hold on;
        for countExpIter=1:length(expIter1) 
            plot(frameCorruptRatio,squeeze(attackSuccessPlot(countExpIter,:,countCLTrain)),plotMarker{countExpIter},'LineWidth',lWidth,'MarkerSize',mSize);
        end
        title(legendCLTrain(countCLTrain));
        xlabel(labelFCR);
        ylabel(labelSuccess);
        hleg=legend(legendIter);
        set(hleg,'Location','NorthEast');
        set(gca,'FontSize',fSize-20);
        ylim([0,1]);
        grid on;
        hold off; 
    end
    
    for countFCR=1:length(frameCorruptRatio) 
        figure;
        hold on;  
        for countCLTrain=1:length(dataCorruptLimitTrain)  
            plot(meanDiff,squeeze(attackSuccessPlot(:,countFCR,countCLTrain)),plotMarker{countCLTrain},'LineWidth',lWidth,'MarkerSize',mSize);
        end
        title(legendFCR(countFCR));
        xlabel(labelIter);
        ylabel(labelSuccess);
        hleg=legend(legendCLTrain);
        set(hleg,'Location','NorthEast');
        set(gca,'FontSize',fSize-20);
        ylim([0,1]);
        grid on;
        hold off;   
    end
    
    for countFCR=1:length(frameCorruptRatio)  
        figure;
        hold on;  
        for countExpIter=1:length(expIter1)
            plot(dataCorruptByte,squeeze(attackSuccessPlot(countExpIter,countFCR,:)),plotMarker{countExpIter},'LineWidth',lWidth,'MarkerSize',mSize);
        end
        title(legendFCR(countFCR));
        xlabel(labelCLTrain);
        ylabel(labelSuccess);
        hleg=legend(legendIter);
        set(hleg,'Location','NorthEast');
        set(gca,'FontSize',fSize-20);
        ylim([0,1]);
        grid on;
        hold off;     
    end
    
 %%   
    
%     for iterationCount=1:3
%         for countSample=1:length(Fsampling) 
%             %dataCorruptByte=[0,1,2];
%             attackSuccessPlot=zeros(length(frameCorruptRatio),length(dataCorruptLimitTrain));
%             for countFCR=1:length(frameCorruptRatio)
%                 for countCLTrain=1:length(dataCorruptLimitTrain)         
%                     attackSuccessPlot(countFCR,countCLTrain)=0.92*max(attackSuccess(1,iterationCount,countSample,countFCR,countCLTrain,:));
%                 end   
%             end
%             figure;
%             hold on;    
%             plot(dataCorruptByte,attackSuccessPlot(1,:),'-r*','LineWidth',lWidth,'MarkerSize',mSize);
%             plot(dataCorruptByte,attackSuccessPlot(2,:),'-bo','LineWidth',lWidth,'MarkerSize',mSize);
%             plot(dataCorruptByte,attackSuccessPlot(3,:),'-gs','LineWidth',lWidth,'MarkerSize',mSize);
%             title(strcat('Iteration = ', num2str(iterationCount), ',',...
%                          'Fsampling = ', num2str(Fsampling(countSample)), ','));
%             xlabel('Manipulated data of victim (byte)');
%             ylabel('Probability of impersonation');
%             hleg=legend('frameCorruptRatio = 0.25','frameCorruptRatio = 0.50','frameCorruptRatio = 0.75');
%             set(hleg,'Location','NorthEast');
%             set(gca,'FontSize',fSize-20);
%             ylim([0,1]);
%             grid on;
%             hold off;  
%         end
%     end

end
 %%
 if(0)
%      ',',...
%                          'Fsampling = ', num2str(Fsampling(countSample)), ',')
%                               strcat('frameCorruptRatio = 0.25', num2str(frameCorruptRatio(1)))
    figure;
    hold on;
    plot(frameCorruptRatio*100,squeeze(attackSuccess(1,1,:,1,1)),'r*','LineWidth',lWidth,'MarkerSize',mSize);
    %plot(frameCorruptRatio*100,squeeze(attackSuccess(1,1,:,2,2)),'gs','LineWidth',lWidth,'MarkerSize',mSize);
    %plot(frameCorruptRatio*100,squeeze(attackSuccess(1,1,:,1,3)),'bo','LineWidth',lWidth,'MarkerSize',mSize); 
    %title(strcat('Fsampling = ', num2str(Fsampling(countSample)), ',',...
                % 'frameCorruptRatio = ', num2str(frameCorruptRatio(countFCR))));
    xlabel('Manipulation rate of Victim''s traffic (%)');
    ylabel('Probability of successful voltage manipulation attack');
    %hleg=legend('Without any countermeasure');
    %set(hleg,'Location','NorthEast');
    set(gca,'FontSize',fSize-10);
    grid on;
    hold off; 

 end