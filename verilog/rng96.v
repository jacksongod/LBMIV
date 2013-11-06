//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Random Number Generator                                     ////
////                                                              ////
////  This file is part of the SystemC RNG                        ////
////                                                              ////
////  Description:                                                ////
////                                                              ////
////  Implementation of random number generator                   ////
////                                                              ////
////  To Do:                                                      ////
////   - done                                                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Javier Castillo, javier.castillo@urjc.es              ////
////                                                              ////
////  This core is provided by Universidad Rey Juan Carlos        ////
////  http://www.escet.urjc.es/~jmartine                          ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.3  2005/07/30 20:07:26  jcastillo
// Correct bit 28. Correct assignation to bit 31
//
// Revision 1.2  2005/07/29 09:13:06  jcastillo
// Correct bit 28 of CASR
//
// Revision 1.1  2004/09/23 09:43:06  jcastillo
// Verilog first import
//

`timescale 10ns/1ns

module rng96 #(parameter  WORDSIZE = 32)(clk,reset,loadseed_i,seed96_i,number96_o);
input clk;
input reset;
input loadseed_i;
input [95:0] seed96_i;
output [95:0] number96_o;

  rng rng0(
      .clk	(clk),
      .reset(reset),
      .loadseed_i(loadseed_i),
      .seed_i(seed96_i[WORDSIZE-1:0]),
      .number_o(number96_o[WORDSIZE-1:0])
   
   );

rng rng1(
      .clk	(clk),
      .reset(reset),
      .loadseed_i(loadseed_i),
      .seed_i(seed96_i[WORDSIZE*2-1:WORDSIZE]),
      .number_o(number96_o[WORDSIZE*2-1:WORDSIZE])
   
   );
   
   
   rng rng2(
      .clk	(clk),
      .reset(reset),
      .loadseed_i(loadseed_i),
      .seed_i(seed96_i[WORDSIZE*3-1:WORDSIZE*2]),
      .number_o(number96_o[WORDSIZE*3-1:WORDSIZE*2])
   
   );


endmodule

