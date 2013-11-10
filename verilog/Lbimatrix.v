module Lbimatrix #(parameter INPUTSIZE = 840,
                       parameter RANDOMSIZE = 96
                       )(
   input		reset,
   input		clk,
   input [INPUTSIZE*2-1:0]      mat_msgin, 
   input                      mat_msginvld,
   input [96*140-1:0]                    seedmatleft_in,
   input [96*140-1:0]                    seedmatright_in,
   output [INPUTSIZE-1:0]       msgmat_out,
   
   //input  start,
  // input [RANDOMSIZE*140-1:0]       randomin
   
   //input  [5:0]		fpnum,

output                       msgmat_outvld
   //input  [11:0]	csr_ldst_thld
);
  parameter RANDOMSIZE6 = RANDOMSIZE/6;
  parameter PARTITION_SIZE = 53;
  parameter LEFTOVER_SIZE = 8;
  parameter NUM_ROW = 140;
   localparam IDLE   = 2'd0;
   localparam RUNNING = 2'd1;
   localparam FINISHED= 2'd2;
   localparam ST_RES = 2'd3;
reg [INPUTSIZE-1 : 0] r_leftinput;
wire [INPUTSIZE-1 : 0] c_leftinput;  // pad input with enough 0s to make 
reg [INPUTSIZE-1 : 0] r_rightinput     ;                                                                         //input bits multiple of 16
 wire [INPUTSIZE-1 : 0] c_rightinput ;
 wire c_start;
 reg r_start;
 

  
  




//assign total_round = PARTITION_SIZE; 
wire [5:0] leftout_matrix [0:139];
wire [95:0] random_seedleft [0:139];
wire [5:0] rightout_matrix [0:139];
wire [95:0] random_seedright [0:139];
wire [5:0] out_matrix[0:139];



wire [139:0] leftoutvalid,rightoutvalid; 
reg r_outmatvalid,r2_outmatvalid; 
wire c_outmatvalid; 
wire r_reset;
assign c_outmatvalid = (&leftoutvalid) & (&rightoutvalid);
 assign c_leftinput = mat_msginvld? {8'b0,mat_msgin[INPUTSIZE*2-1:INPUTSIZE]}:r_leftinput;  // pad input with enough 0s to make 
  assign c_rightinput = mat_msginvld?{8'b0,mat_msgin[INPUTSIZE-1:0]}:r_rightinput;    
  assign c_start = mat_msginvld? 1 :0;
always @(posedge clk) begin
      r_outmatvalid <= r_reset ? 0: c_outmatvalid;
      r2_outmatvalid  <= r_reset ? 0 : r_outmatvalid;
      r_start <= r_reset? 0: c_start; 
   end
   
   always @(posedge clk) begin 
      if (r_reset) begin 
        r_leftinput <= 0;
        r_rightinput <=0;
        r_start <= 0;
      end 
      else  begin
        
       r_leftinput <= c_leftinput;
      r_rightinput <= c_rightinput;
      r_start <=  mat_msginvld; 
      end

   end

assign msgmat_outvld = r2_outmatvalid; 

genvar i;
generate for (i=0;i<NUM_ROW; i=i+1) begin :  leftlbi_mat
   
    wire [5:0]c_outvalue ;
   reg  [5:0]r_outvalue;
   wire outvalid; 
   reg [95:0]r_random;
   wire [95:0]c_random;
   assign random_seedleft[i] = seedmatleft_in[i*96+:96];
   assign leftout_matrix[i] = r_outvalue; 
   assign leftoutvalid[i] = outvalid; 
   
   always @(posedge clk) begin
       r_outvalue <= r_reset ? 0: c_outvalue;
      r_random  <= r_reset ? 0 : c_random;

   end
   Lbirow LBIrow(.clk(clk),
	                       .reset(reset),
	                      .msg_in(r_leftinput),
	                      .msgrow_out(c_outvalue),
	                      .msgrowout_vld(outvalid),
	                      .start(r_start),
						   
						   .randomin(r_random)
						   ); 
   Rng96 rng96(.clk(clk),
	                       .reset(r_reset),
	                      .loadseed_i(c_start),
	                      .seed96_i(random_seedleft[i]),
	                      .number96_o(c_random)
						   ); 
   
end endgenerate

generate for (i=0;i<NUM_ROW; i=i+1) begin :  rightlbi_mat
   
   wire [5:0]c_outvalue ;
   reg  [5:0]r_outvalue;
   wire outvalid; 
   reg [95:0]r_random;
   wire [95:0]c_random;
   assign random_seedright[i] = seedmatright_in[i*96+:96];
   assign rightout_matrix[i] = r_outvalue; 
   assign rightoutvalid[i] = outvalid; 
   
   always @(posedge clk) begin
      r_outvalue <= r_reset ? 0: c_outvalue;
      r_random  <= r_reset ? 0 : c_random;

   end
   Lbirow LBIrow(.clk(clk),
	                       .reset(reset),
	                      .msg_in(r_rightinput),
	                      .msgrow_out(c_outvalue),
	                      .msgrowout_vld(outvalid),
	                      .start(r_start),
						   
						   .randomin(r_random)
						   ); 
   Rng96 rng96(.clk(clk),
	                       .reset(r_reset),
	                      .loadseed_i(c_start),
	                      .seed96_i(random_seedright[i]),
	                      .number96_o(c_random)
						   ); 
   
end endgenerate



generate for (i=0;i<NUM_ROW; i=i+1) begin :  output_mat
   
    assign out_matrix[i] = rightout_matrix[i]+leftout_matrix[i];
	  assign msgmat_out[i*6+:6] = out_matrix[i];
   
end endgenerate










assign r_reset= reset; 

endmodule
