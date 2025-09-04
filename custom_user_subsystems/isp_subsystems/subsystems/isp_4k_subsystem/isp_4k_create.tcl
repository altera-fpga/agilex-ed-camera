###################################################################################
# Copyright (C) 2025 Altera Corporation
#
# This software and the related documents are Altera copyrighted materials, and
# your use of them is governed by the express license under which they were
# provided to you ("License"). Unless the License provides otherwise, you may
# not use, modify, copy, publish, distribute, disclose or transmit this software
# or the related documents without Altera's prior written permission.
#
# This software and the related documents are provided as is, with no express
# or implied warranties, other than those that are expressly stated in the License.
###################################################################################

set_shell_parameter AVMM_HOST               {{AUTO X}}

set_shell_parameter ASYNC_CLK               {0}

# General Video Controls
set_shell_parameter PIP                     {2}
set_shell_parameter VID_OUT_RATE            "p60"
set_shell_parameter VID_OUT_BPS             {10}
set_shell_parameter EN_DEBUG                {1}

# HDR Controls
set_shell_parameter EXP_FUSION_EN           {1}
set_shell_parameter HDR_EN                  {1}

# Warp Controls
set_shell_parameter NO_WARP                 {0}
set_shell_parameter WARP_SB                 {0}
set_shell_parameter WARP_MM                 {1}
set_shell_parameter WARP_CACHE              {512}

# AI Controls
set_shell_parameter AI_EN                   {0}
set_shell_parameter EASY_SCALE_UP           {1}

# 3D LUT Controls.
set_shell_parameter SMALL_3DLUT             {0}
set_shell_parameter LUT_PIP_SHARING_EN      {0}
set_shell_parameter LUT_DOUBLE_BUFFERED_EN  {0}
# Enable to preload a default cube file
set_shell_parameter PRESET_FILE_3DLUT_EN    {0}
# For HDR this would be a sRGB to HLG function
set_shell_parameter PRESET_FILE_3DLUT_0_0   {}
set_shell_parameter PRESET_FILE_3DLUT_0_1   {}
# For HDR this would be a HLG to BT709 function
set_shell_parameter PRESET_FILE_3DLUT_1_0   {}
set_shell_parameter PRESET_FILE_3DLUT_1_1   {}



proc pre_creation_step {} {
    transfer_files
    evaluate_terp
}

proc creation_step {} {
    create_isp_subsystem
}

proc post_creation_step {} {
    edit_top_level_qsys
    add_auto_connections
}

proc post_connection_step {} {
    modify_avmm_arbitration
}


proc transfer_files {} {
    set v_project_path              [get_shell_parameter PROJECT_PATH]
    set v_instance_name             [get_shell_parameter INSTANCE_NAME]
    set v_script_path               [get_shell_parameter SUBSYSTEM_SOURCE_PATH]
    set v_lut_double_buffered_en    [get_shell_parameter LUT_DOUBLE_BUFFERED_EN]
    set v_3d_lut_preset_file_en     [get_shell_parameter PRESET_FILE_3DLUT_EN]
    set v_3d_lut_0_0_preset_file    [get_shell_parameter PRESET_FILE_3DLUT_0_0]
    set v_3d_lut_0_1_preset_file    [get_shell_parameter PRESET_FILE_3DLUT_0_1]
    set v_3d_lut_1_0_preset_file    [get_shell_parameter PRESET_FILE_3DLUT_1_0]
    set v_3d_lut_1_1_preset_file    [get_shell_parameter PRESET_FILE_3DLUT_1_1]

    # Copy Icon
    exec cp -rf ${v_script_path}/../../non_qpds_ip/intel_vvp_icon \
                                                      ${v_project_path}/non_qpds_ip/user/intel_vvp_icon
    file_copy   ${v_script_path}/../../non_qpds_ip/intel_vvp_icon.ipx     ${v_project_path}/non_qpds_ip/user

    # 3D LUT Init Files
    if {${v_3d_lut_preset_file_en}} {
        file_copy ${v_script_path}/${v_3d_lut_0_0_preset_file} \
                                              ${v_project_path}/non_qpds_ip/user/${v_3d_lut_0_0_preset_file}
        file_copy ${v_script_path}/${v_3d_lut_1_0_preset_file} \
                                              ${v_project_path}/non_qpds_ip/user/${v_3d_lut_1_0_preset_file}
        if {${v_lut_double_buffered_en}} {
            file_copy ${v_script_path}/${v_3d_lut_0_1_preset_file} \
                                                  ${v_project_path}/non_qpds_ip/user/${v_3d_lut_0_1_preset_file}
            file_copy ${v_script_path}/${v_3d_lut_1_1_preset_file} \
                                                  ${v_project_path}/non_qpds_ip/user/${v_3d_lut_1_1_preset_file}
        }
        file_copy ${v_script_path}/3D_LUT_preset_script.tcl.terp \
                                              ${v_project_path}/quartus/user/${v_instance_name}_script.tcl.terp
        file_copy ${v_script_path}/3D_LUT_subsystem.qsf.terp \
                                              ${v_project_path}/quartus/user/${v_instance_name}.qsf.terp
    }
}


proc evaluate_terp {} {
    set v_project_name              [get_shell_parameter PROJECT_NAME]
    set v_project_path              [get_shell_parameter PROJECT_PATH]
    set v_instance_name             [get_shell_parameter INSTANCE_NAME]
    set v_lut_double_buffered_en    [get_shell_parameter LUT_DOUBLE_BUFFERED_EN]
    set v_3d_lut_preset_file_en     [get_shell_parameter PRESET_FILE_3DLUT_EN]
    set v_3d_lut_0_0_preset_file    [get_shell_parameter PRESET_FILE_3DLUT_0_0]
    set v_3d_lut_0_1_preset_file    [get_shell_parameter PRESET_FILE_3DLUT_0_1]
    set v_3d_lut_1_0_preset_file    [get_shell_parameter PRESET_FILE_3DLUT_1_0]
    set v_3d_lut_1_1_preset_file    [get_shell_parameter PRESET_FILE_3DLUT_1_1]

    # 3D LUT Init Files
    if {${v_3d_lut_preset_file_en}} {
        evaluate_terp_file  ${v_project_path}/quartus/user/${v_instance_name}_script.tcl.terp \
            [list ${v_project_name} ${v_instance_name} ${v_3d_lut_0_0_preset_file} ${v_3d_lut_1_0_preset_file}] 0 1
        if {${v_lut_double_buffered_en}} {
            evaluate_terp_file  ${v_project_path}/quartus/user/${v_instance_name}_script.tcl.terp \
            [list ${v_project_name} ${v_instance_name} ${v_3d_lut_0_1_preset_file} ${v_3d_lut_1_1_preset_file}] 0 1
        }
        evaluate_terp_file  ${v_project_path}/quartus/user/${v_instance_name}.qsf.terp \
            [list ${v_instance_name}] 0 1
    }
}


