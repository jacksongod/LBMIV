module Lbirow #(parameter INPUTSIZE = 840,
                     //  parameter RANDOMSIZE = 96
                       )(
   input		reset,
   input		clk,
   input [INPUTSIZE*2-1:0]      mat_msgin, 
   input                      mat_msginvld,
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

wire [LEFTOVER_SIZE+INPUTSIZE-1 : 0] leftpadedinput = {8'b0,msg_in[INPUTSIZE*2-1:INPUTSIZE]};  // pad input with enough 0s to make 
                                                                              //input bits multiple of 16
 wire [LEFTOVER_SIZE+INPUTSIZE-1 : 0] rightpadedinput = {8'b0,msg_in[INPUTSIZE-1:0]};
                                                                              
reg [1:0] r_state ;
reg [1:0] c_state ;
//wire [RANDOMSIZE6-1:0] r_msgin_part [PARTITION_SIZE-1:0];
reg [RANDOMSIZE6-1:0] r_msgin_leftpart [PARTITION_SIZE-1:0];
wire[RANDOMSIZE6-1:0] c_msgin_leftpart [PARTITION_SIZE-1:0];
reg [RANDOMSIZE6-1:0] r_msgin_rightpart [PARTITION_SIZE-1:0];
wire[RANDOMSIZE6-1:0] c_msgin_rightpart [PARTITION_SIZE-1:0];


wire [5:0] chunk_sum;
reg [5:0] r_cnt;
reg [5:0] c_cnt;
reg [5:0] r_sum ; 
reg [5:0] c_sum;
wire [5:0]total_round; 
wire r_reset; 
reg valid_res; 
//assign total_round = PARTITION_SIZE; 
genvar i;
generate for (i=0;i<PARTITION_SIZE; i=i+1) begin :  latchin
   always @(posedge clk) begin
      r_msgin_leftpart[i] <= r_reset? 0:c_msgin_leftpart[i];
      r_msgin_rightpart[i] <= r_reset? 0:c_msgin_rightpart[i];  
  end
     assign  c_msgin_leftpart[i] = msgin_vld? leftpadedinput[i*RANDOMSIZE6 +:RANDOMSIZE6]:r_msgin_leftpart[i];
     assign  c_msgin_rightpart[i] = msgin_vld? rightpadedinput[i*RANDOMSIZE6 +:RANDOMSIZE6]:r_msgin_rightpart[i];
end endgenerate
/*generate for (i=0;i<PARTITION_SIZE; i=i+1) begin :  pt
    assign r_msgin_part[i] = padedinput[i*RANDOMSIZE6 +:RANDOMSIZE6];
end endgenerate
assign r_reset = reset;*/ 


generate for (i=0;i<NUM_ROW; i=i+1) begin :  leftlbi_mat
   
   
   
   
end endgenerate




   always @(posedge clk) begin
      r_state  <= r_reset ? 1'b0 : c_state;
      r_sum <= r_reset? 5'b0: c_sum;
     // r_msgin_part <= r_reset? 0:c_msgin_part; 
      r_cnt <= r_reset? 5'b0: c_cnt; 
   end




 

always @*
begin 
    c_cnt = r_cnt; 
    c_state = r_state;
    c_sum = r_sum ;
    valid_res = 0;
    case (r_state)
       IDLE: 
       begin 
         c_cnt = 0; 
        c_sum = 0;
         if(start) begin 
           c_state = RUNNING ;
           
         end 
       end
       RUNNING:
       begin 
         c_cnt = r_cnt+1; 
        if(r_cnt< PARTITION_SIZE-1) begin 
           c_sum = r_sum + chunk_sum;
        end else begin 
           c_cnt=0;
           c_sum = r_sum + chunk_sum;
           c_state = FINISHED;
        end 
       end 
       FINISHED : 
       
       begin 
        c_cnt = 0;
         valid_res = 1; 
         c_state = IDLE; 
       end
       default: 
         c_state = IDLE; 
    endcase 
end         



assign msgrow_out = r_sum;
assign msgrowout_vld = valid_res; 



assign r_reset= reset; 

endmodule
