#include <iostream>
#include <stdio.h>
#include <assert.h>
#include <fstream> 
#include "pin.H"

static UINT64 takenCorrect = 0;
static UINT64 takenIncorrect = 0;
static UINT64 notTakenCorrect = 0;
static UINT64 notTakenIncorrect = 0;

static BOOL bit1 = FALSE;
static BOOL bit2 = FALSE;

// A branch prediction buffer of max
static UINT64 bufferSize = 32000;
static UINT64 indexBits = 5;
static BOOL * branchBuffer;


class BranchPredictor {

  public:
  BranchPredictor() { }

  virtual BOOL makePrediction(ADDRINT address) { return FALSE;};

  virtual void makeUpdate(BOOL takenActually, BOOL takenPredicted, ADDRINT address) { };

};

class myBranchPredictor: public BranchPredictor {
  public:
  myBranchPredictor() {}

  BOOL makePrediction(ADDRINT address){

    // Returns the finds the predicted value of a 2 bit correlational branch prediction cache
    // The size of the cache is 32k.
    if (branchBuffer[(address%(bufferSize/indexBits))*indexBits]) {
      if (branchBuffer[(address%(bufferSize/indexBits)*indexBits)+1])
        return branchBuffer[(address%(bufferSize/indexBits)*indexBits)+1];
      return branchBuffer[(address%(bufferSize/indexBits)*indexBits)+3];
    }
    // if no cache hit, then return the result of the 2 bit branch predictor
    return bit1;
  }

  void makeUpdate(BOOL takenActually, BOOL takenPredicted, ADDRINT address){
    // A 2 bit state machine that moves around strongly / weakly taken / not taken.
    // 00: strongly not taken, 01: weakly not taken, 10: weakly taken, 11: strongly taken
    
    // The standard 2 bit predictor in case no cache hit occurs is updated.
    bit1 = (bit2 & takenActually) | (bit1 & bit2) | (bit1 & takenActually);
    bit2 = (bit1 & !bit2) | (!bit2 & takenActually) | (bit1 & takenActually);

    // 1 bit history correlation bit predictor
    BOOL bufBit1 = branchBuffer[(address%(bufferSize/indexBits)*indexBits)+1];
    BOOL bufBit2 = branchBuffer[(address%(bufferSize/indexBits)*indexBits)+2];
    BOOL bufBit3 = branchBuffer[(address%(bufferSize/indexBits)*indexBits)+3];
    BOOL bufBit4 = branchBuffer[(address%(bufferSize/indexBits)*indexBits)+4];

   
    // Based on the last branch, runs another 2 bit predictor
    branchBuffer[(address%(bufferSize/indexBits)*indexBits)+1] = (bufBit2 & takenActually) | (bufBit1 & bufBit2) | (bufBit1 & takenActually);
    branchBuffer[(address%(bufferSize/indexBits)*indexBits)+2] = (bufBit1 & !bufBit2) | (!bufBit2 & takenActually) | (bufBit1 & takenActually);
    branchBuffer[(address%(bufferSize/indexBits)*indexBits)+3] = (bufBit4 & takenActually) | (bufBit3 & bufBit4) | (bufBit3 & takenActually);
    branchBuffer[(address%(bufferSize/indexBits)*indexBits)+4] = (bufBit3 & !bufBit4) | (!bufBit4 & takenActually) | (bufBit3 & takenActually);
   
  }
    
};

BranchPredictor* BP;


// This knob sets the output file name
KNOB<string> KnobOutputFile(KNOB_MODE_WRITEONCE, "pintool", "o", "result.out", "specify the output file name");


// In examining handle branch, refer to quesiton 1 on the homework
void handleBranch(ADDRINT ip, BOOL direction)
{
  BOOL prediction = BP->makePrediction(ip);
  BP->makeUpdate(direction, prediction, ip);

  /*
  if(prediction) {
    if(direction) {
      takenCorrect++;
    }
    else {
      takenIncorrect++;
    }
  } else {
    if(direction) {
      notTakenIncorrect++;
    }
    else {
      notTakenCorrect++;
    }
  }
  */
  takenCorrect += (UINT64)(prediction & direction);
  takenIncorrect += (UINT64)(prediction & !direction);
  notTakenIncorrect += (UINT64)(!prediction & direction);
  notTakenCorrect += (UINT64)(!prediction & !direction);
  
}


void instrumentBranch(INS ins, void * v)
{   
  if(INS_IsBranch(ins) && INS_HasFallThrough(ins)) {
    INS_InsertCall(
      ins, IPOINT_TAKEN_BRANCH, (AFUNPTR)handleBranch,
      IARG_INST_PTR,
      IARG_BOOL,
      TRUE,
      IARG_END); 

    INS_InsertCall(
      ins, IPOINT_AFTER, (AFUNPTR)handleBranch,
      IARG_INST_PTR,
      IARG_BOOL,
      FALSE,
      IARG_END);

    // Sets that particular location in the cache as a branch instruction.
    // Used to determine cache hits and misses.
    branchBuffer[(INS_Address(ins)%(bufferSize/indexBits))*indexBits] = TRUE; 
  }
}
 

/* ===================================================================== */
VOID Fini(int, VOID * v)
{   
  ofstream outfile;
  outfile.open(KnobOutputFile.Value().c_str());
  outfile.setf(ios::showbase);
  outfile << "takenCorrect: "<< takenCorrect <<"  takenIncorrect: "<< takenIncorrect <<" notTakenCorrect: "<< notTakenCorrect <<" notTakenIncorrect: "<< notTakenIncorrect <<"\n";
  outfile.close();
}


// argc, argv are the entire command line, including pin -t <toolname> -- ...
int main(int argc, char * argv[])
{
    // Make a new branch predictor
    BP = new myBranchPredictor();

    // Initialize pin
    PIN_Init(argc, argv);

    // Initialize Buffer
    branchBuffer = new BOOL[bufferSize];
    for (int i = 0; i < (int)bufferSize; i+=5) {
      branchBuffer[1+i] = 1;
      branchBuffer[3+i] = 1;
    }

    // Register Instruction to be called to instrument instructions
    INS_AddInstrumentFunction(instrumentBranch, 0);

    // Register Fini to be called when the application exits
    PIN_AddFiniFunction(Fini, 0);
    
    // Start the program, never returns
    PIN_StartProgram();
    
    return 0;
}

