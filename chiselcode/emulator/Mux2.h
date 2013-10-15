#ifndef __Mux2__
#define __Mux2__

#include "emulator.h"

class Mux2_t : public mod_t {
 public:
  dat_t<1> Mux2__io_in0;
  dat_t<1> Mux2__io_sel;
  dat_t<1> Mux2__io_in1;
  dat_t<1> Mux2__io_out;
  int clk;
  int clk_cnt;

  void init ( bool rand_init = false );
  void clock_lo ( dat_t<1> reset );
  void clock_hi ( dat_t<1> reset );
  int clock ( dat_t<1> reset );
  void print ( FILE* f );
  bool scan ( FILE* f );
  void dump ( FILE* f, int t );
};

#endif
