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

module rng(clk,reset,loadseed_i,seed_i,number_o);
input clk;
input reset;
input loadseed_i;
input [31:0] seed_i;
output [31:0] number_o;

reg [31:0]number_intern;
assign number_o = number_intern;
wire feedback = number_intern[31]^number_intern[21]^number_intern[1]^number_intern[0];

always @(posedge clk)
  if (reset) 
    number_intern <= 32'h0;
  else if (loadseed_i)
    number_intern <=seed_i;
  else
    number_intern <= {number_o[30:0], feedback} ;

endmodule

