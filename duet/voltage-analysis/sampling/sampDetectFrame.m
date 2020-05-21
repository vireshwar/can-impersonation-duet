function [frameStartIndex,frameEndIndex]=sampDetectFrame(sampleData,NsampInterFrame,dominantFrameMinVal,recessiveFrameMaxVal)
    dominantIndex=find(sampleData>=recessiveFrameMaxVal);
    recessiveIndex=find(sampleData<=dominantFrameMinVal);
    if(~isempty(dominantIndex) && ~isempty(recessiveIndex))
        dominantIndexDiff=dominantIndex(2:end)-dominantIndex(1:end-1);
        frameSep=find(dominantIndexDiff>NsampInterFrame);
        frameStartIndex=dominantIndex(frameSep+1);
        frameEndIndex=dominantIndex(frameSep);
        if(dominantIndex(1)-recessiveIndex(1)>NsampInterFrame)
            frameStartIndex=[dominantIndex(1),frameStartIndex];
        else
            frameEndIndex=frameEndIndex(2:end);
        end
        if(recessiveIndex(end)-dominantIndex(end)>NsampInterFrame)
            frameEndIndex=[frameEndIndex,dominantIndex(end)];
        else
            frameStartIndex=frameStartIndex(1:end-1);
        end
    else
        frameStartIndex=[];
        frameEndIndex=[];
    end
        
