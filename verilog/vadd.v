/*****************************************************************************/
//
// Module          : vadd.vpp
// Revision        :  Revision: 1.2  
// Last Modified On:  Date: 2013/01/23 17:31:48  
// Last Modified By:  Author: gedwards  
//
//-----------------------------------------------------------------------------
//
// Original Author : gedwards
// Created On      : Wed Oct 10 09:26:08 2007
//
//-----------------------------------------------------------------------------
//
// Description     : Sample personality vector add unit
//
//-----------------------------------------------------------------------------
//
// Copyright (c) 2007-2012 : created by Convey Computer Corp. This model is the
// confidential and proprietary property of Convey Computer Corp.
//
/*****************************************************************************/
/*  Id: vadd.vpp,v 1.2 2013/01/23 17:31:48 gedwards Exp   */

`timescale 1 ns / 1 ps

module vadd (
   input		clk,
   input		reset,

   input		idle,
   input		start,
   input  [5:0]		fpnum,

   output		mc_req_ld,
   output		mc_req_st,
   output [47:0]	mc_req_vadr,
   output [1:0]		mc_req_size,
   output		mc_req_flush,
   output [63:0]	mc_req_wrd_rdctl,
   input		mc_rd_rq_stall,
   input		mc_wr_rq_stall,

   input  [31:0]	mc_rsp_rdctl,
   input  [63:0]	mc_rsp_data,
   input		mc_rsp_push,
   output		mc_rsp_stall,

   input  [47:0]	mem_base1,
   input  [47:0]	mem_base2,
   input  [47:0]	mem_base3,
   input  [47:0]	mem_last_offst,

   output [63:0]	sum,
   output		sum_vld,
   output		sum_ovrflw,
   output		res_ovrflw,

   input  [11:0]	csr_ldst_thld
);

   /* ----------         include files        ---------- */

   // Use 63 pipes, instead of 64, to avoid stride of 64
   parameter NUM_FPS = 7'd63;

   /* ----------          wires & regs        ---------- */

   wire [47:0]  c_last_addr1;
   wire [47:0]  c_last_addr2;
   wire [47:0]  c_last_addr3;
   reg  [47:0]  r_last_addr1;
   reg  [47:0]  r_last_addr2;
   reg  [47:0]  r_last_addr3;

   (* equivalent_register_removal = "no" *)
   reg          r_start, r_start2;
   wire         r_reset, idle_reset;

   reg  [2:0]   nxt_state;
   reg  [2:0]   r_state;

   reg  [47:0]  c_ld_addr1;
   reg  [47:0]  r_ld_addr1;
   reg  [47:0]  c_ld_addr2;
   reg  [47:0]  r_ld_addr2;

   reg          c_op_sel;
   reg          r_op_sel;

   wire [63:0]  op_ld_rdctl;

   wire [64:0]  c_result;
   reg  [64:0]  r_result;
   wire         c_result_vld;
   reg          r_result_vld;
   wire         res_fifo_afull;
   wire         res_qempty;
   reg  [47:0]  c_st_addr;
   reg  [47:0]  r_st_addr;
   wire [63:0]  res_st_data;
   wire [64:0]  c_sum;
   wire         c_sum_vld;
   reg          r_sum_vld;
   reg  [64:0]  r_sum;
   reg  [64:0]  r_sum2;
   wire [63:0]  op1_ram_out;
   wire [63:0]  op2_ram_out;
   wire         op1_wea;
   wire         op2_wea;
   wire         op1_qempty;
   wire         op2_qempty;
   reg          c_req_ld;
   reg          r_req_ld;
   reg          c_req_st;
   reg          r_req_st;
   reg  [47:0]  c_req_vadr;
   reg  [47:0]  r_req_vadr;
   reg  [63:0]  c_req_wrd_rdctl;
   reg  [63:0]  r_req_wrd_rdctl;
   reg          r_mc_rsp_push;
   reg  [31:0]  r_mc_rsp_rdctl;
   reg  [63:0]  r_mc_rsp_data;

   reg          r_mc_rd_rq_stall;
   reg          r_mc_wr_rq_stall;

   wire 	op1_fifo_afull;
   wire 	op2_fifo_afull;

   localparam IDLE   = 3'd0;
   localparam LD_OP1 = 3'd1;
   localparam LD_OP2 = 3'd2;
   localparam ST_RES = 3'd3;
   localparam AD_CHK = 3'd4;

   reg  [15:0]  c_ldst_cnt, r_ldst_cnt;

   /* ----------      combinatorial blocks    ---------- */

  // Outputs to smpl_pers
  assign sum = r_sum2[63:0];
  assign sum_vld = r_sum_vld;
  assign sum_ovrflw = r_sum2[64] && r_sum_vld;
  assign res_ovrflw = r_result[64] && r_result_vld;

  assign idle_reset = r_reset || idle;

  // MC interface
  assign mc_req_ld = r_req_ld;
  assign mc_req_st = r_req_st;
  assign mc_req_vadr = r_req_vadr;
  assign mc_req_wrd_rdctl = r_req_wrd_rdctl;
  assign mc_req_size = 2'h3;		// all requests are 8-byte
  assign mc_req_flush = 1'b0;		// write flush not used in this design

  assign mc_rsp_stall = op1_fifo_afull || op2_fifo_afull;

  assign c_last_addr1 = mem_base1 + mem_last_offst;
  assign c_last_addr2 = mem_base2 + mem_last_offst;
  assign c_last_addr3 = mem_base3 + mem_last_offst;

always @*
begin
  nxt_state = r_state;
  c_ld_addr1 = r_ld_addr1;
  c_ld_addr2 = r_ld_addr2;
  c_st_addr = r_st_addr;
  c_op_sel = r_op_sel;
  c_req_ld = 1'b0;
  c_req_st = 1'b0;
  c_req_vadr = r_req_vadr;
  c_req_wrd_rdctl = r_req_wrd_rdctl;
  c_ldst_cnt = r_ldst_cnt;
  case (r_state)
    IDLE:
      begin
        c_op_sel = 1'b0;
        if (r_start2 && (fpnum<NUM_FPS)) begin
          // initialize FP base address
          c_ld_addr1 = mem_base1 + fpnum*8;
          c_ld_addr2 = mem_base2 + fpnum*8;
          c_st_addr  = mem_base3 + fpnum*8;
          nxt_state = AD_CHK;
          c_ldst_cnt = 'd0;
        end
      end
    AD_CHK:
      begin
        if (r_ld_addr1 < r_last_addr1)
          nxt_state = LD_OP1;
        else
          nxt_state = IDLE;
      end
    LD_OP1:
      begin
        c_req_vadr = r_ld_addr1;
        c_req_wrd_rdctl = op_ld_rdctl;
        if (~r_mc_rd_rq_stall) begin
          c_req_ld = 1'b1;
          c_ld_addr1 = r_ld_addr1 + NUM_FPS*8;
          nxt_state = LD_OP2;
          c_op_sel = 1'b1;
        end
      end
    LD_OP2:
      begin
        c_req_vadr = r_ld_addr2;
        c_req_wrd_rdctl = op_ld_rdctl;
        if (~r_mc_rd_rq_stall) begin
          c_req_ld = 1'b1;
          c_ld_addr2 = r_ld_addr2 + NUM_FPS*8;
          nxt_state = LD_OP1;
          c_op_sel = 1'b0;
          c_ldst_cnt = r_ldst_cnt + 'd1;
          if ((r_ldst_cnt==csr_ldst_thld-1) || (r_ld_addr1 >= r_last_addr1) || res_fifo_afull) begin
            c_ldst_cnt = 'd0;
            nxt_state = ST_RES;
          end
        end
      end
    ST_RES:
      begin
        c_req_vadr = r_st_addr;
        c_req_wrd_rdctl = res_st_data;
        if (~r_mc_wr_rq_stall && ~res_qempty) begin
          c_req_st = 1'b1;
          c_st_addr = r_st_addr + NUM_FPS*8;
          c_ldst_cnt = r_ldst_cnt + 'd1;
          if ((r_ldst_cnt==csr_ldst_thld-1) && (r_ld_addr1 < r_last_addr1)) begin
            c_ldst_cnt = 'd0;
            nxt_state = LD_OP1;
          end
        end
        if (c_st_addr >= r_last_addr3)
         nxt_state = IDLE;
      end
    default:  nxt_state = IDLE;
  endcase
end

  // Load operands

  assign op_ld_rdctl = {63'b0, r_op_sel};

  assign op1_wea = r_mc_rsp_push && ~r_mc_rsp_rdctl[0];
  assign op2_wea = r_mc_rsp_push && r_mc_rsp_rdctl[0];

  assign c_result[64:0] = {1'b0, op1_ram_out[63:0]} + {1'b0, op2_ram_out[63:0]};
  assign c_result_vld = !op1_qempty && !op2_qempty && !res_fifo_afull;

  assign c_sum[64:0] = r_result_vld ? r_sum[64:0] + r_result[64:0] : r_sum[64:0];
  assign c_sum_vld = (r_st_addr >= r_last_addr3) || (fpnum>=NUM_FPS);

   /* ----------      external module calls   ---------- */

   fifo #(.DEPTH(2048), .WIDTH(64), .AFULLCNT(2000), .RAM_STYLE("block")) result_fifo (
    .clk    (clk),
    .reset  (r_reset),
    .push   (r_result_vld),
    .din    (r_result[63:0]),
    .afull  (res_fifo_afull),
    .full   (),
    .cnt    (),
    .oclk   (clk),
    .pop    (c_req_st),
    .dout   (res_st_data[63:0]),
    .empty  (res_qempty),
    .rcnt   ()
   );

   fifo #(.DEPTH(32), .WIDTH(64), .AFULLCNT(28)) op1_fifo (
    .clk    (clk),
    .reset  (r_reset),
    .push   (op1_wea),
    .din    (r_mc_rsp_data),
    .afull  (op1_fifo_afull),
    .full   (),
    .cnt    (),
    .oclk   (clk),
    .pop    (c_result_vld),
    .dout   (op1_ram_out),
    .empty  (op1_qempty),
    .rcnt   ()
   );

   fifo #(.DEPTH(32), .WIDTH(64), .AFULLCNT(28)) op2_fifo (
    .clk    (clk),
    .reset  (r_reset),
    .push   (op2_wea),
    .din    (r_mc_rsp_data),
    .afull  (op2_fifo_afull),
    .full   (),
    .cnt    (),
    .oclk   (clk),
    .pop    (c_result_vld),
    .dout   (op2_ram_out),
    .empty  (op2_qempty),
    .rcnt   ()
   );

   /* ----------            registers         ---------- */

   // ISE can have issues with global wires attached to D(flop)/I(lut) inputs
   FDSE rst (.C(clk),.S(reset),.CE(r_reset),.D(!r_reset),.Q(r_reset)); 

   always @(posedge clk) begin
      r_start  <= r_reset ? 1'b0 : start;
      r_start2 <= r_reset ? 1'b0 : r_start;
      r_state  <= r_reset ?  'd0 : nxt_state;
   end

   always @(posedge clk) begin
      r_req_ld <= c_req_ld;
      r_req_st <= c_req_st;
      r_req_vadr <= c_req_vadr;
      r_req_wrd_rdctl <= c_req_wrd_rdctl;
      r_mc_rd_rq_stall <= mc_rd_rq_stall;
      r_mc_wr_rq_stall <= mc_wr_rq_stall;
   end

   always @(posedge clk) begin
      r_last_addr1 <= c_last_addr1;
      r_last_addr2 <= c_last_addr2;
      r_last_addr3 <= c_last_addr3;
   end

   always @(posedge clk) begin
      r_ld_addr1   <= idle_reset ? 'd0 : c_ld_addr1;
      r_ld_addr2   <= idle_reset ? 'd0 : c_ld_addr2;
      r_st_addr    <= idle_reset ? 'd0 : c_st_addr;
      r_op_sel     <= idle_reset ? 'd0 : c_op_sel;
      r_result_vld <= idle_reset ? 'd0 : c_result_vld;
      r_sum_vld    <= idle_reset ? 'd0 : c_sum_vld;
      r_result     <= idle_reset ? 'd0 : c_result;
      r_sum        <= idle_reset ? 'd0 : c_sum;
      r_sum2       <= idle_reset ? 'd0 : r_sum;
      r_ldst_cnt   <= idle_reset ? 'd0 : c_ldst_cnt;
   end

   always @(posedge clk) begin
      r_mc_rsp_push  <= r_reset ? 1'b0 : mc_rsp_push;
      r_mc_rsp_rdctl <= r_reset ? 1'b0 : mc_rsp_rdctl;
      r_mc_rsp_data  <= r_reset ? 1'b0 : mc_rsp_data;
   end


   /* ---------- debug & synopsys off blocks  ---------- */

   // synopsys translate_off

   // Parameters: 1-Severity: Don't Stop, 2-start check only after negedge of reset
   //assert_never #(1, 2, "***ERROR ASSERT: unimplemented instruction cracked") a0 (.clk(clk), .reset_n(~reset), .test_expr(r_unimplemented_inst));

    // synopsys translate_on

endmodule // vadd

// This is the search path for the autoinst commands in emacs.
// After modification you must save file, then reld with C-x C-v
//
// Local Variables:
// verilog-library-directories:("." "../../common/xilinx")
// End:

