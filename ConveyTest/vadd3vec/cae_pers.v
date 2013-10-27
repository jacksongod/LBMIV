/*****************************************************************************/
//
// Module	   : cae_pers.vpp
// Revision	   :  Revision: 1.3  
// Last Modified On:  Date: 2013/01/23 17:37:19  
// Last Modified By:  Author: gedwards  
//
//-----------------------------------------------------------------------------
//
// Original Author : gedwards
// Created On      : Wed Oct 10 09:26:08 2007
//
//-----------------------------------------------------------------------------
//
// Description     : Sample PDK Vector Add Personality
//
//                   Top-level of vadd personality.  For a complete list of 
//                   optional ports, see 
//                   /opt/convey/pdk/<rev>/<platform>/doc/cae_pers.v
//
//-----------------------------------------------------------------------------
//
// Copyright (c) 2007-2013 : created by Convey Computer Corp. This model is the
// confidential and proprietary property of Convey Computer Corp.
//
/*****************************************************************************/
/*  Id: cae_pers.vpp,v 1.3 2013/01/23 17:37:19 gedwards Exp   */

`timescale 1 ns / 1 ps

`include "pdk_fpga_defines.vh"

(* keep_hierarchy = "true" *)
module cae_pers #(parameter    NUM_MC_PORTS = 16) (
   //
   // Clocks and Resets
   //
   input		clk,		// 150MHz PDK core clock
   input		clk_csr,	// half-rate (75MHz) clock for CSR chain
   input		clk2x,		// 2x rate (300MHz) clock
   input		i_reset,	// global reset synchronized to 150MHz clock
   input		i_csr_reset_n,	// 75MHz active-low reset for CSR chain

   // Signals for async personality clock
   input		ppll_reset,
   output		ppll_locked,
   output		clk_per,

   //
   // Dispatch Interface
   //
   input  [31:0]	cae_inst,
   input  [63:0]	cae_data,
   input		cae_inst_vld,

   output [17:0]	cae_aeg_cnt,
   output [15:0]	cae_exception,
   output [63:0]	cae_ret_data,
   output		cae_ret_data_vld,
   output		cae_idle,
   output		cae_stall,

   //
   // MC Interface(s)
   //
   output [NUM_MC_PORTS*1-1 :0]         mc_rq_vld,
   output [NUM_MC_PORTS*32-1:0]         mc_rq_rtnctl,
   output [NUM_MC_PORTS*64-1:0]         mc_rq_data,
   output [NUM_MC_PORTS*48-1:0]         mc_rq_vadr,
   output [NUM_MC_PORTS*2-1 :0]         mc_rq_len,
   output [NUM_MC_PORTS*4-1 :0]         mc_rq_sub,
   output [NUM_MC_PORTS*3-1 :0]         mc_rq_cmd,
   input  [NUM_MC_PORTS*1-1 :0]         mc_rq_stall,
   
   input  [NUM_MC_PORTS*1-1 :0]         mc_rs_vld,
   input  [NUM_MC_PORTS*3-1 :0]         mc_rs_cmd,
   input  [NUM_MC_PORTS*3-1 :0]         mc_rs_sub,
   input  [NUM_MC_PORTS*64-1:0]         mc_rs_data,
   input  [NUM_MC_PORTS*32-1:0]         mc_rs_rtnctl,
   output [NUM_MC_PORTS*1-1 :0]         mc_rs_stall,

   //
   // Write flush 
   //
   output [NUM_MC_PORTS*1-1 :0]         mc_rq_flush,
   input  [NUM_MC_PORTS*1-1 :0]         mc_rs_flush_cmplt,

   //
   // AE-to-AE Interface not used
   //

   //
   // Management/Debug Interface
   //
   input  [3:0]		cae_ring_ctl_in,
   input  [15:0]	cae_ring_data_in,
   output [3:0]		cae_ring_ctl_out,
   output [15:0]	cae_ring_data_out,

   //
   // Miscellaneous
   //
   input  [1:0]		i_aeid,
   input		csr_31_31_intlv_dis
);

