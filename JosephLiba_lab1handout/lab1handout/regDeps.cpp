#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <fstream>
#include <assert.h>
#include "pin.H"

using namespace std;
ofstream OutFile;

// The array storing the spacing frequency between two dependant instructions
UINT64 *dependancySpacing;

// The array storing the dependency lengths.
INT32 * dependancyLengths;

// Output file name
INT32 maxSize;

// Number of registers
UINT32 numRegisters = 1000;
UINT32 maxReg = 0;

// This knob sets the output file name
KNOB<string> KnobOutputFile(KNOB_MODE_WRITEONCE, "pintool", "o", "result.csv", "specify the output file name");

// This knob will set the maximum spacing between two dependant instructions in the program
KNOB<string> KnobMaxSpacing(KNOB_MODE_WRITEONCE, "pintool", "s", "100", "specify the maximum spacing between two dependant instructions in the program");

// This function is called before every instruction is executed. Have to change
// the code to send in the register names from the Instrumentation function
VOID updateSpacingInfo(UINT32 write1,UINT32 write2,UINT32 write3,UINT32 write4, UINT32 read1, UINT32 read2,UINT32 read3,UINT32 read4){

// if dependency found, update histogram
// dependancySpacing update here

    
    if (read1 < maxReg) {
      INT32 count = dependancyLengths[read1];
      
      if (count <= 100) {
        if (count > 0) dependancySpacing[count]++;
      }
      else dependancyLengths[read1] = 0;
      
    }    
    
    if (read2 < maxReg) {
      INT32 count = dependancyLengths[read2];
      if (count <= 100) {
        if (count > 0) dependancySpacing[count]++;
      }
      else dependancyLengths[read2] = 0;
    }
    
    if (read3 < maxReg) {
      INT32 count = dependancyLengths[read3];
      if (count <= 100) {
        if (count > 0) dependancySpacing[count]++;
      }
      else dependancyLengths[read3] = 0;
    }
    if (read4 < maxReg) {
      INT32 count = dependancyLengths[read4];
      if (count <= 100) {
        if (count > 0) dependancySpacing[count]++;
      }
      else dependancyLengths[read4] = 0;
    }

    for (UINT32 i = 0; i < maxReg; i++) {
      if (dependancyLengths[i] > 0) {
        dependancyLengths[i]++;
      }
    }
    
    if (write1 < numRegisters) {
      dependancyLengths[write1] = 1;
    }
    if (write2 < numRegisters) {
      dependancyLengths[write2] = 1;
    }
    if (write3 < numRegisters) {
      dependancyLengths[write3] = 1;
    }
    if (write4 < numRegisters) {
      dependancyLengths[write4] = 1;
    }


}

// Pin calls this function every time a new instruction is encountered
VOID Instruction(INS ins, VOID *v)
{
    // Insert a call to updateSpacingInfo before every instruction.
    // You may need to add arguments to the call.

    UINT32 write1 = numRegisters;
    UINT32 write2 = numRegisters;
    UINT32 write3 = numRegisters;
    UINT32 write4 = numRegisters;
    UINT32 read1 = numRegisters;
    UINT32 read2 = numRegisters;
    UINT32 read3 = numRegisters;
    UINT32 read4 = numRegisters;

    if (INS_MaxNumWRegs(ins) >= 1) {
      write1 = (UINT32)REG_FullRegName(INS_RegW(ins,0));
      if (write1 > maxReg) maxReg = write1;
      if (INS_MaxNumWRegs(ins) >= 2 && (UINT32)INS_RegW(ins,1) != write1) {
        write2 = (UINT32)REG_FullRegName(INS_RegW(ins,1));
        if (write2 > maxReg) maxReg = write2;
        if (INS_MaxNumWRegs(ins) >= 3 && (UINT32)INS_RegW(ins,2) != write1 && (UINT32)INS_RegW(ins,2) != write2) {
          write3 = (UINT32)REG_FullRegName(INS_RegW(ins,2));
          if (write3 > maxReg) maxReg = write3;
          if (INS_MaxNumWRegs(ins) ==4 && (UINT32)INS_RegW(ins,3) != write1 && (UINT32)INS_RegW(ins,3) != write2 && (UINT32)INS_RegW(ins,3) != write3) {
            write4 = (UINT32)REG_FullRegName(INS_RegW(ins,3));
            if (write4 > maxReg) maxReg = write4;
          }
        }
      }
    }

    if (INS_MaxNumRRegs(ins) >= 1) {
      read1 = (UINT32)REG_FullRegName(INS_RegR(ins,0));
      if (read1 > maxReg) maxReg = read1;
      if (INS_MaxNumRRegs(ins) >= 2 && (UINT32)INS_RegR(ins,1) != read1) {
        read2 = (UINT32)REG_FullRegName(INS_RegR(ins,1));
        if (read2 > maxReg) maxReg = read2;
        if (INS_MaxNumRRegs(ins) >= 3 && (UINT32)INS_RegR(ins,2) != read1 && (UINT32)INS_RegR(ins,2) != read2) {
          read3 = (UINT32)REG_FullRegName(INS_RegR(ins,2));
          if (read3 > maxReg) maxReg = read3;
          if (INS_MaxNumRRegs(ins) == 4 && (UINT32)INS_RegR(ins,3) != read1 && (UINT32)INS_RegR(ins,3) != read2 && (UINT32)INS_RegR(ins,3) != read3) {
            read4 = (UINT32)REG_FullRegName(INS_RegR(ins,3));
            if (read4 > maxReg) maxReg = read4;
          }
        }
      }
    }
    
    
    
    INS_InsertCall(ins, IPOINT_BEFORE, (AFUNPTR)updateSpacingInfo, IARG_UINT32, write1,IARG_UINT32, write2,IARG_UINT32, write3,IARG_UINT32, write4, IARG_UINT32,
    read1, IARG_UINT32, read2,IARG_UINT32, read3,IARG_UINT32, read4,  IARG_END);

}

// This function is called when the application exits
VOID Fini(INT32 code, VOID *v)
{
    // Write to a file since cout and cerr maybe closed by the application
    OutFile.open(KnobOutputFile.Value().c_str());
    OutFile.setf(ios::showbase);
	for(INT32 i = 0; i < maxSize; i++)
		OutFile << dependancySpacing[i]<<",";
    OutFile.close();
}

// argc, argv are the entire command line, including pin -t <toolname> -- ...
int main(int argc, char * argv[])
{
    // Initialize pin
    PIN_Init(argc, argv);

    printf("Warning: Pin Tool not implemented\n");

    maxSize = atoi(KnobMaxSpacing.Value().c_str());

    // Initializing depdendancy Spacing
    dependancySpacing = new UINT64[maxSize];
    
    dependancyLengths = new INT32[numRegisters];

    // Register Instruction to be called to instrument instructions
    INS_AddInstrumentFunction(Instruction, 0);

    // Register Fini to be called when the application exits
    PIN_AddFiniFunction(Fini, 0);
    
    // Start the program, never returns
    PIN_StartProgram();
    
    return 0;
}