proc create_isp_subsystem {} {
    set v_project_path            [get_shell_parameter PROJECT_PATH]
    set v_instance_name           [get_shell_parameter INSTANCE_NAME]

    # Video Pipeline
    set v_cppp                    {3}
    set v_vid_out_rate            [get_shell_parameter VID_OUT_RATE]
    set v_vid_out_bps             [get_shell_parameter VID_OUT_BPS]
    set v_pip                     [get_shell_parameter PIP]

    # Warp
    if {${v_pip} > 1} {
        set v_num_warp_engines      {2}
    } else {
        set v_num_warp_engines      {1}
    }
    set v_warp_debug              [get_shell_parameter EN_DEBUG]
    set v_warp_single_bounce      [get_shell_parameter WARP_SB]
    set v_warp_mipmap_enable      [get_shell_parameter WARP_MM]
    set v_warp_cache_blocks       [get_shell_parameter WARP_CACHE]

    # HDR
    set v_exp_fusion_en           [get_shell_parameter EXP_FUSION_EN]
    set v_hdr_en                  [get_shell_parameter HDR_EN]

    # ISP Pipeline
    set v_isp_cppp                {1}
    if {${v_exp_fusion_en}} {
        set v_isp_bps               {16}
        set v_isp_bps_cut           {14}
    } else {
        set v_isp_bps               {12}
        set v_isp_bps_cut           {12}
    }
    set v_tmo_bps                 {12}
    set v_usm_bps                 {10}
    set v_small_vc                {1}

    # Replace Warp with VVP Video Frame Buffer
    set v_no_warp                 [get_shell_parameter NO_WARP]

    # 3D LUT
    set v_small_3d_lut            [get_shell_parameter SMALL_3DLUT]
    set v_lut_pip_sharing_en      [get_shell_parameter LUT_PIP_SHARING_EN]
    set v_lut_double_buffered_en  [get_shell_parameter LUT_DOUBLE_BUFFERED_EN]
    set v_3d_lut_preset_file_en   [get_shell_parameter PRESET_FILE_3DLUT_EN]
    set v_3d_lut_0_0_preset_file  [get_shell_parameter PRESET_FILE_3DLUT_0_0]
    set v_3d_lut_0_1_preset_file  [get_shell_parameter PRESET_FILE_3DLUT_0_1]
    set v_3d_lut_1_0_preset_file  [get_shell_parameter PRESET_FILE_3DLUT_1_0]
    set v_3d_lut_1_1_preset_file  [get_shell_parameter PRESET_FILE_3DLUT_1_1]

    # AI Pipeline
    set v_ai_en                   [get_shell_parameter AI_EN]

    # General
    set v_enable_debug            [get_shell_parameter EN_DEBUG]
    set v_pipeline_ready          {1}

    # Switch Mode - Crash when ASYNC_IP_SW = 1, else Sync Switch on SOF with SYNC_IP_SW = 1, else on EOL
    set v_wbs_async_ip_sw         {0}
    set v_wbs_sync_ip_sw          {1}
    set v_raw_async_ip_sw         {1}
    set v_raw_sync_ip_sw          {1}
    set v_cap_async_ip_sw         {1}
    set v_cap_sync_ip_sw          {1}


    create_system ${v_instance_name}
    save_system   ${v_project_path}/rtl/user/${v_instance_name}.qsys

    load_system   ${v_project_path}/rtl/user/${v_instance_name}.qsys


    ############################
    #### Add Instances      ####
    ############################

    add_instance  isp_cpu_clk_bridge        altera_clock_bridge
    add_instance  isp_cpu_rst_bridge        altera_reset_bridge
    add_instance  isp_vid_clk_bridge        altera_clock_bridge
    add_instance  isp_vid_rst_bridge        altera_reset_bridge
    add_instance  isp_niosv_clk_bridge      altera_clock_bridge
    add_instance  isp_niosv_rst_bridge      altera_reset_bridge
    add_instance  isp_emif_clk_bridge       altera_clock_bridge
    add_instance  isp_emif_rst_bridge       altera_reset_bridge
    add_instance  isp_mm_bridge             altera_avalon_mm_bridge
    add_instance  isp_bls                   intel_vvp_bls
    add_instance  isp_clipper               intel_vvp_clipper
    add_instance  isp_switch_raw_cap        intel_vvp_switch
    add_instance  isp_cpm                   intel_vvp_cpm
    add_instance  isp_dpc                   intel_vvp_dpc
    add_instance  isp_anr                   intel_vvp_anr
    add_instance  isp_blc                   intel_vvp_blc
    add_instance  isp_vc                    intel_vvp_vc
    add_instance  isp_switch_wbs            intel_vvp_switch
    add_instance  isp_wbc                   intel_vvp_wbc
    add_instance  isp_wbs                   intel_vvp_wbs
    add_instance  isp_dms                   intel_vvp_demosaic
    add_instance  isp_hs                    intel_vvp_hs
    add_instance  isp_ccm                   intel_vvp_csc
    if {${v_hdr_en}} {
        add_instance  isp_1d_lut_hdr          intel_vvp_1d_lut
        add_instance  isp_3d_lut_hdr_1        intel_vvp_3d_lut
    }
    add_instance  isp_3d_lut_hdr_2          intel_vvp_3d_lut
    add_instance  isp_tmo                   intel_vvp_tmo
    add_instance  isp_pix_adapt_tmo         intel_vvp_pixel_adapter
    add_instance  isp_usm                   intel_vvp_usm
    if {${v_ai_en} == 0} {
        if {${v_no_warp}} {
            add_instance  isp_vfb               intel_vvp_vfb
        } else {
            add_instance  isp_warp              intel_vvp_warp
        }
        add_instance  isp_se_warp             altera_address_span_extender
    }
    add_instance  isp_tpg                   intel_vvp_tpg
    add_instance  isp_icon                  intel_vvp_icon
    add_instance  isp_mixer                 intel_vvp_mixer
    add_instance  isp_1d_lut                intel_vvp_1d_lut
    add_instance  isp_switch_cap            intel_vvp_switch
    add_instance  isp_pix_adapt_out          intel_vvp_pixel_adapter
    add_instance  isp_vfw                   intel_vvp_vfw
    add_instance  isp_se_vfw                altera_address_span_extender


    ############################
    #### Set Parameters     ####
    ############################

    # isp_cpu_clk_bridge
    set_instance_parameter_value      isp_cpu_clk_bridge    EXPLICIT_CLOCK_RATE       {200000000.0}
    set_instance_parameter_value      isp_cpu_clk_bridge    NUM_CLOCK_OUTPUTS         {1}

    # isp_cpu_rst_bridge
    set_instance_parameter_value      isp_cpu_rst_bridge    ACTIVE_LOW_RESET          {0}
    set_instance_parameter_value      isp_cpu_rst_bridge    NUM_RESET_OUTPUTS         {1}
    set_instance_parameter_value      isp_cpu_rst_bridge    SYNCHRONOUS_EDGES         {deassert}
    set_instance_parameter_value      isp_cpu_rst_bridge    SYNC_RESET                {0}
    set_instance_parameter_value      isp_cpu_rst_bridge    USE_RESET_REQUEST         {0}

    # isp_mm_bridge
    set_instance_parameter_value      isp_mm_bridge       ADDRESS_UNITS                 {SYMBOLS}
    set_instance_parameter_value      isp_mm_bridge       ADDRESS_WIDTH                 {0}
    set_instance_parameter_value      isp_mm_bridge       DATA_WIDTH                    {32}
    set_instance_parameter_value      isp_mm_bridge       LINEWRAPBURSTS                {0}
    set_instance_parameter_value      isp_mm_bridge       M0_WAITREQUEST_ALLOWANCE      {0}
    set_instance_parameter_value      isp_mm_bridge       MAX_BURST_SIZE                {1}
    set_instance_parameter_value      isp_mm_bridge       MAX_PENDING_RESPONSES         {4}
    set_instance_parameter_value      isp_mm_bridge       MAX_PENDING_WRITES            {0}
    set_instance_parameter_value      isp_mm_bridge       PIPELINE_COMMAND              {1}
    set_instance_parameter_value      isp_mm_bridge       PIPELINE_RESPONSE             {1}
    set_instance_parameter_value      isp_mm_bridge       S0_WAITREQUEST_ALLOWANCE      {0}
    set_instance_parameter_value      isp_mm_bridge       SYMBOL_WIDTH                  {8}
    set_instance_parameter_value      isp_mm_bridge       SYNC_RESET                    {0}
    set_instance_parameter_value      isp_mm_bridge       USE_AUTO_ADDRESS_WIDTH        {1}
    set_instance_parameter_value      isp_mm_bridge       USE_RESPONSE                  {0}
    set_instance_parameter_value      isp_mm_bridge       USE_WRITERESPONSE             {0}

    # isp_vid_clk_bridge
    if {(${v_vid_out_rate} == "p60") || (${v_pip} == 1)} {
        set_instance_parameter_value      isp_vid_clk_bridge    EXPLICIT_CLOCK_RATE     {297000000.0}
    } else {
        set_instance_parameter_value      isp_vid_clk_bridge    EXPLICIT_CLOCK_RATE     {148500000.0}
    }
    set_instance_parameter_value      isp_vid_clk_bridge      NUM_CLOCK_OUTPUTS       {1}

    # isp_vid_rst_bridge
    set_instance_parameter_value      isp_vid_rst_bridge      ACTIVE_LOW_RESET        {0}
    set_instance_parameter_value      isp_vid_rst_bridge      NUM_RESET_OUTPUTS       {1}
    set_instance_parameter_value      isp_vid_rst_bridge      SYNCHRONOUS_EDGES       {deassert}
    set_instance_parameter_value      isp_vid_rst_bridge      SYNC_RESET              {0}
    set_instance_parameter_value      isp_vid_rst_bridge      USE_RESET_REQUEST       {0}

    # isp_niosv_clk_bridge
    set_instance_parameter_value      isp_niosv_clk_bridge      EXPLICIT_CLOCK_RATE     {200000000.0}
    set_instance_parameter_value      isp_niosv_clk_bridge      NUM_CLOCK_OUTPUTS       {1}

    # isp_niosv_rst_bridge
    set_instance_parameter_value      isp_niosv_rst_bridge      ACTIVE_LOW_RESET        {0}
    set_instance_parameter_value      isp_niosv_rst_bridge      NUM_RESET_OUTPUTS       {1}
    set_instance_parameter_value      isp_niosv_rst_bridge      SYNCHRONOUS_EDGES       {deassert}
    set_instance_parameter_value      isp_niosv_rst_bridge      SYNC_RESET              {0}
    set_instance_parameter_value      isp_niosv_rst_bridge      USE_RESET_REQUEST       {0}

    # isp_emif_clk_bridge
    set_instance_parameter_value      isp_emif_clk_bridge     EXPLICIT_CLOCK_RATE       {200000000.0}
    set_instance_parameter_value      isp_emif_clk_bridge     NUM_CLOCK_OUTPUTS         {1}

    # isp_emif_rst_bridge
    set_instance_parameter_value      isp_emif_rst_bridge     ACTIVE_LOW_RESET          {1}
    set_instance_parameter_value      isp_emif_rst_bridge     NUM_RESET_OUTPUTS         {1}
    set_instance_parameter_value      isp_emif_rst_bridge     SYNCHRONOUS_EDGES         {deassert}
    set_instance_parameter_value      isp_emif_rst_bridge     SYNC_RESET                {0}
    set_instance_parameter_value      isp_emif_rst_bridge     USE_RESET_REQUEST         {0}

    # isp_bls
    set_instance_parameter_value      isp_bls       AV_MAX_PENDING_READS          {8}
    set_instance_parameter_value      isp_bls       BPS                           ${v_isp_bps}
    set_instance_parameter_value      isp_bls       C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_bls       C_OMNI_CAP_ID_COMPONENT       {0}
    set_instance_parameter_value      isp_bls       C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_bls       C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_bls       C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_bls       C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_bls       C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_bls       C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_bls       C_OMNI_CAP_TYPE               {372}
    set_instance_parameter_value      isp_bls       C_OMNI_CAP_VERSION            {1}
    set_instance_parameter_value      isp_bls       DUPLICATE_AND_BYPASS          {1}
    set_instance_parameter_value      isp_bls       ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value      isp_bls       ENABLE_EXT_DATA_RW            {0}
    set_instance_parameter_value      isp_bls       EXTERNAL_MODE                 {1}
    set_instance_parameter_value      isp_bls       H_TAPS                        {1}
    set_instance_parameter_value      isp_bls       MAX_HEIGHT                    {4096}
    set_instance_parameter_value      isp_bls       MAX_WIDTH                     {4096}
    set_instance_parameter_value      isp_bls       NO_BLANKING                   {1}
    set_instance_parameter_value      isp_bls       NUMBER_OF_COLOR_PLANES        ${v_isp_cppp}
    set_instance_parameter_value      isp_bls       NUM_EXT_DATA_REGS             {0}
    set_instance_parameter_value      isp_bls       PIPELINE_DATA_MM              {0}
    set_instance_parameter_value      isp_bls       PIPELINE_READY                ${v_pipeline_ready}
    set_instance_parameter_value      isp_bls       PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_bls       P_CORE_CTRL_ID                {0}
    set_instance_parameter_value      isp_bls       P_UPDATE_CMD_SUPPORTED        {0}
    set_instance_parameter_value      isp_bls       RUNTIME_CONTROL               {1}
    set_instance_parameter_value      isp_bls       SEPARATE_SLAVE_CLOCK          {1}
    set_instance_parameter_value      isp_bls       SLAVE_PROTOCOL                {Avalon}
    set_instance_parameter_value      isp_bls       V_TAPS                        {1}

    # isp_clipper
    set_instance_parameter_value      isp_clipper       BOTTOM_OFFSET                 {0}
    set_instance_parameter_value      isp_clipper       BPS                           ${v_isp_bps}
    set_instance_parameter_value      isp_clipper       CLIPPING_METHOD               {OFFSETS}
    set_instance_parameter_value      isp_clipper       C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_clipper       C_OMNI_CAP_ID_COMPONENT       {0}
    set_instance_parameter_value      isp_clipper       C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_clipper       C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_clipper       C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_clipper       C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_clipper       C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_clipper       C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_clipper       C_OMNI_CAP_TYPE               {557}
    set_instance_parameter_value      isp_clipper       C_OMNI_CAP_VERSION            {1}
    set_instance_parameter_value      isp_clipper       ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value      isp_clipper       EXTERNAL_MODE                 {1}
    set_instance_parameter_value      isp_clipper       LEFT_OFFSET                   {0}
    set_instance_parameter_value      isp_clipper       NUMBER_OF_COLOR_PLANES        ${v_isp_cppp}
    set_instance_parameter_value      isp_clipper       PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_clipper       RECTANGLE_HEIGHT              {2160}
    set_instance_parameter_value      isp_clipper       RECTANGLE_WIDTH               {3840}
    set_instance_parameter_value      isp_clipper       RIGHT_OFFSET                  {0}
    set_instance_parameter_value      isp_clipper       RUNTIME_CONTROL               {0}
    set_instance_parameter_value      isp_clipper       SEPARATE_SLAVE_CLOCK          {1}
    set_instance_parameter_value      isp_clipper       SLAVE_PROTOCOL                {Avalon}
    set_instance_parameter_value      isp_clipper       TOP_OFFSET                    {0}

    # isp_switch_raw_cap
    set_instance_parameter_value      isp_switch_raw_cap       BPS                           ${v_isp_bps}
    set_instance_parameter_value      isp_switch_raw_cap       CRASH_SWITCH                  ${v_raw_async_ip_sw}
    set_instance_parameter_value      isp_switch_raw_cap       C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_switch_raw_cap       C_OMNI_CAP_ID_COMPONENT       {4}
    set_instance_parameter_value      isp_switch_raw_cap       C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_switch_raw_cap       C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_switch_raw_cap       C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_switch_raw_cap       C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_switch_raw_cap       C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_switch_raw_cap       C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_switch_raw_cap       C_OMNI_CAP_TYPE               {565}
    set_instance_parameter_value      isp_switch_raw_cap       C_OMNI_CAP_VERSION            {2}
    set_instance_parameter_value      isp_switch_raw_cap       ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value      isp_switch_raw_cap       EXTERNAL_MODE                 {0}
    set_instance_parameter_value      isp_switch_raw_cap       NUMBER_OF_COLOR_PLANES        ${v_isp_cppp}
    set_instance_parameter_value      isp_switch_raw_cap       NUM_INPUTS                    {1}
    set_instance_parameter_value      isp_switch_raw_cap       NUM_OUTPUTS                   {2}
    set_instance_parameter_value      isp_switch_raw_cap       PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_switch_raw_cap       SEPARATE_SLAVE_CLOCK          {1}
    set_instance_parameter_value      isp_switch_raw_cap       SLAVE_PROTOCOL                {Avalon}
    set_instance_parameter_value      isp_switch_raw_cap       UNINTERRUPTED_INPUTS          ${v_raw_sync_ip_sw}
    set_instance_parameter_value      isp_switch_raw_cap       USE_OP_RESP                   {0}
    set_instance_parameter_value      isp_switch_raw_cap       USE_TREADIES                  {1}
    set_instance_parameter_value      isp_switch_raw_cap       VVP_INTF_TYPE                 {VVP_LITE}

    # isp_cpm
    set_instance_parameter_value      isp_cpm       BPS                           ${v_isp_bps}
    set_instance_parameter_value      isp_cpm       C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_cpm       C_OMNI_CAP_ID_COMPONENT       {0}
    set_instance_parameter_value      isp_cpm       C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_cpm       C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_cpm       C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_cpm       C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_cpm       C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_cpm       C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_cpm       C_OMNI_CAP_TYPE               {571}
    set_instance_parameter_value      isp_cpm       C_OMNI_CAP_VERSION            {1}
    set_instance_parameter_value      isp_cpm       ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value      isp_cpm       EXTERNAL_MODE                 {1}
    set_instance_parameter_value      isp_cpm       IP0_KEEP_COLOR_PLANE_0        {1}
    set_instance_parameter_value      isp_cpm       IP0_KEEP_COLOR_PLANE_1        {1}
    set_instance_parameter_value      isp_cpm       IP0_KEEP_COLOR_PLANE_2        {1}
    set_instance_parameter_value      isp_cpm       IP0_KEEP_COLOR_PLANE_3        {1}
    set_instance_parameter_value      isp_cpm       IP1_KEEP_COLOR_PLANE_0        {1}
    set_instance_parameter_value      isp_cpm       IP1_KEEP_COLOR_PLANE_1        {1}
    set_instance_parameter_value      isp_cpm       IP1_KEEP_COLOR_PLANE_2        {1}
    set_instance_parameter_value      isp_cpm       IP1_KEEP_COLOR_PLANE_3        {1}
    set_instance_parameter_value      isp_cpm       KEEP_IP1_AUX_PACKETS          {1}
    set_instance_parameter_value      isp_cpm       KEEP_OP1_AUX_PACKETS          {1}
    set_instance_parameter_value      isp_cpm       MAPPING_COLOR_PLANE_0         {0}
    set_instance_parameter_value      isp_cpm       MAPPING_COLOR_PLANE_1         {0}
    set_instance_parameter_value      isp_cpm       MAPPING_COLOR_PLANE_2         {0}
    set_instance_parameter_value      isp_cpm       MAPPING_COLOR_PLANE_3         {0}
    set_instance_parameter_value      isp_cpm       MODE                          {REARRANGE}
    set_instance_parameter_value      isp_cpm       NUMBER_OF_COLOR_PLANES_IN0    ${v_isp_cppp}
    set_instance_parameter_value      isp_cpm       NUMBER_OF_COLOR_PLANES_IN1    {2}
    set_instance_parameter_value      isp_cpm       NUMBER_OF_COLOR_PLANES_OUT0   ${v_cppp}
    set_instance_parameter_value      isp_cpm       NUMBER_OF_COLOR_PLANES_OUT1   {2}
    set_instance_parameter_value      isp_cpm       OP0_KEEP_COLOR_PLANE_0        {1}
    set_instance_parameter_value      isp_cpm       OP0_KEEP_COLOR_PLANE_1        {1}
    set_instance_parameter_value      isp_cpm       OP0_KEEP_COLOR_PLANE_2        {1}
    set_instance_parameter_value      isp_cpm       OP0_KEEP_COLOR_PLANE_3        {1}
    set_instance_parameter_value      isp_cpm       OP1_KEEP_COLOR_PLANE_0        {1}
    set_instance_parameter_value      isp_cpm       OP1_KEEP_COLOR_PLANE_1        {1}
    set_instance_parameter_value      isp_cpm       OP1_KEEP_COLOR_PLANE_2        {1}
    set_instance_parameter_value      isp_cpm       OP1_KEEP_COLOR_PLANE_3        {1}
    set_instance_parameter_value      isp_cpm       PADDING_COLOR_PLANE_0         {0}
    set_instance_parameter_value      isp_cpm       PADDING_COLOR_PLANE_1         {0}
    set_instance_parameter_value      isp_cpm       PADDING_COLOR_PLANE_2         {0}
    set_instance_parameter_value      isp_cpm       PADDING_COLOR_PLANE_3         {0}
    set_instance_parameter_value      isp_cpm       PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_cpm       P_CORE_CTRL_ID                {0}
    set_instance_parameter_value      isp_cpm       P_UPDATE_CMD_SUPPORTED        {0}
    set_instance_parameter_value      isp_cpm       RUNTIME_CONTROL               {1}
    set_instance_parameter_value      isp_cpm       SEPARATE_SLAVE_CLOCK          {1}
    set_instance_parameter_value      isp_cpm       SLAVE_PROTOCOL                {Avalon}

    # isp_dpc
    set_instance_parameter_value      isp_dpc       AV_MAX_PENDING_READS          {8}
    set_instance_parameter_value      isp_dpc       BPS_IN                        ${v_isp_bps}
    set_instance_parameter_value      isp_dpc       BPS_OUT                       ${v_isp_bps}
    set_instance_parameter_value      isp_dpc       C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_dpc       C_OMNI_CAP_ID_COMPONENT       {0}
    set_instance_parameter_value      isp_dpc       C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_dpc       C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_dpc       C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_dpc       C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_dpc       C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_dpc       C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_dpc       C_OMNI_CAP_TYPE               {373}
    set_instance_parameter_value      isp_dpc       C_OMNI_CAP_VERSION            {1}
    set_instance_parameter_value      isp_dpc       DUPLICATE_AND_BYPASS          {0}
    set_instance_parameter_value      isp_dpc       ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value      isp_dpc       ENABLE_EXT_DATA_RW            {0}
    set_instance_parameter_value      isp_dpc       EXTERNAL_MODE                 {1}
    set_instance_parameter_value      isp_dpc       H_TAPS                        {5}
    set_instance_parameter_value      isp_dpc       MAX_HEIGHT                    {4096}
    set_instance_parameter_value      isp_dpc       MAX_WIDTH                     {4096}
    set_instance_parameter_value      isp_dpc       NO_BLANKING                   {1}
    set_instance_parameter_value      isp_dpc       NUMBER_OF_COLOR_PLANES_IN     ${v_isp_cppp}
    set_instance_parameter_value      isp_dpc       NUMBER_OF_COLOR_PLANES_OUT    ${v_isp_cppp}
    set_instance_parameter_value      isp_dpc       NUM_EXT_DATA_REGS             {0}
    set_instance_parameter_value      isp_dpc       PIPELINE_DATA_MM              {0}
    set_instance_parameter_value      isp_dpc       PIPELINE_READY                ${v_pipeline_ready}
    set_instance_parameter_value      isp_dpc       PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_dpc       P_CORE_CTRL_ID                {0}
    set_instance_parameter_value      isp_dpc       P_UPDATE_CMD_SUPPORTED        {0}
    set_instance_parameter_value      isp_dpc       RUNTIME_CONTROL               {1}
    set_instance_parameter_value      isp_dpc       SEPARATE_SLAVE_CLOCK          {1}
    set_instance_parameter_value      isp_dpc       SLAVE_PROTOCOL                {Avalon}
    set_instance_parameter_value      isp_dpc       V_TAPS                        {5}

    # isp_anr
    set_instance_parameter_value      isp_anr       AV_MAX_PENDING_READS          {8}
    set_instance_parameter_value      isp_anr       BPS_IN                        ${v_isp_bps}
    set_instance_parameter_value      isp_anr       BPS_OUT                       ${v_isp_bps}
    set_instance_parameter_value      isp_anr       C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_anr       C_OMNI_CAP_ID_COMPONENT       {0}
    set_instance_parameter_value      isp_anr       C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_anr       C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_anr       C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_anr       C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_anr       C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_anr       C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_anr       C_OMNI_CAP_TYPE               {374}
    set_instance_parameter_value      isp_anr       C_OMNI_CAP_VERSION            {2}
    set_instance_parameter_value      isp_anr       DUPLICATE_AND_BYPASS          {0}
    set_instance_parameter_value      isp_anr       CFA_ENABLE                    {1}
    set_instance_parameter_value      isp_anr       ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value      isp_anr       ENABLE_EXT_DATA_RW            {0}
    set_instance_parameter_value      isp_anr       EXTERNAL_MODE                 {1}
    set_instance_parameter_value      isp_anr       H_TAPS                        {17}
    set_instance_parameter_value      isp_anr       MAX_HEIGHT                    {65536}
    set_instance_parameter_value      isp_anr       MAX_WIDTH                     {4096}
    set_instance_parameter_value      isp_anr       NO_BLANKING                   {1}
    set_instance_parameter_value      isp_anr       NUMBER_OF_COLOR_PLANES        ${v_isp_cppp}
    set_instance_parameter_value      isp_anr       NUM_EXT_DATA_REGS             {2048}
    set_instance_parameter_value      isp_anr       PIPELINE_DATA_MM              {0}
    set_instance_parameter_value      isp_anr       PIPELINE_READY                ${v_pipeline_ready}
    set_instance_parameter_value      isp_anr       PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_anr       P_CORE_CTRL_ID                {0}
    set_instance_parameter_value      isp_anr       P_UPDATE_CMD_SUPPORTED        {0}
    set_instance_parameter_value      isp_anr       RUNTIME_CONTROL               {1}
    set_instance_parameter_value      isp_anr       SEPARATE_SLAVE_CLOCK          {1}
    set_instance_parameter_value      isp_anr       SLAVE_PROTOCOL                {Avalon}
    set_instance_parameter_value      isp_anr       V_TAPS                        {17}

    # isp_blc
    set_instance_parameter_value      isp_blc       AV_MAX_PENDING_READS          {8}
    set_instance_parameter_value      isp_blc       BPS_IN                        ${v_isp_bps}
    set_instance_parameter_value      isp_blc       BPS_OUT                       ${v_isp_bps}
    set_instance_parameter_value      isp_blc       C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_blc       C_OMNI_CAP_ID_COMPONENT       {0}
    set_instance_parameter_value      isp_blc       C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_blc       C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_blc       C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_blc       C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_blc       C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_blc       C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_blc       C_OMNI_CAP_TYPE               {375}
    set_instance_parameter_value      isp_blc       C_OMNI_CAP_VERSION            {1}
    set_instance_parameter_value      isp_blc       DUPLICATE_AND_BYPASS          {0}
    set_instance_parameter_value      isp_blc       ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value      isp_blc       ENABLE_EXT_DATA_RW            {0}
    set_instance_parameter_value      isp_blc       EXTERNAL_MODE                 {1}
    set_instance_parameter_value      isp_blc       H_TAPS                        {1}
    set_instance_parameter_value      isp_blc       MAX_HEIGHT                    {4096}
    set_instance_parameter_value      isp_blc       MAX_WIDTH                     {4096}
    set_instance_parameter_value      isp_blc       NO_BLANKING                   {1}
    set_instance_parameter_value      isp_blc       NUMBER_OF_COLOR_PLANES_IN     ${v_isp_cppp}
    set_instance_parameter_value      isp_blc       NUMBER_OF_COLOR_PLANES_OUT    ${v_isp_cppp}
    set_instance_parameter_value      isp_blc       NUM_EXT_DATA_REGS             {0}
    set_instance_parameter_value      isp_blc       PIPELINE_DATA_MM              {0}
    set_instance_parameter_value      isp_blc       PIPELINE_READY                ${v_pipeline_ready}
    set_instance_parameter_value      isp_blc       PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_blc       P_CORE_CTRL_ID                {0}
    set_instance_parameter_value      isp_blc       P_UPDATE_CMD_SUPPORTED        {0}
    set_instance_parameter_value      isp_blc       REFLECT_AROUND_ZERO           {1}
    set_instance_parameter_value      isp_blc       RUNTIME_CONTROL               {1}
    set_instance_parameter_value      isp_blc       SEPARATE_SLAVE_CLOCK          {1}
    set_instance_parameter_value      isp_blc       SLAVE_PROTOCOL                {Avalon}
    set_instance_parameter_value      isp_blc       V_TAPS                        {1}

    # isp_vc
    set_instance_parameter_value      isp_vc        AV_MAX_PENDING_READS          {8}
    set_instance_parameter_value      isp_vc        BPS_IN                        ${v_isp_bps}
    set_instance_parameter_value      isp_vc        BPS_OUT                       ${v_isp_bps}
    set_instance_parameter_value      isp_vc        CFA_ENABLE                    {1}
    set_instance_parameter_value      isp_vc        CFA_NUM_OF_COLOR_PLANES       ${v_isp_cppp}
    set_instance_parameter_value      isp_vc        C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_vc        C_OMNI_CAP_ID_COMPONENT       {0}
    set_instance_parameter_value      isp_vc        C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_vc        C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_vc        C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_vc        C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_vc        C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_vc        C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_vc        C_OMNI_CAP_TYPE               {376}
    set_instance_parameter_value      isp_vc        C_OMNI_CAP_VERSION            {1}
    set_instance_parameter_value      isp_vc        DUPLICATE_AND_BYPASS          {0}
    set_instance_parameter_value      isp_vc        ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value      isp_vc        ENABLE_EXT_DATA_RW            {0}
    set_instance_parameter_value      isp_vc        EXTERNAL_MODE                 {1}
    set_instance_parameter_value      isp_vc        H_TAPS                        {1}
    if {${v_small_vc}} {
        set_instance_parameter_value      isp_vc      MAX_GAIN_MESH_POINTS          {1024}
        set_instance_parameter_value      isp_vc      PER_COLOR_GAIN_ENABLE         {0}
    } else {
        set_instance_parameter_value      isp_vc      MAX_GAIN_MESH_POINTS          {4096}
        set_instance_parameter_value      isp_vc      PER_COLOR_GAIN_ENABLE         {1}
    }
    set_instance_parameter_value      isp_vc        MAX_HEIGHT                    {4096}
    set_instance_parameter_value      isp_vc        MAX_WIDTH                     {4096}
    set_instance_parameter_value      isp_vc        NO_BLANKING                   {1}
    set_instance_parameter_value      isp_vc        NUM_EXT_DATA_REGS             {32768}
    set_instance_parameter_value      isp_vc        PIPELINE_DATA_MM              {1}
    set_instance_parameter_value      isp_vc        PIPELINE_READY                ${v_pipeline_ready}
    set_instance_parameter_value      isp_vc        PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_vc        P_CORE_CTRL_ID                {0}
    set_instance_parameter_value      isp_vc        P_UPDATE_CMD_SUPPORTED        {0}
    set_instance_parameter_value      isp_vc        RGB_NUM_OF_COLOR_PLANES       ${v_isp_cppp}
    set_instance_parameter_value      isp_vc        RUNTIME_CONTROL               {1}
    set_instance_parameter_value      isp_vc        SEPARATE_SLAVE_CLOCK          {1}
    set_instance_parameter_value      isp_vc        SLAVE_PROTOCOL                {Avalon}
    set_instance_parameter_value      isp_vc        V_TAPS                        {1}

    # isp_switch_wbs
    set_instance_parameter_value      isp_switch_wbs      BPS                           ${v_isp_bps}
    set_instance_parameter_value      isp_switch_wbs      CRASH_SWITCH                  ${v_wbs_async_ip_sw}
    set_instance_parameter_value      isp_switch_wbs      C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_switch_wbs      C_OMNI_CAP_ID_COMPONENT       {3}
    set_instance_parameter_value      isp_switch_wbs      C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_switch_wbs      C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_switch_wbs      C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_switch_wbs      C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_switch_wbs      C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_switch_wbs      C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_switch_wbs      C_OMNI_CAP_TYPE               {565}
    set_instance_parameter_value      isp_switch_wbs      C_OMNI_CAP_VERSION            {2}
    set_instance_parameter_value      isp_switch_wbs      ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value      isp_switch_wbs      EXTERNAL_MODE                 {1}
    set_instance_parameter_value      isp_switch_wbs      NUMBER_OF_COLOR_PLANES        ${v_isp_cppp}
    set_instance_parameter_value      isp_switch_wbs      NUM_INPUTS                    {3}
    set_instance_parameter_value      isp_switch_wbs      NUM_OUTPUTS                   {3}
    set_instance_parameter_value      isp_switch_wbs      PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_switch_wbs      SEPARATE_SLAVE_CLOCK          {1}
    set_instance_parameter_value      isp_switch_wbs      SLAVE_PROTOCOL                {Avalon}
    set_instance_parameter_value      isp_switch_wbs      UNINTERRUPTED_INPUTS          ${v_wbs_sync_ip_sw}
    set_instance_parameter_value      isp_switch_wbs      USE_OP_RESP                   {0}
    set_instance_parameter_value      isp_switch_wbs      USE_TREADIES                  {1}
    set_instance_parameter_value      isp_switch_wbs      VVP_INTF_TYPE                 {VVP_LITE}

    # isp_wbc
    set_instance_parameter_value      isp_wbc       AV_MAX_PENDING_READS          {8}
    set_instance_parameter_value      isp_wbc       BPS_IN                        ${v_isp_bps}
    set_instance_parameter_value      isp_wbc       BPS_OUT                       ${v_isp_bps}
    set_instance_parameter_value      isp_wbc       C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_wbc       C_OMNI_CAP_ID_COMPONENT       {0}
    set_instance_parameter_value      isp_wbc       C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_wbc       C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_wbc       C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_wbc       C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_wbc       C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_wbc       C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_wbc       C_OMNI_CAP_TYPE               {378}
    set_instance_parameter_value      isp_wbc       C_OMNI_CAP_VERSION            {1}
    set_instance_parameter_value      isp_wbc       DUPLICATE_AND_BYPASS          {0}
    set_instance_parameter_value      isp_wbc       ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value      isp_wbc       ENABLE_EXT_DATA_RW            {0}
    set_instance_parameter_value      isp_wbc       EXTERNAL_MODE                 {1}
    set_instance_parameter_value      isp_wbc       H_TAPS                        {1}
    set_instance_parameter_value      isp_wbc       MAX_HEIGHT                    {4096}
    set_instance_parameter_value      isp_wbc       MAX_WIDTH                     {4096}
    set_instance_parameter_value      isp_wbc       NO_BLANKING                   {1}
    set_instance_parameter_value      isp_wbc       NUMBER_OF_COLOR_PLANES_IN     ${v_isp_cppp}
    set_instance_parameter_value      isp_wbc       NUMBER_OF_COLOR_PLANES_OUT    ${v_isp_cppp}
    set_instance_parameter_value      isp_wbc       NUM_EXT_DATA_REGS             {0}
    set_instance_parameter_value      isp_wbc       PIPELINE_DATA_MM              {0}
    set_instance_parameter_value      isp_wbc       PIPELINE_READY                ${v_pipeline_ready}
    set_instance_parameter_value      isp_wbc       PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_wbc       P_CORE_CTRL_ID                {0}
    set_instance_parameter_value      isp_wbc       P_UPDATE_CMD_SUPPORTED        {0}
    set_instance_parameter_value      isp_wbc       RUNTIME_CONTROL               {1}
    set_instance_parameter_value      isp_wbc       SEPARATE_SLAVE_CLOCK          {1}
    set_instance_parameter_value      isp_wbc       SLAVE_PROTOCOL                {Avalon}
    set_instance_parameter_value      isp_wbc       V_TAPS                        {1}

    # isp_wbs
    set_instance_parameter_value      isp_wbs       AV_MAX_PENDING_READS          {8}
    set_instance_parameter_value      isp_wbs       BPS                           ${v_isp_bps}
    set_instance_parameter_value      isp_wbs       C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_wbs       C_OMNI_CAP_ID_COMPONENT       {0}
    set_instance_parameter_value      isp_wbs       C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_wbs       C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_wbs       C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_wbs       C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_wbs       C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_wbs       C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_wbs       C_OMNI_CAP_TYPE               {377}
    set_instance_parameter_value      isp_wbs       C_OMNI_CAP_VERSION            {1}
    set_instance_parameter_value      isp_wbs       DUPLICATE_AND_BYPASS          {0}
    set_instance_parameter_value      isp_wbs       ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value      isp_wbs       ENABLE_EXT_DATA_RW            {1}
    set_instance_parameter_value      isp_wbs       EXTERNAL_MODE                 {1}
    set_instance_parameter_value      isp_wbs       H_TAPS                        {1}
    set_instance_parameter_value      isp_wbs       MAX_HEIGHT                    {4096}
    set_instance_parameter_value      isp_wbs       MAX_WIDTH                     {4096}
    set_instance_parameter_value      isp_wbs       NO_BLANKING                   {1}
    set_instance_parameter_value      isp_wbs       NUMBER_OF_COLOR_PLANES        ${v_isp_cppp}
    set_instance_parameter_value      isp_wbs       NUM_EXT_DATA_REGS             {512}
    set_instance_parameter_value      isp_wbs       PIPELINE_DATA_MM              {1}
    set_instance_parameter_value      isp_wbs       PIPELINE_READY                ${v_pipeline_ready}
    set_instance_parameter_value      isp_wbs       PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_wbs       PRECISION_BITS                {8}
    set_instance_parameter_value      isp_wbs       P_CORE_CTRL_ID                {0}
    set_instance_parameter_value      isp_wbs       P_UPDATE_CMD_SUPPORTED        {0}
    set_instance_parameter_value      isp_wbs       RUNTIME_CONTROL               {1}
    set_instance_parameter_value      isp_wbs       SEPARATE_SLAVE_CLOCK          {1}
    set_instance_parameter_value      isp_wbs       SLAVE_PROTOCOL                {Avalon}
    set_instance_parameter_value      isp_wbs       V_TAPS                        {2}

    # isp_dms
    set_instance_parameter_value      isp_dms       AV_MAX_PENDING_READS          {8}
    set_instance_parameter_value      isp_dms       BPS_IN                        ${v_isp_bps}
    set_instance_parameter_value      isp_dms       BPS_OUT                       ${v_isp_bps}
    set_instance_parameter_value      isp_dms       C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_dms       C_OMNI_CAP_ID_COMPONENT       {0}
    set_instance_parameter_value      isp_dms       C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_dms       C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_dms       C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_dms       C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_dms       C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_dms       C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_dms       C_OMNI_CAP_TYPE               {582}
    set_instance_parameter_value      isp_dms       C_OMNI_CAP_VERSION            {2}
    set_instance_parameter_value      isp_dms       DUPLICATE_AND_BYPASS          {0}
    set_instance_parameter_value      isp_dms       ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value      isp_dms       ENABLE_EXT_DATA_RW            {0}
    set_instance_parameter_value      isp_dms       EXTERNAL_MODE                 {1}
    set_instance_parameter_value      isp_dms       H_TAPS                        {5}
    set_instance_parameter_value      isp_dms       MAX_HEIGHT                    {4096}
    set_instance_parameter_value      isp_dms       MAX_WIDTH                     {4096}
    set_instance_parameter_value      isp_dms       NO_BLANKING                   {1}
    set_instance_parameter_value      isp_dms       NUMBER_OF_COLOR_PLANES_IN     ${v_isp_cppp}
    set_instance_parameter_value      isp_dms       NUMBER_OF_COLOR_PLANES_OUT    ${v_cppp}
    set_instance_parameter_value      isp_dms       NUM_EXT_DATA_REGS             {0}
    set_instance_parameter_value      isp_dms       PIPELINE_DATA_MM              {0}
    set_instance_parameter_value      isp_dms       PIPELINE_READY                ${v_pipeline_ready}
    set_instance_parameter_value      isp_dms       PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_dms       P_CORE_CTRL_ID                {0}
    set_instance_parameter_value      isp_dms       P_UPDATE_CMD_SUPPORTED        {0}
    set_instance_parameter_value      isp_dms       RUNTIME_CONTROL               {1}
    set_instance_parameter_value      isp_dms       SEPARATE_SLAVE_CLOCK          {1}
    set_instance_parameter_value      isp_dms       SLAVE_PROTOCOL                {Avalon}
    set_instance_parameter_value      isp_dms       V_TAPS                        {5}

    # isp_hs
    set_instance_parameter_value      isp_hs        AV_MAX_PENDING_READS          {8}
    set_instance_parameter_value      isp_hs        BPS                           ${v_isp_bps}
    set_instance_parameter_value      isp_hs        C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_hs        C_OMNI_CAP_ID_COMPONENT       {0}
    set_instance_parameter_value      isp_hs        C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_hs        C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_hs        C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_hs        C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_hs        C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_hs        C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_hs        C_OMNI_CAP_TYPE               {379}
    set_instance_parameter_value      isp_hs        C_OMNI_CAP_VERSION            {1}
    set_instance_parameter_value      isp_hs        DUPLICATE_AND_BYPASS          {1}
    set_instance_parameter_value      isp_hs        ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value      isp_hs        ENABLE_EXT_DATA_RW            {1}
    set_instance_parameter_value      isp_hs        EXTERNAL_MODE                 {1}
    set_instance_parameter_value      isp_hs        H_TAPS                        {1}
    set_instance_parameter_value      isp_hs        MAX_HEIGHT                    {4096}
    set_instance_parameter_value      isp_hs        MAX_WIDTH                     {4096}
    set_instance_parameter_value      isp_hs        NO_BLANKING                   {1}
    set_instance_parameter_value      isp_hs        NUMBER_OF_COLOR_PLANES        ${v_cppp}
    set_instance_parameter_value      isp_hs        NUM_HIST_BINS                 {256}
    set_instance_parameter_value      isp_hs        PIPELINE_DATA_MM              {1}
    set_instance_parameter_value      isp_hs        PIPELINE_READY                ${v_pipeline_ready}
    set_instance_parameter_value      isp_hs        PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_hs        P_CORE_CTRL_ID                {0}
    set_instance_parameter_value      isp_hs        P_UPDATE_CMD_SUPPORTED        {0}
    set_instance_parameter_value      isp_hs        RUNTIME_CONTROL               {1}
    set_instance_parameter_value      isp_hs        SEPARATE_SLAVE_CLOCK          {1}
    set_instance_parameter_value      isp_hs        SLAVE_PROTOCOL                {Avalon}
    set_instance_parameter_value      isp_hs        V_TAPS                        {1}

    # isp_ccm
    set_instance_parameter_value      isp_ccm       BPS_IN                        ${v_isp_bps}
    set_instance_parameter_value      isp_ccm       BPS_OUT                       ${v_isp_bps}
    set_instance_parameter_value      isp_ccm       COEFFICIENT_INT_BITS          {8}
    set_instance_parameter_value      isp_ccm       COEFFICIENT_SIGNED            {1}
    set_instance_parameter_value      isp_ccm       COEF_SUM_FRACTION_BITS        {8}
    set_instance_parameter_value      isp_ccm       C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_ccm       C_OMNI_CAP_ID_COMPONENT       {1}
    set_instance_parameter_value      isp_ccm       C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_ccm       C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_ccm       C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_ccm       C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_ccm       C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_ccm       C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_ccm       C_OMNI_CAP_TYPE               {559}
    set_instance_parameter_value      isp_ccm       C_OMNI_CAP_VERSION            {1}
    set_instance_parameter_value      isp_ccm       ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value      isp_ccm       EXTERNAL_MODE                 {1}
    set_instance_parameter_value      isp_ccm       MOVE_BINARY_POINT_RIGHT       {0}
    set_instance_parameter_value      isp_ccm       OUTPUT_COLORSPACE             {0}
    set_instance_parameter_value      isp_ccm       PIPELINE_READY                ${v_pipeline_ready}
    set_instance_parameter_value      isp_ccm       PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_ccm       P_CORE_CTRL_ID                {0}
    set_instance_parameter_value      isp_ccm       P_UPDATE_CMD_SUPPORTED        {0}
    set_instance_parameter_value      isp_ccm       REMOVE_FRACTION_METHOD        {1}
    set_instance_parameter_value      isp_ccm       REQ_FCOEFF_A0                 {1.0}
    set_instance_parameter_value      isp_ccm       REQ_FCOEFF_A1                 {0.0}
    set_instance_parameter_value      isp_ccm       REQ_FCOEFF_A2                 {0.0}
    set_instance_parameter_value      isp_ccm       REQ_FCOEFF_B0                 {0.0}
    set_instance_parameter_value      isp_ccm       REQ_FCOEFF_B1                 {1.0}
    set_instance_parameter_value      isp_ccm       REQ_FCOEFF_B2                 {0.0}
    set_instance_parameter_value      isp_ccm       REQ_FCOEFF_C0                 {0.0}
    set_instance_parameter_value      isp_ccm       REQ_FCOEFF_C1                 {0.0}
    set_instance_parameter_value      isp_ccm       REQ_FCOEFF_C2                 {1.0}
    set_instance_parameter_value      isp_ccm       REQ_FCOEFF_S0                 {0.0}
    set_instance_parameter_value      isp_ccm       REQ_FCOEFF_S1                 {0.0}
    set_instance_parameter_value      isp_ccm       REQ_FCOEFF_S2                 {0.0}
    set_instance_parameter_value      isp_ccm       RUNTIME_CONTROL               {1}
    set_instance_parameter_value      isp_ccm       SEPARATE_SLAVE_CLOCK          {1}
    set_instance_parameter_value      isp_ccm       SLAVE_PROTOCOL                {Avalon}
    set_instance_parameter_value      isp_ccm       SUMMAND_INT_BITS              {10}
    set_instance_parameter_value      isp_ccm       SUMMAND_SIGNED                {1}

    if {${v_hdr_en}} {
        # isp_1d_lut_hdr
        set_instance_parameter_value      isp_1d_lut_hdr        AV_MAX_PENDING_READS          {8}
        set_instance_parameter_value      isp_1d_lut_hdr        BITS_LUT                      {12}
        set_instance_parameter_value      isp_1d_lut_hdr        BITS_STEP                     {2}
        set_instance_parameter_value      isp_1d_lut_hdr        BPS_IN                        ${v_isp_bps}
        set_instance_parameter_value      isp_1d_lut_hdr        BPS_OUT                       ${v_isp_bps_cut}
        set_instance_parameter_value      isp_1d_lut_hdr        C_OMNI_CAP_ID_ASSOCIATED      {0}
        set_instance_parameter_value      isp_1d_lut_hdr        C_OMNI_CAP_ID_COMPONENT       {1}
        set_instance_parameter_value      isp_1d_lut_hdr        C_OMNI_CAP_IRQ                {255}
        set_instance_parameter_value      isp_1d_lut_hdr        C_OMNI_CAP_IRQ_ENABLE         {0}
        set_instance_parameter_value      isp_1d_lut_hdr        C_OMNI_CAP_IRQ_ENABLE_EN      {0}
        set_instance_parameter_value      isp_1d_lut_hdr        C_OMNI_CAP_IRQ_STATUS         {0}
        set_instance_parameter_value      isp_1d_lut_hdr        C_OMNI_CAP_IRQ_STATUS_EN      {0}
        set_instance_parameter_value      isp_1d_lut_hdr        C_OMNI_CAP_TAG                {0}
        set_instance_parameter_value      isp_1d_lut_hdr        C_OMNI_CAP_TYPE               {381}
        set_instance_parameter_value      isp_1d_lut_hdr        C_OMNI_CAP_VERSION            {1}
        set_instance_parameter_value      isp_1d_lut_hdr        DUPLICATE_AND_BYPASS          {0}
        set_instance_parameter_value      isp_1d_lut_hdr        ENABLE_DEBUG                  ${v_enable_debug}
        set_instance_parameter_value      isp_1d_lut_hdr        ENABLE_EXT_DATA_RW            {0}
        set_instance_parameter_value      isp_1d_lut_hdr        EQUIDISTANT                   {0}
        set_instance_parameter_value      isp_1d_lut_hdr        EXTERNAL_MODE                 {1}
        set_instance_parameter_value      isp_1d_lut_hdr        H_TAPS                        {1}
        set_instance_parameter_value      isp_1d_lut_hdr        MAX_HEIGHT                    {4096}
        set_instance_parameter_value      isp_1d_lut_hdr        MAX_WIDTH                     {4096}
        set_instance_parameter_value      isp_1d_lut_hdr        NO_BLANKING                   {1}
        set_instance_parameter_value      isp_1d_lut_hdr        NUMBER_OF_COLOR_PLANES        ${v_cppp}
        set_instance_parameter_value      isp_1d_lut_hdr        PIPELINE_DATA_MM              {0}
        set_instance_parameter_value      isp_1d_lut_hdr        PIPELINE_READY                ${v_pipeline_ready}
        set_instance_parameter_value      isp_1d_lut_hdr        PIXELS_IN_PARALLEL            ${v_pip}
        set_instance_parameter_value      isp_1d_lut_hdr        P_CORE_CTRL_ID                {0}
        set_instance_parameter_value      isp_1d_lut_hdr        P_UPDATE_CMD_SUPPORTED        {0}
        set_instance_parameter_value      isp_1d_lut_hdr        REVERSE_LUT                   {0}
        set_instance_parameter_value      isp_1d_lut_hdr        RUNTIME_CONTROL               {1}
        set_instance_parameter_value      isp_1d_lut_hdr        SEPARATE_SLAVE_CLOCK          {1}
        set_instance_parameter_value      isp_1d_lut_hdr        SLAVE_PROTOCOL                {Avalon}
        set_instance_parameter_value      isp_1d_lut_hdr        V_TAPS                        {1}

        # isp_3d_lut_hdr_1
        set_instance_parameter_value      isp_3d_lut_hdr_1        BPS_IN                        ${v_isp_bps_cut}
        set_instance_parameter_value      isp_3d_lut_hdr_1        BPS_OUT                       ${v_isp_bps_cut}
        set_instance_parameter_value      isp_3d_lut_hdr_1        BYPASS_ALPHA                  {1023}
        set_instance_parameter_value      isp_3d_lut_hdr_1        C_OMNI_CAP_ID_ASSOCIATED      {0}
        set_instance_parameter_value      isp_3d_lut_hdr_1        C_OMNI_CAP_ID_COMPONENT       {1}
        set_instance_parameter_value      isp_3d_lut_hdr_1        C_OMNI_CAP_IRQ                {255}
        set_instance_parameter_value      isp_3d_lut_hdr_1        C_OMNI_CAP_IRQ_ENABLE         {0}
        set_instance_parameter_value      isp_3d_lut_hdr_1        C_OMNI_CAP_IRQ_ENABLE_EN      {0}
        set_instance_parameter_value      isp_3d_lut_hdr_1        C_OMNI_CAP_IRQ_STATUS         {0}
        set_instance_parameter_value      isp_3d_lut_hdr_1        C_OMNI_CAP_IRQ_STATUS_EN      {0}
        set_instance_parameter_value      isp_3d_lut_hdr_1        C_OMNI_CAP_TAG                {0}
        set_instance_parameter_value      isp_3d_lut_hdr_1        C_OMNI_CAP_TYPE               {357}
        set_instance_parameter_value      isp_3d_lut_hdr_1        C_OMNI_CAP_VERSION            {1}
        set_instance_parameter_value      isp_3d_lut_hdr_1        EXTERNAL_MODE                 {1}
        set_instance_parameter_value      isp_3d_lut_hdr_1        LUT_ALPHA                     {0}
        set_instance_parameter_value      isp_3d_lut_hdr_1        LUT_CPU_READABLE              {0}
        set_instance_parameter_value      isp_3d_lut_hdr_1        LUT_DEPTH                     ${v_isp_bps_cut}
        if {(${v_pip} > 1) && (${v_lut_pip_sharing_en} )} {
            set_instance_parameter_value      isp_3d_lut_hdr_1      LUT_PIP_SHARING               {1}
        } else {
            set_instance_parameter_value      isp_3d_lut_hdr_1      LUT_PIP_SHARING               {0}
        }
        if {${v_small_3d_lut}} {
            set_instance_parameter_value      isp_3d_lut_hdr_1      LUT_DIMENSION                 {17}
        } else {
            set_instance_parameter_value      isp_3d_lut_hdr_1      LUT_DIMENSION                 {33}
        }
        if {${v_lut_double_buffered_en}} {
            set_instance_parameter_value      isp_3d_lut_hdr_1      LUT_DOUBLE_BUFFERED           {1}
        } else {
            set_instance_parameter_value      isp_3d_lut_hdr_1      LUT_DOUBLE_BUFFERED           {0}
        }
        if {${v_3d_lut_preset_file_en}} {
            set_instance_parameter_value      isp_3d_lut_hdr_1      LUT_INIT_0                    {1}
            set_instance_parameter_value      isp_3d_lut_hdr_1      LUT_INIT_FILENAME_0 \
                                                      ${v_project_path}/non_qpds_ip/user/${v_3d_lut_0_0_preset_file}
            if {${v_lut_double_buffered_en}} {
                set_instance_parameter_value      isp_3d_lut_hdr_1      LUT_INIT_1                    {1}
                set_instance_parameter_value      isp_3d_lut_hdr_1      LUT_INIT_FILENAME_1 \
                                                      ${v_project_path}/non_qpds_ip/user/${v_3d_lut_0_1_preset_file}
            }
        } else {
            set_instance_parameter_value      isp_3d_lut_hdr_1      LUT_INIT_0                    {0}
            set_instance_parameter_value      isp_3d_lut_hdr_1      LUT_INIT_FILENAME_0           {}
            set_instance_parameter_value      isp_3d_lut_hdr_1      LUT_INIT_1                    {0}
            set_instance_parameter_value      isp_3d_lut_hdr_1      LUT_INIT_FILENAME_1           {}
        }
        set_instance_parameter_value      isp_3d_lut_hdr_1        LUT_INIT_TYPE_0               {normalized}
        set_instance_parameter_value      isp_3d_lut_hdr_1        LUT_INIT_TYPE_1               {normalized}
        set_instance_parameter_value      isp_3d_lut_hdr_1        PIXELS_IN_PARALLEL            ${v_pip}
        set_instance_parameter_value      isp_3d_lut_hdr_1        RESET_ENABLED                 {0}
        set_instance_parameter_value      isp_3d_lut_hdr_1        RUNTIME_CONTROL               {1}
        set_instance_parameter_value      isp_3d_lut_hdr_1        SEPARATE_SLAVE_CLOCK          {1}
        set_instance_parameter_value      isp_3d_lut_hdr_1        SLAVE_PROTOCOL                {Avalon}
    }

    # isp_3d_lut_hdr_2
    set_instance_parameter_value      isp_3d_lut_hdr_2        BPS_IN                        ${v_isp_bps_cut}
    set_instance_parameter_value      isp_3d_lut_hdr_2        BPS_OUT                       ${v_tmo_bps}
    set_instance_parameter_value      isp_3d_lut_hdr_2        BYPASS_ALPHA                  {1023}
    set_instance_parameter_value      isp_3d_lut_hdr_2        C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_3d_lut_hdr_2        C_OMNI_CAP_ID_COMPONENT       {0}
    set_instance_parameter_value      isp_3d_lut_hdr_2        C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_3d_lut_hdr_2        C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_3d_lut_hdr_2        C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_3d_lut_hdr_2        C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_3d_lut_hdr_2        C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_3d_lut_hdr_2        C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_3d_lut_hdr_2        C_OMNI_CAP_TYPE               {357}
    set_instance_parameter_value      isp_3d_lut_hdr_2        C_OMNI_CAP_VERSION            {1}
    set_instance_parameter_value      isp_3d_lut_hdr_2        EXTERNAL_MODE                 {1}
    set_instance_parameter_value      isp_3d_lut_hdr_2        LUT_ALPHA                     {0}
    set_instance_parameter_value      isp_3d_lut_hdr_2        LUT_CPU_READABLE              {0}
    set_instance_parameter_value      isp_3d_lut_hdr_2        LUT_DEPTH                     ${v_isp_bps_cut}
        if {(${v_pip} > 1) && (${v_lut_pip_sharing_en} )} {
            set_instance_parameter_value      isp_3d_lut_hdr_2      LUT_PIP_SHARING               {1}
        } else {
            set_instance_parameter_value      isp_3d_lut_hdr_2      LUT_PIP_SHARING               {0}
        }
        if {${v_small_3d_lut}} {
            set_instance_parameter_value      isp_3d_lut_hdr_2      LUT_DIMENSION                 {17}
        } else {
            set_instance_parameter_value      isp_3d_lut_hdr_2      LUT_DIMENSION                 {33}
        }
        if {${v_lut_double_buffered_en}} {
            set_instance_parameter_value      isp_3d_lut_hdr_2      LUT_DOUBLE_BUFFERED           {1}
        } else {
            set_instance_parameter_value      isp_3d_lut_hdr_2      LUT_DOUBLE_BUFFERED           {0}
        }
    if {${v_3d_lut_preset_file_en}} {
        set_instance_parameter_value      isp_3d_lut_hdr_2      LUT_INIT_0                    {1}
        set_instance_parameter_value      isp_3d_lut_hdr_2      LUT_INIT_FILENAME_0 \
                                                    ${v_project_path}/non_qpds_ip/user/${v_3d_lut_1_0_preset_file}
        if {${v_lut_double_buffered_en}} {
            set_instance_parameter_value      isp_3d_lut_hdr_2      LUT_INIT_1                    {1}
            set_instance_parameter_value      isp_3d_lut_hdr_2      LUT_INIT_FILENAME_1 \
                                                    ${v_project_path}/non_qpds_ip/user/${v_3d_lut_1_1_preset_file}
        }
    } else {
        set_instance_parameter_value      isp_3d_lut_hdr_2      LUT_INIT_0                    {0}
        set_instance_parameter_value      isp_3d_lut_hdr_2      LUT_INIT_FILENAME_0           {}
        set_instance_parameter_value      isp_3d_lut_hdr_2      LUT_INIT_1                    {0}
        set_instance_parameter_value      isp_3d_lut_hdr_2      LUT_INIT_FILENAME_1           {}
    }
    set_instance_parameter_value      isp_3d_lut_hdr_2        LUT_INIT_TYPE_0               {normalized}
    set_instance_parameter_value      isp_3d_lut_hdr_2        LUT_INIT_TYPE_1               {normalized}
    set_instance_parameter_value      isp_3d_lut_hdr_2        PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_3d_lut_hdr_2        RESET_ENABLED                 {0}
    set_instance_parameter_value      isp_3d_lut_hdr_2        RUNTIME_CONTROL               {1}
    set_instance_parameter_value      isp_3d_lut_hdr_2        SEPARATE_SLAVE_CLOCK          {1}
    set_instance_parameter_value      isp_3d_lut_hdr_2        SLAVE_PROTOCOL                {Avalon}

    # isp_tmo
    set_instance_parameter_value      isp_tmo         C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_tmo         C_OMNI_CAP_ID_COMPONENT       {0}
    set_instance_parameter_value      isp_tmo         C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_tmo         C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_tmo         C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_tmo         C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_tmo         C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_tmo         C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_tmo         C_OMNI_CAP_TYPE               {355}
    set_instance_parameter_value      isp_tmo         C_OMNI_CAP_VERSION            {1}
    set_instance_parameter_value      isp_tmo         P_BPS                         ${v_tmo_bps}
    set_instance_parameter_value      isp_tmo         P_NUMBER_OF_COLOR_PLANES      ${v_cppp}
    set_instance_parameter_value      isp_tmo         P_PIXELS_IN_PARALLEL          ${v_pip}

    # isp_pix_adapt_tmo
    set_instance_parameter_value      isp_pix_adapt_tmo     BPS_IN                        ${v_tmo_bps}
    set_instance_parameter_value      isp_pix_adapt_tmo     BPS_OUT                       ${v_usm_bps}
    set_instance_parameter_value      isp_pix_adapt_tmo     ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value      isp_pix_adapt_tmo     EXTERNAL_MODE                 {1}
    set_instance_parameter_value      isp_pix_adapt_tmo     NUMBER_OF_COLOR_PLANES        ${v_cppp}
    set_instance_parameter_value      isp_pix_adapt_tmo     PIPELINE_READY                ${v_pipeline_ready}
    set_instance_parameter_value      isp_pix_adapt_tmo     PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_pix_adapt_tmo     P_CORE_CTRL_ID                {0}
    set_instance_parameter_value      isp_pix_adapt_tmo     P_UPDATE_CMD_SUPPORTED        {0}
    set_instance_parameter_value      isp_pix_adapt_tmo     RUNTIME_CONTROL               {0}
    set_instance_parameter_value      isp_pix_adapt_tmo     SEPARATE_SLAVE_CLOCK          {0}
    set_instance_parameter_value      isp_pix_adapt_tmo     SLAVE_PROTOCOL                {Avalon}

    # isp_usm
    set_instance_parameter_value      isp_usm       BPS                           ${v_usm_bps}
    set_instance_parameter_value      isp_usm       COEFFS_FRACTION_BITS          {8}
    set_instance_parameter_value      isp_usm       COEFFS_INTEGER_BITS           {0}
    set_instance_parameter_value      isp_usm       C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_usm       C_OMNI_CAP_ID_COMPONENT       {0}
    set_instance_parameter_value      isp_usm       C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_usm       C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_usm       C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_usm       C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_usm       C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_usm       C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_usm       C_OMNI_CAP_TYPE               {380}
    set_instance_parameter_value      isp_usm       C_OMNI_CAP_VERSION            {1}
    set_instance_parameter_value      isp_usm       ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value      isp_usm       EXTERNAL_MODE                 {1}
    set_instance_parameter_value      isp_usm       H_TAPS                        {5}
    set_instance_parameter_value      isp_usm       MAX_HEIGHT                    {4096}
    set_instance_parameter_value      isp_usm       MAX_WIDTH                     {4096}
    set_instance_parameter_value      isp_usm       NO_BLANKING                   {1}
    set_instance_parameter_value      isp_usm       PIPELINE_READY                ${v_pipeline_ready}
    set_instance_parameter_value      isp_usm       PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_usm       P_CORE_CTRL_ID                {0}
    set_instance_parameter_value      isp_usm       P_UPDATE_CMD_SUPPORTED        {0}
    set_instance_parameter_value      isp_usm       RUNTIME_CONTROL               {1}
    set_instance_parameter_value      isp_usm       SEPARATE_SLAVE_CLOCK          {1}
    set_instance_parameter_value      isp_usm       SIGNED_COEFFS                 {0}
    set_instance_parameter_value      isp_usm       SLAVE_PROTOCOL                {Avalon}
    set_instance_parameter_value      isp_usm       V_TAPS                        {5}

    if {${v_ai_en} == 0} {
        if {${v_no_warp}} {
            # isp_vfb
            set_instance_parameter_value      isp_vfb         BPS                           ${v_usm_bps}
            set_instance_parameter_value      isp_vfb         CLOCKS_ARE_SEPARATE           {1}
            set_instance_parameter_value      isp_vfb         C_OMNI_CAP_ID_ASSOCIATED      {0}
            set_instance_parameter_value      isp_vfb         C_OMNI_CAP_ID_COMPONENT       {0}
            set_instance_parameter_value      isp_vfb         C_OMNI_CAP_IRQ                {255}
            set_instance_parameter_value      isp_vfb         C_OMNI_CAP_IRQ_ENABLE         {0}
            set_instance_parameter_value      isp_vfb         C_OMNI_CAP_IRQ_ENABLE_EN      {0}
            set_instance_parameter_value      isp_vfb         C_OMNI_CAP_IRQ_STATUS         {0}
            set_instance_parameter_value      isp_vfb         C_OMNI_CAP_IRQ_STATUS_EN      {0}
            set_instance_parameter_value      isp_vfb         C_OMNI_CAP_TAG                {0}
            set_instance_parameter_value      isp_vfb         C_OMNI_CAP_TYPE               {567}
            set_instance_parameter_value      isp_vfb         C_OMNI_CAP_VERSION            {1}
            set_instance_parameter_value      isp_vfb         DROP_BROKEN_FRAMES            {1}
            set_instance_parameter_value      isp_vfb         DROP_RPT_AUX_PKTS_WITH_FRAMES {0}
            set_instance_parameter_value      isp_vfb         ENABLE_DEBUG                  ${v_enable_debug}
            set_instance_parameter_value      isp_vfb         EXTERNAL_MODE                 {1}
            set_instance_parameter_value      isp_vfb         FRAME_DROP_ENABLE             {1}
            set_instance_parameter_value      isp_vfb         FRAME_REPEAT_ENABLE           {1}
            set_instance_parameter_value      isp_vfb         MAX_CONTROL_PACKETS           {0}
            set_instance_parameter_value      isp_vfb         MAX_HEIGHT                    {2160}
            set_instance_parameter_value      isp_vfb         MAX_WIDTH                     {3840}
            set_instance_parameter_value      isp_vfb         MEM_BUFF_BASE_ADDR            {0}
            set_instance_parameter_value      isp_vfb         MEM_BUFF_LINE_STRIDE          {32768}
            set_instance_parameter_value      isp_vfb         MEM_BUFF_STRIDE               {268435456}
            set_instance_parameter_value      isp_vfb         NUMBER_OF_COLOR_PLANES        ${v_cppp}
            set_instance_parameter_value      isp_vfb         PACKING                       {PERFECT}
            set_instance_parameter_value      isp_vfb         PIXELS_IN_PARALLEL            ${v_pip}
            set_instance_parameter_value      isp_vfb         P_AV_MM_ADDR_WIDTH            {32}
            set_instance_parameter_value      isp_vfb         P_AV_MM_DATA_WIDTH            {256}
            if {${v_vid_out_rate} == "p60"} {
                set_instance_parameter_value      isp_vfb       READ_BURST_TARGET             {64}
                set_instance_parameter_value      isp_vfb       READ_FIFO_DEPTH               {1024}
                set_instance_parameter_value      isp_vfb       WRITE_BURST_TARGET            {64}
                set_instance_parameter_value      isp_vfb       WRITE_FIFO_DEPTH              {1024}
            } else {
                set_instance_parameter_value      isp_vfb       READ_BURST_TARGET             {32}
                set_instance_parameter_value      isp_vfb       READ_FIFO_DEPTH               {64}
                set_instance_parameter_value      isp_vfb       WRITE_BURST_TARGET            {32}
                set_instance_parameter_value      isp_vfb       WRITE_FIFO_DEPTH              {64}
            }
            set_instance_parameter_value      isp_vfb         RUNTIME_CONTROL               {1}
            set_instance_parameter_value      isp_vfb         SEPARATE_SLAVE_CLOCK          {1}
        } else {
            # isp_warp
            set_instance_parameter_value      isp_warp        BPS                           ${v_usm_bps}
            set_instance_parameter_value      isp_warp        CACHE_BLOCKS                  ${v_warp_cache_blocks}
            set_instance_parameter_value      isp_warp        C_OMNI_CAP_ID_ASSOCIATED      {0}
            set_instance_parameter_value      isp_warp        C_OMNI_CAP_ID_COMPONENT       {0}
            set_instance_parameter_value      isp_warp        C_OMNI_CAP_IRQ                {255}
            set_instance_parameter_value      isp_warp        C_OMNI_CAP_IRQ_ENABLE         {0}
            set_instance_parameter_value      isp_warp        C_OMNI_CAP_IRQ_ENABLE_EN      {0}
            set_instance_parameter_value      isp_warp        C_OMNI_CAP_IRQ_STATUS         {0}
            set_instance_parameter_value      isp_warp        C_OMNI_CAP_IRQ_STATUS_EN      {0}
            set_instance_parameter_value      isp_warp        C_OMNI_CAP_TAG                {0}
            set_instance_parameter_value      isp_warp        C_OMNI_CAP_TYPE               {367}
            set_instance_parameter_value      isp_warp        C_OMNI_CAP_VERSION            {1}
            set_instance_parameter_value      isp_warp        DEBUG_ENABLE                  ${v_warp_debug}
            set_instance_parameter_value      isp_warp        EASY_WARP                     {0}
            set_instance_parameter_value      isp_warp        EXTERNAL_MODE                 {1}
            set_instance_parameter_value      isp_warp        MAX_INPUT_WIDTH               {3840}
            set_instance_parameter_value      isp_warp        MAX_OUTPUT_WIDTH              {3840}
            set_instance_parameter_value      isp_warp        MEMORY_MAP                    {2}
            set_instance_parameter_value      isp_warp        MIPMAP_ENABLE                 ${v_warp_mipmap_enable}
            set_instance_parameter_value      isp_warp        NUMBER_OF_COLOR_PLANES        ${v_cppp}
            set_instance_parameter_value      isp_warp        NUM_ENGINES                   ${v_num_warp_engines}
            set_instance_parameter_value      isp_warp        PIXELS_IN_PARALLEL            ${v_pip}
            set_instance_parameter_value      isp_warp        SINGLE_BOUNCE                 ${v_warp_single_bounce}
            set_instance_parameter_value      isp_warp        EXT_MEM_DATA_WIDTH            256
        }
        # isp_se_warp
        if {${v_vid_out_rate} == "p60"} {
            set_instance_parameter_value      isp_se_warp       BURSTCOUNT_WIDTH              {7}
        } else {
            set_instance_parameter_value      isp_se_warp       BURSTCOUNT_WIDTH              {6}
        }
        set_instance_parameter_value      isp_se_warp         DATA_WIDTH                    {256}
        set_instance_parameter_value      isp_se_warp         ENABLE_SLAVE_PORT             {0}
        set_instance_parameter_value      isp_se_warp         MASTER_ADDRESS_DEF            {0}
        set_instance_parameter_value      isp_se_warp         MASTER_ADDRESS_WIDTH          {33}
        set_instance_parameter_value      isp_se_warp         MAX_PENDING_READS             {64}
        set_instance_parameter_value      isp_se_warp         SLAVE_ADDRESS_WIDTH           {26}
        set_instance_parameter_value      isp_se_warp         SUB_WINDOW_COUNT              {1}
        set_instance_parameter_value      isp_se_warp         SYNC_RESET                    {0}
    }

    # isp_tpg
    set_instance_parameter_value      isp_tpg       BINARY_DISPLAY_MODE           {Seconds}
    set_instance_parameter_value      isp_tpg       BPS                           ${v_usm_bps}
    set_instance_parameter_value      isp_tpg       CORE_COL_SPACE_0              {0}
    set_instance_parameter_value      isp_tpg       CORE_COL_SPACE_1              {0}
    set_instance_parameter_value      isp_tpg       CORE_COL_SPACE_2              {0}
    set_instance_parameter_value      isp_tpg       CORE_COL_SPACE_3              {0}
    set_instance_parameter_value      isp_tpg       CORE_COL_SPACE_4              {0}
    set_instance_parameter_value      isp_tpg       CORE_COL_SPACE_5              {0}
    set_instance_parameter_value      isp_tpg       CORE_COL_SPACE_6              {0}
    set_instance_parameter_value      isp_tpg       CORE_COL_SPACE_7              {0}
    set_instance_parameter_value      isp_tpg       CORE_PATTERN_0                {1}
    set_instance_parameter_value      isp_tpg       CORE_PATTERN_1                {0}
    set_instance_parameter_value      isp_tpg       CORE_PATTERN_2                {0}
    set_instance_parameter_value      isp_tpg       CORE_PATTERN_3                {0}
    set_instance_parameter_value      isp_tpg       CORE_PATTERN_4                {0}
    set_instance_parameter_value      isp_tpg       CORE_PATTERN_5                {0}
    set_instance_parameter_value      isp_tpg       CORE_PATTERN_6                {0}
    set_instance_parameter_value      isp_tpg       CORE_PATTERN_7                {0}
    set_instance_parameter_value      isp_tpg       C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_tpg       C_OMNI_CAP_ID_COMPONENT       {1}
    set_instance_parameter_value      isp_tpg       C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_tpg       C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_tpg       C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_tpg       C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_tpg       C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_tpg       C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_tpg       C_OMNI_CAP_TYPE               {566}
    set_instance_parameter_value      isp_tpg       C_OMNI_CAP_VERSION            {1}
    set_instance_parameter_value      isp_tpg       ENABLE_CTRL_IN                {0}
    set_instance_parameter_value      isp_tpg       ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value      isp_tpg       EXTERNAL_MODE                 {1}
    set_instance_parameter_value      isp_tpg       FIXED_BARS_MODE               {0}
    set_instance_parameter_value      isp_tpg       FIXED_B_BACKGROUND            {0}
    set_instance_parameter_value      isp_tpg       FIXED_B_CB                    {16}
    set_instance_parameter_value      isp_tpg       FIXED_B_FONT                  {255}
    set_instance_parameter_value      isp_tpg       FIXED_FINE_FACTOR             {256}
    set_instance_parameter_value      isp_tpg       FIXED_FPS                     {60}
    set_instance_parameter_value      isp_tpg       FIXED_G_BACKGROUND            {0}
    set_instance_parameter_value      isp_tpg       FIXED_G_FONT                  {255}
    set_instance_parameter_value      isp_tpg       FIXED_G_Y                     {16}
    set_instance_parameter_value      isp_tpg       FIXED_HEIGHT                  {16384}
    set_instance_parameter_value      isp_tpg       FIXED_INTERLACE               {0}
    set_instance_parameter_value      isp_tpg       FIXED_LOCATION_X              {0}
    set_instance_parameter_value      isp_tpg       FIXED_LOCATION_Y              {0}
    set_instance_parameter_value      isp_tpg       FIXED_POWER_FACTOR            {16}
    set_instance_parameter_value      isp_tpg       FIXED_R_BACKGROUND            {0}
    set_instance_parameter_value      isp_tpg       FIXED_R_CR                    {16}
    set_instance_parameter_value      isp_tpg       FIXED_R_FONT                  {255}
    set_instance_parameter_value      isp_tpg       FIXED_SCALE_FACTOR            {1}
    set_instance_parameter_value      isp_tpg       FIXED_WIDTH                   {16384}
    set_instance_parameter_value      isp_tpg       NUM_CORES                     {2}
    set_instance_parameter_value      isp_tpg       OUTPUT_FORMAT                 {4.4.4}
    set_instance_parameter_value      isp_tpg       PIPELINE_READY                ${v_pipeline_ready}
    set_instance_parameter_value      isp_tpg       PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_tpg       RUNTIME_CONTROL               {1}
    set_instance_parameter_value      isp_tpg       SEPARATE_SLAVE_CLOCK          {1}
    set_instance_parameter_value      isp_tpg       SLAVE_PROTOCOL                {Avalon}

    # isp_icon
    set_instance_parameter_value      isp_icon      BPS                           ${v_usm_bps}
    set_instance_parameter_value      isp_icon      EXTERNAL_MODE                 {1}
    set_instance_parameter_value      isp_icon      PIPELINE_READY                ${v_pipeline_ready}
    set_instance_parameter_value      isp_icon      PIXELS_IN_PARALLEL            ${v_pip}

    # isp_mixer
    set_instance_parameter_value      isp_mixer       BLENDING_MODE_1               {0}
    if {${v_ai_en}} {
        set_instance_parameter_value      isp_mixer     NUM_LAYERS                    {4}
        set_instance_parameter_value      isp_mixer     BLENDING_MODE_2               {2}
        set_instance_parameter_value      isp_mixer     BLENDING_MODE_3               {1}
        set_instance_parameter_value      isp_mixer     RESTRICTED_OFFSETS_3          {1}
    } else {
        set_instance_parameter_value      isp_mixer     NUM_LAYERS                    {3}
        set_instance_parameter_value      isp_mixer     BLENDING_MODE_2               {1}
        set_instance_parameter_value      isp_mixer     BLENDING_MODE_3               {0}
        set_instance_parameter_value      isp_mixer     RESTRICTED_OFFSETS_3          {0}
    }
    set_instance_parameter_value      isp_mixer       BLENDING_MODE_4               {0}
    set_instance_parameter_value      isp_mixer       BLENDING_MODE_5               {0}
    set_instance_parameter_value      isp_mixer       BLENDING_MODE_6               {0}
    set_instance_parameter_value      isp_mixer       BLENDING_MODE_7               {0}
    set_instance_parameter_value      isp_mixer       BPS                           ${v_usm_bps}
    set_instance_parameter_value      isp_mixer       C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_mixer       C_OMNI_CAP_ID_COMPONENT       {0}
    set_instance_parameter_value      isp_mixer       C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_mixer       C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_mixer       C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_mixer       C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_mixer       C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_mixer       C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_mixer       C_OMNI_CAP_TYPE               {563}
    set_instance_parameter_value      isp_mixer       C_OMNI_CAP_VERSION            {1}
    set_instance_parameter_value      isp_mixer       DO_ROUNDING                   {0}
    set_instance_parameter_value      isp_mixer       ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value      isp_mixer       EXPORT_PROBES                 {0}
    set_instance_parameter_value      isp_mixer       EXTERNAL_MODE                 {1}
    set_instance_parameter_value      isp_mixer       NUMBER_OF_COLOR_PLANES        ${v_cppp}
    set_instance_parameter_value      isp_mixer       PIPELINE_LEVEL                {1}
    set_instance_parameter_value      isp_mixer       PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_mixer       P_CORE_CTRL_ID                {0}
    set_instance_parameter_value      isp_mixer       P_UPDATE_CMD_SUPPORTED        {0}
    set_instance_parameter_value      isp_mixer       RESTRICTED_OFFSETS_1          {1}
    set_instance_parameter_value      isp_mixer       RESTRICTED_OFFSETS_2          {1}
    set_instance_parameter_value      isp_mixer       RESTRICTED_OFFSETS_4          {0}
    set_instance_parameter_value      isp_mixer       RESTRICTED_OFFSETS_5          {0}
    set_instance_parameter_value      isp_mixer       RESTRICTED_OFFSETS_6          {0}
    set_instance_parameter_value      isp_mixer       RESTRICTED_OFFSETS_7          {0}
    set_instance_parameter_value      isp_mixer       RUNTIME_CONTROL               {1}
    set_instance_parameter_value      isp_mixer       SEPARATE_SLAVE_CLOCK          {1}
    set_instance_parameter_value      isp_mixer       SLAVE_PROTOCOL                {Avalon}

    # isp_1d_lut
    set_instance_parameter_value      isp_1d_lut      AV_MAX_PENDING_READS          {8}
    set_instance_parameter_value      isp_1d_lut      BITS_LUT                      {9}
    set_instance_parameter_value      isp_1d_lut      BITS_STEP                     {2}
    set_instance_parameter_value      isp_1d_lut      BPS_IN                        ${v_usm_bps}
    set_instance_parameter_value      isp_1d_lut      BPS_OUT                       ${v_isp_bps}
    set_instance_parameter_value      isp_1d_lut      C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_1d_lut      C_OMNI_CAP_ID_COMPONENT       {0}
    set_instance_parameter_value      isp_1d_lut      C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_1d_lut      C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_1d_lut      C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_1d_lut      C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_1d_lut      C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_1d_lut      C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_1d_lut      C_OMNI_CAP_TYPE               {381}
    set_instance_parameter_value      isp_1d_lut      C_OMNI_CAP_VERSION            {1}
    set_instance_parameter_value      isp_1d_lut      DUPLICATE_AND_BYPASS          {0}
    set_instance_parameter_value      isp_1d_lut      ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value      isp_1d_lut      ENABLE_EXT_DATA_RW            {0}
    set_instance_parameter_value      isp_1d_lut      EQUIDISTANT                   {0}
    set_instance_parameter_value      isp_1d_lut      EXTERNAL_MODE                 {1}
    set_instance_parameter_value      isp_1d_lut      H_TAPS                        {1}
    set_instance_parameter_value      isp_1d_lut      MAX_HEIGHT                    {4096}
    set_instance_parameter_value      isp_1d_lut      MAX_WIDTH                     {4096}
    set_instance_parameter_value      isp_1d_lut      NO_BLANKING                   {1}
    set_instance_parameter_value      isp_1d_lut      NUMBER_OF_COLOR_PLANES        ${v_cppp}
    set_instance_parameter_value      isp_1d_lut      PIPELINE_DATA_MM              {0}
    set_instance_parameter_value      isp_1d_lut      PIPELINE_READY                ${v_pipeline_ready}
    set_instance_parameter_value      isp_1d_lut      PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_1d_lut      P_CORE_CTRL_ID                {0}
    set_instance_parameter_value      isp_1d_lut      P_UPDATE_CMD_SUPPORTED        {0}
    set_instance_parameter_value      isp_1d_lut      REVERSE_LUT                   {0}
    set_instance_parameter_value      isp_1d_lut      RUNTIME_CONTROL               {1}
    set_instance_parameter_value      isp_1d_lut      SEPARATE_SLAVE_CLOCK          {1}
    set_instance_parameter_value      isp_1d_lut      SLAVE_PROTOCOL                {Avalon}
    set_instance_parameter_value      isp_1d_lut      V_TAPS                        {1}

    # isp_switch_cap
    set_instance_parameter_value      isp_switch_cap      BPS                           ${v_isp_bps}
    set_instance_parameter_value      isp_switch_cap      CRASH_SWITCH                  ${v_cap_async_ip_sw}
    set_instance_parameter_value      isp_switch_cap      C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_switch_cap      C_OMNI_CAP_ID_COMPONENT       {5}
    set_instance_parameter_value      isp_switch_cap      C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_switch_cap      C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_switch_cap      C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_switch_cap      C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_switch_cap      C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_switch_cap      C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_switch_cap      C_OMNI_CAP_TYPE               {565}
    set_instance_parameter_value      isp_switch_cap      C_OMNI_CAP_VERSION            {2}
    set_instance_parameter_value      isp_switch_cap      ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value      isp_switch_cap      EXTERNAL_MODE                 {0}
    set_instance_parameter_value      isp_switch_cap      NUMBER_OF_COLOR_PLANES        ${v_cppp}
    set_instance_parameter_value      isp_switch_cap      NUM_INPUTS                    {2}
    set_instance_parameter_value      isp_switch_cap      NUM_OUTPUTS                   {2}
    set_instance_parameter_value      isp_switch_cap      PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_switch_cap      SEPARATE_SLAVE_CLOCK          {1}
    set_instance_parameter_value      isp_switch_cap      SLAVE_PROTOCOL                {Avalon}
    set_instance_parameter_value      isp_switch_cap      UNINTERRUPTED_INPUTS          ${v_cap_sync_ip_sw}
    set_instance_parameter_value      isp_switch_cap      USE_OP_RESP                   {0}
    set_instance_parameter_value      isp_switch_cap      USE_TREADIES                  {1}
    set_instance_parameter_value      isp_switch_cap      VVP_INTF_TYPE                 {VVP_LITE}

    # isp_pix_adapt_out
    set_instance_parameter_value      isp_pix_adapt_out      BPS_IN                        ${v_isp_bps}
    set_instance_parameter_value      isp_pix_adapt_out      BPS_OUT                       ${v_vid_out_bps}
    set_instance_parameter_value      isp_pix_adapt_out      ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value      isp_pix_adapt_out      EXTERNAL_MODE                 {1}
    set_instance_parameter_value      isp_pix_adapt_out      NUMBER_OF_COLOR_PLANES        ${v_cppp}
    set_instance_parameter_value      isp_pix_adapt_out      PIPELINE_READY                ${v_pipeline_ready}
    set_instance_parameter_value      isp_pix_adapt_out      PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_pix_adapt_out      P_CORE_CTRL_ID                {0}
    set_instance_parameter_value      isp_pix_adapt_out      P_UPDATE_CMD_SUPPORTED        {0}
    set_instance_parameter_value      isp_pix_adapt_out      RUNTIME_CONTROL               {0}
    set_instance_parameter_value      isp_pix_adapt_out      SEPARATE_SLAVE_CLOCK          {0}
    set_instance_parameter_value      isp_pix_adapt_out      SLAVE_PROTOCOL                {Avalon}

    # isp_vfw
    set_instance_parameter_value      isp_vfw         BPS                           ${v_isp_bps}
    set_instance_parameter_value      isp_vfw         CLOCKS_ARE_SEPARATE           {1}
    set_instance_parameter_value      isp_vfw         C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_vfw         C_OMNI_CAP_ID_COMPONENT       {0}
    set_instance_parameter_value      isp_vfw         C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_vfw         C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_vfw         C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_vfw         C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_vfw         C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_vfw         C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_vfw         C_OMNI_CAP_TYPE               {585}
    set_instance_parameter_value      isp_vfw         C_OMNI_CAP_VERSION            {1}
    set_instance_parameter_value      isp_vfw         ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value      isp_vfw         EXTERNAL_MODE                 {1}
    set_instance_parameter_value      isp_vfw         MAX_HEIGHT                    {4096}
    set_instance_parameter_value      isp_vfw         MAX_WIDTH                     {4096}
    set_instance_parameter_value      isp_vfw         NUMBER_OF_COLOR_PLANES        ${v_cppp}
    set_instance_parameter_value      isp_vfw         PACKING                       {PERFECT}
    set_instance_parameter_value      isp_vfw         PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_vfw         P_AV_MM_ADDR_WIDTH            {32}
    set_instance_parameter_value      isp_vfw         P_AV_MM_DATA_WIDTH            {256}
    set_instance_parameter_value      isp_vfw         SEPARATE_SLAVE_CLOCK          {1}
    set_instance_parameter_value      isp_vfw         SLAVE_PROTOCOL                {Avalon}
    # p60 or p30 1PIP is faster clock
    if {(${v_vid_out_rate} == "p60") || (${v_pip} == 1)} {
        set_instance_parameter_value      isp_vfw         WRITE_BURST_TARGET            {64}
        set_instance_parameter_value      isp_vfw         WRITE_FIFO_DEPTH              {1024}
    } else {
        set_instance_parameter_value      isp_vfw         WRITE_BURST_TARGET            {32}
        set_instance_parameter_value      isp_vfw         WRITE_FIFO_DEPTH              {64}
    }

    # isp_se_vfw
    # p60 or p30 1PIP is faster clock
    if {(${v_vid_out_rate} == "p60") || (${v_pip} == 1)} {
        set_instance_parameter_value      isp_se_vfw      BURSTCOUNT_WIDTH              {7}
    } else {
        set_instance_parameter_value      isp_se_vfw      BURSTCOUNT_WIDTH              {6}
    }
    set_instance_parameter_value      isp_se_vfw      DATA_WIDTH                    {256}
    set_instance_parameter_value      isp_se_vfw      ENABLE_SLAVE_PORT             {0}
    set_instance_parameter_value      isp_se_vfw      MASTER_ADDRESS_DEF            {0}
    set_instance_parameter_value      isp_se_vfw      MASTER_ADDRESS_WIDTH          {33}
    set_instance_parameter_value      isp_se_vfw      MAX_PENDING_READS             {8}
    set_instance_parameter_value      isp_se_vfw      SLAVE_ADDRESS_WIDTH           {26}
    set_instance_parameter_value      isp_se_vfw      SUB_WINDOW_COUNT              {1}
    set_instance_parameter_value      isp_se_vfw      SYNC_RESET                    {0}


    ############################
    #### Create Connections ####
    ############################

    # isp_cpu_clk_bridge
    add_connection         isp_cpu_clk_bridge.out_clk         isp_cpu_rst_bridge.clk
    add_connection         isp_cpu_clk_bridge.out_clk         isp_mm_bridge.clk
    add_connection         isp_cpu_clk_bridge.out_clk         isp_bls.agent_clock
    add_connection         isp_cpu_clk_bridge.out_clk         isp_clipper.agent_clock
    add_connection         isp_cpu_clk_bridge.out_clk         isp_switch_raw_cap.agent_clock
    add_connection         isp_cpu_clk_bridge.out_clk         isp_cpm.agent_clock
    add_connection         isp_cpu_clk_bridge.out_clk         isp_dpc.agent_clock
    add_connection         isp_cpu_clk_bridge.out_clk         isp_anr.agent_clock
    add_connection         isp_cpu_clk_bridge.out_clk         isp_blc.agent_clock
    add_connection         isp_cpu_clk_bridge.out_clk         isp_vc.agent_clock
    add_connection         isp_cpu_clk_bridge.out_clk         isp_switch_wbs.agent_clock
    add_connection         isp_cpu_clk_bridge.out_clk         isp_wbc.agent_clock
    add_connection         isp_cpu_clk_bridge.out_clk         isp_wbs.agent_clock
    add_connection         isp_cpu_clk_bridge.out_clk         isp_dms.agent_clock
    add_connection         isp_cpu_clk_bridge.out_clk         isp_hs.agent_clock
    add_connection         isp_cpu_clk_bridge.out_clk         isp_ccm.agent_clock
    if {${v_hdr_en}} {
        add_connection         isp_cpu_clk_bridge.out_clk       isp_1d_lut_hdr.agent_clock
        add_connection         isp_cpu_clk_bridge.out_clk       isp_3d_lut_hdr_1.cpu_clock
    }
    add_connection         isp_cpu_clk_bridge.out_clk         isp_3d_lut_hdr_2.cpu_clock
    add_connection         isp_cpu_clk_bridge.out_clk         isp_tmo.external_cpu_clock
    add_connection         isp_cpu_clk_bridge.out_clk         isp_usm.agent_clock
    if {${v_ai_en} == 0} {
        if {${v_no_warp}} {
            add_connection         isp_cpu_clk_bridge.out_clk     isp_vfb.control_clock
        } else {
            add_connection         isp_cpu_clk_bridge.out_clk     isp_warp.av_mm_control_agent_clock
        }
    }
    add_connection         isp_cpu_clk_bridge.out_clk         isp_tpg.agent_clock
    add_connection         isp_cpu_clk_bridge.out_clk         isp_mixer.agent_clock
    add_connection         isp_cpu_clk_bridge.out_clk         isp_1d_lut.agent_clock
    add_connection         isp_cpu_clk_bridge.out_clk         isp_switch_cap.agent_clock
    add_connection         isp_cpu_clk_bridge.out_clk         isp_vfw.control_clock

    # isp_cpu_rst_bridge
    add_connection      isp_cpu_rst_bridge.out_reset          isp_mm_bridge.reset
    add_connection      isp_cpu_rst_bridge.out_reset          isp_bls.agent_reset
    add_connection      isp_cpu_rst_bridge.out_reset          isp_clipper.agent_reset
    add_connection      isp_cpu_rst_bridge.out_reset          isp_switch_raw_cap.agent_reset
    add_connection      isp_cpu_rst_bridge.out_reset          isp_cpm.agent_reset
    add_connection      isp_cpu_rst_bridge.out_reset          isp_dpc.agent_reset
    add_connection      isp_cpu_rst_bridge.out_reset          isp_anr.agent_reset
    add_connection      isp_cpu_rst_bridge.out_reset          isp_blc.agent_reset
    add_connection      isp_cpu_rst_bridge.out_reset          isp_vc.agent_reset
    add_connection      isp_cpu_rst_bridge.out_reset          isp_switch_wbs.agent_reset
    add_connection      isp_cpu_rst_bridge.out_reset          isp_wbc.agent_reset
    add_connection      isp_cpu_rst_bridge.out_reset          isp_wbs.agent_reset
    add_connection      isp_cpu_rst_bridge.out_reset          isp_dms.agent_reset
    add_connection      isp_cpu_rst_bridge.out_reset          isp_hs.agent_reset
    add_connection      isp_cpu_rst_bridge.out_reset          isp_ccm.agent_reset
    if {${v_hdr_en}} {
        add_connection    isp_cpu_rst_bridge.out_reset          isp_1d_lut_hdr.agent_reset
        add_connection    isp_cpu_rst_bridge.out_reset          isp_3d_lut_hdr_1.cpu_reset
    }
    add_connection      isp_cpu_rst_bridge.out_reset          isp_3d_lut_hdr_2.cpu_reset
    add_connection      isp_cpu_rst_bridge.out_reset          isp_tmo.external_cpu_reset
    add_connection      isp_cpu_rst_bridge.out_reset          isp_usm.agent_reset
    if {${v_ai_en} == 0} {
        if {${v_no_warp}} {
            add_connection    isp_cpu_rst_bridge.out_reset        isp_vfb.control_reset
        } else {
            add_connection    isp_cpu_rst_bridge.out_reset        isp_warp.av_mm_control_agent_reset
        }
    }
    add_connection      isp_cpu_rst_bridge.out_reset          isp_tpg.agent_reset
    add_connection      isp_cpu_rst_bridge.out_reset          isp_mixer.agent_reset
    add_connection      isp_cpu_rst_bridge.out_reset          isp_1d_lut.agent_reset
    add_connection      isp_cpu_rst_bridge.out_reset          isp_switch_cap.agent_reset
    add_connection      isp_cpu_rst_bridge.out_reset          isp_vfw.control_reset

    # isp_vid_clk_bridge
    add_connection         isp_vid_clk_bridge.out_clk           isp_vid_rst_bridge.clk
    add_connection         isp_vid_clk_bridge.out_clk           isp_bls.main_clock
    add_connection         isp_vid_clk_bridge.out_clk           isp_clipper.main_clock
    add_connection         isp_vid_clk_bridge.out_clk           isp_switch_raw_cap.main_clock
    add_connection         isp_vid_clk_bridge.out_clk           isp_cpm.main_clock
    add_connection         isp_vid_clk_bridge.out_clk           isp_dpc.main_clock
    add_connection         isp_vid_clk_bridge.out_clk           isp_anr.main_clock
    add_connection         isp_vid_clk_bridge.out_clk           isp_blc.main_clock
    add_connection         isp_vid_clk_bridge.out_clk           isp_vc.main_clock
    add_connection         isp_vid_clk_bridge.out_clk           isp_switch_wbs.main_clock
    add_connection         isp_vid_clk_bridge.out_clk           isp_wbc.main_clock
    add_connection         isp_vid_clk_bridge.out_clk           isp_wbs.main_clock
    add_connection         isp_vid_clk_bridge.out_clk           isp_dms.main_clock
    add_connection         isp_vid_clk_bridge.out_clk           isp_hs.main_clock
    add_connection         isp_vid_clk_bridge.out_clk           isp_ccm.main_clock
    if {${v_hdr_en}} {
        add_connection         isp_vid_clk_bridge.out_clk           isp_1d_lut_hdr.main_clock
        add_connection         isp_vid_clk_bridge.out_clk           isp_3d_lut_hdr_1.vid_clock
    }
    add_connection         isp_vid_clk_bridge.out_clk           isp_3d_lut_hdr_2.vid_clock
    add_connection         isp_vid_clk_bridge.out_clk           isp_tmo.vid_clock
    add_connection         isp_vid_clk_bridge.out_clk           isp_pix_adapt_tmo.main_clock
    add_connection         isp_vid_clk_bridge.out_clk           isp_usm.main_clock
    if {${v_ai_en} == 0} {
        if {${v_no_warp}} {
            add_connection         isp_vid_clk_bridge.out_clk           isp_vfb.main_clock
        } else {
            add_connection         isp_vid_clk_bridge.out_clk           isp_warp.core_clock
            add_connection         isp_vid_clk_bridge.out_clk           isp_warp.axi4s_vid_in_0_clock
            add_connection         isp_vid_clk_bridge.out_clk           isp_warp.axi4s_vid_out_0_clock
        }
    }
    add_connection         isp_vid_clk_bridge.out_clk           isp_tpg.main_clock
    add_connection         isp_vid_clk_bridge.out_clk           isp_icon.main_clock
    add_connection         isp_vid_clk_bridge.out_clk           isp_mixer.main_clock
    add_connection         isp_vid_clk_bridge.out_clk           isp_1d_lut.main_clock
    add_connection         isp_vid_clk_bridge.out_clk           isp_switch_cap.main_clock
    add_connection         isp_vid_clk_bridge.out_clk           isp_pix_adapt_out.main_clock
    add_connection         isp_vid_clk_bridge.out_clk           isp_vfw.main_clock

    # isp_vid_rst_bridge
    add_connection         isp_vid_rst_bridge.out_reset         isp_bls.main_reset
    add_connection         isp_vid_rst_bridge.out_reset         isp_clipper.main_reset
    add_connection         isp_vid_rst_bridge.out_reset         isp_switch_raw_cap.main_reset
    add_connection         isp_vid_rst_bridge.out_reset         isp_cpm.main_reset
    add_connection         isp_vid_rst_bridge.out_reset         isp_dpc.main_reset
    add_connection         isp_vid_rst_bridge.out_reset         isp_anr.main_reset
    add_connection         isp_vid_rst_bridge.out_reset         isp_blc.main_reset
    add_connection         isp_vid_rst_bridge.out_reset         isp_vc.main_reset
    add_connection         isp_vid_rst_bridge.out_reset         isp_switch_wbs.main_reset
    add_connection         isp_vid_rst_bridge.out_reset         isp_wbc.main_reset
    add_connection         isp_vid_rst_bridge.out_reset         isp_wbs.main_reset
    add_connection         isp_vid_rst_bridge.out_reset         isp_dms.main_reset
    add_connection         isp_vid_rst_bridge.out_reset         isp_hs.main_reset
    add_connection         isp_vid_rst_bridge.out_reset         isp_ccm.main_reset
    if {${v_hdr_en}} {
        add_connection         isp_vid_rst_bridge.out_reset         isp_1d_lut_hdr.main_reset
        add_connection         isp_vid_rst_bridge.out_reset         isp_3d_lut_hdr_1.vid_reset
    }
    add_connection         isp_vid_rst_bridge.out_reset         isp_3d_lut_hdr_2.vid_reset
    add_connection         isp_vid_rst_bridge.out_reset         isp_tmo.vid_reset
    add_connection         isp_vid_rst_bridge.out_reset         isp_pix_adapt_tmo.main_reset
    add_connection         isp_vid_rst_bridge.out_reset         isp_usm.main_reset
    if {${v_ai_en} == 0} {
        if {${v_no_warp}} {
            add_connection         isp_vid_rst_bridge.out_reset         isp_vfb.main_reset
        } else {
            add_connection         isp_vid_rst_bridge.out_reset         isp_warp.core_reset
            add_connection         isp_vid_rst_bridge.out_reset         isp_warp.axi4s_vid_in_0_reset
            add_connection         isp_vid_rst_bridge.out_reset         isp_warp.axi4s_vid_out_0_reset
        }
    }
    add_connection         isp_vid_rst_bridge.out_reset         isp_tpg.main_reset
    add_connection         isp_vid_rst_bridge.out_reset         isp_icon.main_reset
    add_connection         isp_vid_rst_bridge.out_reset         isp_mixer.main_reset
    add_connection         isp_vid_rst_bridge.out_reset         isp_1d_lut.main_reset
    add_connection         isp_vid_rst_bridge.out_reset         isp_switch_cap.main_reset
    add_connection         isp_vid_rst_bridge.out_reset         isp_pix_adapt_out.main_reset
    add_connection         isp_vid_rst_bridge.out_reset         isp_vfw.main_reset

    # isp_niosv_clk_bridge
    add_connection         isp_niosv_clk_bridge.out_clk         isp_niosv_rst_bridge.clk
    add_connection         isp_niosv_clk_bridge.out_clk         isp_tmo.internal_cpu_clock

    # isp_niosv_rst_bridge
    add_connection         isp_niosv_rst_bridge.out_reset       isp_tmo.internal_cpu_reset

    # isp_emif_clk_bridge
    add_connection         isp_emif_clk_bridge.out_clk          isp_emif_rst_bridge.clk
    if {${v_ai_en} == 0} {
        if {${v_no_warp}} {
            add_connection         isp_emif_clk_bridge.out_clk          isp_vfb.mem_clock
        } else {
            add_connection         isp_emif_clk_bridge.out_clk          isp_warp.av_mm_memory_host_clock
        }
        add_connection         isp_emif_clk_bridge.out_clk          isp_se_warp.clock
    }
    add_connection         isp_emif_clk_bridge.out_clk          isp_vfw.mem_clock
    add_connection         isp_emif_clk_bridge.out_clk          isp_se_vfw.clock

    # isp_emif_rst_bridge
    if {${v_ai_en} == 0} {
        if {${v_no_warp}} {
            add_connection         isp_emif_rst_bridge.out_reset        isp_vfb.mem_reset
        } else {
            add_connection         isp_emif_rst_bridge.out_reset        isp_warp.av_mm_memory_host_reset
        }
        add_connection         isp_emif_rst_bridge.out_reset        isp_se_warp.reset
    }
    add_connection         isp_emif_rst_bridge.out_reset        isp_vfw.mem_reset
    add_connection         isp_emif_rst_bridge.out_reset        isp_se_vfw.reset

    # isp_mm_bridge
    add_connection          isp_mm_bridge.m0            isp_bls.av_mm_control_agent
    add_connection          isp_mm_bridge.m0            isp_clipper.av_mm_control_agent
    add_connection          isp_mm_bridge.m0            isp_switch_raw_cap.av_mm_control_agent
    add_connection          isp_mm_bridge.m0            isp_cpm.av_mm_control_agent
    add_connection          isp_mm_bridge.m0            isp_dpc.av_mm_control_agent
    add_connection          isp_mm_bridge.m0            isp_anr.av_mm_control_agent
    add_connection          isp_mm_bridge.m0            isp_blc.av_mm_control_agent
    add_connection          isp_mm_bridge.m0            isp_vc.av_mm_control_agent
    add_connection          isp_mm_bridge.m0            isp_switch_wbs.av_mm_control_agent
    add_connection          isp_mm_bridge.m0            isp_wbc.av_mm_control_agent
    add_connection          isp_mm_bridge.m0            isp_wbs.av_mm_control_agent
    add_connection          isp_mm_bridge.m0            isp_dms.av_mm_control_agent
    add_connection          isp_mm_bridge.m0            isp_hs.av_mm_control_agent
    add_connection          isp_mm_bridge.m0            isp_ccm.av_mm_control_agent
    if {${v_hdr_en}} {
        add_connection        isp_mm_bridge.m0            isp_1d_lut_hdr.av_mm_control_agent
        add_connection        isp_mm_bridge.m0            isp_3d_lut_hdr_1.av_mm_cpu_agent
    }
    add_connection          isp_mm_bridge.m0            isp_3d_lut_hdr_2.av_mm_cpu_agent
    add_connection          isp_mm_bridge.m0            isp_tmo.av_mm_cpu_agent
    add_connection          isp_mm_bridge.m0            isp_usm.av_mm_control_agent
    if {${v_ai_en} == 0} {
        if {${v_no_warp}} {
            add_connection      isp_mm_bridge.m0            isp_vfb.av_mm_control_agent
        } else {
            add_connection      isp_mm_bridge.m0            isp_warp.av_mm_control_agent
        }
    }
    add_connection          isp_mm_bridge.m0            isp_tpg.av_mm_control_agent
    add_connection          isp_mm_bridge.m0            isp_mixer.av_mm_control_agent
    add_connection          isp_mm_bridge.m0            isp_1d_lut.av_mm_control_agent
    add_connection          isp_mm_bridge.m0            isp_switch_cap.av_mm_control_agent
    add_connection          isp_mm_bridge.m0            isp_vfw.av_mm_control_agent

    # isp_bls
    add_connection         isp_bls.axi4s_vid_out        isp_clipper.axi4s_vid_in

    # isp_clipper
    add_connection         isp_clipper.axi4s_vid_out      isp_switch_raw_cap.axi4s_vid_in_0

    # isp_switch_raw_cap
    add_connection         isp_switch_raw_cap.axi4s_vid_out_0         isp_dpc.axi4s_vid_in
    add_connection         isp_switch_raw_cap.axi4s_vid_out_1         isp_cpm.axi4s_vid_in

    # isp_cpm
    add_connection         isp_cpm.axi4s_vid_out          isp_switch_cap.axi4s_vid_in_1

    # isp_dpc
    add_connection         isp_dpc.axi4s_vid_out          isp_anr.axi4s_vid_in

    # isp_anr
    add_connection         isp_anr.axi4s_vid_out          isp_blc.axi4s_vid_in

    # isp_blc
    add_connection         isp_blc.axi4s_vid_out          isp_vc.axi4s_vid_in

    # isp_vc
    add_connection         isp_vc.axi4s_vid_out           isp_switch_wbs.axi4s_vid_in_0

    # isp_switch_wbs
    add_connection         isp_switch_wbs.axi4s_vid_out_0         isp_wbc.axi4s_vid_in
    add_connection         isp_switch_wbs.axi4s_vid_out_1         isp_wbs.axi4s_vid_in
    add_connection         isp_switch_wbs.axi4s_vid_out_2         isp_dms.axi4s_vid_in

    # isp_wbc
    add_connection         isp_wbc.axi4s_vid_out          isp_switch_wbs.axi4s_vid_in_1

    # isp_wbs
    add_connection         isp_wbs.axi4s_vid_out          isp_switch_wbs.axi4s_vid_in_2

    # isp_dms
    add_connection         isp_dms.axi4s_vid_out          isp_hs.axi4s_vid_in

    # isp_hs
    add_connection         isp_hs.axi4s_vid_out           isp_ccm.axi4s_vid_in

    if {${v_hdr_en}} {
        # isp_ccm
        add_connection         isp_ccm.axi4s_vid_out        isp_1d_lut_hdr.axi4s_vid_in

        # isp_1d_lut_hdr
        add_connection         isp_1d_lut_hdr.axi4s_vid_out       isp_3d_lut_hdr_1.axi4s_vid_in

        # isp_3d_lut_hdr_1
        add_connection         isp_3d_lut_hdr_1.axi4s_vid_out     isp_3d_lut_hdr_2.axi4s_vid_in
    } else {
        # isp_ccm
        add_connection         isp_ccm.axi4s_vid_out              isp_3d_lut_hdr_2.axi4s_vid_in
    }

    # isp_3d_lut_hdr_2
    add_connection         isp_3d_lut_hdr_2.axi4s_vid_out       isp_tmo.axi4s_vid_in

    # isp_tmo
    add_connection         isp_tmo.axi4s_vid_out                isp_pix_adapt_tmo.axi4s_vid_in

    # isp_pix_adapt_tmo
    add_connection         isp_pix_adapt_tmo.axi4s_vid_out      isp_usm.axi4s_vid_in

    if {${v_ai_en} == 0} {
        if {${v_no_warp}} {
            # isp_usm
            add_connection         isp_usm.axi4s_vid_out                  isp_vfb.axi4s_vid_in
            # isp_vfb
            add_connection         isp_vfb.axi4s_vid_out                  isp_mixer.axi4s_vid_1_in
            add_connection         isp_vfb.av_mm_mem_write_host           isp_se_warp.windowed_slave
            add_connection         isp_vfb.av_mm_mem_read_host            isp_se_warp.windowed_slave
        } else {
            # isp_usm
            add_connection         isp_usm.axi4s_vid_out                  isp_warp.axi4s_vid_in_0
            # isp_warp
            add_connection         isp_warp.axi4s_vid_out_0               isp_mixer.axi4s_vid_1_in
            add_connection         isp_warp.av_mm_memory_host             isp_se_warp.windowed_slave
        }
    }

    # isp_tpg
    add_connection         isp_tpg.axi4s_vid_out              isp_mixer.axi4s_vid_0_in

    # isp_icon
    if {${v_ai_en}} {
        add_connection         isp_icon.axi4s_vid_out           isp_mixer.axi4s_vid_3_in
    } else {
        add_connection         isp_icon.axi4s_vid_out           isp_mixer.axi4s_vid_2_in
    }

    # isp_mixer
    add_connection         isp_mixer.axi4s_vid_out            isp_1d_lut.axi4s_vid_in

    # isp_1d_lut
    add_connection         isp_1d_lut.axi4s_vid_out           isp_switch_cap.axi4s_vid_in_0

    # isp_switch_cap
    add_connection         isp_switch_cap.axi4s_vid_out_0           isp_pix_adapt_out.axi4s_vid_in
    add_connection         isp_switch_cap.axi4s_vid_out_1           isp_vfw.axi4s_vid_in

    # isp_vfw
    add_connection         isp_vfw.av_mm_mem_write_host             isp_se_vfw.windowed_slave


    ##########################
    ##### Create Exports #####
    ##########################

    # isp_cpu_clk_bridge
    add_interface           cpu_clk_in    clock       sink
    set_interface_property  cpu_clk_in    EXPORT_OF   isp_cpu_clk_bridge.in_clk

    # isp_cpu_rst_bridge
    add_interface           cpu_rst_in    reset       sink
    set_interface_property  cpu_rst_in    EXPORT_OF   isp_cpu_rst_bridge.in_reset

    # isp_vid_clk_bridge
    set_interface_property  vid_clk_in    EXPORT_OF   isp_vid_clk_bridge.in_clk

    # isp_vid_rst_bridge
    set_interface_property  vid_rst_in    EXPORT_OF   isp_vid_rst_bridge.in_reset

    # isp_niosv_clk_bridge
    set_interface_property  niosv_clk_in  EXPORT_OF   isp_niosv_clk_bridge.in_clk

    # isp_niosv_rst_bridge
    set_interface_property  niosv_rst_in  EXPORT_OF   isp_niosv_rst_bridge.in_reset

    # isp_emif_clk_bridge
    set_interface_property  emif_clk_in   EXPORT_OF   isp_emif_clk_bridge.in_clk

    # isp_emif_rst_bridge
    set_interface_property  emif_rst_in   EXPORT_OF   isp_emif_rst_bridge.in_reset

    # isp_mm_bridge
    add_interface           mm_ctrl_in    avalon      slave
    set_interface_property  mm_ctrl_in    EXPORT_OF   isp_mm_bridge.s0

    # isp_bls
    add_interface           isp_in_s_vid_axis    axi4stream  subordinate
    set_interface_property  isp_in_s_vid_axis    EXPORT_OF   isp_bls.axi4s_vid_in

    if {${v_ai_en}} {
        # isp_usm
        add_interface           isp_out_m_vid_axis        axi4stream  manager
        set_interface_property  isp_out_m_vid_axis        EXPORT_OF   isp_usm.axi4s_vid_out

        # isp_mixer
        add_interface           ai_fres_out_s_vid_axis    axi4stream  subordinate
        set_interface_property  ai_fres_out_s_vid_axis    EXPORT_OF   isp_mixer.axi4s_vid_1_in

        add_interface           ai_res_out_s_vid_axis     axi4stream  subordinate
        set_interface_property  ai_res_out_s_vid_axis     EXPORT_OF   isp_mixer.axi4s_vid_2_in
    } else {
        # isp_se_warp
        set_interface_property  av_mm_host_warp    EXPORT_OF   isp_se_warp.expanded_master
        if {${v_no_warp} == 0} {
            set_interface_property  warp_int      EXPORT_OF   isp_warp.interrupt
        }
    }

    # isp_vfw
    set_interface_property  vfw_int    EXPORT_OF   isp_vfw.frame_writer_int

    # isp_se_vfw
    set_interface_property  av_mm_host_vfw    EXPORT_OF   isp_se_vfw.expanded_master

    # isp_pix_adapt_out
    add_interface           full_isp_out_m_vid_axis    axi4stream  manager
    set_interface_property  full_isp_out_m_vid_axis    EXPORT_OF   isp_pix_adapt_out.axi4s_vid_out


    #################################
    ##### Assign Base Addresses #####
    #################################

    set_connection_parameter_value isp_mm_bridge.m0/isp_bls.av_mm_control_agent             baseAddress "0x00009600"
    set_connection_parameter_value isp_mm_bridge.m0/isp_clipper.av_mm_control_agent         baseAddress "0x00008e00"
    set_connection_parameter_value isp_mm_bridge.m0/isp_switch_raw_cap.av_mm_control_agent  baseAddress "0x0000d200"
    set_connection_parameter_value isp_mm_bridge.m0/isp_cpm.av_mm_control_agent             baseAddress "0x0000da00"
    set_connection_parameter_value isp_mm_bridge.m0/isp_dpc.av_mm_control_agent             baseAddress "0x00008c00"
    set_connection_parameter_value isp_mm_bridge.m0/isp_anr.av_mm_control_agent             baseAddress "0x00010000"
    set_connection_parameter_value isp_mm_bridge.m0/isp_blc.av_mm_control_agent             baseAddress "0x00008a00"
    set_connection_parameter_value isp_mm_bridge.m0/isp_vc.av_mm_control_agent              baseAddress "0x00040000"
    set_connection_parameter_value isp_mm_bridge.m0/isp_switch_wbs.av_mm_control_agent      baseAddress "0x0000d000"
    set_connection_parameter_value isp_mm_bridge.m0/isp_wbc.av_mm_control_agent             baseAddress "0x00009400"
    set_connection_parameter_value isp_mm_bridge.m0/isp_wbs.av_mm_control_agent             baseAddress "0x0000c000"
    set_connection_parameter_value isp_mm_bridge.m0/isp_dms.av_mm_control_agent             baseAddress "0x00009200"
    set_connection_parameter_value isp_mm_bridge.m0/isp_hs.av_mm_control_agent              baseAddress "0x0000b000"
    set_connection_parameter_value isp_mm_bridge.m0/isp_ccm.av_mm_control_agent             baseAddress "0x00009c00"
    if {${v_hdr_en}} {
        set_connection_parameter_value isp_mm_bridge.m0/isp_1d_lut_hdr.av_mm_control_agent  baseAddress "0x00020000"
        set_connection_parameter_value isp_mm_bridge.m0/isp_3d_lut_hdr_1.av_mm_cpu_agent    baseAddress "0x00009a00"
    }
    set_connection_parameter_value isp_mm_bridge.m0/isp_3d_lut_hdr_2.av_mm_cpu_agent        baseAddress "0x00008200"
    set_connection_parameter_value isp_mm_bridge.m0/isp_tmo.av_mm_cpu_agent                 baseAddress "0x00009000"
    set_connection_parameter_value isp_mm_bridge.m0/isp_usm.av_mm_control_agent             baseAddress "0x00009800"
    if {${v_ai_en} == 0} {
        if {${v_no_warp}} {
            set_connection_parameter_value isp_mm_bridge.m0/isp_vfb.av_mm_control_agent     baseAddress "0x00000000"
        } else {
            set_connection_parameter_value isp_mm_bridge.m0/isp_warp.av_mm_control_agent    baseAddress "0x00000000"
        }
    }
    set_connection_parameter_value isp_mm_bridge.m0/isp_tpg.av_mm_control_agent             baseAddress "0x00008800"
    set_connection_parameter_value isp_mm_bridge.m0/isp_mixer.av_mm_control_agent           baseAddress "0x00008400"
    set_connection_parameter_value isp_mm_bridge.m0/isp_1d_lut.av_mm_control_agent          baseAddress "0x0000e000"
    set_connection_parameter_value isp_mm_bridge.m0/isp_switch_cap.av_mm_control_agent      baseAddress "0x0000d800"
    set_connection_parameter_value isp_mm_bridge.m0/isp_vfw.av_mm_control_agent             baseAddress "0x0000d400"

    lock_avalon_base_address  isp_bls.av_mm_control_agent
    lock_avalon_base_address  isp_clipper.av_mm_control_agent
    lock_avalon_base_address  isp_switch_raw_cap.av_mm_control_agent
    lock_avalon_base_address  isp_cpm.av_mm_control_agent
    lock_avalon_base_address  isp_dpc.av_mm_control_agent
    lock_avalon_base_address  isp_anr.av_mm_control_agent
    lock_avalon_base_address  isp_blc.av_mm_control_agent
    lock_avalon_base_address  isp_vc.av_mm_control_agent
    lock_avalon_base_address  isp_switch_wbs.av_mm_control_agent
    lock_avalon_base_address  isp_wbc.av_mm_control_agent
    lock_avalon_base_address  isp_wbs.av_mm_control_agent
    lock_avalon_base_address  isp_dms.av_mm_control_agent
    lock_avalon_base_address  isp_hs.av_mm_control_agent
    lock_avalon_base_address  isp_ccm.av_mm_control_agent
    if {${v_hdr_en}} {
        lock_avalon_base_address  isp_1d_lut_hdr.av_mm_control_agent
        lock_avalon_base_address  isp_3d_lut_hdr_1.av_mm_cpu_agent
    }
    lock_avalon_base_address  isp_3d_lut_hdr_2.av_mm_cpu_agent
    lock_avalon_base_address  isp_tmo.av_mm_cpu_agent
    lock_avalon_base_address  isp_usm.av_mm_control_agent
    if {${v_ai_en} == 0} {
        if {${v_no_warp}} {
            lock_avalon_base_address  isp_vfb.av_mm_control_agent
        } else {
            lock_avalon_base_address  isp_warp.av_mm_control_agent
        }
    }
    lock_avalon_base_address  isp_tpg.av_mm_control_agent
    lock_avalon_base_address  isp_mixer.av_mm_control_agent
    lock_avalon_base_address  isp_1d_lut.av_mm_control_agent
    lock_avalon_base_address  isp_switch_cap.av_mm_control_agent
    lock_avalon_base_address  isp_vfw.av_mm_control_agent

    if {(${v_ai_en} == 0) && (${v_no_warp} == 0)} {
        set_connection_parameter_value isp_warp.av_mm_memory_host/isp_se_warp.windowed_slave \
                                                qsys_mm.burstAdapterImplementation {PER_BURST_TYPE_CONVERTER}
        set_connection_parameter_value isp_warp.av_mm_memory_host/isp_se_warp.windowed_slave \
                                                qsys_mm.widthAdapterImplementation {OPTIMIZED_CONVERTER}
        set_domain_assignment isp_warp.av_mm_memory_host qsys_mm.burstAdapterImplementation PER_BURST_TYPE_CONVERTER
        set_domain_assignment isp_warp.av_mm_memory_host qsys_mm.widthAdapterImplementation OPTIMIZED_CONVERTER
    }

    #############################
    ##### Sync / Validation #####
    #############################

    sync_sysinfo_parameters
    save_system
}


