/*****************************************************************************/
/*   SHA 256                               */ 
/*                     */
/*   Inputs:                    */
/*   Outputs:                                     */
/*****************************************************************************/
`timescale 1 ns / 1 ps
module t_sha256_top();
   
   //declairng input and output regs and wires	   
   reg clk, rst;
   reg [839:0] msg_in;
   reg valid;
   wire [5:0] final_out;
   wire validout; 
  reg start; 
  reg [95:0] randomin; 
   //wire ready;
   
   //instatiating UUT	 
    Lbirow LBIUUT (rst, clk,msg_in, valid,final_out, validout, start,randomin);
   
   //creating clock
   initial clk=1'b0;
   always @(clk) clk<= #5 ~clk;
   
   //assigning inputs 
   initial begin
       rst = 1'b1; 
        msg_in = 512'h0;
        valid = 0;
        start = 0;
        #5 rst = 1'b0;
     //  valid = 1'b0;
      // #11 rst = 1'b0;
     //  #10 valid = 1'b1;
     //  first = 1'b1;
     //  last = 1'b0; 
      valid = 1;
       msg_in = 512'h343332323132333577726c6468656c6f343332323132333577726c6468656c6f343332323132333577726c6468656c6f343332323132333577726c6468656c6f;
     //  #640 first = 1'b0;
     
     #10 msg_in = {32'h00000200,448'h0,32'h80000000};
    // #10 msg_in = 0;
      //   valid = 0;
     //  #5 last = 1'b1; 
     #10  msg_in = 512'h64736464646b7366616c666a6a6b647364736166666a6b6c6a6b7361616b6c6666646a73736a616b6a6b66646c647361616a6b66646c3b73736b6a6664736661;
     //  #640 first = 1'b0;
	 #10 valid = 0;
	      msg_in = 512'h343332323132333577726c6468656c6f343332323132333577726c6468656c6f343332323132333577726c6468656c6f343332323132333577726c6468656c6f;
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
