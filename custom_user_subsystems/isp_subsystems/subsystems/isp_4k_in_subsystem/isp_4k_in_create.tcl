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

set_shell_parameter AVMM_HOST             {{AUTO X}}

# General Video Controls
set_shell_parameter PIP                   {2}
set_shell_parameter VID_OUT_RATE          "p60"
set_shell_parameter EN_DEBUG              {1}

# HDR Controls
set_shell_parameter MULTI_SENSOR          {1}
set_shell_parameter EXP_FUSION_EN         {1}


proc pre_creation_step {} {
    transfer_files
}

proc creation_step {} {
    create_isp_in_subsystem
}

proc post_creation_step {} {
    edit_top_level_qsys
    add_auto_connections
    edit_top_v_file
}

proc transfer_files {} {
    set v_project_path      [get_shell_parameter PROJECT_PATH]
    set v_script_path       [get_shell_parameter SUBSYSTEM_SOURCE_PATH]

    exec cp -rf ${v_script_path}/../../non_qpds_ip/intel_vvp_remosaic         ${v_project_path}/non_qpds_ip/user
    file_copy   ${v_script_path}/../../non_qpds_ip/intel_vvp_remosaic.ipx     ${v_project_path}/non_qpds_ip/user
}

proc create_isp_in_subsystem {} {
    set v_project_path      [get_shell_parameter PROJECT_PATH]
    set v_instance_name     [get_shell_parameter INSTANCE_NAME]
    set v_multi_sensor      [get_shell_parameter MULTI_SENSOR]
    set v_exp_fusion_en     [get_shell_parameter EXP_FUSION_EN]

    # Video Pipeline
    set v_cppp              {3}
    # Exposure Fusion output has increased bps video pipeline
    if {${v_exp_fusion_en}} {
        set v_bps           {16}
    } else {
        set v_bps           {12}
    }
    set v_vid_out_rate      [get_shell_parameter VID_OUT_RATE]
    set v_pip               [get_shell_parameter PIP]

    # ISP Pipeline
    set v_isp_cppp          {1}

    # General
    set v_enable_debug      [get_shell_parameter EN_DEBUG]
    set v_pipeline_ready    {1}

    # Switch Mode - Crash when ASYNC_IP_SW = 1, else Sync Switch on SOF with SYNC_IP_SW = 1, else on EOL
    set v_async_ip_sw       {0}
    set v_sync_ip_sw        {0}


    create_system ${v_instance_name}
    save_system   ${v_project_path}/rtl/user/${v_instance_name}.qsys

    load_system   ${v_project_path}/rtl/user/${v_instance_name}.qsys


    ############################
    #### Add Instances      ####
    ############################

    add_instance  isp_in_cpu_clk_bridge           altera_clock_bridge
    add_instance  isp_in_cpu_rst_bridge           altera_reset_bridge
    add_instance  isp_in_mm_bridge                altera_avalon_mm_bridge
    add_instance  isp_in_vid_clk_bridge           altera_clock_bridge
    add_instance  isp_in_vid_rst_bridge           altera_reset_bridge
    add_instance  isp_in_tpg                      intel_vvp_tpg
    add_instance  isp_in_rms                      intel_vvp_remosaic
    add_instance  isp_in_switch                   intel_vvp_switch


    ############################
    #### Set Parameters     ####
    ############################

    # isp_in_cpu_clk_bridge
    set_instance_parameter_value      isp_in_cpu_clk_bridge       EXPLICIT_CLOCK_RATE     {200000000.0}
    set_instance_parameter_value      isp_in_cpu_clk_bridge       NUM_CLOCK_OUTPUTS       {1}

    # isp_in_cpu_rst_bridge
    set_instance_parameter_value      isp_in_cpu_rst_bridge       ACTIVE_LOW_RESET        {0}
    set_instance_parameter_value      isp_in_cpu_rst_bridge       NUM_RESET_OUTPUTS       {1}
    set_instance_parameter_value      isp_in_cpu_rst_bridge       SYNCHRONOUS_EDGES       {deassert}
    set_instance_parameter_value      isp_in_cpu_rst_bridge       SYNC_RESET              {0}
    set_instance_parameter_value      isp_in_cpu_rst_bridge       USE_RESET_REQUEST       {0}

    # isp_in_mm_bridge
    set_instance_parameter_value      isp_in_mm_bridge          ADDRESS_UNITS                 {SYMBOLS}
    set_instance_parameter_value      isp_in_mm_bridge          ADDRESS_WIDTH                 {0}
    set_instance_parameter_value      isp_in_mm_bridge          DATA_WIDTH                    {32}
    set_instance_parameter_value      isp_in_mm_bridge          LINEWRAPBURSTS                {0}
    set_instance_parameter_value      isp_in_mm_bridge          M0_WAITREQUEST_ALLOWANCE      {0}
    set_instance_parameter_value      isp_in_mm_bridge          MAX_BURST_SIZE                {1}
    set_instance_parameter_value      isp_in_mm_bridge          MAX_PENDING_RESPONSES         {4}
    set_instance_parameter_value      isp_in_mm_bridge          MAX_PENDING_WRITES            {0}
    set_instance_parameter_value      isp_in_mm_bridge          PIPELINE_COMMAND              {1}
    set_instance_parameter_value      isp_in_mm_bridge          PIPELINE_RESPONSE             {1}
    set_instance_parameter_value      isp_in_mm_bridge          S0_WAITREQUEST_ALLOWANCE      {0}
    set_instance_parameter_value      isp_in_mm_bridge          SYMBOL_WIDTH                  {8}
    set_instance_parameter_value      isp_in_mm_bridge          SYNC_RESET                    {0}
    set_instance_parameter_value      isp_in_mm_bridge          USE_AUTO_ADDRESS_WIDTH        {1}
    set_instance_parameter_value      isp_in_mm_bridge          USE_RESPONSE                  {0}
    set_instance_parameter_value      isp_in_mm_bridge          USE_WRITERESPONSE             {0}

    # isp_in_vid_clk_bridge
    if {(${v_vid_out_rate} == "p60") || (${v_pip} == 1)} {
        set_instance_parameter_value      isp_in_vid_clk_bridge     EXPLICIT_CLOCK_RATE     {297000000.0}
    } else {
        set_instance_parameter_value      isp_in_vid_clk_bridge     EXPLICIT_CLOCK_RATE     {148500000.0}
    }
    set_instance_parameter_value      isp_in_vid_clk_bridge       NUM_CLOCK_OUTPUTS       {1}

    # isp_in_vid_rst_bridge
    set_instance_parameter_value      isp_in_vid_rst_bridge       ACTIVE_LOW_RESET              {0}
    set_instance_parameter_value      isp_in_vid_rst_bridge       NUM_RESET_OUTPUTS             {1}
    set_instance_parameter_value      isp_in_vid_rst_bridge       SYNCHRONOUS_EDGES             {deassert}
    set_instance_parameter_value      isp_in_vid_rst_bridge       SYNC_RESET                    {0}
    set_instance_parameter_value      isp_in_vid_rst_bridge       USE_RESET_REQUEST             {0}

    # isp_in_tpg
    set_instance_parameter_value      isp_in_tpg        BINARY_DISPLAY_MODE           {Seconds}
    set_instance_parameter_value      isp_in_tpg        BPS                           ${v_bps}
    set_instance_parameter_value      isp_in_tpg        CORE_COL_SPACE_0              {0}
    set_instance_parameter_value      isp_in_tpg        CORE_COL_SPACE_1              {0}
    set_instance_parameter_value      isp_in_tpg        CORE_COL_SPACE_2              {0}
    set_instance_parameter_value      isp_in_tpg        CORE_COL_SPACE_3              {0}
    set_instance_parameter_value      isp_in_tpg        CORE_COL_SPACE_4              {0}
    set_instance_parameter_value      isp_in_tpg        CORE_COL_SPACE_5              {0}
    set_instance_parameter_value      isp_in_tpg        CORE_COL_SPACE_6              {0}
    set_instance_parameter_value      isp_in_tpg        CORE_COL_SPACE_7              {0}
    set_instance_parameter_value      isp_in_tpg        CORE_PATTERN_0                {0}
    set_instance_parameter_value      isp_in_tpg        CORE_PATTERN_1                {1}
    set_instance_parameter_value      isp_in_tpg        CORE_PATTERN_2                {3}
    set_instance_parameter_value      isp_in_tpg        CORE_PATTERN_3                {0}
    set_instance_parameter_value      isp_in_tpg        CORE_PATTERN_4                {0}
    set_instance_parameter_value      isp_in_tpg        CORE_PATTERN_5                {0}
    set_instance_parameter_value      isp_in_tpg        CORE_PATTERN_6                {0}
    set_instance_parameter_value      isp_in_tpg        CORE_PATTERN_7                {0}
    set_instance_parameter_value      isp_in_tpg        C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_in_tpg        C_OMNI_CAP_ID_COMPONENT       {0}
    set_instance_parameter_value      isp_in_tpg        C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_in_tpg        C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_in_tpg        C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_in_tpg        C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_in_tpg        C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_in_tpg        C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_in_tpg        C_OMNI_CAP_TYPE               {566}
    set_instance_parameter_value      isp_in_tpg        C_OMNI_CAP_VERSION            {1}
    set_instance_parameter_value      isp_in_tpg        ENABLE_CTRL_IN                {0}
    set_instance_parameter_value      isp_in_tpg        ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value      isp_in_tpg        EXTERNAL_MODE                 {1}
    set_instance_parameter_value      isp_in_tpg        FIXED_BARS_MODE               {0}
    set_instance_parameter_value      isp_in_tpg        FIXED_B_BACKGROUND            {0}
    set_instance_parameter_value      isp_in_tpg        FIXED_B_CB                    {16}
    set_instance_parameter_value      isp_in_tpg        FIXED_B_FONT                  {255}
    set_instance_parameter_value      isp_in_tpg        FIXED_FINE_FACTOR             {256}
    set_instance_parameter_value      isp_in_tpg        FIXED_FPS                     {60}
    set_instance_parameter_value      isp_in_tpg        FIXED_G_BACKGROUND            {0}
    set_instance_parameter_value      isp_in_tpg        FIXED_G_FONT                  {255}
    set_instance_parameter_value      isp_in_tpg        FIXED_G_Y                     {16}
    set_instance_parameter_value      isp_in_tpg        FIXED_HEIGHT                  {16384}
    set_instance_parameter_value      isp_in_tpg        FIXED_INTERLACE               {0}
    set_instance_parameter_value      isp_in_tpg        FIXED_LOCATION_X              {0}
    set_instance_parameter_value      isp_in_tpg        FIXED_LOCATION_Y              {0}
    set_instance_parameter_value      isp_in_tpg        FIXED_POWER_FACTOR            {16}
    set_instance_parameter_value      isp_in_tpg        FIXED_R_BACKGROUND            {0}
    set_instance_parameter_value      isp_in_tpg        FIXED_R_CR                    {16}
    set_instance_parameter_value      isp_in_tpg        FIXED_R_FONT                  {255}
    set_instance_parameter_value      isp_in_tpg        FIXED_SCALE_FACTOR            {1}
    set_instance_parameter_value      isp_in_tpg        FIXED_WIDTH                   {16384}
    set_instance_parameter_value      isp_in_tpg        NUM_CORES                     {2}
    set_instance_parameter_value      isp_in_tpg        OUTPUT_FORMAT                 {4.4.4}
    set_instance_parameter_value      isp_in_tpg        PIPELINE_READY                ${v_pipeline_ready}
    set_instance_parameter_value      isp_in_tpg        PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_in_tpg        RUNTIME_CONTROL               {1}
    set_instance_parameter_value      isp_in_tpg        SEPARATE_SLAVE_CLOCK          {1}
    set_instance_parameter_value      isp_in_tpg        SLAVE_PROTOCOL                {Avalon}

    # isp_in_rms
    set_instance_parameter_value      isp_in_rms        BPS                           ${v_bps}
    set_instance_parameter_value      isp_in_rms        C_CONV_MODE                   {148}
    set_instance_parameter_value      isp_in_rms        C_CPU_OFFSET                  {0}
    set_instance_parameter_value      isp_in_rms        C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_in_rms        C_OMNI_CAP_ID_COMPONENT       {0}
    set_instance_parameter_value      isp_in_rms        C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_in_rms        C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_in_rms        C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_in_rms        C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_in_rms        C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_in_rms        C_OMNI_CAP_SIZE               {64}
    set_instance_parameter_value      isp_in_rms        C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_in_rms        C_OMNI_CAP_TYPE               {581}
    set_instance_parameter_value      isp_in_rms        C_OMNI_CAP_VERSION            {1}
    set_instance_parameter_value      isp_in_rms        NUMBER_OF_COLOR_PLANES        ${v_cppp}
    set_instance_parameter_value      isp_in_rms        PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_in_rms        RUNTIME_CONTROL               {1}

    # isp_in_switch
    set_instance_parameter_value      isp_in_switch     BPS                           ${v_bps}
    set_instance_parameter_value      isp_in_switch     CRASH_SWITCH                  ${v_async_ip_sw}
    set_instance_parameter_value      isp_in_switch     C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_in_switch     C_OMNI_CAP_ID_COMPONENT       {1}
    set_instance_parameter_value      isp_in_switch     C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_in_switch     C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_in_switch     C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_in_switch     C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_in_switch     C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_in_switch     C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_in_switch     C_OMNI_CAP_TYPE               {565}
    set_instance_parameter_value      isp_in_switch     C_OMNI_CAP_VERSION            {2}
    set_instance_parameter_value      isp_in_switch     ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value      isp_in_switch     EXTERNAL_MODE                 {1}
    set_instance_parameter_value      isp_in_switch     NUMBER_OF_COLOR_PLANES        ${v_isp_cppp}
    if {${v_multi_sensor}} {
        set_instance_parameter_value      isp_in_switch   NUM_INPUTS                    {3}
    } else {
        set_instance_parameter_value      isp_in_switch   NUM_INPUTS                    {2}
    }
    set_instance_parameter_value      isp_in_switch     NUM_OUTPUTS                   {1}
    set_instance_parameter_value      isp_in_switch     PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_in_switch     SEPARATE_SLAVE_CLOCK          {1}
    set_instance_parameter_value      isp_in_switch     SLAVE_PROTOCOL                {Avalon}
    set_instance_parameter_value      isp_in_switch     UNINTERRUPTED_INPUTS          ${v_sync_ip_sw}
    set_instance_parameter_value      isp_in_switch     USE_OP_RESP                   {0}
    set_instance_parameter_value      isp_in_switch     USE_TREADIES                  {1}
    set_instance_parameter_value      isp_in_switch     VVP_INTF_TYPE                 {VVP_LITE}


    ############################
    #### Create Connections ####
    ############################

    # isp_in_cpu_clk_bridge
    add_connection          isp_in_cpu_clk_bridge.out_clk           isp_in_cpu_rst_bridge.clk
    add_connection          isp_in_cpu_clk_bridge.out_clk           isp_in_mm_bridge.clk
    add_connection          isp_in_cpu_clk_bridge.out_clk           isp_in_tpg.agent_clock
    add_connection          isp_in_cpu_clk_bridge.out_clk           isp_in_rms.agent_clock
    add_connection          isp_in_cpu_clk_bridge.out_clk           isp_in_switch.agent_clock

    # isp_in_cpu_rst_bridge
    add_connection          isp_in_cpu_rst_bridge.out_reset         isp_in_mm_bridge.reset
    add_connection          isp_in_cpu_rst_bridge.out_reset         isp_in_tpg.agent_reset
    add_connection          isp_in_cpu_rst_bridge.out_reset         isp_in_rms.agent_reset
    add_connection          isp_in_cpu_rst_bridge.out_reset         isp_in_switch.agent_reset

    # isp_in_mm_bridge
    add_connection          isp_in_mm_bridge.m0           isp_in_tpg.av_mm_control_agent
    add_connection          isp_in_mm_bridge.m0           isp_in_rms.av_mm_control_agent
    add_connection          isp_in_mm_bridge.m0           isp_in_switch.av_mm_control_agent

    # isp_in_vid_clk_bridge
    add_connection          isp_in_vid_clk_bridge.out_clk           isp_in_vid_rst_bridge.clk
    add_connection          isp_in_vid_clk_bridge.out_clk           isp_in_tpg.main_clock
    add_connection          isp_in_vid_clk_bridge.out_clk           isp_in_rms.main_clock
    add_connection          isp_in_vid_clk_bridge.out_clk           isp_in_switch.main_clock

    # isp_in_vid_rst_bridge
    add_connection          isp_in_vid_rst_bridge.out_reset         isp_in_tpg.main_reset
    add_connection          isp_in_vid_rst_bridge.out_reset         isp_in_rms.main_reset
    add_connection          isp_in_vid_rst_bridge.out_reset         isp_in_switch.main_reset

    # isp_in_tpg
    add_connection          isp_in_tpg.axi4s_vid_out            isp_in_rms.axi4s_vid_in

    # isp_in_rms
    add_connection          isp_in_rms.axi4s_vid_out       isp_in_switch.axi4s_vid_in_0


    ##########################
    ##### Create Exports #####
    ##########################

    # isp_in_cpu_clk_bridge
    add_interface           cpu_clk_in      clock       sink
    set_interface_property  cpu_clk_in      EXPORT_OF   isp_in_cpu_clk_bridge.in_clk

    # isp_in_cpu_rst_bridge
    add_interface           cpu_rst_in      reset       sink
    set_interface_property  cpu_rst_in      EXPORT_OF   isp_in_cpu_rst_bridge.in_reset

    # isp_in_vid_clk_bridge
    set_interface_property  vid_clk_in      EXPORT_OF   isp_in_vid_clk_bridge.in_clk

    # isp_in_vid_rst_bridge
    set_interface_property  vid_rst_in      EXPORT_OF   isp_in_vid_rst_bridge.in_reset

    # isp_in_mm_bridge
    add_interface           mm_ctrl_in      avalon      slave
    set_interface_property  mm_ctrl_in      EXPORT_OF   isp_in_mm_bridge.s0

    # isp_in_intel_vvp_pip_conv_mipi_0
    add_interface           mipi_csi2_0_s_vid_axis        axi4stream  subordinate
    set_interface_property  mipi_csi2_0_s_vid_axis        EXPORT_OF   isp_in_switch.axi4s_vid_in_1

    if {${v_multi_sensor}} {
        # isp_in_intel_vvp_pip_conv_mipi_1
        add_interface           mipi_csi2_1_s_vid_axis    axi4stream  subordinate
        set_interface_property  mipi_csi2_1_s_vid_axis    EXPORT_OF   isp_in_switch.axi4s_vid_in_2
    }

    # isp_in_switch
    add_interface           isp_in_m_vid_axis      axi4stream  manager
    set_interface_property  isp_in_m_vid_axis      EXPORT_OF   isp_in_switch.axi4s_vid_out_0


    #################################
    ##### Assign Base Addresses #####
    #################################

    set_connection_parameter_value isp_in_mm_bridge.m0/isp_in_tpg.av_mm_control_agent       baseAddress "0x00000400"
    set_connection_parameter_value isp_in_mm_bridge.m0/isp_in_rms.av_mm_control_agent       baseAddress "0x00000600"
    set_connection_parameter_value isp_in_mm_bridge.m0/isp_in_switch.av_mm_control_agent    baseAddress "0x00000800"

    lock_avalon_base_address  isp_in_tpg.av_mm_control_agent
    lock_avalon_base_address  isp_in_rms.av_mm_control_agent
    lock_avalon_base_address  isp_in_switch.av_mm_control_agent


    #############################
    ##### Sync / Validation #####
    #############################

    sync_sysinfo_parameters
    save_system
}


