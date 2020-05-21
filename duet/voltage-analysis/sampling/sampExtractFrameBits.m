function [frameBits,stuffID]=sampExtractFrameBits(NsampSym,risingIndex,fallingIndex)
frameStuffBits=[];
for count=1:length(risingIndex)-1
    dominantCount=round((fallingIndex(count)-risingIndex(count))/NsampSym);
    recessiveCount=round((risingIndex(count+1)-fallingIndex(count))/NsampSym);
    if(dominantCount>5)
        dominantCount=5;
    elseif(dominantCount==0)
        dominantCount=1;
    end
    if(recessiveCount>5)
        recessiveCount=5;
    elseif(recessiveCount==0)
        recessiveCount=1;
    end
    frameStuffBits=[frameStuffBits,zeros(1,dominantCount),ones(1,recessiveCount)];
end

frameBits=[];
stuffID=0;
for count=1:length(frameStuffBits)
    if(count>5)
        checkStuff=sum(frameStuffBits(count-(1:5)));
        if(checkStuff~=0 && checkStuff~=5)
            frameBits=[frameBits,frameStuffBits(count)];
        else
            if(length(frameBits)<=13)
                stuffID=stuffID+1;
            end
        end
    else
        frameBits=[frameBits,frameStuffBits(count)];
    end
end
    