`include "pdk_fpga_param.vh"
//initial 
  // begin 
    // $display("%0t: Start Dumping",$realtime());
    // $vcdpluson(0,testbench);

 // end 
   //
   // Local clock generation
   //
   (* KEEP = "true" *) wire reset_per;
   cae_clock clock (
      .clk(clk),
      .clk2x(clk2x),
      .clkhx(clk_csr), 
      .i_reset(i_reset),
      .ppll_reset(ppll_reset),

      .clk_per(clk_per),
      .clk_per_2x(clk_per_2x),
      .ppll_locked(ppll_locked),
      .reset_per(reset_per)
   );


   //
   // Instruction decode
   //
   wire [4:0]	inst_caep;
   wire [17:0]	inst_aeg_idx;
   instdec dec (
      .cae_inst(cae_inst),
      .cae_data(cae_data),
      .cae_inst_vld(cae_inst_vld),

      .inst_val(inst_val),
      .inst_caep(inst_caep),
      .inst_aeg_wr(inst_aeg_wr),
      .inst_aeg_rd(inst_aeg_rd),
      .inst_aeg_idx(inst_aeg_idx),
      .err_unimpl(err_unimpl)
   );


   //**************************************************************************
   //			   PERSONALITY SPECIFIC LOGIC
   //**************************************************************************

   //
   // AEG[0..NA-1] Registers
   //
   localparam NA = 34;
   localparam NB = 6;		// Number of bits to represent NAEG

   assign cae_aeg_cnt = NA;

   reg		r_sum_vld;
   reg  [64:0]	r_sum;
   wire [63:0]	w_aeg[NA-1:0];

   wire xbar_enabled = MC_XBAR;

   genvar g;
   generate for (g=0; g<NA; g=g+1) begin : g0
      reg [63:0] c_aeg, r_aeg;

      always @* begin
	 case (g)
	    4: c_aeg = {63'h0, xbar_enabled};
	    30,31,32,33: c_aeg = r_sum_vld ? r_sum[63:0] : r_aeg;
	 default: c_aeg = r_aeg;
	 endcase
      end

      wire c_aeg_we = inst_aeg_wr && inst_aeg_idx[NB-1:0] == g;

      always @(posedge clk_per) begin
	 if (c_aeg_we)
	    r_aeg <= cae_data;
	 else
	    r_aeg <= c_aeg;
      end
      assign w_aeg[g] = r_aeg;
   end endgenerate

   reg		r_ret_val, r_err_unimpl, r_err_aegidx;
   reg [63:0]	r_ret_data;

   wire c_val_aegidx = inst_aeg_idx < NA;

   always @(posedge clk_per) begin
      r_ret_val    <= inst_aeg_rd && c_val_aegidx;
      r_ret_data   <= w_aeg[inst_aeg_idx[NB-1:0]];
      r_err_aegidx <= (inst_aeg_wr || inst_aeg_rd) && !c_val_aegidx;
      r_err_unimpl <= err_unimpl || (inst_val && inst_caep !== 'd0);
   end
   assign cae_ret_data_vld = r_ret_val;
   assign cae_ret_data     = r_ret_data;

   assign cae_exception[1:0] = {r_err_aegidx, r_err_unimpl};

   //
   // Dispatch logic
   //
   localparam CNT_BITS = 7'd45;

   wire [47:0]	mem_base1 = w_aeg[0][47:0];
   wire [47:0]	mem_base2 = w_aeg[1][47:0];
   wire [47:0]	mem_base3 = w_aeg[2][47:0];
   wire [47:0]	mem_base4 = w_aeg[5][47:0];
   
   wire [47:0]	mem_last_offst = {w_aeg[3][CNT_BITS-1:0], 3'b0};

   wire c_invalid_intlv = ((MC_XBAR == 0) || (MC_XBAR_INTLV == 0)) && !csr_31_31_intlv_dis;

   wire c_caep00 = inst_val && inst_caep == 5'd0
		&& !c_invalid_intlv;

   wire [15:0]	r_sum_ovrflw_vec, r_res_ovrflw_vec, r_sum_vld_vec;
   reg		r_caep00, r_idle,
		r_sum_ovrflw, r_res_ovrflw, r_err_intlv;

   always @(posedge clk_per) begin
      r_caep00 <= c_caep00;
      r_idle   <= cae_idle;

      r_sum_ovrflw     <= |r_sum_ovrflw_vec;
      r_res_ovrflw     <= |r_res_ovrflw_vec;
      r_err_intlv      <= inst_val && c_invalid_intlv;
   end

   assign cae_exception[15:2] = {10'b0,
				 r_sum_ovrflw,
				 r_res_ovrflw,
				 1'b0,
				 r_err_intlv};


   //
   // Control state machine
   //
   wire [63:0]	r_au_sum [15:0];
   wire [63:0]	c_sum_mux;
   reg  [63:0]	c_sum_in, r_sum_in, r_sum_csr;
   reg  [64:0]	c_sum;
   reg  [3:0]	c_sum_cnt, r_sum_cnt;
   reg  [2:0]	c_state, r_state;

   localparam  IDLE     = 3'd0,
	       VADD     = 3'd1,
	       SUM      = 3'd2,
	       WAIT     = 3'd3,
	       SUM_VLD  = 3'd4;

   assign c_sum_mux = r_au_sum[r_sum_cnt];
   always @*
    begin
      c_state = r_state;
      c_sum_cnt = r_sum_cnt;
      c_sum_in = 64'b0;
      c_sum = r_sum + r_sum_in;
      case (r_state)
	IDLE:
	  if (r_caep00) begin
	    c_sum = 65'd0;
	    c_state = VADD;
	  end
	VADD:
	  if (&r_sum_vld_vec)
	    c_state = SUM;
	SUM: begin
          c_sum_in = c_sum_mux;
	  c_sum_cnt = {r_sum_cnt + 4'h1};
	  if (r_sum_cnt == 4'd15)
	    c_state = WAIT;
	end
	// Wait one cycle for sum to be valid
	WAIT: begin
	    c_state = SUM_VLD;
	end
	SUM_VLD: begin
	    c_state = IDLE;
	end
	default:
	  c_state = IDLE;
      endcase
   end

   // ISE can have issues with global wires attached to D(flop)/I(lut) inputs
   wire r_reset;
   FDSE rst (.C(clk_per),.S(reset_per),.CE(r_reset),.D(!r_reset),.Q(r_reset));

   always @(posedge clk_per) begin
      r_state	<= r_reset ? 3'b0  : c_state;
      r_sum_vld	<= c_state == SUM_VLD;

      r_sum_in	<= r_reset ? 64'b0 : c_sum_in;
      r_sum	<= r_reset ? 65'b0 : c_sum;
      r_sum_cnt	<= r_reset ? 4'b0  : c_sum_cnt;
    end

   always @(posedge clk_csr) begin
      r_sum_csr <= r_sum[63:0];
   end

   assign cae_idle  = (r_state == IDLE) && !r_caep00;
   assign cae_stall = (r_state != IDLE) || c_caep00 || r_caep00;

   // CSR programmable threshold to control ld/st crossover
   wire [11:0]	csr_ldst_thld;

   //
   // Submodules
   //

   // Control/Status
   cae_csr csr (
      // Outputs
      .ring_ctl_out	(cae_ring_ctl_out),
      .ring_data_out	(cae_ring_data_out),
      .csr_ldst_thld    (csr_ldst_thld),
      // Inputs
      .clk_csr		(clk_csr),
      .i_csr_reset_n	(i_csr_reset_n),
      .ring_ctl_in	(cae_ring_ctl_in),
      .ring_data_in	(cae_ring_data_in),
      .cae_csr_status	({61'b0, r_state}),
      .cae_csr_vis	({16'b0, cae_exception, 16'b0, r_sum_vld_vec}),
      .cae_csr_sum	(r_sum_csr)
   );

// Temporary wires for remapping ports
wire [15:0] mc_req_ld, mc_req_st, mc_rs_st_vld;
wire [63:0] mc_req_wrd_rdctl[15:0];

genvar i;
generate for (i=0; i<16; i=i+1) begin : fp
   wire [3:0] local_fp = i;

  // remap old vadd ports to new MX ports
  assign mc_rq_vld[i] = mc_req_ld[i] || mc_req_st[i];
  assign mc_rq_rtnctl[i*32 +: 32] = mc_req_ld[i] ? mc_req_wrd_rdctl[i] : 32'b0;
  assign mc_rq_data[i*64 +: 64] = mc_req_st[i] ? mc_req_wrd_rdctl[i] : 64'b0;
  assign mc_rq_sub[i*4 +: 4] = 4'd0;
  assign mc_rq_cmd[i*3 +: 3] = mc_req_ld[i] ? 3'd1 : 
                               mc_req_st[i] ? 3'd2 : 3'd0;
  assign mc_rs_st_vld[i] = mc_rs_vld[i] && (mc_rs_cmd[i*3 +: 3]==3'd2); // ld_rsp is 2

   vadd add (
      .mc_req_ld	(mc_req_ld[i]),
      .mc_req_st	(mc_req_st[i]),
      .mc_req_wrd_rdctl	(mc_req_wrd_rdctl[i]),
      .mc_req_vadr	(mc_rq_vadr[i*48 +: 48]),
      .mc_req_size	(mc_rq_len[i*2 +: 2]),
      .mc_req_flush	(mc_rq_flush[i]),
      .mc_rsp_stall	(mc_rs_stall[i]),
      .sum		(r_au_sum[i]),
      .sum_vld		(r_sum_vld_vec[i]),
      .sum_ovrflw	(r_sum_ovrflw_vec[i]),
      .res_ovrflw	(r_res_ovrflw_vec[i]),
      // Inputs
      .clk		(clk_per),
      .reset		(reset_per),
      .idle		(r_idle),
      .start		(r_caep00),
      .fpnum		({i_aeid, local_fp}),
      .mem_base1	(mem_base1[47:0]),
      .mem_base2	(mem_base2[47:0]),
      .mem_base3	(mem_base3[47:0]),
      .mem_base4	(mem_base4[47:0]),
 
      .mem_last_offst	(mem_last_offst[47:0]),
      .mc_rd_rq_stall	(mc_rq_stall[i]),
      .mc_wr_rq_stall	(mc_rq_stall[i]),
      .mc_rsp_rdctl	(mc_rs_rtnctl[i*32 +: 32]),
      .mc_rsp_data	(mc_rs_data[i*64 +: 64]),
      .mc_rsp_push	(mc_rs_st_vld[i]), 
      .csr_ldst_thld	(csr_ldst_thld)
   );

end endgenerate

   /* ---------- debug & synopsys off blocks  ---------- */

   // synopsys translate_off

   // Parameters: 1-Severity: Don't Stop, 2-start check only after negedge of reset
   //assert_never #(1, 2, "***ERROR ASSERT: unimplemented instruction cracked") a0 (.clk(clk_per), .reset_n(~reset), .test_expr(r_unimplemented_inst));

    // synopsys translate_on

endmodule // cae_pers
