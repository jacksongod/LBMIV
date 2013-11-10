/*****************************************************************************/
/*   SHA 256                               */ 
/*                     */
/*   Inputs:                    */
/*   Outputs:                                     */
/*****************************************************************************/
`timescale 1 ns / 1 ps

module t_Lbimatrix();
   
   //declairng input and output regs and wires	   
   reg clk, rst;
   reg [1679:0] msg_in;
   reg valid;
   wire [839:0] msg_out;
   wire validout; 
  reg [96*140-1:0]rightloadseed; 
  reg [96*140-1:0]leftloadseed;
 // reg [95:0] randomin; 
   //wire ready;
   
   //instatiating UUT	 
    Lbimatrix lbimatUUT ( rst,clk, msg_in,valid,leftloadseed,rightloadseed,msg_out,validout);
   
   //creating clock
   initial clk=1'b0;
   always @(clk) clk<= #5 ~clk;
   
   //assigning inputs 
   initial begin
       rst = 1'b1; 
        
     //   valid = 0;
        valid = 0;
        rightloadseed = {420{$random}};
        leftloadseed = {420{$random}};
        msg_in = {53{$random}};
        #15 rst = 1'b0;

      

     #20 valid= 1;

      #10   valid = 0;
	  
   end  

   //force simulation end
   initial begin
       #15000 $stop; 
   end
   
endmodule



