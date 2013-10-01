/*****************************************************************************/
//
// Module          : cae_csr.v
// Revision        :  Revision: 1.2  
// Last Modified On:  Date: 2012/12/14 17:43:19  
// Last Modified By:  Author: jamelio  
//
//-----------------------------------------------------------------------------
//
// Original Author : Glen Edwards
// Created On      : Jun 24, 2009
//
//-----------------------------------------------------------------------------
//
// Description     : CAE csr block contains registers accessible by the
//		     management processor
//
//-----------------------------------------------------------------------------
//
// Copyright (c) 2008-2011 : Created by Convey Computer Corp. This model is the
// confidential and proprietary property of Convey Computer Corp.
//
/*****************************************************************************/
/*  Id: cae_csr.v,v 1.2 2012/12/14 17:43:19 jamelio Exp   */

(* keep_hierarchy = "true" *)
module cae_csr (
input		clk_csr,
input		i_csr_reset_n,

input	[3:0]	ring_ctl_in,
input	[15:0]	ring_data_in,

output	[3:0]	ring_ctl_out,
output	[15:0]	ring_data_out,

//
// CSRs
//
input	[63:0]	cae_csr_status,
input	[63:0]	cae_csr_vis,
input	[63:0]	cae_csr_sum,
output	[63:0]	cae_csr_scratch,

output	[11:0]	csr_ldst_thld
);

    localparam	CAE_CSR_SEL		= 16'h8000,
		CAE_CSR_ADR_MASK	= 16'h8000,
		CAE_CSR_STATUS		= 16'd1,
		CAE_CSR_VIS		= 16'd2,
		CAE_CSR_SCRATCH		= 16'd3,
		CAE_CSR_SUM		= 16'h4,
		CAE_CSR_LDST_THLD	= 16'h5;

    // CSR ring interface
    wire	func_wr_vld, func_rd_vld;
    wire [15:0]	func_address;
    wire [63:0]	func_wr_data;
    reg		c_func_ack;
    reg  [63:0]	c_func_rd_data;

    // Registers
    reg 	r_csr_reset_n;
    reg [63:0]	c_csr_scratch, r_csr_scratch;
    reg [11:0]	c_csr_ldst_thld, r_csr_ldst_thld;

    assign cae_csr_scratch = r_csr_scratch;
    assign csr_ldst_thld = r_csr_ldst_thld;

    always @* begin
	c_func_ack = func_rd_vld;
	c_func_rd_data = 64'h0;
	c_csr_scratch = r_csr_scratch;
	c_csr_ldst_thld = r_csr_ldst_thld;

	case(func_address)
	CAE_CSR_STATUS: begin
	    c_func_rd_data = cae_csr_status;
	end
	CAE_CSR_VIS: begin
	    c_func_rd_data = cae_csr_vis;
	end
	CAE_CSR_SCRATCH: begin
	    c_func_rd_data = r_csr_scratch;
	    if (func_wr_vld) c_csr_scratch = func_wr_data;
	end
	CAE_CSR_SUM: begin
	    c_func_rd_data = cae_csr_sum;
	end
	CAE_CSR_LDST_THLD: begin
	    c_func_rd_data = r_csr_ldst_thld;
	    if (func_wr_vld) c_csr_ldst_thld = func_wr_data[11:0];
	end
	default: begin
	    c_func_rd_data = 64'h0;
	end
	endcase
    end

  
    always @(posedge clk_csr) begin
      if (i_csr_reset_n)
        r_csr_reset_n <= ~(1'b0);
      else
        r_csr_reset_n <= (1'b0);
    end
      
    always @(posedge clk_csr) begin
      r_csr_scratch <= c_csr_scratch;
      r_csr_ldst_thld <= ~r_csr_reset_n ? 12'd1536 : c_csr_ldst_thld;
    end

    csr_agent #(
	.ADDRESS_MASK(CAE_CSR_ADR_MASK),
	.ADDRESS_SELECT(CAE_CSR_SEL)
    ) agent (
	// Outputs
	.ring_ctl_out	(ring_ctl_out),
	.ring_data_out	(ring_data_out),
	.func_wr_valid	(func_wr_vld),
	.func_rd_valid	(func_rd_vld),
	.func_address	(func_address),
	.func_wr_data	(func_wr_data),
	// Inputs
	.core_clk83	(clk_csr),
	.reset_n	(r_csr_reset_n),
	.ring_ctl_in	(ring_ctl_in),
	.ring_data_in	(ring_data_in),
	.func_ack	(c_func_ack),
	.func_rd_data	(c_func_rd_data)
    );

endmodule
