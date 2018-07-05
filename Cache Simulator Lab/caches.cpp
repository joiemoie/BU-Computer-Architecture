#include <iostream>
#include <fstream> 
#include <stdio.h>
#include <assert.h>
#include <math.h>
#include "pin.H"

UINT32 logPageSize;
UINT32 logPhysicalMemSize;
UINT32 unalignedAccesses;
UINT32 accesses;

//Function to obtain physical page number given a virtual page number
UINT64 getPhysicalPageNumber(UINT64 virtualPageNumber)
{
    INT32 key = (INT32) virtualPageNumber;
    key = ~key + (key << 15); // key = (key << 15) - key - 1;
    key = key ^ (key >> 12);
    key = key + (key << 2);
    key = key ^ (key >> 4);
    key = key * 2057; // key = (key + (key << 3)) + (key << 11);
    key = key ^ (key >> 16);
    return (UINT32) (key&(((UINT32)(~0))>>(32-logPhysicalMemSize)));
}

class CacheModel
{

    protected:
        UINT32   logNumRows;
        UINT32   logBlockSize;
        UINT32   associativity;
        UINT64   readReqs;
        UINT64   writeReqs;
        UINT64   readHits;
        UINT64   writeHits;
        UINT32** tag;
        bool**   validBit;

        // FOR LRU Policy
        UINT64 count; // The number of memory accesses performed so far
        
        /* Stores the count when a cache entry was last modified. Realistically, I don't
        need all 32 bits. I only need as many as logAssociativity bits*/
        UINT32** order;

    public:
        //Constructor for a cache
        CacheModel(UINT32 logNumRowsParam, UINT32 logBlockSizeParam, UINT32 associativityParam)
        {
            logNumRows = logNumRowsParam;
            logBlockSize = logBlockSizeParam;
            associativity = associativityParam;
            readReqs = 0;
            writeReqs = 0;
            readHits = 0;
            writeHits = 0;
            count = 0; //An additional initialization for the memory counter
            tag = new UINT32*[1u<<logNumRows];
            validBit = new bool*[1u<<logNumRows];
            order = new UINT32*[1u<<logNumRows]; // An additional initialization for time counter of each entry
            for(UINT32 i = 0; i < 1u<<logNumRows; i++)
            {
               tag[i] = new UINT32[associativity];
               validBit[i] = new bool[associativity];
               order[i] = new UINT32[associativity];
               for(UINT32 j = 0; j < associativity; j++)
                 validBit[i][j] = false;
            }
        }

        //Call this function to update the cache state whenever data is read
        virtual void readReq(UINT32 virtualAddr) = 0;

        //Call this function to update the cache state whenever data is written
        virtual void writeReq(UINT32 virtualAddr) = 0;

        /* A function that is universal across all cache reads and writes. It checks
         if a tag and index is in the cache. Returns true on a cache hit. Also
        updates the cache using the LRU policy */
        bool cacheHit(UINT32 virtualAddr, bool virtualTag)
        {
          bool hit = false; // flag to check for a cache hit
          UINT32 index = 0;
          UINT32 subTag = 0;

          // Index is either physical index or virtual index from the beginning, so no translation needed
          index = (virtualAddr<<(32-logNumRows-logBlockSize))>>(32-logNumRows); // index is lower order bits
          
          // If using virtual tag, no translation needed. Otherwise, translate.
          if (virtualTag){
            subTag = virtualAddr>>(logBlockSize+logNumRows); // tag is higher order bits
          }
          else {
            UINT32 physPage = getPhysicalPageNumber((virtualAddr>>logBlockSize)<<logBlockSize);
            subTag = physPage >> logNumRows;
          }
          //Checks the index if any of the entries match the tag.
          for(UINT32 i = 0; i < associativity && !hit; i++){
            if (validBit[index][i] && tag[index][i] == subTag) {
              hit = true;
              order[index][i] = count; // Updates the entry's memory count time.
            }
          }
          
          // On no cache hit, replaces the least recently used cache entry
          if (!hit) {
            bool slotFound = false;
            UINT32 emptySlot = 0;
            UINT32 lowestCount = count;
            for(UINT32 i = 0; i < associativity && !hit && !slotFound; i++){
              //If a bit is not valid, it is open and immediately used. 
              if (!validBit[index][i]) {
                slotFound = true;
                emptySlot = i;

              }
              //The lowest slot memory count time will be selected for replacement.
              if (order[index][i] < lowestCount) {
                lowestCount = order[index][i];
                emptySlot = i;
              }
            }
            validBit[index][emptySlot] = true;
            tag[index][emptySlot] = subTag;
            order[index][emptySlot] = count;
          }
          count++;
          return hit; 
        }

