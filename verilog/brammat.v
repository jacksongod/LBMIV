module brammat (                                                                                      
input clk,
input r_reset,
output [15:0]fifo_pop,
input [15:0]  mcfifo_empty,
output          err_unimpl
);    
      
//reg [8:0] r_bramindex [0:419];
//wire [8:0] c_bramindex  [0:419]; 
reg [5:0] r_bramaddr [0:419];
wire [5:0] c_bramaddr [0:419];
wire [32:0] bramin [0:419];
wire [419:0] bramwrite_en;                                                                            
wire [4:0] bram_offset [0:419]; 
wire [15:0]write_req;  
genvar i;             
generate for (i=0; i<419; i=i+1) begin : br                                                           
   bramwrite_en[i] = (mc[(i/2)%16].r_round_index;
 wire [3:0] round_index = 
  always @(posedge clk) begin 

  //   r_bramindex[i] <= r_reset? bram_offset[i] : c_bramindex[i];                                       
     r_bramaddr[i] <= r_reset? 6'b0 : c_bramaddr[i];                                                  
  end 
                             
  assign c_bramaddr[i] = (bramwrite_en[i])?(r_bramaddr[i]+6'b1):r_bramaddr[i];                                     
                                                                              
end endgenerate      
      
generate for (i=0; i<16; i=i+1) begin : mc                                                            
      
  reg [3:0] r_round_index;
  wire [3:0] c_round_index;
       wire [3:0]wrap_index; 
  if (i == 0 ||i == 1) begin 
      assign wrap_index =  (c_round_index>4'd13)?(c_round_index-4'd14):c_round_index;
  end
  else  begin 
      assign wrap_index =  (c_round_index>4'd12)?(c_round_index-4'd13):c_round_index;
  
  end

  always @(posedge clk) begin                                                                         
     r_round_index <= r_reset? i : wrap_index;                    
  end
  assign c_round_index = (write_req[i])? (r_round_index+4'b1) : r_round_index;                                     
end endgenerate
                                                                                                      
endmodule

