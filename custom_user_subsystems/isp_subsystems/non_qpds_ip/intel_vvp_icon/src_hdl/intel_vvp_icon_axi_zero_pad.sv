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
 * Module: intel_vvp_icon_axi_zero_pad
 *
 * Description: Takes axi data that is not integer multiple of bytes >= 2 and pads it
 *                up with zeros to the next whole byte >= 2
 *                Also pads the user signal from the min-width VVP_USER_KEEP_BITS (2)
 *                that we actually use and pads it to match the number of bytes in the data
 *
 * ##################################################################################
*/

`default_nettype none

module intel_vvp_icon_axi_zero_pad (
  pure_data_in,
  pure_user_in,

  padded_data_out,
  padded_user_out
);

  import intel_vvp_icon_pkg::*;

  parameter   BPS                        =  10;
  parameter   NUMBER_OF_COLOR_PLANES     =  3;
  parameter   PIXELS_IN_PARALLEL         =  2;

  localparam  PIXEL_WIDTH                =  BPS * NUMBER_OF_COLOR_PLANES;
  localparam  PIXEL_BYTES                =  (((PIXEL_WIDTH + 7) / 8) < 2) ? 2 : (PIXEL_WIDTH + 7) / 8;
  localparam  PIXEL_WIDTH_PAD            =  PIXEL_BYTES * 8;
  localparam  DATA_WIDTH_IN              =  PIXEL_WIDTH * PIXELS_IN_PARALLEL;
  localparam  DATA_WIDTH_OUT             =  PIXEL_WIDTH_PAD * PIXELS_IN_PARALLEL;
  localparam  USER_WIDTH_OUT             =  PIXEL_BYTES * PIXELS_IN_PARALLEL;

  input    wire  [DATA_WIDTH_IN - 1 : 0]       pure_data_in;
  input    wire  [VVP_USER_KEEP_BITS - 1 : 0]  pure_user_in;

  output   wire  [DATA_WIDTH_OUT - 1 : 0]   padded_data_out;
  output   wire  [USER_WIDTH_OUT - 1 : 0]   padded_user_out;

  genvar j;
  generate

    if (USER_WIDTH_OUT > VVP_USER_KEEP_BITS) begin
        assign padded_user_out = {{(USER_WIDTH_OUT-VVP_USER_KEEP_BITS){1'b0}},pure_user_in};
    end else begin
        assign padded_user_out = pure_user_in;
    end

    for (j=0; j<PIXELS_IN_PARALLEL; j=j+1) begin :  strip_gen

      if (PIXEL_WIDTH_PAD > PIXEL_WIDTH) begin
        assign padded_data_out[(j+1)*PIXEL_WIDTH_PAD-1:j*PIXEL_WIDTH_PAD] = {{(PIXEL_WIDTH_PAD-PIXEL_WIDTH){1'b0}},pure_data_in[(j+1)*PIXEL_WIDTH-1:j*PIXEL_WIDTH]};
      end else begin
        assign padded_data_out[(j+1)*PIXEL_WIDTH_PAD-1:j*PIXEL_WIDTH_PAD] = pure_data_in[(j+1)*PIXEL_WIDTH-1:j*PIXEL_WIDTH];
      end

    end

  endgenerate

endmodule

`default_nettype wire
