/*****************************************************************************/
/*   SHA 256                               */ 
/*                     */
/*   Inputs:                    */
/*   Outputs:                                     */
/*****************************************************************************/
`timescale 1 ns / 1 ps
module t_rng();
   
   //declairng input and output regs and wires	   
   reg clk, rst;
   reg [95:0] seed_in;
  // reg valid;
   wire [95:0] random_out;
   //wire validout; 
  reg loadseed; 
 // reg [95:0] randomin; 
   //wire ready;
   
   //instatiating UUT	 
    rng96 RNGUUT ( clk,rst, loadseed,seed_in,random_out);
   
   //creating clock
   initial clk=1'b0;
   always @(clk) clk<= #5 ~clk;
   
   //assigning inputs 
   initial begin
       rst = 1'b1; 
        
     //   valid = 0;
        loadseed = 0;
        seed_in = 96'hdeadbeef1234567890abcdef;
        #5 rst = 1'b0;

      

     #10 loadseed = 1;

      #10   loadseed = 0;
	  
   end  

   //force simulation end
   initial begin
       #15000 $stop; 
   end
   
endmodule

