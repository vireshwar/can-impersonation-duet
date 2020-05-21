%close all;
%clc;

% Plot waveforms
lWidth=3;
mSize=30;
fSize=36;

plotMarker={'-r*','-bo','-gs','-kv','-m^','-y+','-r*','-bo','-gs','-kv','-m^','-y+'};
plotMarkerOnly={'bo','gs','kv','m^','y+','r*','r*','bo','gs','kv','m^','y+'};

featuresNames={'mean-g00','std-g00','var-g00','skew-g00','kurt-g00','rms-g00','max-g00','energy-g00',...
               'mean-fft-g00','std-fft-g00','var-fft-g00','skew-fft-g00','kurt-fft-g00','rms-fft-g00','max-fft-g00','energy-fft-g00',...
               'mean-g01','std-g01','var-g01','skew-g01','kurt-g01','rms-g01','max-g01','energy-g01',...
               'mean-fft-g01','std-fft-g01','var-fft-g01','skew-fft-g01','kurt-fft-g01','rms-fft-g01','max-fft-g01','energy-fft-g01',...
               'mean-g10','std-g10','var-g10','skew-g10','kurt-g10','rms-g10','max-g10','energy-g10'...
               'mean-fft-g10','std-fft-g10','var-fft-g10','skew-fft-g10','kurt-fft-g10','rms-fft-g10','max-fft-g10','energy-fft-g10'};

% Define the ranges of the grid
limValMin=-3; 
limValMax=5; 
u = linspace(limValMin, limValMax, 100);
v = linspace(limValMin, limValMax, 100);
predictorGridNorm=zeros(length(u)*length(v),2);                                 
for i = 1:length(u)
    for j = 1:length(v)
        predictorGridNorm((i-1)*length(v)+j,:)=[u(i),v(j)];  
    end
end

if(0)
    id=[1,2,3];
    for countFeature=2
        figure;
        hold on;
        for countID1=1:length(id)
            countID=id(countID1);
            indexFind=find(responseVictim==countID);
            predictorPlot=predictorVictim(indexFind,countFeature);
            plot(predictorPlot,plotMarkerOnly{countID},'LineWidth',1,'MarkerSize',mSize);                
        end
        hold off;
        title(strcat("Feature: ",num2str(countFeature)));
        hleg=legend('Training - Victim','Training - Attacker', 'Training - Accomplice');
        set(hleg,'Location','NorthEastOutside','FontSize',fSize);
        xlabel('Frame number'); 
        ylabel('Standard Deviation');  
        set(gca,'FontSize',fSize)
        grid on;
    end
end
%%
featureRankNames=(featuresNames(NumFeatures))';
if(0)
    close all;                  
    for countFeature=length(NumFeatures)/2:-1:1
        NumFeaturesPlot=NumFeatures(2*(countFeature-1)+(1:2));
        figure(countFeature); 
        xlabel(featuresNames(NumFeaturesPlot(1))); 
        ylabel(featuresNames(NumFeaturesPlot(2)));                       
        hold on;  
        predictorTrainPlot=predictorVictimNorm(:,NumFeaturesPlot);
        plotClass(predictorTrainPlot',responseTrain',0);                     

        %plotModel=scission_trainML(mlAlgo,predictorTrainPlot,responseTrain);
        %[predictedResponsePlot,~] = scission_testML(mlAlgo,plotModel,predictorGridNorm,[]);                    
        %plotClass(predictorGridNorm',predictedResponsePlot',1);  
        %xlim([-limVal,limVal]);ylim([-limVal,limVal]);
        hold off;                                                              
    end
end

if(0)    
    NumFeaturesPlot=1:18;
    numClassPlot=[victimECU,attackerECU,accompECU];
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
    
    hleg=legend('Victim + Att', 'Attacker','Accomplice','Acc + Att');
    set(hleg,'Location','NorthEast','FontSize',fSize);
    xlabel('Features'); 
    ylabel('Mean of standardized values');  
    set(gca,'FontSize',fSize)
    grid on;
    hold off;
end

if(1)
    countFeature=1;
    NumFeaturesPlot=NumFeatures(2*(countFeature-1)+(1:2));
    meanTrainPlot=meanTrain(2*(countFeature-1)+(1:2));
    stdTrainPlot=stdTrain(2*(countFeature-1)+(1:2));
    predictorGrid=meanTrainPlot+predictorGridNorm.*stdTrainPlot;
    figure(countFeature); 
    subplot(1,2,1); 
    hold on;  
    predictorTrainPlot=predictorVictim(:,NumFeaturesPlot);
    plotClass(predictorTrainPlot',responseTrain',0);                     

    xlabel('Mean');
    ylabel('Standard deviation');
    title({'Training set'},'FontWeight','normal');
    xlim([meanTrainPlot(1)+limValMin*stdTrainPlot(1),meanTrainPlot(1)+limValMax*stdTrainPlot(1)]);
    ylim([meanTrainPlot(2)+limValMin*stdTrainPlot(2),meanTrainPlot(2)+limValMax*stdTrainPlot(2)]);
    %daspect([1 0.1 1]);
    hleg=legend('Victim + Att','Attacker','Accomplice');
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
    %plotClass(predictorGrid',predictedResponsePlot',1);  
    
    xlabel('Mean');
    ylabel('Standard deviation');
    title({'Test set'},'FontWeight','normal');
    xlim([meanTrainPlot(1)+limValMin*stdTrainPlot(1),meanTrainPlot(1)+limValMax*stdTrainPlot(1)]);
    ylim([meanTrainPlot(2)+limValMin*stdTrainPlot(2),meanTrainPlot(2)+limValMax*stdTrainPlot(2)]);
    %daspect([1 0.1 1]);
    hleg=legend('Acc + Att', 'Attacker','Accomplice');
    set(hleg,'Location','NorthEast','FontSize',fSize-5);
    set(gca,'FontSize',fSize);
    grid on;
    hold off;       
end  