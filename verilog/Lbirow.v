module Lbirow #(parameter INPUTSIZE = 840,
                       parameter RANDOMSIZE = 96
                       )(
   input		reset,
   input		clk,
   input [INPUTSIZE-1:0]      msg_in, 
   input                      msgin_vld,
   output [INPUTSIZE-1:0]       msg_out,
   output                       msgout_vld,
   
   input [RANDOMSIZE-1:0]       randomin
   
   //input  [5:0]		fpnum,


   //input  [11:0]	csr_ldst_thld
);
  parameter RANDOMSIZE6 = RANDOMSIZE/6;
  parameter PARTITION_SIZE = 53;
  parameter LEFTOVER_SIZE = 8;
   localparam IDLE   = 2'd0;
   localparam RUNNING = 2'd1;
   localparam LD_OP2 = 2'd2;
   localparam ST_RES = 2'd3;

wire [LEFTOVER+INPUTSIZE-1 : 0] padedinput = {LEFTOVER_SIZE'b0,msg_in}; 
reg [1:0] r_state ;
wire [1:0] c_state ;
reg [RANDOMSIZE-1:0] r_msgin_part [PARTITION_SIZE-1:0];
wire [RANDOMSIZE-1:0] c_msgin_part [PARTITION_SIZE-1:0];
wire [5:0] chunk_sum;
reg [5:0] r_cnt;
wire [5:0] c_cnt;

genvar i;
generate for (i=0;i<PARTITION_SIZE; i=i+1) begin :  pt
   always @(posedge clk) begin
      r_msgin_part[i] <= r_reset? 0:c_msgin_part[i]; 
  end
     assign  c_msgin_part[i] = msgin_vld? padedinput[i*RANDOMSIZE6 +:RANDOMSIZE6]:r_msgin_part[i];
     
end endgenerate
    
assign r_reset = reset; 

   always @(posedge clk) begin
      r_state  <= r_reset ? 0 : c_state;
      r_msgin_part <= r_reset? 0:c_msgin_part; 
      r_cnt <= r_reset? 0: c_cnt; 
   end



assign chunk_sum = r_msgin_part[r_cnt][]

always @*
begin 
    c_cnt = r_cnt; 
    c_state = r_state;
    case (r_state)
       IDLE: 
       begin 
         if(msgin_vld == 1'b1) begin 
           c_state = RUNNING ;
           c_cnt = 0; 
         end 
       end
       RUNNING:
       begin 
         
    
wire [31:0]s1;
wire  [31:0]ch;
wire [31:0]temp1;
wire [31:0]s0;
wire [31:0]maj;
wire [31:0]temp2;

assign s1 = {ein[5:0],ein[31:6]} ^ {ein[10:0],ein[31:11]}^{ein[24:0],ein[31:25]};
assign ch = (ein & fin )^ ((~ein )&gin);
assign temp1 = hin +s1+ ch+ ckey+warray;
assign s0 = {ain[1:0],ain[31:2]} ^ {ain[12:0],ain[31:13]} ^{ain[21:0],ain[31:22]};
assign maj =(ain & bin) ^ (ain & cin) ^ (bin & cin);
assign temp2 = s0+maj;


assign hout = gin;
assign gout = fin;
assign fout = ein;
assign eout = din +temp1; 
assign dout = cin;
assign cout = bin;
assign bout = ain;
assign aout = temp1+temp2;





endmodule
