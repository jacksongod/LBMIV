module t_shacompre();
   
   //declairng input and output regs and wires	   
   reg		rst;
   reg		clk;
   reg [31:0] warray; 
   reg [31:0]      ckey;
   reg [31:0]       ain;
   reg [31:0]       bin;
   reg [31:0]       cin;
   reg [31:0]       din;
   reg [31:0]       ein;
   reg [31:0]       fin;
   reg [31:0]       gin;
   reg [31:0]       hin;
   wire [31:0]       aout;
   wire [31:0]       bout;
   wire [31:0]       cout;
   wire [31:0]       dout;
   wire [31:0]       eout;
   wire [31:0]       fout;
   wire [31:0]       gout;
   wire [31:0]       hout;

   //instatiating UUT	 
  shacompre shacompre(.clk(clk),
	                       .rst(rst),
	                       .ckey(ckey),
						   .warray(warray),
						   .ain(ain),   
	                       .bin(bin),
						   .cin(cin),
						   .din(din),
						   .ein(ein),
						   .fin(fin),
						   .gin(gin),
						   .hin(hin),
						   .aout(aout),
	                       .bout(bout),
						   .cout(cout),
						   .dout(dout),
						   .eout(eout),
						   .fout(fout),
						   .gout(gout),
						   .hout(hout)
						   ); 
   //creating clock
   initial clk=1'b0;
   always @(clk) clk<= #5 ~clk;
   
   //assigning inputs 
   initial begin
       rst = 1'b1; 
       ckey = 32'h428a2f98;
	   warray = 32'h68656c6f;
	   ain = 32'h6a09e667;
       bin = 32'hbb67ae85;
       cin = 32'h3c6ef372;
       din = 32'ha54ff53a;
       ein = 32'h510e527f;
       fin = 32'h9b05688c;
       gin = 32'h1f83d9ab;
       hin = 32'h5be0cd19;
     //  #11 rst = 1'b0;
     //  #10 valid = 1'b1;
    end
   //force simulation end
   initial begin
       #15000 $stop; 
   end
   
endmodule