module brammat (                                                                                      
input clk,
input bram_reset,
//output [15:0] mcfifo_pop,
//input [15:0]  mcfifo_empty,
input [15:0] fifo_write_req,
input [1023:0] fifo_datain,

input lorrselect,
input [5:0] bram_addr,

output [32*420-1:0]bram_outl,
output [32*420-1:0]bram_outr

);    
      
//reg [8:0] r_bramindex [0:419];
//wire [8:0] c_bramindex  [0:419]; 
reg [5:0] r_bramaddr [0:419];
wire [5:0] c_bramaddr [0:419];
wire [32:0] bramin [0:419];
wire [419:0] bramwrite_en;                                                                            
wire [4:0] bram_offset [0:419]; 
wire [15:0]write_req;  


assign write_req = fifo_write_req;

genvar i;             
generate for (i=0; i<420; i=i+1) begin : br 
 wire [3:0] round_index = i/32;  
 wire bramwrite_curr = bramwrite_en[i]; 
 wire curr_r_bramaddr= r_bramaddr[i];
 wire curr_c_bramaddr= c_bramaddr[i];
 assign  bramwrite_en[i] = ((mc[(i/2)%16].r_round_index) == round_index)&(write_req[(i/2)%16]);
 wire [31:0] data_in;
 wire [6:0] addra = bramwrite_en[i]? {lorrselect,r_bramaddr[i]}:{1'b0,bram_addr};
 if (i%2==0) begin 
   assign data_in = fifo_datain[((i/2)%16)*64+:32];
   
end 
else begin  
    assign data_in = fifo_datain[(((i/2)%16)*64+32)+:32];


end 

dpram #(.DEPTH(128),.WIDTH(32))bram( 
   .clk(clk),
   .we0(bramwrite_en[i]),
   .adr0(addra),
   .din0(data_in),
   .dout0(bram_outl[i*32+:32]),
   .we1(1'b0),
   .adr1({1'b1,bram_addr}),
   .din1(32'b0),
   .dout1(bram_outr[i*32+:32]),
   .ce0(1'b1),
   .ce1(1'b1),
   .oreg_ce0(1'b1),
   .oreg_ce1(1'b1),
   .oreg_rst0(1'b0),
   .oreg_rst1(1'b0)

);

  always @(posedge clk) begin 

  //   r_bramindex[i] <= r_reset? bram_offset[i] : c_bramindex[i];                                       
     r_bramaddr[i] <= bram_reset? 6'b0 : c_bramaddr[i];                                                  
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
     r_round_index <= bram_reset? 4'b0 : wrap_index;                    
  end
  assign c_round_index = (write_req[i])? (r_round_index+4'b1) : r_round_index;   
                                   
end endgenerate
                                                                                                      
endmodule

