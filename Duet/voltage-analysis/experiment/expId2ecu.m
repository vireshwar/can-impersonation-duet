function frameECU=expId2ecu(frameIDHex,carExp,iteration,ideaExp)

if(carExp==0) % Testbed
    if(strcmp(ideaExp,'Duet'))
        if(iteration==1)
            ecu1={'015','016','017','018'}; % Victim, Port-7
            ecu2={'00B','00C','00D','00E'}; %Attacker, Port-8
            ecu3={'001','002','003','004','005','006'}; % Accomplice, Port-9 
        end
    end
end

frameECU=zeros(length(frameIDHex),1);
for count=1:length(frameIDHex)
    if(sum(strcmp(frameIDHex(count),ecu1)))
        frameECU(count)=1;
    elseif(sum(strcmp(frameIDHex(count),ecu2)))
        frameECU(count)=2;
    elseif(sum(strcmp(frameIDHex(count),ecu3)))
        frameECU(count)=3;
    elseif(sum(strcmp(frameIDHex(count),ecu4)))
        frameECU(count)=4;
    elseif(sum(strcmp(frameIDHex(count),ecu5)))
        frameECU(count)=5;
    elseif(sum(strcmp(frameIDHex(count),ecu6)))
        frameECU(count)=6;
    elseif(sum(strcmp(frameIDHex(count),ecu7)))
        frameECU(count)=7;
    elseif(sum(strcmp(frameIDHex(count),ecu8)))
        frameECU(count)=8;
    elseif(sum(strcmp(frameIDHex(count),ecu9)))
        frameECU(count)=9;
    elseif(sum(strcmp(frameIDHex(count),ecu10)))
        frameECU(count)=10;
    elseif(sum(strcmp(frameIDHex(count),ecu11)))
        frameECU(count)=11;
    end
end


