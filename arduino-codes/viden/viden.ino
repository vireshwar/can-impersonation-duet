#include <SPI.h>
#include <math.h>
#include "mcp_can.h"

const int SPI_CS_PIN = 9;
MCP_CAN CAN(SPI_CS_PIN);                                    // Set CS pin


// Setting paramters for sampling
#define spi_readwrite SPI.transfer // pSPI->transfer
#ifndef cbi
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif
#ifndef sbi
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#endif


///// Constant values ////
#define freq 16 //MHz
#define overflowTime (65536/freq) //us, 2^16/freq
#define period 10000 //us //periodicity

const int timeMargin = 1000; // margin for sampling periodic message
const int accompliceID = 1;
const int attackerID = 11;
const int victimID = 21;
const int numIDs=3;
const int allID[numIDs] = {accompliceID,attackerID,victimID};
//const int allID[numIDs] = {0x015};

const int NsampData = 50;
const uint64_t waitFilterTime =   200000LL; // 200 milliseconds

const bool printInfo = true;

//////// Variables ///////
uint64_t timeNow = 0;
volatile unsigned long overflows = 0;
int countH = 0;
int countL = 0;
int dataSampH[NsampData];
int dataSampL[NsampData];
int iter=0;
int Niter=10;
unsigned char len;
unsigned char buf[8];
bool msgReceivedH=false;
bool msgReceivedL=false;
////////// Setup /////////

void setup()
{
  Serial.begin(1000000);
  while (CAN_OK != CAN.begin(CAN_500KBPS))  {
    Serial.println("CAN BUS Shield init fail");
    Serial.println(" Init CAN BUS Shield again");
    delay(100);
  }
  Serial.println("CAN BUS Shield init ok!");
  delay(100);
  
  // Set registers for sampling
  sbi(ADCSRA, ADPS2);
  cbi(ADCSRA, ADPS1);
  cbi(ADCSRA, ADPS0);

  // Set registers for timing
  TCCR1A = 0;
  TCCR1B = 0;
  TCCR1C = 0;
  TIMSK1 = _BV(TOIE1);

 // Set masks and filters
  int filt0=CAN.mcp2515_readRegister(MCP_RXB0CTRL);
  int filt1=CAN.mcp2515_readRegister(MCP_RXB1CTRL);
  CAN.mcp2515_modifyRegister(MCP_RXB0CTRL,filt0,0); 
  CAN.mcp2515_modifyRegister(MCP_RXB1CTRL,filt1,0);   
  emptyDataSampH();
  emptyDataSampL();
  startCleanTimer();
  Serial.println("Set up ok!");
}

/// Loop /////

void loop() {
  for (int i=0; i<numIDs; i++){
    if(videnMaskAndFilter(allID[i])) {
      iter=0;
      while(iter<Niter) {  
        videnSampling(!printInfo); 
        iter++;
      }
    }
  }
  
//  startCleanTimer();
//  while(getElapsedTime()<phaseChangeTime) {
//    for (int i=0; i<numIDs; i++){
//      videnMaskAndFilter(allID[i]);
//      timeNow = getElapsedTime();
//      while(getElapsedTime()-timeNow<trainTime) {    
//          if(CAN_MSGAVAIL == CAN.checkReceive()) videnSampling(!printInfo);   
//      }
//    }
//  }
//
//  Serial.println("Test Phase");
//  
//  videnMaskAndFilter(victimID);
//
//  Serial.println("No Attack");
//  timeNow = getElapsedTime();
//  while(getElapsedTime()-timeNow<timeTestVictim){
//  if(CAN_MSGAVAIL == CAN.checkReceive()) videnSampling(false);   
//  }
//  
//  int res = CAN.sendMsgBuf(phaseChangeToTest, 0, 8, phaseChangeMsg, false);
//  delay(100);
//  Serial.println("Masquerade Attack");
//  trainingPhase=false;
//  while(1){
//  if(CAN_MSGAVAIL == CAN.checkReceive()) videnSampling(false);   
//  }   

  
}


// Other functions

