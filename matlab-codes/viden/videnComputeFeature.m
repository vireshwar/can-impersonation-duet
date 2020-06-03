function features=videnComputeFeature(dataRefH,dataRefL,Kbuffer,Rround,updateDispersion)

    Nround=min([floor(length(dataRefH)/Kbuffer),floor(length(dataRefL)/Kbuffer)]);         
    if(updateDispersion==1)
        medianIndex=ceil(Kbuffer*0.5);
        tenIndex=ceil(Kbuffer*0.1);
        tfiveIndex=ceil(Kbuffer*0.25);
        sfiveIndex=ceil(Kbuffer*0.75);
        ninetyIndex=ceil(Kbuffer*0.90);
        features=zeros(6,Nround-Rround);
        for countRound=Rround+1:Nround
            dataPrevH=sort(dataRefH(((countRound-1-Rround)*Kbuffer+1):((countRound-1)*Kbuffer)));    
            dataPrevL=sort(dataRefL(((countRound-1-Rround)*Kbuffer+1):((countRound-1)*Kbuffer)));
            dataCurrentH=sort(dataRefH(((countRound-1)*Kbuffer+1):(countRound*Kbuffer)));    
            dataCurrentL=sort(dataRefL(((countRound-1)*Kbuffer+1):(countRound*Kbuffer)));
            features(1,countRound-Rround)=dataCurrentH(medianIndex);
            features(3,countRound-Rround)=updateDispersionFunc(dataPrevH,dataCurrentH(sfiveIndex),0.75);
            features(5,countRound-Rround)=updateDispersionFunc(dataPrevH,dataCurrentH(ninetyIndex),0.90);
            features(2,countRound-Rround)=dataCurrentL(medianIndex); 
            features(4,countRound-Rround)=updateDispersionFunc(dataPrevL,dataCurrentL(tfiveIndex),0.25);
            features(6,countRound-Rround)=updateDispersionFunc(dataPrevL,dataCurrentL(tenIndex),0.10);
        end
    elseif(updateDispersion==2)
        medianIndex=ceil(Kbuffer*Rround*0.5);
        tenIndex=ceil(Kbuffer*Rround*0.1);
        tfiveIndex=ceil(Kbuffer*Rround*0.25);
        sfiveIndex=ceil(Kbuffer*Rround*0.75);
        ninetyIndex=ceil(Kbuffer*Rround*0.90);
        features=zeros(6,Nround-Rround+1);
        for countRound=Rround:Nround
            dataRoundH=sort(dataRefH(((countRound-Rround)*Kbuffer+1):(countRound*Kbuffer)));    
            dataRoundL=sort(dataRefL(((countRound-Rround)*Kbuffer+1):(countRound*Kbuffer)));
            features(1,countRound-Rround+1)=dataRoundH(medianIndex);
            features(3,countRound-Rround+1)=dataRoundH(sfiveIndex);
            features(5,countRound-Rround+1)=dataRoundH(ninetyIndex);
            features(2,countRound-Rround+1)=dataRoundL(medianIndex);
            features(4,countRound-Rround+1)=dataRoundL(tfiveIndex);
            features(6,countRound-Rround+1)=dataRoundL(tenIndex);
        end
    else
        medianIndex=ceil(Kbuffer*0.5);
        tenIndex=ceil(Kbuffer*0.1);
        tfiveIndex=ceil(Kbuffer*0.25);
        sfiveIndex=ceil(Kbuffer*0.75);
        ninetyIndex=ceil(Kbuffer*0.90);
        dataSortH=sort(reshape(dataRefH(1:Kbuffer*Nround),Kbuffer,Nround));
        dataSortL=sort(reshape(dataRefL(1:Kbuffer*Nround),Kbuffer,Nround));
        features=[dataSortH(medianIndex,:);dataSortL(medianIndex,:);...
                  dataSortH(sfiveIndex,:);dataSortL(tfiveIndex,:);...
                  dataSortH(ninetyIndex,:);dataSortL(tenIndex,:)];
    end
end

function lambda=updateDispersionFunc(dataPrev,lambda,perc)
    alpha=4;
    lambda=lambda + alpha*(perc-sum(dataPrev<lambda)/length(dataPrev))^3;
end