proc edit_top_level_qsys {} {
    set v_project_name        [get_shell_parameter PROJECT_NAME]
    set v_project_path        [get_shell_parameter PROJECT_PATH]
    set v_instance_name       [get_shell_parameter INSTANCE_NAME]

    load_system ${v_project_path}/rtl/${v_project_name}_qsys.qsys

    add_instance ${v_instance_name} ${v_instance_name}

    sync_sysinfo_parameters
    save_system
}


proc add_auto_connections {} {
    set v_instance_name             [get_shell_parameter INSTANCE_NAME]
    set v_avmm_host                 [get_shell_parameter AVMM_HOST]
    set v_vid_out_rate              [get_shell_parameter VID_OUT_RATE]
    set v_pip                       [get_shell_parameter PIP]
    set v_multi_sensor              [get_shell_parameter MULTI_SENSOR]

    add_auto_connection   ${v_instance_name}    cpu_clk_in      200000000
    add_auto_connection   ${v_instance_name}    cpu_rst_in      200000000

    if {(${v_vid_out_rate} == "p60") || (${v_pip} == 1)} {
        add_auto_connection   ${v_instance_name}    vid_clk_in      297000000
        add_auto_connection   ${v_instance_name}    vid_rst_in      297000000
    } else {
        add_auto_connection   ${v_instance_name}    vid_clk_in      148500000
        add_auto_connection   ${v_instance_name}    vid_rst_in      148500000
    }

    # from mipi csi
    add_auto_connection   ${v_instance_name}    mipi_csi2_0_s_vid_axis      mipi_csi2_0_vid_axis
    if {${v_multi_sensor}} {
        add_auto_connection   ${v_instance_name}    mipi_csi2_1_s_vid_axis      mipi_csi2_1_vid_axis
    }

    # to isp
    add_auto_connection   ${v_instance_name}    isp_in_m_vid_axis           isp_in_vid_axis

    # HPS to mm bridge
    add_avmm_connections  mm_ctrl_in      ${v_avmm_host}
}

proc edit_top_v_file {} {
    add_declaration_list wire   ""          "multiple_isp_pipes"

    add_assignments_list "multiple_isp_pipes"     "1'b0"
}