proc  edit_top_level_qsys {} {
    set v_project_name      [get_shell_parameter PROJECT_NAME]
    set v_project_path      [get_shell_parameter PROJECT_PATH]
    set v_instance_name     [get_shell_parameter INSTANCE_NAME]
    set v_ai_en             [get_shell_parameter AI_EN]
    set v_easy_scale_up     [get_shell_parameter EASY_SCALE_UP]

    load_system ${v_project_path}/rtl/${v_project_name}_qsys.qsys

    add_instance ${v_instance_name} ${v_instance_name}

    if {${v_ai_en} && ${v_easy_scale_up}} {
        # isp_mixer
        add_interface           ai_res_out_s_vid_axis     axi4stream  subordinate
        set_interface_property  ai_res_out_s_vid_axis     EXPORT_OF   ${v_instance_name}.ai_res_out_s_vid_axis
    }

    sync_sysinfo_parameters
    save_system
}


proc add_auto_connections {} {
    set v_instance_name       [get_shell_parameter INSTANCE_NAME]
    set v_avmm_host           [get_shell_parameter AVMM_HOST]
    set v_vid_out_rate        [get_shell_parameter VID_OUT_RATE]
    set v_ai_en               [get_shell_parameter AI_EN]
    set v_easy_scale_up       [get_shell_parameter EASY_SCALE_UP]
    set v_pip                 [get_shell_parameter PIP]
    set v_async_clk           [get_shell_parameter ASYNC_CLK]

    if {(${v_ai_en} ) && (${v_easy_scale_up} == 0)} {
        add_auto_connection   ${v_instance_name} ai_res_out_s_vid_axis         ai_box_out_m_vid_axis
    }

     add_auto_connection   ${v_instance_name} cpu_clk_in       200000000
    add_auto_connection   ${v_instance_name} cpu_rst_in       200000000

    if {(${v_vid_out_rate} == "p60") || (${v_pip} == 1)} {
        add_auto_connection   ${v_instance_name} vid_clk_in       297000000
        add_auto_connection   ${v_instance_name} vid_rst_in       297000000
    } else {
        add_auto_connection   ${v_instance_name} vid_clk_in       148500000
        add_auto_connection   ${v_instance_name} vid_rst_in       148500000
    }

    add_auto_connection   ${v_instance_name} niosv_clk_in     200000000
    add_auto_connection   ${v_instance_name} niosv_rst_in     200000000

    # frame writer to DDR4
    if {${v_async_clk} != 0} {
        add_auto_connection   ${v_instance_name} emif_clk_in   [expr ${v_async_clk} * 1000000]
        add_auto_connection   ${v_instance_name} emif_rst_in   [expr ${v_async_clk} * 1000000]
    } else {
        add_auto_connection   ${v_instance_name} emif_clk_in   emif_user_clk
        add_auto_connection   ${v_instance_name} emif_rst_in   emif_user_rst
    }
    add_auto_connection   ${v_instance_name} av_mm_host_vfw   emif_user_data

    # warp to DDR4
    if {${v_ai_en}} {
        # to ai
        add_auto_connection   ${v_instance_name} isp_out_m_vid_axis         isp_out_vid_axis

        # from ai
        add_auto_connection   ${v_instance_name} ai_fres_out_s_vid_axis     ai_in_vid_axis

    } else {
        # Warp or vfb
        add_auto_connection   ${v_instance_name} av_mm_host_warp            emif_user_data
    }

    # from isp in
    add_auto_connection   ${v_instance_name} isp_in_s_vid_axis          isp_in_vid_axis

    # to vid out
    add_auto_connection   ${v_instance_name} full_isp_out_m_vid_axis    full_isp_out_vid_axis

    # HPS to mm bridge
    add_avmm_connections  mm_ctrl_in      ${v_avmm_host}
}

proc modify_avmm_arbitration {} {
    set v_project_name  [get_shell_parameter PROJECT_NAME]
    set v_project_path  [get_shell_parameter PROJECT_PATH]
    set v_instance_name [get_shell_parameter INSTANCE_NAME]
    set v_ai_en         [get_shell_parameter AI_EN]
    set v_no_warp       [get_shell_parameter NO_WARP]

    if {(${v_ai_en} == 0) && (${v_no_warp} == 0)} {
        # Give warp priority in to FPGA EMIF to avoid video glitches at output
        load_system ${v_project_path}/rtl/${v_project_name}_qsys.qsys

        set v_warp_avmm_conn [get_connections ${v_instance_name}.av_mm_host_warp]
        set v_num_conns      [llength ${v_warp_avmm_conn}]

        if {${v_num_conns} > 0} {
            set_connection_parameter_value ${v_warp_avmm_conn} arbitrationPriority {16}
        }

        sync_sysinfo_parameters
        save_system
    }
}
