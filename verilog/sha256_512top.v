/*****************************************************************************/

//
/*****************************************************************************/


`timescale 1 ns / 1 ps

module sha256_512top #(parameter CHUNKSIZE = 512)(
   input		clk,
   input		reset,
   input valid,
   input  [CHUNKSIZE-1:0] datain,
   output validoutput,
   output [CHUNKSIZE/2-1:0] final_hout
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
   wire valid_interm;
   wire [31:0] hash_update[0:7];
   wire [31:0] hash_update2[0:7];
   wire [31:0] hash_ori[0:7];
   wire [31:0] hash_ori2[0:7];
 wire last_validout ;
  // reg startreg;
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
          

   wire  [31:0] a;
   wire  [31:0] b;
   wire  [31:0] c;
   wire  [31:0] d;
   wire [31:0] e;
   wire [31:0] f;
   wire [31:0] g;
   wire [31:0] h;
   wire r_reset;
   wire [31:0] hashout [0:7];
   wire [31:0] finalout[0:7];
	   sha256_512chunk UT0(.clk(clk),
	                       .reset(reset),
						    .validin(valid),
	             .memorychunk(datain),
						   .init_ain(a),   
	             .init_bin(b),
						   .init_cin(c),
						   .init_din(d),
						   .init_ein(e),
						   .init_fin(f),
						   .init_gin(g),
						   .init_hin(h),
						   .final_aout(hashout[0]),
	             .final_bout(hashout[1]),
						   .final_cout(hashout[2]),
						   .final_dout(hashout[3]),
						   .final_eout(hashout[4]),
						   .final_fout(hashout[5]),
						   .final_gout(hashout[6]),
						   .final_hout(hashout[7]),
						   .validout(valid_interm),
						   .ori_ahash(hash_ori[0]),
						   .ori_bhash(hash_ori[1]),
						   .ori_chash(hash_ori[2]),
						   .ori_dhash(hash_ori[3]),
						   .ori_ehash(hash_ori[4]),
						   .ori_fhash(hash_ori[5]),
						   .ori_ghash(hash_ori[6]),
						   .ori_hhash(hash_ori[7])
						   ); 
	 genvar j;					   
	 generate for (j=0; j<8; j=j+1) begin : updatehash
       assign hash_update[j] = hashout[j] + hash_ori[j];
       assign finalout[j] = hash_ori2[j] + hash_update2[j];
   end endgenerate


  sha256_512chunk UT1(.clk(clk),
	                       .reset(reset),
	             .memorychunk({32'h00000200,448'h0,32'h80000000}),
						   .init_ain(hash_update[0]),   
	             .init_bin(hash_update[1]),
				  .validin(valid_interm),
						   .init_cin(hash_update[2]),
						   .init_din(hash_update[3]),
						   .init_ein(hash_update[4]),
						   .init_fin(hash_update[5]),
						   .init_gin(hash_update[6]),
						   .init_hin(hash_update[7]),
						   .final_aout(hash_update2[0]),
	             .final_bout(hash_update2[1]),
						   .final_cout(hash_update2[2]),
						   .final_dout(hash_update2[3]),
						   .final_eout(hash_update2[4]),
						   .final_fout(hash_update2[5]),
						   .final_gout(hash_update2[6]),
						   .final_hout(hash_update2[7]),
						   .validout(last_validout),
						   .ori_ahash(hash_ori2[0]),
						   .ori_bhash(hash_ori2[1]),
						   .ori_chash(hash_ori2[2]),
						   .ori_dhash(hash_ori2[3]),
						   .ori_ehash(hash_ori2[4]),
						   .ori_fhash(hash_ori2[5]),
						   .ori_ghash(hash_ori2[6]),
						   .ori_hhash(hash_ori2[7])
						   ); 
						   
		assign final_hout = {finalout[0],finalout[1],finalout[2],finalout[3],finalout[4],finalout[5],finalout[6],finalout[7]};
   /* ----------      combinatorial blocks    ---------- */

   /* ----------      external module calls   ---------- */

 
   /* ----------            registers         ---------- */

   // ISE can have issues with global wires attached to D(flop)/I(lut) inputs
   
     
 
  reg  final_validout; 
  always @(posedge clk) begin
	     final_validout <= r_reset? 31'h0: last_validout;
	end 
	assign validoutput = final_validout; 
	
	
   assign r_reset = reset; 
  // FDSE rst (.C(clk),.S(reset),.CE(r_reset),.D(!r_reset),.Q(r_reset)); 


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


endmodule



