function [dataRefH,dataRefL,ackThresH,ackThresL]=videnAckThres(dataH,dataL,Mbuffer,countID)
% minstd=0.005;
% Bparam=15;
% Bparam2=1;

NroundH=floor(length(dataH)/Mbuffer);         
dataBufferH=reshape(dataH(1:Mbuffer*NroundH),Mbuffer,NroundH);
dataBufferMaxH=sort(max(dataBufferH));
dataBufferModeH=sort(median(dataBufferH));        
% dataBufferModeH_std_org=std(dataBufferModeH);
% dataBufferModeH_std_mod=dataBufferModeH_std_org*(dataBufferModeH_std_org>0.001)+minstd*(dataBufferModeH_std_org<=0.001);
% dataBufferLimitH_org=max(dataBufferModeH)+Bparam*dataBufferModeH_std_mod;
% dataBufferLimitH_mod=min([dataBufferLimitH_org,max(dataBufferMaxH)]);
% dataBufferMaxRefH=dataBufferMaxH(dataBufferMaxH>=dataBufferLimitH_mod);
% tau1H=median(dataBufferMaxRefH)-3*mad(dataBufferMaxRefH);
% tau2H=mean(dataBufferMaxRefH)-3*std(dataBufferMaxRefH);
% ackThresH=max([tau1H,tau2H,min(dataBufferModeH)]);
sfivePerc=ceil(length(dataBufferMaxH)*0.50);
ackThresH=dataBufferMaxH(sfivePerc);

NroundL=floor(length(dataL)/Mbuffer); 
dataBufferL=reshape(dataL(1:Mbuffer*NroundL),Mbuffer,NroundL);
dataBufferMinL=sort(min(dataBufferL));
dataBufferModeL=sort(median(dataBufferL));        
% dataBufferModeL_std_org=std(dataBufferModeL);
% dataBufferModeL_std_mod=dataBufferModeL_std_org*(dataBufferModeL_std_org>0.001)+minstd*(dataBufferModeL_std_org<=0.001);
% dataBufferLimitL_org=min(dataBufferModeL)-Bparam*dataBufferModeL_std_mod;
% dataBufferLimitL_mod=max([dataBufferLimitL_org,min(dataBufferMinL)]);
% dataBufferMinRefL=dataBufferMinL(dataBufferMinL<=dataBufferLimitL_mod);
% tau1L=median(dataBufferMinRefL)+3*mad(dataBufferMinRefL);
% tau2L=mean(dataBufferMinRefL)+3*std(dataBufferMinRefL);
% ackThresL=min([tau1L,tau2L,max(dataBufferModeL)]);
tfivePerc=ceil(length(dataBufferMinL)*0.50);
ackThresL=dataBufferMinL(tfivePerc);

dataRefH=dataH(dataH<=ackThresH);
dataRefL=dataL(dataL>=ackThresL);

if(0)
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
    
    
%     figure;
%     subplot(1,2,1);
%     hold on;
%     histogram(dataBufferModeL,'BinWidth',0.01,'BinLimits',[1 2.5]);
%     histogram(dataBufferMinL,'BinWidth',0.01,'BinLimits',[1 2.5]);
%     legend('Most frequent set', 'Minimum set');
%     title(strcat("CANL, ID: ",num2str(countID)));
%     hold off;
%     
%     subplot(1,2,2);
%     hold on;
%     histogram(dataBufferModeH,'BinWidth',0.01,'BinLimits',[2.5 4]);
%     histogram(dataBufferMaxH,'BinWidth',0.01,'BinLimits',[2.5 4]);
%     legend('Most frequent set', 'Maximum set');
%     title(strcat(" CANH, ID: ",num2str(countID)));
%     hold off;
   

end