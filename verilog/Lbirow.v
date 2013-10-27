module Lbirow #(parameter INPUTSIZE = 1680,
                       parameter RANDOMSIZE = 96
                       )(
   input		reset,
   input		clk,
   input [INPUTSIZE-1:0]      msg_in, 
   input                      msgin_vld,
   output [INPUTSIZE/2-1:0]       msg_out,
   output                       msgout_vld,
   
   input [RANDOMSIZE-1:0]       randomin
   
   //input  [5:0]		fpnum,


   //input  [11:0]	csr_ldst_thld
);
   localparam IDLE   = 2'd0;
   localparam RUNNNING = 2'd1;
   localparam LD_OP2 = 2'd2;
   localparam ST_RES = 2'd3;

reg [1:0] c_state , r_state ;
reg [RANDOMSIZE-1:0]  c_msgin_part,r_msgin_part;

assign r_reset = reset; 
   always @(posedge clk) begin
      r_state  <= r_reset ? 0 : c_state;
      r_msgin_part <= r_reset? 0:c_msgin_part; 
   end



always @*
begin 
    c_state <= r_state;
    case (r_state)
       IDLE: 
       begin 
         if(msgin_vld == 1'b1) begin 
           
    
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
