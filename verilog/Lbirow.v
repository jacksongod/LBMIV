module Lbirow #(parameter INPUTSIZE = 840,
                       parameter RANDOMSIZE = 96
                       )(
   input		reset,
   input		clk,
   input [INPUTSIZE-1:0]      msg_in, 
   input                      msgin_vld,
   output [5:0]       msgrow_out,
   output                       msgrowout_vld,
   input  start,
   input [RANDOMSIZE-1:0]       randomin
   
   //input  [5:0]		fpnum,


   //input  [11:0]	csr_ldst_thld
);
  parameter RANDOMSIZE6 = RANDOMSIZE/6;
  parameter PARTITION_SIZE = 53;
  parameter LEFTOVER_SIZE = 8;
   localparam IDLE   = 2'd0;
   localparam RUNNING = 2'd1;
   localparam FINISHED= 2'd2;
   localparam ST_RES = 2'd3;

wire [LEFTOVER_SIZE+INPUTSIZE-1 : 0] padedinput = {LEFTOVER_SIZE'b0,msg_in};  // pad input with enough 0s to make 
                                                                              //input bits multiple of 16
reg [1:0] r_state ;
wire [1:0] c_state ;
reg [RANDOMSIZE6-1:0] r_msgin_part [PARTITION_SIZE-1:0];
wire [RANDOMSIZE6-1:0] c_msgin_part [PARTITION_SIZE-1:0];


wire [5:0] chunk_sum;
reg [5:0] r_cnt;
wire [5:0] c_cnt;
reg [5:0] r_sum ; 
wire [5:0] c_sum;
wire [5:0]total_round; 

assign total_round = PARTITION_SIZE; 
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
     // r_msgin_part <= r_reset? 0:c_msgin_part; 
      r_cnt <= r_reset? 0: c_cnt; 
   end


//   4-level Adder tree:
//                           chunk_sum   (lev0)
//                             /     \ 
//                         lev1_0   lev1_1
//                    /     \        /      \
//              lev2_0   lev2_1   lev2_2   lev2_3
//        /     \       /     \     /     \       /      \
//    lev3_0 lev3_1 lev3_2  lev3_3 lev3_4 lev3_5 lev3_6 lev3_7 
//      /\    /\      /\      /\     /\    /\      /\     /\
//       ........      lev4 (0-15) as leaves   .......... 
                 
wire [5:0] lev1 [0:1];
wire [5:0] lev2 [0:3];
wire [5:0] lev3 [0:7];
wire [5:0] lev4 [0:15];

//bottom up addition
generate for (i=0;i<16; i=i+1) begin :  lvl4addition
    assign lev4[i] = {6{r_msgin_part[r_cnt][i]}} & randomin[i*6+:6];     //selecting which chunk of input 
                                                                         //based on which round(r_cnt)        
                                                                        // mask with randommatrix                  
end endgenerate

generate for (i=0;i<8; i=i+1) begin :  lvl3addition
    assign lev3[i] = lev4[2*i] +lev4[2*i+1];    
                                                                                                                  
end endgenerate

generate for (i=0;i<4; i=i+1) begin :  lvl2addition
    assign lev2[i] = lev3[2*i] +lev3[2*i+1];    
                                                                                                                  
end endgenerate

generate for (i=0;i<2; i=i+1) begin :  lvl1addition
    assign lev1[i] = lev2[2*i] +lev2[2*i+1];    
                                                                                                                  
end endgenerate


assign chunk_sum = lev1[0]+lev1[1];


 

always @*
begin 
    c_cnt = r_cnt; 
    c_state = r_state;
    c_sum = r_sum ;
    valid_res = 0;
    case (r_state)
       IDLE: 
       begin 
         if(start) begin 
           c_state = RUNNING ;
           c_cnt = 0; 
         end 
       end
       RUNNING:
       begin 
         c_cnt = r_cnt+1; 
        if(r_cnt< total_round) begin 
           c_sum = r_sum + chunk_sum;
        end else begin 
           c_state = FINISHED;
        end 
       end 
       FINISHED : 
       begin 
         valid_res = 1; 
         c_state = IDLE; 
       end
       default: 
         c_state = IDLE; 
    endcase 
end         

wire valid_res; 

assign msgrow_out = r_sum;
assign msgrowout_vld = valid_res; 



assign r_reset= reset; 

endmodule
