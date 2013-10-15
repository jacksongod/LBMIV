/*****************************************************************************/
/*   SHA 256                               */ 
/*                     */
/*   Inputs:                    */
/*   Outputs:                                     */
/*****************************************************************************/
`timescale 1 ns / 1 ps
module t_sha_multi_chunks2();
   
   //declairng input and output regs and wires	   
   reg clk, rst;
   reg [511:0] msg_in;
   reg valid;
   wire [31:0] final_aout;
   wire [31:0] final_bout;
   wire [31:0] final_cout; 
   wire [31:0] final_dout;
   wire [31:0] final_eout;
   wire [31:0] final_fout;
   wire [31:0] final_gout;
   wire [31:0] final_hout;
   //wire ready;
   
   //instatiating UUT	 
   sha256_512chunk UUT (clk, rst,msg_in,final_aout,final_bout,final_cout,final_dout,final_eout,final_fout,final_gout,final_hout);
   
   //creating clock
   initial clk=1'b0;
   always @(clk) clk<= #5 ~clk;
   
   //assigning inputs 
   initial begin
       rst = 1'b1; 
        msg_in = 512'h0;
     //   valid = 0;
        #5 rst = 1'b0;
     //  valid = 1'b0;
      // #11 rst = 1'b0;
     //  #10 valid = 1'b1;
     //  first = 1'b1;
     //  last = 1'b0; 
    //  valid = 1;
       msg_in = 512'h343332323132333577726c6468656c6f343332323132333577726c6468656c6f343332323132333577726c6468656c6f343332323132333577726c6468656c6f;
     //  #640 first = 1'b0;
     
     #10 msg_in = {32'h00000200,448'h0,32'h80000000};
    // #10 msg_in = 0;
      //   valid = 0;
     //  #5 last = 1'b1; 
     //  msg_in = 512'h68656c6f77726c64313233353433323268656c6f77726c64313233353433323268656c6f77726c64313233353433323268656c6f77726c643132333534333232;
     //  #640 first = 1'b0;
     //  #5 last = 1'b1; 
     //  msg_in = 512'b00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000001_11000000; 
    //   #640 first = 1'b0;
    //   #5 last = 1'b1; 
      // msg_in = 512'b00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000001_11000000; 
      // #640 first = 1'b0;
      // #5 last = 1'b1; 
   //    msg_in = 512'b00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000001_11000000; 
      // #640 first = 1'b0;
      // #5 last = 1'b1; 
  //     msg_in = 512'b00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000001_11000000; 
   end  

   //force simulation end
   initial begin
       #15000 $stop; 
   end
   
endmodule