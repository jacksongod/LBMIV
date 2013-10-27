#include <convey/usr/cny_comp.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

#undef DEBUG

typedef unsigned long long uint64;
extern long cpVadd();
void usage (char *);

int main(int argc, char *argv[])
{
  long i;
  long size;
  uint64  *a1, *a2, *a3,*a4;
  uint64  *cp_a1, *cp_a2, *cp_a3,*cp_a4;
  uint64 act_sum;
  uint64 exp_sum=0;

  // check command line args
  if (argc == 1)
    size = 100;		// default size
  else if (argc == 2) {
    size = atoi(argv[1]);
    if (size > 0) {
      printf("Running UserApp.exe with size = %lld\n", size);
      fflush(stdout);
    } else {
      usage (argv[0]);
      return 0;
    }
  }
  else {
    usage (argv[0]);
    return 0;
  }

  // Get personality signature
  // The "pdk" personality is the PDK sample vadd personality
  cny_image_t        sig2;
  cny_image_t        sig;
  int stat;
  if (cny_get_signature)
    cny_get_signature("pdk", &sig, &sig2, &stat);
  else 
    fprintf(stderr,"ERROR:  cny_get_signature not found\n");

  if (stat) {
    printf("***ERROR: cny_get_signature() Failure: %d\n", stat);
    exit(1);
  }

  // check interleave
  // this example requires binary interleave
  if (cny_cp_interleave() == CNY_MI_3131) {
    printf("ERROR - interleave set to 3131, this personality requires binary interleave\n");
    exit (1);
  }

  //-------------------------------------------------------
  // For max performance, fill arrays on host, then use
  // datamover to copy data to coprocessor
  //-------------------------------------------------------

  // Allocate memory on host
  a1 = (uint64 *) (malloc)(size*8);
  a2 = (uint64 *) (malloc)(size*8);
  a3 = (uint64 *) (malloc)(size*8);
  a4 = (uint64 *) (malloc)(size*8);
  
  // Allocate memory on coprocessor
  if (cny_cp_malloc)  {
    cp_a1 = (uint64 *) (cny_cp_malloc)(size*8);
    cp_a2 = (uint64 *) (cny_cp_malloc)(size*8);
    cp_a3 = (uint64 *) (cny_cp_malloc)(size*8);
    cp_a4 = (uint64 *) (cny_cp_malloc)(size*8);
  }
  else 
    printf("malloc failed\n");

  // populate operand arrays in host memory
  for (i = 0; i < size; i++) {
    a1[i] = i;
    a2[i] = 2 * i;
    a4[i] =  3*i;
    
  }

  // copy arrays to coproceesor using datamover
  cny_cp_memcpy(cp_a1, a1, size*8);  
  cny_cp_memcpy(cp_a2, a2, size*8);  
  cny_cp_memcpy(cp_a4, a4, size*8);  

  // vector add copcall
  act_sum = l_copcall_fmt(sig, cpVadd, "AAAAA", cp_a1, cp_a2, cp_a3, size,cp_a4);

  // copy results arrray to host using datamover
  cny_cp_memcpy(a3, cp_a3, size*8);  

  //-------------------------------------------------------
  // verify results on host
  //-------------------------------------------------------
  for (i = 0; i < size; i++) {
    exp_sum += a1[i] + a2[i]+a4[i];
#ifdef DEBUG
    if (a3[i] != a1[i] + a2[i]+a4[i]) {
      printf("a1[%d]=%lld + a2[%d]=%lld +a4[%d] = %lld = a3[%d]=%lld\n", i, a1[i], i, a2[i],i,a4[i], i, a3[i]);
      fflush(stdout);
    }
#endif
  }

  if (exp_sum==act_sum) {
    printf("Sample 1 test passed - sum=%lld\n", exp_sum);
    fflush(stdout);
  } else {
    printf("Sample 1 test failed - expected sum=%lld, actual sum=%lld\n", exp_sum, act_sum);
    fflush(stdout);
  }

  return 0;
}

// Print usage message and exit with error.
void
usage (char* p)
{
    printf("usage: %s [count (default 100)] \n", p);
    exit (1);
}

