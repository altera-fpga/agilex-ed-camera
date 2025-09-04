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
 * Module: intel_vvp_icon_algo_cmp
 *
 * Description: AXI master pipeline stage
 *
 * ##################################################################################
*/

`default_nettype none

module intel_vvp_icon_algo_comp (
  clk,
  rst,

  axi_st_data_out_tvalid,
  axi_st_data_out_tready,
  axi_st_data_out_tlast,
  axi_st_data_out_tuser,
  axi_st_data_out_tdata
);

  import intel_vvp_icon_pkg::*;

  parameter   BPS                     =  8;
  parameter   PIXELS_IN_PARALLEL      =  1;
  parameter   ICON_WIDTH              =  128;
  parameter   ICON_HEIGHT             =  128;
  parameter   DEVICE_FAMILY           =  "Stratix_10";

  localparam  NUMBER_OF_COLOR_PLANES  =  3;
  localparam  MEM_BPS                 =  8;
  localparam  MEM_LATENCY             =  2;
  localparam  PIXEL_WIDTH             =  NUMBER_OF_COLOR_PLANES * BPS;
  localparam  PIXEL_BYTES             =  (PIXEL_WIDTH < VVP_CTRL_WIDTH) ? (VVP_CTRL_WIDTH+7)/8 : (PIXEL_WIDTH+7)/8;
  localparam  USER_WIDTH              =  PIXEL_BYTES * PIXELS_IN_PARALLEL;
  localparam  DATA_WIDTH              =  USER_WIDTH * 8;
  localparam  DATA_WIDTH_INTERNAL     =  PIXEL_WIDTH * PIXELS_IN_PARALLEL;
  localparam  MEM_PIXEL_WIDTH         =  MEM_BPS * NUMBER_OF_COLOR_PLANES;
  localparam  MEM_WIDTH               =  MEM_PIXEL_WIDTH * PIXELS_IN_PARALLEL;
  localparam  MEM_WORDS               =  ((ICON_WIDTH + PIXELS_IN_PARALLEL - 1) / PIXELS_IN_PARALLEL) * ICON_HEIGHT;
  localparam  MEM_ADDR_W              =  vvp_clog2(MEM_WORDS);
  localparam  MIF_FILE_1_PIP          =  "../intel_vvp_icon_altera_1_pip.mif";
  localparam  MIF_FILE_2_PIP          =  "../intel_vvp_icon_altera_2_pip.mif";
  localparam  MIF_FILE_4_PIP          =  "../intel_vvp_icon_altera_4_pip.mif";
  localparam  MIF_FILE_8_PIP          =  "../intel_vvp_icon_altera_8_pip.mif";
  localparam  MIF_FILE_FINAL          =  (PIXELS_IN_PARALLEL == 8) ? MIF_FILE_8_PIP : (PIXELS_IN_PARALLEL == 4) ? MIF_FILE_4_PIP : (PIXELS_IN_PARALLEL == 2) ? MIF_FILE_2_PIP : MIF_FILE_1_PIP;
  localparam  LOCAL_ONE_CONST         =  1;
  localparam  ICON_WIDTH_MINUS_TWO    =  ICON_WIDTH - PIXELS_IN_PARALLEL - 1;
  localparam  ICON_HEIGHT_MINUS_TWO   =  ICON_HEIGHT - 2;
  localparam  PIX_COUNT_W             =  vvp_num_bits(ICON_WIDTH_MINUS_TWO) + 1;
  localparam  LINE_COUNT_W            =  vvp_num_bits(ICON_HEIGHT_MINUS_TWO) + 1;

  input    wire                       clk;
  input    wire                       rst;

  output   wire                       axi_st_data_out_tvalid;
  input    wire                       axi_st_data_out_tready;
  output   wire                       axi_st_data_out_tlast;
  output   wire  [USER_WIDTH - 1 : 0] axi_st_data_out_tuser;
  output   wire  [DATA_WIDTH - 1 : 0] axi_st_data_out_tdata;

  enum  logic [1 : 0]  {  IDLE,
                          RUN_LINE,
                          CHECK_EOF
                       } state, state_nxt;

  reg   [MEM_ADDR_W - 1 : 0]          mem_address;
  reg   [PIX_COUNT_W - 1 : 0]         pix_count;
  reg   [LINE_COUNT_W - 1 : 0]        line_count;
  reg                                 sof_marker;
  reg   [MEM_LATENCY - 1 : 0]         dout_valid;
  reg   [MEM_LATENCY - 1 : 0]         dout_last;
  reg   [VVP_USER_KEEP_BITS - 1 : 0]  dout_user      [0 : MEM_LATENCY - 1];

  wire                                dout_ready;
  wire  [MEM_WIDTH - 1 : 0]           mem_data;
  wire  [DATA_WIDTH_INTERNAL - 1 : 0] mem_data_pad;
  wire  [DATA_WIDTH - 1 : 0]          dout_data;
  wire  [USER_WIDTH - 1 : 0]          dout_user_pad;

  //memory to hold the icon
  altera_syncram # (
    .ram_block_type         ("M20K"),
    .address_aclr_a         ("NONE"),
    .clock_enable_input_a   ("BYPASS"),
    .clock_enable_output_a  ("NORMAL"),
    .init_file              (MIF_FILE_FINAL),
    .intended_device_family (DEVICE_FAMILY),
    .lpm_hint               ("ENABLE_RUNTIME_MOD=NO"),
    .lpm_type               ("altera_syncram"),
    .numwords_a             (MEM_WORDS),
    .operation_mode         ("ROM"),
    .outdata_aclr_a         ("NONE"),
    .outdata_sclr_a         ("NONE"),
    .outdata_reg_a          ("CLOCK0"),
    .enable_force_to_zero   ("FALSE"),
    .widthad_a              (MEM_ADDR_W),
    .width_a                (MEM_WIDTH),
    .width_byteena_a        (1)
  ) coeff_rom_inst (
    .address_a              (mem_address),
    .clock0                 (clk),
    .q_a                    (mem_data),
    .aclr0                  (1'b0),
    .aclr1                  (1'b0),
    .address2_a             (1'b1),
    .address2_b             (1'b1),
    .address_b              (1'b1),
    .addressstall_a         (~dout_ready),
    .addressstall_b         (1'b0),
    .byteena_a              (1'b1),
    .byteena_b              (1'b1),
    .clock1                 (1'b1),
    .clocken0               (dout_ready),
    .clocken1               (1'b1),
    .clocken2               (1'b1),
    .clocken3               (1'b1),
    .data_a                 ({MEM_WIDTH{1'b1}}),
    .data_b                 (1'b1),
    .eccencbypass           (1'b0),
    .eccencparity           (8'b0),
    .eccstatus              (),
    .q_b                    (),
    .rden_a                 (1'b1),
    .rden_b                 (1'b1),
    .sclr                   (1'b0),
    .wren_a                 (1'b0),
    .wren_b                 (1'b0)
  );

  //pad up with zeros to byte align the pixels (if necessary)
  intel_vvp_icon_axi_zero_pad # (
    .BPS                    (BPS),
    .NUMBER_OF_COLOR_PLANES (NUMBER_OF_COLOR_PLANES),
    .PIXELS_IN_PARALLEL     (PIXELS_IN_PARALLEL)
  ) pad_inst (
    .pure_data_in           (mem_data_pad),
    .pure_user_in           (dout_user[MEM_LATENCY-1]),
    .padded_data_out        (dout_data),
    .padded_user_out        (dout_user_pad)
  );

  intel_vvp_icon_axi_master # (
    .DATA_WIDTH          (DATA_WIDTH),
    .IS_TOKEN_INTERFACE  (0),
    .PIPELINE_READY      (0)
  ) dout_master_inst (
    .clk                 (clk),
    .rst                 (rst),
    .din_valid           (dout_valid[MEM_LATENCY-1]),
    .din_data            (dout_data),
    .din_user            (dout_user_pad),
    .din_last            (dout_last[MEM_LATENCY-1]),
    .din_ready           (dout_ready),
    .axi_st_dout_tvalid  (axi_st_data_out_tvalid),
    .axi_st_dout_tdata   (axi_st_data_out_tdata),
    .axi_st_dout_tuser   (axi_st_data_out_tuser),
    .axi_st_dout_tlast   (axi_st_data_out_tlast),
    .axi_st_dout_tready  (axi_st_data_out_tready)
  );

  always @ (posedge clk) begin
    if (rst) begin
      state <= IDLE;
      dout_valid <= {MEM_LATENCY{1'b0}};
    end else begin
      state <= state_nxt;
      if (dout_ready) begin
        for (int i=0; i<MEM_LATENCY; i=i+1) begin
          if (i==0) begin
            dout_valid[i] <= (state == RUN_LINE);
          end else begin
            dout_valid[i] <= dout_valid[i-1];
          end
        end
      end
    end
  end

  always @ (posedge clk) begin
    if (dout_ready) begin
      for (int i=0; i<MEM_LATENCY; i=i+1) begin
        if (i==0) begin
          dout_last[i] <= pix_count[PIX_COUNT_W-1];
          dout_user[i] <= {{VVP_USER_KEEP_BITS-1{1'b0}},sof_marker};
        end else begin
          dout_last[i] <= dout_last[i-1];
          dout_user[i] <= dout_user[i-1];
        end
      end
    end
    if (state == RUN_LINE) begin
      if (dout_ready) begin
        pix_count <= pix_count - PIXELS_IN_PARALLEL[PIX_COUNT_W-1:0];
      end
    end else begin
      pix_count <= ICON_WIDTH_MINUS_TWO[PIX_COUNT_W-1:0];
    end
    if (state == IDLE) begin
      line_count <= ICON_HEIGHT_MINUS_TWO[LINE_COUNT_W-1:0];
      sof_marker <= 1'b1;
      mem_address <= {MEM_ADDR_W{1'b0}};
    end else begin
      if (state == CHECK_EOF) begin
        line_count <= line_count + {LINE_COUNT_W{1'b1}};
      end
      if (dout_ready) begin
        sof_marker <= 1'b0;
      end
      if (state == RUN_LINE) begin
        if (dout_ready) begin
          mem_address <= mem_address + LOCAL_ONE_CONST[MEM_ADDR_W-1:0];
        end
      end
    end
  end

  always @ (*) begin
    state_nxt = state;
    case (state)
      IDLE        : begin
                      state_nxt = RUN_LINE;
                    end
      RUN_LINE    : begin
                      if (dout_ready && pix_count[PIX_COUNT_W-1]) begin
                        state_nxt = CHECK_EOF;
                      end
                    end
      default     : begin
                      if (line_count[LINE_COUNT_W-1]) begin
                        state_nxt = IDLE;
                      end else begin
                        state_nxt = RUN_LINE;
                      end
                    end
      endcase
  end

  genvar j, k;
  generate

    for (j=0; j<PIXELS_IN_PARALLEL; j=j+1) begin :  pip_gen
      for (k=0; k<NUMBER_OF_COLOR_PLANES; k=k+1) begin   :  cp_gen
        if (MEM_BPS < BPS) begin
          assign mem_data_pad[j*PIXEL_WIDTH+(k+1)*BPS-1:j*PIXEL_WIDTH+k*BPS] = {mem_data[j*MEM_PIXEL_WIDTH+(k+1)*MEM_BPS-1:j*MEM_PIXEL_WIDTH+k*MEM_BPS],{BPS-MEM_BPS{1'b0}}};
        end else begin
          assign mem_data_pad = mem_data;
        end
      end
    end

  endgenerate

endmodule

`default_nettype wire
