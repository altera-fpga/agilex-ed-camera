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
 * Module: intel_vvp_icon_pkg
 *
 * Description: Package for ICON
 *
 * ##################################################################################
*/

`default_nettype none

package intel_vvp_icon_pkg;

  //some localparams that define global properties of all interfaces
  localparam  VVP_CTRL_WIDTH          =  16;
  localparam  VVP_USER_KEEP_BITS      =  2;
  localparam  VVP_MAX_CTRL_SIZE       =  4;

  // ------------------------------------------------------------------------
  // -- Control packet definitions
  // ------------------------------------------------------------------------
  localparam                                VVP_CTRL_PKT_TYPE_W         = 5;
  localparam  bit [VVP_CTRL_PKT_TYPE_W-1:0] VVP_CTRL_PKT_IP             = 5'd0;
  localparam  bit [VVP_CTRL_PKT_TYPE_W-1:0] VVP_CTRL_PKT_EOF            = 5'd1;

  localparam                                VVP_IP_COSITE_W             = 2;
  localparam  bit [VVP_IP_COSITE_W-1:0]     VVP_IP_COSITE_TL            = 2'b00; //-- Top-Left

  localparam                                VVP_IP_COLSPACE_W           = 7;
  localparam  bit [VVP_IP_COLSPACE_W-1:0]   VVP_IP_COLSPACE_RGB         = 7'd0;

  localparam                                VVP_IP_SUBSA_W              = 2;
  localparam  bit [VVP_IP_SUBSA_W-1:0]      VVP_IP_SUBSA_444            = 2'b11;

  localparam                                VVP_IP_INTLACE_W            = 4;

  localparam  logic [VVP_IP_INTLACE_W-1:0]  VVP_IP_PROGRESSIVE_NATIVE_0 = 4'b0011;

  localparam                                VVP_IP_BPS_W                = 5;

  // ------------------------------------------------------------------------
  // vvp_clog2 returns the ceiling of the log base 2 of the argument and is
  // almost equivalent to the Verilog-2005 function $clog2
  // It returns ceil(log2(x)) for x >= 2 and returns 1 for x==1 and x==0
  // Typical use case: with a memory of depth D, vvp_clog2(D) is the width
  // needed for the address bus
  // This should not be confused with the number of bits needed to represent
  // the number D (see below,
  // Max input size: 32-bit value
  // ------------------------------------------------------------------------
  function integer vvp_clog2;
    input [31:0] value;
    integer i;
    begin
      vvp_clog2 = 32;
      for (i=31; i>0; i=i-1) begin
        if (2**i >= value) begin
          vvp_clog2 = i;
        end
      end
    end
  endfunction

  // ------------------------------------------------------------------------
  // vvp_num_bits returns the number of bits needed to represent the given
  // argument. Mathematically, this is ceil(log2(x+1)). For instance,
  // alt_size(4) = 3  (ie, 4 == 3'b100)
  // Note that alt_size(1) == alt_size(0) == 1
  // Max input size: 32-bit value
  // ------------------------------------------------------------------------
  function integer vvp_num_bits;
    input [31:0] value;
    integer i;
    begin
      vvp_num_bits = 32;
      for (i=31; i>0; i=i-1) begin
        if (2**i -1 >= value) begin
          vvp_num_bits = i;
        end
      end
    end
  endfunction

endpackage

`default_nettype wire
