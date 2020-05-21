function [frameData_g00,frameData_g01,frameData_g10]=scissionExtractSample(frameData,NsampSym,NsampExtractMargin,risingIndex,fallingIndex,truncID)

% firstDataIndex=find(risingIndex-risingIndex(1)>truncID*NsampSym,1)-1;
frameData_g00=[];
frameData_g01=[];
frameData_g10=[];
for count=1:length(risingIndex)-2
    dominantCount=min(fallingIndex(count)-risingIndex(count),NsampSym);
    recessiveCount=min(risingIndex(count+1)-fallingIndex(count),NsampSym); 
    if(dominantCount==NsampSym)
        firstDataIndex=max(risingIndex(count)+NsampSym,truncID*NsampSym+risingIndex(1));
        frameData_g00=[frameData_g00,frameData(firstDataIndex:fallingIndex(count)-NsampExtractMargin)];
    end
    if(risingIndex(count)-risingIndex(1)>truncID*NsampSym-NsampExtractMargin)
        frameData_g10=[frameData_g10,frameData(risingIndex(count)+(0:dominantCount-1))];
    end
    if(fallingIndex(count)-risingIndex(1)>truncID*NsampSym-NsampExtractMargin)
        frameData_g01=[frameData_g01,frameData(fallingIndex(count)+(0:recessiveCount-1))];
    end
end