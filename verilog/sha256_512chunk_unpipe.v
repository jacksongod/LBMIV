/*****************************************************************************/
//
// Module          : vadd.vpp
// Revision        :  Revision: 1.2  
// Last Modified On:  Date: 2013/01/23 17:31:48  
// Last Modified By:  Author: gedwards  
//
//-----------------------------------------------------------------------------
//
// Original Author : gedwards
// Created On      : Wed Oct 10 09:26:08 2007
//
//-----------------------------------------------------------------------------
//
// Description     : Sample personality vector add unit
//
//-----------------------------------------------------------------------------
//
// Copyright (c) 2007-2012 : created by Convey Computer Corp. This model is the
// confidential and proprietary property of Convey Computer Corp.
//
/*****************************************************************************/
/*  Id: vadd.vpp,v 1.2 2013/01/23 17:31:48 gedwards Exp   */

`timescale 1 ns / 1 ps

module sha256_512chunk #(parameter CHUNKSIZE = 512)(
   input		clk,
   input		reset,

   input  [CHUNKSIZE-1:0] memorychunk,
   output [31:0] final_aout,
   output [31:0] final_bout,
   output [31:0] final_cout, 
   output [31:0] final_dout,
   output [31:0] final_eout,
   output [31:0] final_fout,
   output [31:0] final_gout,
   output [31:0] final_hout
   //input  [5:0]		fpnum,


   //input  [11:0]	csr_ldst_thld
);


   /* ----------         include files        ---------- */

   // Use 63 pipes, instead of 64, to avoid stride of 64
   parameter NUM_W = 64;
  // parameter CHUNKLENGTH = 512;
   parameter PADLENGTH = 512;
   /* ----------          wires & regs        ---------- */

   wire  [31:0]  hash_value [0:7];
  // reg  [31:0]  next_hash_value [0:7];
   wire  [31:0]  round_key [0:63];
   wire  [CHUNKSIZE-1:0] final_chunk;
   wire [31:0] w [0:63];
    // defining hash localparams
           localparam H0 = 32'h6a09e667;
           localparam H1 = 32'hbb67ae85;
           localparam H2 = 32'h3c6ef372;
           localparam H3 = 32'ha54ff53a;
           localparam H4 = 32'h510e527f;
           localparam H5 = 32'h9b05688c;
           localparam H6 = 32'h1f83d9ab;
           localparam H7 = 32'h5be0cd19;
           // defining round constants
           localparam K00 = 32'h428a2f98;
           localparam K01 = 32'h71374491;
           localparam K02 = 32'hb5c0fbcf;
           localparam K03 = 32'he9b5dba5;
           localparam K04 = 32'h3956c25b;
           localparam K05 = 32'h59f111f1;
           localparam K06 = 32'h923f82a4;
           localparam K07 = 32'hab1c5ed5;
           localparam K08 = 32'hd807aa98;
           localparam K09 = 32'h12835b01;
           localparam K10 = 32'h243185be;
           localparam K11 = 32'h550c7dc3;
           localparam K12 = 32'h72be5d74;
           localparam K13 = 32'h80deb1fe;
           localparam K14 = 32'h9bdc06a7;
           localparam K15 = 32'hc19bf174;
           localparam K16 = 32'he49b69c1;
           localparam K17 = 32'hefbe4786;
           localparam K18 = 32'h0fc19dc6;
           localparam K19 = 32'h240ca1cc;
           localparam K20 = 32'h2de92c6f;
           localparam K21 = 32'h4a7484aa;
           localparam K22 = 32'h5cb0a9dc;
           localparam K23 = 32'h76f988da;
           localparam K24 = 32'h983e5152;
           localparam K25 = 32'ha831c66d;
           localparam K26 = 32'hb00327c8;
           localparam K27 = 32'hbf597fc7;
           localparam K28 = 32'hc6e00bf3;
           localparam K29 = 32'hd5a79147;
           localparam K30 = 32'h06ca6351;
           localparam K31 = 32'h14292967;
           localparam K32 = 32'h27b70a85;
           localparam K33 = 32'h2e1b2138;
           localparam K34 = 32'h4d2c6dfc;
           localparam K35 = 32'h53380d13;
           localparam K36 = 32'h650a7354;
           localparam K37 = 32'h766a0abb;
           localparam K38 = 32'h81c2c92e;
           localparam K39 = 32'h92722c85;
           localparam K40 = 32'ha2bfe8a1;
           localparam K41 = 32'ha81a664b;
           localparam K42 = 32'hc24b8b70;
           localparam K43 = 32'hc76c51a3;
           localparam K44 = 32'hd192e819;
           localparam K45 = 32'hd6990624;
           localparam K46 = 32'hf40e3585;
           localparam K47 = 32'h106aa070;
           localparam K48 = 32'h19a4c116;
           localparam K49 = 32'h1e376c08;
           localparam K50 = 32'h2748774c;
           localparam K51 = 32'h34b0bcb5;
           localparam K52 = 32'h391c0cb3;
           localparam K53 = 32'h4ed8aa4a;
           localparam K54 = 32'h5b9cca4f;
           localparam K55 = 32'h682e6ff3;
           localparam K56 = 32'h748f82ee;
           localparam K57 = 32'h78a5636f;
           localparam K58 = 32'h84c87814;
           localparam K59 = 32'h8cc70208;
           localparam K60 = 32'h90befffa;
           localparam K61 = 32'ha4506ceb;
           localparam K62 = 32'hbef9a3f7;
           localparam K63 = 32'hc67178f2;

   wire  [31:0] a;
   wire  [31:0] b;
   wire  [31:0] c;
   wire  [31:0] d;
   wire [31:0] e;
   wire [31:0] f;
   wire [31:0] g;
   wire [31:0] h;
   wire r_reset;
 
   assign a = hash_value[0];
   assign b = hash_value[1];
   assign c = hash_value[2];
   assign d = hash_value[3];
   assign e = hash_value[4];
   assign f = hash_value[5];
   assign g = hash_value[6];
   assign h = hash_value[7];
   
   
   
assign	   hash_value [0] = H0;
assign	   hash_value [1] = H1;
	assign   hash_value [2] = H2;
	assign   hash_value [3] = H3;
assign	   hash_value [4] = H4;
assign	   hash_value [5] = H5;
assign	   hash_value [6] = H6;
assign	   hash_value [7] = H7;
assign	   round_key[0]= K00;
assign	   round_key[1]= K01;
assign	   round_key[2]= K02;
	assign   round_key[3]= K03;
assign	   round_key[4]= K04;
assign	   round_key[5]= K05;
assign	   round_key[6]= K06;
assign	   round_key[7]= K07;
assign	   round_key[8]= K08;
assign	   round_key[9]= K09;
assign	   round_key[10]= K10;
assign	   round_key[11]= K11;
assign	   round_key[12]= K12;
assign	   round_key[13]= K13;
assign	   round_key[14]= K14;
assign	   round_key[15]= K15;
assign	   round_key[16]= K16;
assign	   round_key[17]= K17;
assign	   round_key[18]= K18;
assign	   round_key[19]= K19;
assign	   round_key[20]= K20;
assign	   round_key[21]= K21;
assign	   round_key[22]= K22;
assign	   round_key[23]= K23;
assign	   round_key[24]= K24;
assign	   round_key[25]= K25;
assign	   round_key[26]= K26;
assign	   round_key[27]= K27;
assign	   round_key[28]= K28;
assign	   round_key[29]= K29;
assign	   round_key[30]= K30;
assign	   round_key[31]= K31;
assign	   round_key[32]= K32;
assign	   round_key[33]= K33;
assign	   round_key[34]= K34;
assign	   round_key[35]= K35;
assign	   round_key[36]= K36;
assign	   round_key[37]= K37;
assign	   round_key[38]= K38;
assign	   round_key[39]= K39;
assign	   round_key[40]= K40;
assign	   round_key[41]= K41;
assign	   round_key[42]= K42;
assign	   round_key[43]= K43;
assign	   round_key[44]= K44;
assign	   round_key[45]= K45;
assign	   round_key[46]= K46;
assign	   round_key[47]= K47;
assign	   round_key[48]= K48;
assign	   round_key[49]= K49;
assign	   round_key[50]= K50;
assign	   round_key[51]= K51;
assign	   round_key[52]= K52;
assign	   round_key[53]= K53;
assign	   round_key[54]= K54;
assign	   round_key[55]= K55;
assign	   round_key[56]= K56;
assign	   round_key[57]= K57;
assign	   round_key[58]= K58;
assign	   round_key[59]= K59;
assign	   round_key[60]= K60;
	assign   round_key[61]= K61;
	assign   round_key[62]= K62;
	assign   round_key[63]= K63; 
	
	
	always @(posedge clk) begin
    // if(r_reset) 
   end
   
   //assign final_chunk = {8'h0,8'h02,488'h0,8'h80,memorychunk};  //pad chunk with length and bit'1'
   assign final_chunk = memorychunk; 
   genvar j;
   generate for (j=0; j<16; j=j+1) begin : Wfill1
       assign w[j] = final_chunk [32*j+:32];
   
   end endgenerate
   
   genvar k;
   generate for (k=16; k<NUM_W; k=k+1) begin : Wfill2
       wire [31:0] s0 ;
	   wire [31:0] s1  ;
	   
	   assign s0 = {w[k-15][6:0],w[k-15][31:7]} ^ {w[k-15][17:0],w[k-15][31:18]} ^(w[k-15]>>3);
	   assign s1 = {w[k-2][16:0],w[k-2][31:17]} ^ {w[k-2][18:0],w[k-2][31:19]} ^(w[k-2]>>10);
       assign w[k] = w[k-16] + w[k-7]+s0 +s1;
  end endgenerate
   
   genvar l;
   generate for (l=0; l<64; l=l+1) begin : compreloop
       wire [31:0] s0 ;
	   wire [31:0] s1  ;
	   wire [31:0] aout,bout,cout,dout,eout,fout,gout,hout;
	   wire [31:0] ain,bin,cin,din,ein,fin,gin,hin;
	  
	   if (l==0) begin
	     assign ain = a;
		  assign bin = b;
		  assign cin = c;
		  assign din = d;
		  assign ein = e;
		  assign fin = f;
		  assign gin = g;
		  assign hin = h;
	   end
	   else begin 
	    assign  ain = compreloop[l-1].aout;
		  assign bin = compreloop[l-1].bout;
		  assign cin = compreloop[l-1].cout;
		  assign din = compreloop[l-1].dout;
		  assign ein = compreloop[l-1].eout;
		  assign fin = compreloop[l-1].fout;
		  assign gin = compreloop[l-1].gout;
		  assign hin = compreloop[l-1].hout;
	   end 
	   shacompre shacompre(.clk(clk),
	                       .rst(r_reset),
	                       .ckey(round_key[l]),
						   .warray(w[l]),
						   .ain(ain),   
	             .bin(bin),
						   .cin(cin),
						   .din(din),
						   .ein(ein),
						   .fin(fin),
						   .gin(gin),
						   .hin(hin),
						   .aout(aout),
	             .bout(bout),
						   .cout(cout),
						   .dout(dout),
						   .eout(eout),
						   .fout(fout),
						   .gout(gout),
						   .hout(hout)
						   ); 
  end endgenerate
 assign final_aout = compreloop[63].aout;
 assign final_bout = compreloop[63].bout;
 assign final_cout = compreloop[63].cout;
 assign final_dout = compreloop[63].dout;
 assign final_eout = compreloop[63].eout;
 assign final_fout = compreloop[63].fout;
 assign final_gout = compreloop[63].gout;
 assign final_hout = compreloop[63].hout;
   /* ----------      combinatorial blocks    ---------- */

   /* ----------      external module calls   ---------- */

 
   /* ----------            registers         ---------- */

   // ISE can have issues with global wires attached to D(flop)/I(lut) inputs
   
   
   assign r_reset = reset; 
  // FDSE rst (.C(clk),.S(reset),.CE(r_reset),.D(!r_reset),.Q(r_reset)); 






   /* ---------- debug & synopsys off blocks  ---------- */

   // synopsys translate_off

   // Parameters: 1-Severity: Don't Stop, 2-start check only after negedge of reset
   //assert_never #(1, 2, "***ERROR ASSERT: unimplemented instruction cracked") a0 (.clk(clk), .reset_n(~reset), .test_expr(r_unimplemented_inst));

    // synopsys translate_on

endmodule // vadd

// This is the search path for the autoinst commands in emacs.
// After modification you must save file, then reld with C-x C-v
//
// Local Variables:
// verilog-library-directories:("." "../../common/xilinx")
// End:

