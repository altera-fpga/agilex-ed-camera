/* ##################################################################################
 * Copyright (C) 2025 Altera Corporation
 *
 * This software and the related documents are Altera copyrighted materials, and
 * your use of them is governed by the express license under which they were
 * provided to you ("License"). Unless the License provides otherwise, you may
 * not use, modify, copy, publish, distribute, disclose or transmit this software
 * or the related documents without Altera's prior written permission.
 *
 * This software and the related documents are provided as is, with no express
 * or implied warranties, other than those that are expressly stated in the License.
 * ##################################################################################

 * ##################################################################################
 *
 * Module: intel_vvp_icon_axi_pipeline_stage
 *
 * Description: AXI master pipeline stage
 *
 * ##################################################################################
*/

`default_nettype none

module intel_vvp_icon_axi_pipeline_stage (
  clk,
  rst,

  axi_st_din_tvalid,
  axi_st_din_tdata,
  axi_st_din_tuser,
  axi_st_din_tlast,
  axi_st_din_tready,

  axi_st_dout_tvalid,
  axi_st_dout_tdata,
  axi_st_dout_tuser,
  axi_st_dout_tlast,
  axi_st_dout_tready
);

  import intel_vvp_icon_pkg::*;

  parameter   DATA_WIDTH           =  24;
  parameter   IS_TOKEN_INTERFACE   =  0;

  localparam  USER_WIDTH     =  (IS_TOKEN_INTERFACE > 0) ? 1 : (((DATA_WIDTH + 7) / 8) < VVP_USER_KEEP_BITS) ? VVP_USER_KEEP_BITS : (DATA_WIDTH + 7) / 8;

  input    wire                          clk;
  input    wire                          rst;

  input    wire                          axi_st_din_tvalid;
  input    wire  [DATA_WIDTH - 1 : 0]    axi_st_din_tdata;
  input    wire  [USER_WIDTH - 1 : 0]    axi_st_din_tuser;
  input    wire                          axi_st_din_tlast;
  output   reg                           axi_st_din_tready;

  output   reg                           axi_st_dout_tvalid;
  output   reg   [DATA_WIDTH - 1 : 0]    axi_st_dout_tdata;
  output   reg   [USER_WIDTH - 1 : 0]    axi_st_dout_tuser;
  output   reg                           axi_st_dout_tlast;
  input    wire                          axi_st_dout_tready;

  reg                        din_ready_dup;
  reg                        dout_valid_dup;
  reg   [DATA_WIDTH - 1 : 0] tdata_reg;
  reg                        tlast_reg;
  reg   [USER_WIDTH - 1 : 0] tuser_reg;

  wire                       din_ready_raw;
  wire                       dout_valid_raw;

  always @ (posedge clk) begin
    if (rst) begin
      axi_st_din_tready   <= 1'b1;
      axi_st_dout_tvalid  <= 1'b0;
      din_ready_dup       <= 1'b1;
      dout_valid_dup      <= 1'b0;
    end else begin
      axi_st_din_tready   <= din_ready_raw;
      axi_st_dout_tvalid  <= dout_valid_raw;
      din_ready_dup       <= din_ready_raw;
      dout_valid_dup      <= dout_valid_raw;
    end
  end

  always @ (posedge clk) begin
    //1 Reg deep FIFO.
    if (din_ready_dup) begin
      tdata_reg <= axi_st_din_tdata;
      tlast_reg <= axi_st_din_tlast;
      tuser_reg <= axi_st_din_tuser;
    end
    // Select between FIFO or input data.
    if (axi_st_dout_tready || ~dout_valid_dup) begin
      if (~din_ready_dup) begin
        axi_st_dout_tdata <= tdata_reg;
        axi_st_dout_tuser <= tuser_reg;
        axi_st_dout_tlast <= tlast_reg;
      end else begin
        axi_st_dout_tdata <= axi_st_din_tdata;
        axi_st_dout_tuser <= axi_st_din_tuser;
        axi_st_dout_tlast <= axi_st_din_tlast;
      end
    end
  end

  assign dout_valid_raw = axi_st_din_tvalid || (dout_valid_dup && (~din_ready_dup || ~axi_st_dout_tready));
  assign din_ready_raw = axi_st_dout_tready || (din_ready_dup && (~dout_valid_dup || ~axi_st_din_tvalid));

endmodule

`default_nettype wire