inline void videnSampling(bool printInfoLocal) {
    int idH = 0; 
    emptyBuffers(!printInfo);
    // Start sampling CAN-H    
    msgReceivedH=false;  
    while(!msgReceivedH){
      countH=0;   
      while (countH < NsampData && !msgReceivedH) {
        int sampH = analogRead(A0);
        dataSampH[countH]=sampH;   
        countH++;
        if(CAN_MSGAVAIL == CAN.checkReceive()) {
          idH = readMsgID();
//          Serial.println(countH);
          if(countH>=8) {
            msgReceivedH=true;
          } else {
            emptyDataSampH();
            countH=0; 
            delay(random(1,5));
            emptyBuffers(!printInfo);
          }
        }      
      }
      if(countH==NsampData && !msgReceivedH) emptyDataSampH();
    }

        
    int idL = 0; 
    emptyBuffers(!printInfo);
    // Start sampling CAN-L    
    msgReceivedL=false;  
    while(!msgReceivedL){
      countL=0;   
      while (countL < NsampData && !msgReceivedL) {
        int sampL = analogRead(A1);
        dataSampL[countL]=sampL;   
        countL++;
        if(CAN_MSGAVAIL == CAN.checkReceive()) {
          idL = readMsgID();
//          Serial.println(countL);
          if(countL>=8) {
            msgReceivedL=true;
          } else {
            emptyDataSampL();
            countL=0; 
            delay(random(1,5));
            emptyBuffers(!printInfo);
          }
        }      
      }
      if(countL==NsampData && !msgReceivedL) emptyDataSampL();
    }

    String stringID =  String(idH, HEX);
    while (stringID.length()<3) stringID = "0" + stringID;
 
    int i=0;
    while (i < 8) {
      Serial.print(stringID);
      Serial.print("   ");
      Serial.print(dataSampH[countH-i-1]);
      Serial.print("   ");
      Serial.print(dataSampL[countL-i-1]);
      Serial.println();
      i++;
    }


    if(printInfoLocal) printSample();
}

inline void emptyDataSampH() {
  int i=0;
  while (i < NsampData) {
    dataSampH[i] = 0;
    i++;
  }
}

inline void emptyDataSampL() {
  int i=0;
  while (i < NsampData) {
    dataSampL[i] = 0;
    i++;
  }
}

inline void printSample() {
  Serial.print("DataSampH -- Length: ");
  Serial.print(countH);
  Serial.print(" , Samples:  ");
  for (int i = 0; i < NsampData; i++) {
    Serial.print((int)dataSampH[i]);
    Serial.print("     ");
  }
  Serial.println();
  Serial.print("DataSampL -- Length: ");
  Serial.print(countL);
  Serial.print(" , Samples:  ");
  for (int i = 0; i < NsampData; i++) {
    Serial.print((int)dataSampL[i]);
    Serial.print("     ");
  }
  Serial.println();
 // delay(10000);
}

inline int readMsgID() {
  CAN.readMsgBuf(&len, buf);
  int id = CAN.getCanId();
  return id;
}

inline unsigned char readLastByte() {
  CAN.readMsgBuf(&len, buf);
  unsigned char bufStr = buf[len-1];
  return bufStr;
}

inline void emptyBuffers(bool printInfoLocal) {
  while (CAN_MSGAVAIL == CAN.checkReceive()) {
    CAN.readMsgBuf(&len, buf);
    int id = CAN.getCanId();
    if(printInfoLocal){
      Serial.print("Received ID: ");
      Serial.println(id);
      Serial.print("Received Data: ");
      Serial.println(buf[7]);
    }
  }
}

inline uint64_t getElapsedTime() { //in us
  uint64_t currOverflows = overflows;
  unsigned int currTimer = TCNT1;
  return (currOverflows * overflowTime + currTimer / freq);
}

inline void startCleanTimer() {
  overflows = 0; TCNT1 = 0; TCCR1B = 1;
}

ISR(TIMER1_OVF_vect) {
  overflows++;
}


inline bool videnMaskAndFilter(int sampleID){
  startCleanTimer();
  bool filtSuccess=false;
  while(!filtSuccess && getElapsedTime()<waitFilterTime){
//  Serial.println(sampleID);
                            
    CAN.init_Mask(0, 0, 0x7FF);                        
    CAN.init_Mask(1, 0, 0x7FF); 
    CAN.init_Filt(0, 0, sampleID);                         
    CAN.init_Filt(1, 0, sampleID);                          
    CAN.init_Filt(2, 0, sampleID);                          
    CAN.init_Filt(3, 0, sampleID);                          
    CAN.init_Filt(4, 0, sampleID);                          
    CAN.init_Filt(5, 0, sampleID);     
    emptyBuffers(!printInfo);

    while(CAN_MSGAVAIL != CAN.checkReceive() && getElapsedTime()<waitFilterTime);
    bool filtSuccess1=(readMsgID()==sampleID);
    while(CAN_MSGAVAIL != CAN.checkReceive() && getElapsedTime()<waitFilterTime);
    bool filtSuccess2=(readMsgID()==sampleID);
    return filtSuccess = filtSuccess1 && filtSuccess2;      
  }
  Serial.print("All filters are set to ID: ");
  Serial.println(sampleID);
}

inline void Serialprint(uint64_t value)
{
  if ( value >= 10 ) Serialprint(value / 10);
  Serial.print((int)(value % 10));
}
