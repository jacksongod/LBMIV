/*****************************************************************************/

//
/*****************************************************************************/


`timescale 1 ns / 1 ps

module sha256_512chunk #(parameter CHUNKSIZE = 512)(
   input		clk,
   input		reset,
  // input valid,
   input  [CHUNKSIZE-1:0] memorychunk,
   input [31:0] init_ain,
   input [31:0] init_bin,
   input [31:0] init_cin,
   input [31:0] init_din,
   input [31:0] init_ein,
   input [31:0] init_fin,
   input [31:0] init_gin,
   input [31:0] init_hin,
   output [31:0] final_aout,
   output [31:0] final_bout,
   output [31:0] final_cout, 
   output [31:0] final_dout,
   output [31:0] final_eout,
   output [31:0] final_fout,
   output [31:0] final_gout,
   output [31:0] final_hout,
   output [31:0] ori_ahash,
   output [31:0] ori_bhash,
   output [31:0] ori_chash, 
   output [31:0] ori_dhash,
   output [31:0] ori_ehash,
   output [31:0] ori_fhash,
   output [31:0] ori_ghash,
   output [31:0] ori_hhash
   //input  [5:0]		fpnum,


   //input  [11:0]	csr_ldst_thld
);


   /* ----------         include files        ---------- */

  
   parameter NUM_W = 64;
  // parameter CHUNKLENGTH = 512;
   parameter PADLENGTH = 512;
   /* ----------          wires & regs        ---------- */

   wire  [31:0]  hash_value [0:7];
  // reg  [31:0]  next_hash_value [0:7];
   wire  [31:0]  round_key [0:63];
   wire  [CHUNKSIZE-1:0] final_chunk;
   wire [31:0] w [0:63];
   reg [31:0] wfillreg [0:63];
   reg [7:0]validcount;
   reg startreg;
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
 
  
 /*always @(posedge clk) begin
	    if (r_reset == 0) begin 
	        if (valid == 1)begin 
	          startreg <= 1;
	        end 
	          
	        if (startreg == 0) begin 
	             validcount <= 8'h0;  
	        end 
	       else if (validcount == 67)
	        else begin
	             validcount <= validcount+1;
	        end 
	    end
	    else begin
	       validcount <= 8'h0;
	       startreg <= 0;
      end
    
  end   */

 genvar j;
   generate for (j=0; j<64; j=j+1) begin : pipe1
      
       always @(posedge clk) begin
        wfillreg[j]  <= r_reset ? 1'b0 : w[j];
    
      end
   
   end endgenerate

   
   //assign final_chunk = {8'h0,8'h02,488'h0,8'h80,memorychunk};  //pad chunk with length and bit'1'
   assign final_chunk = memorychunk; 
 //  genvar j;
   generate for (j=0; j<16; j=j+1) begin : Wfill1
       assign w[j] = final_chunk [32*j+:32];
   
   end endgenerate
   
   genvar k;
   generate for (k=16; k<NUM_W; k=k+1) begin : Wfill2
       wire [31:0] s0 ;
	   wire [31:0] s1  ;
	 //  reg [31:0] s0reg;
	 //  reg[31:0] s1reg;
	 //  always @(posedge clk) begin
   //   s0reg  <= r_reset ? 31'h0 : s0;
   //   s1reg  <= r_reset?  31'h0: s1;
   //   end
   assign s0 = {w[k-15][6:0],w[k-15][31:7]} ^ {w[k-15][17:0],w[k-15][31:18]} ^(w[k-15]>>3);
	   assign s1 = {w[k-2][16:0],w[k-2][31:17]} ^ {w[k-2][18:0],w[k-2][31:19]} ^(w[k-2]>>10);
       assign w[k] = w[k-16] + w[k-7]+s0 +s1;
	    
	 //  assign s0 = {wfillreg[k-15][6:0],wfillreg[k-15][31:7]} ^ {wfillreg[k-15][17:0],wfillreg[k-15][31:18]} ^(wfillreg[k-15]>>3);
	 //  assign s1 = {wfillreg[k-2][16:0],wfillreg[k-2][31:17]} ^ {wfillreg[k-2][18:0],wfillreg[k-2][31:19]} ^(wfillreg[k-2]>>10);
   //    assign w[k] = wfillreg[k-16] + wfillreg[k-7]+s0reg +s1reg;
  end endgenerate
   
   genvar l;
   generate for (l=0; l<64; l=l+1) begin : compreloop
       wire [31:0] s0 ;
	   wire [31:0] s1  ;
	   wire [31:0] aout,bout,cout,dout,eout,fout,gout,hout;
	   reg [31:0] aoutreg,boutreg,coutreg,doutreg,eoutreg,foutreg,goutreg,houtreg;
	   reg [31:0] ori_a,ori_b,ori_c,ori_d,ori_e,ori_f,ori_g,ori_h;
	   wire [31:0] ain,bin,cin,din,ein,fin,gin,hin;
	 //  reg [31:0] aoutreg,boutreg,coutreg,din,ein,fin,gin,hin;
	   reg [31:0] wreg [0:63-l];
	   
	  always @(posedge clk) begin
      aoutreg  <= r_reset ? 31'h0 : aout;
      boutreg  <= r_reset ? 31'h0 : bout;
      coutreg  <= r_reset ? 31'h0 : cout;
      doutreg  <= r_reset ? 31'h0 : dout;
      eoutreg  <= r_reset ? 31'h0 : eout;
      foutreg  <= r_reset ? 31'h0 : fout;
      goutreg  <= r_reset ? 31'h0 : gout;
      houtreg  <= r_reset ? 31'h0 : hout;  
      ori_a <= r_reset? 31'h0 : init_ain;
      end
	   if (l==0) begin
	     always @(posedge clk) begin 
	       ori_a <= r_reset? 31'h0 : init_ain;
	       ori_b <= r_reset? 31'h0 : init_bin;
	       ori_c <= r_reset? 31'h0 : init_cin;
	       ori_d <= r_reset? 31'h0 : init_din;
	       ori_e <= r_reset? 31'h0 : init_ein;
	       ori_f <= r_reset? 31'h0 : init_fin;
	       ori_g <= r_reset? 31'h0 : init_gin;
	       ori_h <= r_reset? 31'h0 : init_hin;
	     end
	     for (k=0;k<64;k=k+1) begin
	       always @(posedge clk) begin 
	       wreg[k] <= r_reset? 31'h0: w[k];
	         end 
	     end
	     assign ain = a;
		  assign bin = b;
		  assign cin = c;
		  assign din = d;
		  assign ein = e;
		  assign fin = f;
		  assign gin = g;
		  assign hin = h;
		/*  shacompre shacompre(.clk(clk),
	                       .rst(r_reset),
	                       .ckey(round_key[l]),
						   .warray(w[0]),
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
						   ); */
	   end
	   else begin 
	     always @(posedge clk) begin 
	       ori_a <= r_reset? 31'h0 : compreloop[l-1].ori_a;
	       ori_b <= r_reset? 31'h0 : compreloop[l-1].ori_b;
	       ori_c <= r_reset? 31'h0 : compreloop[l-1].ori_c;
	       ori_d <= r_reset? 31'h0 : compreloop[l-1].ori_d;
	       ori_e <= r_reset? 31'h0 : compreloop[l-1].ori_e;
	       ori_f <= r_reset? 31'h0 : compreloop[l-1].ori_f;
	       ori_g <= r_reset? 31'h0 : compreloop[l-1].ori_g;
	       ori_h <= r_reset? 31'h0 : compreloop[l-1].ori_h;
	     end
	     for (k=0;k<64-l;k=k+1) begin
	       always @(posedge clk) begin
	     wreg[k] <= r_reset? 31'h0: compreloop[l-1].wreg[k+1];
	         end
	     end
	    assign  ain = compreloop[l-1].aoutreg;
		  assign bin = compreloop[l-1].boutreg;
		  assign cin = compreloop[l-1].coutreg;
		  assign din = compreloop[l-1].doutreg;
		  assign ein = compreloop[l-1].eoutreg;
		  assign fin = compreloop[l-1].foutreg;
		  assign gin = compreloop[l-1].goutreg;
		  assign hin = compreloop[l-1].houtreg;
		 /* shacompre shacompre(.clk(clk),
	                       .rst(r_reset),
	                       .ckey(round_key[l]),
						   .warray(compreloop[l-1].wreg[1]),
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
						   ); */
	   end 
	   shacompre shacompre(.clk(clk),
	                       .rst(r_reset),
	                       .ckey(round_key[l]),
						   .warray(wreg[0]),
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
 assign ori_ahash = compreloop[63].ori_a;
 assign ori_bhash = compreloop[63].ori_b;
 assign ori_chash = compreloop[63].ori_c;
 assign ori_dhash = compreloop[63].ori_d;
 assign ori_ehash = compreloop[63].ori_e;
 assign ori_fhash = compreloop[63].ori_f;
 assign ori_ghash = compreloop[63].ori_g;
 assign ori_hhash = compreloop[63].ori_h;
 assign final_aout = compreloop[63].aoutreg;
 assign final_bout = compreloop[63].boutreg;
 assign final_cout = compreloop[63].coutreg;
 assign final_dout = compreloop[63].doutreg;
 assign final_eout = compreloop[63].eoutreg;
 assign final_fout = compreloop[63].foutreg;
 assign final_gout = compreloop[63].goutreg;
 assign final_hout = compreloop[63].houtreg;
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
 assign a = init_ain;
   assign b = init_bin;
   assign c = init_cin;
   assign d = init_din;
   assign e = init_ein;
   assign f = init_fin;
   assign g = init_gin;
   assign h = init_hin;
   
   
   
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
endmodule // vadd

// This is the search path for the autoinst commands in emacs.
// After modification you must save file, then reld with C-x C-v
//
// Local Variables:
// verilog-library-directories:("." "../../common/xilinx")
// End:

