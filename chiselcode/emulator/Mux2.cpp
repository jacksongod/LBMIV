#include "Mux2.h"

void Mux2_t::init ( bool rand_init ) {
}
void Mux2_t::clock_lo ( dat_t<1> reset ) {
  val_t T0__w0;
  { T0__w0 = ~Mux2__io_sel.values[0]; }
  T0__w0 = T0__w0 & 1;
  val_t T1__w0;
  { T1__w0 = T0__w0&Mux2__io_in0.values[0]; }
  val_t T2__w0;
  { T2__w0 = Mux2__io_sel.values[0]&Mux2__io_in1.values[0]; }
  val_t T3__w0;
  { T3__w0 = T2__w0|T1__w0; }
  { Mux2__io_out.values[0] = T3__w0; }
}
void Mux2_t::clock_hi ( dat_t<1> reset ) {
}
int Mux2_t::clock ( dat_t<1> reset ) {
  uint32_t min = ((uint32_t)1<<31)-1;
  if (clk_cnt < min) min = clk_cnt;
  clk_cnt-=min;
  if (clk_cnt == 0) clock_lo( reset );
  if (clk_cnt == 0) clock_hi( reset );
  if (clk_cnt == 0) clk_cnt = clk;
  return min;
}
void Mux2_t::print ( FILE* f ) {
  fprintf(f, "%s", TO_CSTR(Mux2__io_out));
  fprintf(f, "\n");
  fflush(f);
}
bool Mux2_t::scan ( FILE* f ) {
  str_to_dat(read_tok(f), Mux2__io_sel);
  str_to_dat(read_tok(f), Mux2__io_in0);
  str_to_dat(read_tok(f), Mux2__io_in1);
  return(!feof(f));
}
void Mux2_t::dump(FILE *f, int t) {
}
