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
 * Module: intel_vvp_icon_scheduler
 *
 * Description: ICON scheduler
 *
 * ##################################################################################
*/

`default_nettype none

module intel_vvp_icon_scheduler (
  clk,
  rst,

  axi_st_ctrl_out_tvalid,
  axi_st_ctrl_out_tdata,
  axi_st_ctrl_out_tlast,
  axi_st_ctrl_out_tuser,
  axi_st_ctrl_out_tready
);

  import intel_vvp_icon_pkg::*;

  parameter   EXTERNAL_MODE  =  0;
  parameter   BPS            =  10;
  parameter   ICON_WIDTH     =  100;
  parameter   ICON_HEIGHT    =  100;

  localparam  USER_WIDTH           =  (VVP_CTRL_WIDTH + 7) / 8;
  localparam  LINE_COUNT_LESS_TWO  =  ICON_HEIGHT - 2;
  localparam  LINE_COUNT_WIDTH     =  vvp_num_bits(LINE_COUNT_LESS_TWO) + 1;

  input    wire                             clk;
  input    wire                             rst;

  output   wire                             axi_st_ctrl_out_tvalid;
  output   wire  [VVP_CTRL_WIDTH - 1 : 0]   axi_st_ctrl_out_tdata; 
  output   wire                             axi_st_ctrl_out_tlast;
  output   wire  [USER_WIDTH - 1 : 0]       axi_st_ctrl_out_tuser;
  input    wire                             axi_st_ctrl_out_tready;

  enum  logic [1 : 0]  {  IDLE,
                          SEND_IIP,
                          SEND_TOKENS,
                          SEND_EOF
                       }  state, state_nxt;

  reg   [LINE_COUNT_WIDTH - 1 : 0]    line_count;
  reg                                 first_line;
  reg                                 ctrl_out_valid;

  logic                               ctrl_out_last;
  logic [VVP_USER_KEEP_BITS - 1 : 0]  ctrl_out_user;
  logic [VVP_CTRL_WIDTH - 1 :0]       ctrl_out_data;
  logic [1 : 0]                       iip_track;
  logic                               eof_done;

  wire                                ctrl_out_ready;

  intel_vvp_icon_axi_master # (
    .DATA_WIDTH          (VVP_CTRL_WIDTH),
    .IS_TOKEN_INTERFACE  (0),
    .PIPELINE_READY      (0)
  ) ctrl_master_inst (  
    .clk                 (clk),
    .rst                 (rst),
    .din_valid           (ctrl_out_valid),
    .din_data            (ctrl_out_data),
    .din_user            (ctrl_out_user),
    .din_last            (ctrl_out_last),
    .din_ready           (ctrl_out_ready),
    .axi_st_dout_tvalid  (axi_st_ctrl_out_tvalid),
    .axi_st_dout_tdata   (axi_st_ctrl_out_tdata),
    .axi_st_dout_tuser   (axi_st_ctrl_out_tuser),
    .axi_st_dout_tlast   (axi_st_ctrl_out_tlast),
    .axi_st_dout_tready  (axi_st_ctrl_out_tready)
  );

  always @ (*) begin
    state_nxt = state;
    case(state)
      IDLE        : begin
                      state_nxt = (EXTERNAL_MODE > 0) ? SEND_TOKENS : SEND_IIP;
                    end
      SEND_IIP    : begin
                      if ((&iip_track) && ctrl_out_ready) begin
                        state_nxt = SEND_TOKENS;
                      end
                    end
      SEND_TOKENS : begin
                      if (line_count[LINE_COUNT_WIDTH-1] && ctrl_out_ready) begin
                        state_nxt = (EXTERNAL_MODE > 0) ? IDLE : SEND_EOF;
                      end
                    end
      default     : begin
                      if (eof_done && ctrl_out_ready) begin
                        state_nxt = IDLE;
                      end
                    end
    endcase
  end

  always @ (posedge clk) begin
    if (rst) begin
      state           <= IDLE;
      ctrl_out_valid  <= 1'b0;
    end else begin
      state   <= state_nxt;
      if (ctrl_out_ready) begin
        ctrl_out_valid  <= (state != IDLE);
      end
    end
  end

  generate
    if (EXTERNAL_MODE > 0) begin
      always @ (posedge clk) begin
        if (state == IDLE) begin
          line_count <= LINE_COUNT_LESS_TWO[LINE_COUNT_WIDTH-1:0];
          first_line <= 1'b1;
        end else begin
          if (ctrl_out_ready) begin
            line_count <= line_count + {LINE_COUNT_WIDTH{1'b1}};
            first_line <= 1'b0;
          end
        end
        if (ctrl_out_ready) begin
          ctrl_out_user <= {{USER_WIDTH-1{1'b0}},first_line};
        end
      end

      assign ctrl_out_data = {VVP_CTRL_WIDTH{1'b0}};
      assign ctrl_out_last = 1'b1;
      assign eof_done = 1'b0;
      assign iip_track = 2'b00;

    end else begin

      localparam  BPS_LESS_ONE         =  BPS - 1;
      localparam  LOCAL_TWO_CONST      =  2;
      localparam  WIDTH_LESS_ONE       =  ICON_WIDTH - 1;
      localparam  HEIGHT_LESS_ONE      =  ICON_HEIGHT - 1;
      localparam  CS_SS_OUTPUT         =  BPS_LESS_ONE | (VVP_IP_SUBSA_444 << VVP_IP_BPS_W) | (VVP_IP_COSITE_TL << (VVP_IP_BPS_W + VVP_IP_SUBSA_W)) | (VVP_IP_COLSPACE_RGB << (VVP_IP_BPS_W + VVP_IP_SUBSA_W + VVP_IP_COSITE_W));
      localparam  EOF_HEADER_OUTPUT    =  VVP_CTRL_PKT_EOF;

      reg            ctrl_header;

      always @ (posedge clk) begin
        if (state == IDLE) begin
          iip_track <= 2'b00;
        end else begin
          if (ctrl_out_ready) begin
            iip_track <= iip_track + 2'b01;
          end
        end
        if (state == SEND_IIP) begin
          line_count <= LINE_COUNT_LESS_TWO[LINE_COUNT_WIDTH-1:0];
          first_line <= 1'b1;
        end else begin
          if (ctrl_out_ready) begin
            line_count <= line_count + {LINE_COUNT_WIDTH{1'b1}};
            first_line <= 1'b0;
          end
        end
        if (state == SEND_TOKENS) begin
          eof_done <= 1'b0;
        end else begin
          if (ctrl_out_ready) begin
            eof_done <= 1'b1;
          end
        end
        if ((state == SEND_TOKENS) || (state == IDLE)) begin
          ctrl_header <= 1'b1;
        end else begin
          if (ctrl_out_ready) begin
            ctrl_header <= 1'b0;
          end
        end
        if (ctrl_out_ready) begin
          ctrl_out_last <= ((state == SEND_IIP) && (&iip_track))|| (state == SEND_TOKENS) || ((state == SEND_EOF) && eof_done);
          if (state == SEND_TOKENS) begin
            ctrl_out_user <= {{USER_WIDTH-1{1'b0}},first_line};
          end else begin
            if (ctrl_header) begin
              ctrl_out_user <= LOCAL_TWO_CONST[USER_WIDTH-1:0];
            end else begin
              ctrl_out_user <= {USER_WIDTH{1'b0}};
            end
          end
          if (state == SEND_IIP) begin
            case (iip_track)
              2'b00    :  ctrl_out_data <= {{VVP_CTRL_WIDTH-(VVP_CTRL_PKT_TYPE_W+VVP_IP_INTLACE_W){1'b0}},VVP_IP_PROGRESSIVE_NATIVE_0,VVP_CTRL_PKT_IP};
              2'b01    :  ctrl_out_data <= WIDTH_LESS_ONE[VVP_CTRL_WIDTH-1:0];
              2'b10    :  ctrl_out_data <= HEIGHT_LESS_ONE[VVP_CTRL_WIDTH-1:0];
              default  :  ctrl_out_data <= {VVP_IP_COLSPACE_RGB,VVP_IP_COSITE_TL,VVP_IP_SUBSA_444,BPS_LESS_ONE[VVP_IP_BPS_W-1:0]};
            endcase
          end else begin
            if (eof_done) begin
              ctrl_out_data <= {VVP_CTRL_WIDTH{1'b0}};
            end else begin
              ctrl_out_data <= {{VVP_CTRL_WIDTH-VVP_CTRL_PKT_TYPE_W{1'b0}},VVP_CTRL_PKT_EOF};
            end
          end
        end
      end

    end

  endgenerate

endmodule

`default_nettype wire
