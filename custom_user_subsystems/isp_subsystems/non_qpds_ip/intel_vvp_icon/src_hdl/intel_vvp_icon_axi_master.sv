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
 * Module: intel_vvp_icon_axi_master
 *
 * Description: Creates an AXI master interface for ICON
 *
 * ##################################################################################
*/

`default_nettype none

module intel_vvp_icon_axi_master (
  clk,
  rst,

  din_valid,
  din_data,
  din_user,
  din_last,
  din_ready,

  axi_st_dout_tvalid,
  axi_st_dout_tdata,
  axi_st_dout_tuser,
  axi_st_dout_tlast,
  axi_st_dout_tready
);

  import intel_vvp_icon_pkg::*;

  parameter   DATA_WIDTH           =  24;
  parameter   IS_TOKEN_INTERFACE   =  0;
  parameter   PIPELINE_READY       =  0;

  localparam  USER_WIDTH     =  (IS_TOKEN_INTERFACE > 0) ? 1 : (((DATA_WIDTH + 7) / 8) < VVP_USER_KEEP_BITS) ? VVP_USER_KEEP_BITS : (DATA_WIDTH + 7) / 8;

  input    wire                          clk;
  input    wire                          rst;

  input    wire                          din_valid;
  input    wire  [DATA_WIDTH - 1 : 0]    din_data;
  input    wire  [USER_WIDTH - 1 : 0]    din_user;
  input    wire                          din_last;
  output   wire                          din_ready;

  output   wire                          axi_st_dout_tvalid;
  output   wire  [DATA_WIDTH - 1 : 0]    axi_st_dout_tdata;
  output   wire  [USER_WIDTH - 1 : 0]    axi_st_dout_tuser;
  output   wire                          axi_st_dout_tlast;
  input    wire                          axi_st_dout_tready;

  generate
    if (PIPELINE_READY > 0) begin
      intel_vvp_icon_axi_pipeline_stage # (
        .DATA_WIDTH             (DATA_WIDTH),
        .IS_TOKEN_INTERFACE     (IS_TOKEN_INTERFACE)
      ) pipe_bridge_inst (
        .clk                    (clk),
        .rst                    (rst),
        .axi_st_din_tvalid      (din_valid),
        .axi_st_din_tdata       (din_data),
        .axi_st_din_tuser       (din_user),
        .axi_st_din_tlast       (din_last),
        .axi_st_din_tready      (din_ready),
        .axi_st_dout_tvalid     (axi_st_dout_tvalid),
        .axi_st_dout_tdata      (axi_st_dout_tdata),
        .axi_st_dout_tuser      (axi_st_dout_tuser),
        .axi_st_dout_tlast      (axi_st_dout_tlast),
        .axi_st_dout_tready     (axi_st_dout_tready)
      );
    end else begin
      assign axi_st_dout_tvalid = din_valid;
      assign axi_st_dout_tdata = din_data;
      assign axi_st_dout_tuser = din_user;
      assign axi_st_dout_tlast = din_last;
      assign din_ready = axi_st_dout_tready || ~axi_st_dout_tvalid;

    end

  endgenerate

endmodule

`default_nettype wire