        //Do not modify this function
        void dumpResults(ofstream *outfile)
        {
        	*outfile << readReqs <<","<< writeReqs <<","<< readHits <<","<< writeHits <<"\n";
        }
};

CacheModel* cachePP;
CacheModel* cacheVP;
CacheModel* cacheVV;

class LruPhysIndexPhysTagCacheModel: public CacheModel
{
    public:
        LruPhysIndexPhysTagCacheModel(UINT32 logNumRowsParam, UINT32 logBlockSizeParam, UINT32 associativityParam)
            : CacheModel(logNumRowsParam, logBlockSizeParam, associativityParam)
        {
        }

        // translates to a physical address first before checking the cache
        void readReq(UINT32 virtualAddr)
        {
          readReqs++;
          // Converts the virtual page address to a physical page address
          UINT32 physAddr = (getPhysicalPageNumber(virtualAddr>>logBlockSize)<<logBlockSize) + ((virtualAddr<<(32-logBlockSize))>>(32-logBlockSize));
          if (cacheHit(physAddr, false)) readHits++;

        }

        // translates to a physical address first before checking the cache
        void writeReq(UINT32 virtualAddr)
        {
          writeReqs++;
          // Converts the virtual page number to a physical page number
          UINT32 physAddr = (getPhysicalPageNumber(virtualAddr>>logBlockSize)<<logBlockSize) | ((virtualAddr<<(32-logBlockSize))>>(32-logBlockSize));
          if (cacheHit(physAddr, false)) writeHits++;
        }
};

class LruVirIndexPhysTagCacheModel: public CacheModel
{
    public:
        LruVirIndexPhysTagCacheModel(UINT32 logNumRowsParam, UINT32 logBlockSizeParam, UINT32 associativityParam)
            : CacheModel(logNumRowsParam, logBlockSizeParam, associativityParam)
        {
        }
          
        // sends the virtual address, then checks the physical tag later// sends the virtual address, then checks the physical tag later
        void readReq(UINT32 virtualAddr)
        {
          readReqs++;

          if (cacheHit(virtualAddr, false)) readHits++;;
        }

          // sends the virtual address, then checks the physical tag later
        void writeReq(UINT32 virtualAddr)
        {
          writeReqs++;

          if (cacheHit(virtualAddr, false)) writeHits++;
        }
};

class LruVirIndexVirTagCacheModel: public CacheModel
{
    public:
        LruVirIndexVirTagCacheModel(UINT32 logNumRowsParam, UINT32 logBlockSizeParam, UINT32 associativityParam)
            : CacheModel(logNumRowsParam, logBlockSizeParam, associativityParam)
        {
        }

          // sends the virtual address, then checks the physical tag later
        void readReq(UINT32 virtualAddr)
        {
          readReqs++;
          if (cacheHit(virtualAddr, true)) readHits++;
        }

          // sends the virtual address, then checks the physical tag later
        void writeReq(UINT32 virtualAddr)
        {
          writeReqs++;
          if (cacheHit(virtualAddr, true)) writeHits++;
        }
};

//Cache analysis routine
void cacheLoad(UINT32 virtualAddr)
{
    //Here the virtual address is aligned to a word boundary
    virtualAddr = (virtualAddr >> 2) << 2;
    cachePP->readReq(virtualAddr);
    cacheVP->readReq(virtualAddr);
    cacheVV->readReq(virtualAddr);
}

