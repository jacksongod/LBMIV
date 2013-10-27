#include "CaeSim.h"
#include "CaeIsa.h"
#include <stdio.h>

#define NUM_AEGS 34
#define PERS_NUM 4

#define AEG_MA1 0
#define AEG_MA2 1
#define AEG_MA3 2
#define AEG_MA4 5
#define AEG_CNT 3
#define AEG_SAE_BASE 30 

#define NUM_MCS 8
#define NUM_AEPIPES 16
#define NUM_FPS 63
#define MEM_REQ_SIZE 8

#define AEUIE 0
#undef DEBUG

void
CCaeIsa::InitPers()
{
    SetAegCnt(NUM_AEGS);
    WriteAeg(0, 0, 0);
    SetPersNum(PERS_NUM);
    // clear the sum registers
    for (int aeId = 0; aeId < 4; aeId += 1) {
	WriteAeg(aeId, AEG_SAE_BASE+aeId, 0);
    }
}

void
CCaeIsa::CaepInst(int aeId, int opcode, int immed, uint32 inst, uint64 scalar) // F7,0,20-3F
{
    switch (opcode) {
	// CAEP00 - M[a1] + M[a2] -> M[a3]
	case 0x20: {
	    uint64 length, a1, a2, a3,a4;
	    uint64 val1, val2, val3, val4, sum = 0;

	    length = ReadAeg(aeId, AEG_CNT);
          // printf("Sum init : %lld\n",sum);
	    for (uint64 i = 0; i < NUM_AEPIPES; i++) {
		int fpnum = (aeId << 4) + i;
		int fp_offset = fpnum*8;
	        a1 = ReadAeg(aeId, AEG_MA1) + fp_offset;
	        a2 = ReadAeg(aeId, AEG_MA2) + fp_offset;
	        a3 = ReadAeg(aeId, AEG_MA3) + fp_offset;
	        a4 = ReadAeg(aeId, AEG_MA4) + fp_offset;
                
		uint64 last_a1 = ReadAeg(aeId, AEG_MA1) + length*8;
		while ((a1 < last_a1) && (fpnum<NUM_FPS)) {
#ifdef DEBUG
		printf("AE=%d fpnum=%d fpnum*64=%d a1=%llx a2=%llx a3=%llx mc_nums(1,2,3) = %lld,%lld,%lld\n", 
                        aeId, fpnum, fpnum*64, a1, a2, a3, (a1>>6)&7, (a2>>6)&7, (a3>>6)&7);
#endif
		    AeMemLoad(aeId, McNum(a1), a1, MEM_REQ_SIZE, false, val1);
		    AeMemLoad(aeId, McNum(a2), a2, MEM_REQ_SIZE, false, val2);
		    AeMemLoad(aeId, McNum(a4), a4, MEM_REQ_SIZE, false, val4);
              // printf("a4: %lld\n",val4);    
              // printf("AE: %d a3: %lld i:%lld\n",aeId,val3,i);    
		    val3 = val1 + val2 + val4;
		    sum += val3;
             //  printf("AE: %d a3: %lld i:%lld  sum: %lld\n",aeId,val3,i,sum);    
#ifdef DEBUG
		    printf("AE=%d:  i = %lld val1=%lld val2=%lld val3=%lld sum=%lld\n",aeId,i, val1, val2, val3, sum);
#endif
		    AeMemStore(aeId, McNum(a3), a3, MEM_REQ_SIZE, false, val3);

		    // increment addresses
		    a1 += NUM_FPS*8;	// number of pipes * 8 bytes
		    a2 += NUM_FPS*8;
		    a3 += NUM_FPS*8;
		    a4 += NUM_FPS*8;
                    
		}
	    }
	    WriteAeg(aeId, AEG_SAE_BASE+aeId, sum);
	    break;
	}

	default:{
	    printf("Default case hit - opcode = %x\n", opcode);
	    for (int aeId = 0; aeId < CAE_AE_CNT; aeId += 1)
		SetException(aeId, AEUIE);
	}
    }
}

