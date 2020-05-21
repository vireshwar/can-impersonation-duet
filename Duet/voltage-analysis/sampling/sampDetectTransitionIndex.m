function [risingIndex,fallingIndex]=sampDetectTransitionIndex(frameData,NsampDetectMargin,dominantSymbolMinVal,recessiveSymbolMaxVal)
    dominantIndex=find(frameData>=recessiveSymbolMaxVal);
    recessiveIndex=find(frameData<=dominantSymbolMinVal);
      
    risingIndex=[];
    fallingIndex=[];
    count=1;
    risingIndex(1)=dominantIndex(1);
    while(count<200)
        foundFalling=find(recessiveIndex>risingIndex(count)+NsampDetectMargin,NsampDetectMargin);
        jitterCount=1;
        while(sum(recessiveIndex(foundFalling(jitterCount+1:NsampDetectMargin))-recessiveIndex(foundFalling(jitterCount:NsampDetectMargin-1)))>NsampDetectMargin+1-jitterCount)     
            jitterCount=jitterCount+1;
        end
        fallingIndex(count)=recessiveIndex(foundFalling(jitterCount));  

        foundRising=find(dominantIndex>fallingIndex(count)+NsampDetectMargin,1);
        if(~isempty(foundRising))
           risingIndex(count+1)=dominantIndex(foundRising); 
        else
            break;
        end
        count=count+1;
        
    end    
    