module shacompre (
   input		rst,
   input		clk,
   input [31:0] warray, 
   input [31:0]      ckey,
   input [31:0]       ain,
   input [31:0]       bin,
   input [31:0]       cin,
   input [31:0]       din,
   input [31:0]       ein,
   input [31:0]       fin,
   input [31:0]       gin,
   input [31:0]       hin,
   output [31:0]       aout,
   output [31:0]       bout,
   output [31:0]       cout,
   output [31:0]       dout,
   output [31:0]       eout,
   output [31:0]       fout,
   output [31:0]       gout,
   output [31:0]       hout
   //input  [5:0]		fpnum,


   //input  [11:0]	csr_ldst_thld
);


wire [31:0]s1;
wire  [31:0]ch;
wire [31:0]temp1;
wire [31:0]s0;
wire [31:0]maj;
wire [31:0]temp2;

assign s1 = {ein[5:0],ein[31:6]} ^ {ein[10:0],ein[31:11]}^{ein[24:0],ein[31:25]};
assign ch = (ein & fin )^ ((~ein )&gin);
assign temp1 = hin +s1+ ch+ ckey+warray;
assign s0 = {ain[1:0],ain[31:2]} ^ {ain[12:0],ain[31:13]} ^{ain[21:0],ain[31:22]};
assign maj =(ain & bin) ^ (ain & cin) ^ (bin & cin);
assign temp2 = s0+maj;


assign hout = gin;
assign gout = fin;
assign fout = ein;
assign eout = din +temp1; 
assign dout = cin;
assign cout = bin;
assign bout = ain;
assign aout = temp1+temp2;





endmodule
