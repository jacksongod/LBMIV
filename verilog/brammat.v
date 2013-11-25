module brammat (                                                                                      
input clk,
input r_reset,
output pop
input [15:0] 
output          err_unimpl
);    
      
reg [8:0] r_bramindex [0:419];
wire [8:0] c_bramindex  [0:419]; 
reg [5:0] r_bramaddr [0:419];
wire [5:0] c_bramaddr [0:419];
wire [32:0] bramin [0:419];
wire [419:0] bramwrite_en;                                                                            
wire [4:0] bram_offset [0:419]; 
wire [15:0] write_req;  
//genvar i;             
generate for (i=0; i<419; i=i+1) begin : br                                                           
  assign bram_offset [i] = (i/2)%16;
  reg [8:0] r_ld_index; 
  wire [8:0] c_ld_index;
  wire [8:0]wrap_index; 
  always @(posedge clk) begin 
     r_ld_index <= r_reset? 9'b0 : (c_ld_index>=9'd420?c_ld_index-9'd420:c_ld_index);                 
     r_bramindex[i] <= r_reset? bramoffset[i] : c_bramindex[i];                                       
     r_bramaddr[i] <= r_reset? 6'b0 : c_bramaddr[i];                                                  
  end 
  assign wrap_index = (r_ld_index>= 9'd420)?r_ld_index-9'd420 : r_ld                                  
  assign c_bramaddr = bramwrite_en[i]?r_bramaddr+6'b1:r_bramaddr;                                     
  assign c_ld_index =   
                                                                                                      
end endgenerate      
      
generate for (i=0; i<16; i=i+1) begin : mc                                                            
      
  reg [8:0] r_ld_index;
  wire [8:0] c_ld_index;
      
  always @(posedge clk) begin                                                                         
     r_ld_index <= r_reset? i : (c_ld_index>=9'd420?c_ld_index-9'd420:c_ld_index);                    
  end
  assign c_ld_index = write_req[i]? r_ld_index+9'b1 : r_ld_index;                                     
end endgenerate
                                                                                                      
endmodule