//Cache analysis routine
void cacheStore(UINT32 virtualAddr)
{

    //Counts total accesses and unaligned accesses
    accesses++;
    if ((virtualAddr<<30)>>30 > 0) unalignedAccesses++;
    
    //Here the virtual address is aligned to a word boundary
    virtualAddr = (virtualAddr >> 2) << 2;
    
    cachePP->writeReq(virtualAddr);
    cacheVP->writeReq(virtualAddr);
    cacheVV->writeReq(virtualAddr);
}

// This knob will set the outfile name
KNOB<string> KnobOutputFile(KNOB_MODE_WRITEONCE, "pintool",
			    "o", "results.out", "specify optional output file name");

// This knob will set the param logPhysicalMemSize
KNOB<UINT32> KnobLogPhysicalMemSize(KNOB_MODE_WRITEONCE, "pintool",
                "m", "16", "specify the log of physical memory size in bytes");

// This knob will set the param logPageSize
KNOB<UINT32> KnobLogPageSize(KNOB_MODE_WRITEONCE, "pintool",
                "p", "12", "specify the log of page size in bytes");

// This knob will set the cache param logNumRows
KNOB<UINT32> KnobLogNumRows(KNOB_MODE_WRITEONCE, "pintool",
                "r", "9", "specify the log of number of rows in the cache");

// This knob will set the cache param logBlockSize
KNOB<UINT32> KnobLogBlockSize(KNOB_MODE_WRITEONCE, "pintool",
                "b", "2", "specify the log of block size of the cache in bytes");

// This knob will set the cache param associativity
KNOB<UINT32> KnobAssociativity(KNOB_MODE_WRITEONCE, "pintool",
                "a", "1", "specify the associativity of the cache");

// Pin calls this function every time a new instruction is encountered
VOID Instruction(INS ins, VOID *v)
{
    if(INS_IsMemoryRead(ins))
        INS_InsertCall(ins, IPOINT_BEFORE, (AFUNPTR)cacheLoad, IARG_MEMORYREAD_EA, IARG_END);
    if(INS_IsMemoryWrite(ins))
        INS_InsertCall(ins, IPOINT_BEFORE, (AFUNPTR)cacheStore, IARG_MEMORYWRITE_EA, IARG_END);
}

// This function is called when the application exits
VOID Fini(INT32 code, VOID *v)
{
    ofstream outfile;
    outfile.open(KnobOutputFile.Value().c_str());
    outfile.setf(ios::showbase);
    outfile << "physical index physical tag: ";
    cachePP->dumpResults(&outfile);
     outfile << "virtual index physical tag: ";
    cacheVP->dumpResults(&outfile);
     outfile << "virtual index virtual tag: ";
    cacheVV->dumpResults(&outfile);
    outfile.close();
    
    // For testing
    //std::cout << accesses << " " << unalignedAccesses;
}

// argc, argv are the entire command line, including pin -t <toolname> -- ...
int main(int argc, char * argv[])
{
    // Initialize pin
    PIN_Init(argc, argv);
	
    logPageSize = KnobLogPageSize.Value();
    logPhysicalMemSize = KnobLogPhysicalMemSize.Value();

    cachePP = new LruPhysIndexPhysTagCacheModel(KnobLogNumRows.Value(), KnobLogBlockSize.Value(), KnobAssociativity.Value()); 
    cacheVP = new LruVirIndexPhysTagCacheModel(KnobLogNumRows.Value(), KnobLogBlockSize.Value(), KnobAssociativity.Value());
    cacheVV = new LruVirIndexVirTagCacheModel(KnobLogNumRows.Value(), KnobLogBlockSize.Value(), KnobAssociativity.Value());

    // Register Instruction to be called to instrument instructions
    INS_AddInstrumentFunction(Instruction, 0);

    // Register Fini to be called when the application exits
    PIN_AddFiniFunction(Fini, 0);

    // Start the program, never returns
    PIN_StartProgram();

    return 0;
}
