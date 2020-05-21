function [victimID,attackerID,victimECU,attackerECU,accompECU,busSpeed,voltMult] = expInfo(carExp,iterationCount,trainingPhase)
if(carExp==0) % Testbed
    busSpeed=500E3;
    voltMult=2.5;
    if(iterationCount==1)
        victimID='015'; 
        attackerID='015';
        victimECU=1; 
        attackerECU=2;
        accompECU=3; 
    end
end

if(trainingPhase==0)
    victimID = attackerID;
end
