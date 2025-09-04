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

set_shell_parameter AVMM_HOST           {{AUTO X}}

# General Video Controls
set_shell_parameter PIP                 {2}
set_shell_parameter VID_OUT_RATE        "p60"
set_shell_parameter VID_OUT_BPS         {10}
set_shell_parameter EN_DEBUG            {1}
set_shell_parameter VID_OUT_TPG_EN      {1}
set_shell_parameter PIP_CONV_FIFO_DEPTH {512}


proc creation_step {} {
    create_vid_out_subsystem
}

proc post_creation_step {} {
    edit_top_level_qsys
    add_auto_connections
    edit_top_v_file
}


proc create_vid_out_subsystem {} {
    set v_project_path      [get_shell_parameter PROJECT_PATH]
    set v_instance_name     [get_shell_parameter INSTANCE_NAME]

    # Vid Pipeline
    set v_cppp              {3}
    set v_pip               [get_shell_parameter PIP]
    set v_vid_out_rate      [get_shell_parameter VID_OUT_RATE]
    set v_vid_out_bps       [get_shell_parameter VID_OUT_BPS]
    set v_board_name        [get_shell_parameter DEVKIT]

    if {${v_board_name} == "AGX_5E_MACNICA_Sulfur_Devkit"} {
        set v_vid_out_if_pip    {2}
    } else {
        set v_vid_out_if_pip    {4}
    }

    # General
    set v_enable_debug      [get_shell_parameter EN_DEBUG]
    set v_pipeline_ready    {1}

    # Switch Mode - Crash when ASYNC_IP_SW = 1, else Sync Switch on SOF with SYNC_IP_SW = 1, else on EOL
    set v_async_ip_sw       {0}
    set v_sync_ip_sw        {0}

    set v_output_tpg_en          [get_shell_parameter VID_OUT_TPG_EN]
    set v_pip_conv_fifo_depth    [get_shell_parameter PIP_CONV_FIFO_DEPTH]

    # If DP and 25.1, then we are using Multi-rate DP
    if {(${v_vid_out_rate} == "p60") || (${v_pip} == 1)} {
        set_shell_parameter DUAL_CLOCK_EN {0}
    } else {
        set_shell_parameter DUAL_CLOCK_EN {1}
    }
    set v_dual_clock_en   [get_shell_parameter DUAL_CLOCK_EN]

    create_system ${v_instance_name}
    save_system   ${v_project_path}/rtl/user/${v_instance_name}.qsys

    load_system   ${v_project_path}/rtl/user/${v_instance_name}.qsys


    ############################
    #### Add Instances      ####
    ############################

    add_instance  vid_out_cpu_clk_bridge        altera_clock_bridge
    add_instance  vid_out_cpu_rst_bridge        altera_reset_bridge
    add_instance  vid_out_mm_bridge             altera_avalon_mm_bridge
    add_instance  vid_out_vid_clk_bridge        altera_clock_bridge
    add_instance  vid_out_vid_rst_bridge        altera_reset_bridge
    if {${v_output_tpg_en}} {
      add_instance  vid_out_tpg                 intel_vvp_tpg
      add_instance  vid_out_switch              intel_vvp_switch
    }
    if {${v_dual_clock_en} == 1} {
      add_instance  vid_out_if_clk_bridge       altera_clock_bridge
      add_instance  vid_out_if_rst_bridge       altera_reset_bridge
    }
    add_instance  vid_out_pip_conv              intel_vvp_pip_conv
    add_instance  vid_out_proto_conv            intel_vvp_protocol_conv
    add_instance  vid_out_pio_board             altera_avalon_pio
    add_instance  vid_out_pio_status            altera_avalon_pio
    add_instance  vid_out_pio_supportd_fmats    altera_avalon_pio
    add_instance  vid_out_pio_curr_format       altera_avalon_pio
    add_instance  vid_out_pio_format_ovrride    altera_avalon_pio


    ############################
    #### Set Parameters     ####
    ############################

    # vid_out_cpu_clk_bridge
    set_instance_parameter_value      vid_out_cpu_clk_bridge     EXPLICIT_CLOCK_RATE       {200000000.0}
    set_instance_parameter_value      vid_out_cpu_clk_bridge     NUM_CLOCK_OUTPUTS         {1}

    # vid_out_cpu_rst_bridge
    set_instance_parameter_value      vid_out_cpu_rst_bridge     ACTIVE_LOW_RESET              {0}
    set_instance_parameter_value      vid_out_cpu_rst_bridge     NUM_RESET_OUTPUTS             {1}
    set_instance_parameter_value      vid_out_cpu_rst_bridge     SYNCHRONOUS_EDGES             {deassert}
    set_instance_parameter_value      vid_out_cpu_rst_bridge     SYNC_RESET                    {0}
    set_instance_parameter_value      vid_out_cpu_rst_bridge     USE_RESET_REQUEST             {0}

    # vid_out_mm_bridge
    set_instance_parameter_value      vid_out_mm_bridge        ADDRESS_UNITS                 {SYMBOLS}
    set_instance_parameter_value      vid_out_mm_bridge        ADDRESS_WIDTH                 {0}
    set_instance_parameter_value      vid_out_mm_bridge        DATA_WIDTH                    {32}
    set_instance_parameter_value      vid_out_mm_bridge        LINEWRAPBURSTS                {0}
    set_instance_parameter_value      vid_out_mm_bridge        M0_WAITREQUEST_ALLOWANCE      {0}
    set_instance_parameter_value      vid_out_mm_bridge        MAX_BURST_SIZE                {1}
    set_instance_parameter_value      vid_out_mm_bridge        MAX_PENDING_RESPONSES         {4}
    set_instance_parameter_value      vid_out_mm_bridge        MAX_PENDING_WRITES            {0}
    set_instance_parameter_value      vid_out_mm_bridge        PIPELINE_COMMAND              {1}
    set_instance_parameter_value      vid_out_mm_bridge        PIPELINE_RESPONSE             {1}
    set_instance_parameter_value      vid_out_mm_bridge        S0_WAITREQUEST_ALLOWANCE      {0}
    set_instance_parameter_value      vid_out_mm_bridge        SYMBOL_WIDTH                  {8}
    set_instance_parameter_value      vid_out_mm_bridge        SYNC_RESET                    {0}
    set_instance_parameter_value      vid_out_mm_bridge        USE_AUTO_ADDRESS_WIDTH        {1}
    set_instance_parameter_value      vid_out_mm_bridge        USE_RESPONSE                  {0}
    set_instance_parameter_value      vid_out_mm_bridge        USE_WRITERESPONSE             {0}

    # vid_out_vid_clk_bridge
    if {(${v_vid_out_rate} == "p60") || (${v_pip} == 1)} {
      set_instance_parameter_value      vid_out_vid_clk_bridge     EXPLICIT_CLOCK_RATE     {297000000.0}
    } else {
      set_instance_parameter_value      vid_out_vid_clk_bridge     EXPLICIT_CLOCK_RATE     {148500000.0}
    }
    set_instance_parameter_value      vid_out_vid_clk_bridge       NUM_CLOCK_OUTPUTS       {1}

    # vid_out_vid_rst_bridge
    set_instance_parameter_value      vid_out_vid_rst_bridge     ACTIVE_LOW_RESET        {0}
    set_instance_parameter_value      vid_out_vid_rst_bridge     NUM_RESET_OUTPUTS       {1}
    set_instance_parameter_value      vid_out_vid_rst_bridge     SYNCHRONOUS_EDGES       {deassert}
    set_instance_parameter_value      vid_out_vid_rst_bridge     SYNC_RESET              {0}
    set_instance_parameter_value      vid_out_vid_rst_bridge     USE_RESET_REQUEST       {0}

    if {${v_dual_clock_en} == 1} {
      # vid_out_if_clk_bridge
      set_instance_parameter_value    vid_out_if_clk_bridge    EXPLICIT_CLOCK_RATE   {297000000.0}
      set_instance_parameter_value    vid_out_if_clk_bridge    NUM_CLOCK_OUTPUTS     {1}

      # vid_out_if_rst_bridge
      set_instance_parameter_value    vid_out_if_rst_bridge      ACTIVE_LOW_RESET        {0}
      set_instance_parameter_value    vid_out_if_rst_bridge      NUM_RESET_OUTPUTS       {1}
      set_instance_parameter_value    vid_out_if_rst_bridge      SYNCHRONOUS_EDGES       {deassert}
      set_instance_parameter_value    vid_out_if_rst_bridge      SYNC_RESET              {0}
      set_instance_parameter_value    vid_out_if_rst_bridge      USE_RESET_REQUEST       {0}
    }

    if {${v_output_tpg_en}} {
      # vid_out_tpg
      set_instance_parameter_value    vid_out_tpg          BINARY_DISPLAY_MODE           {Seconds}
      set_instance_parameter_value    vid_out_tpg          BPS                           ${v_vid_out_bps}
      set_instance_parameter_value    vid_out_tpg          CORE_COL_SPACE_0              {0}
      set_instance_parameter_value    vid_out_tpg          CORE_COL_SPACE_1              {0}
      set_instance_parameter_value    vid_out_tpg          CORE_COL_SPACE_2              {0}
      set_instance_parameter_value    vid_out_tpg          CORE_COL_SPACE_3              {0}
      set_instance_parameter_value    vid_out_tpg          CORE_COL_SPACE_4              {0}
      set_instance_parameter_value    vid_out_tpg          CORE_COL_SPACE_5              {0}
      set_instance_parameter_value    vid_out_tpg          CORE_COL_SPACE_6              {0}
      set_instance_parameter_value    vid_out_tpg          CORE_COL_SPACE_7              {0}
      set_instance_parameter_value    vid_out_tpg          CORE_PATTERN_0                {0}
      set_instance_parameter_value    vid_out_tpg          CORE_PATTERN_1                {1}
      set_instance_parameter_value    vid_out_tpg          CORE_PATTERN_2                {0}
      set_instance_parameter_value    vid_out_tpg          CORE_PATTERN_3                {0}
      set_instance_parameter_value    vid_out_tpg          CORE_PATTERN_4                {0}
      set_instance_parameter_value    vid_out_tpg          CORE_PATTERN_5                {0}
      set_instance_parameter_value    vid_out_tpg          CORE_PATTERN_6                {0}
      set_instance_parameter_value    vid_out_tpg          CORE_PATTERN_7                {0}
      set_instance_parameter_value    vid_out_tpg          C_OMNI_CAP_ID_ASSOCIATED      {0}
      set_instance_parameter_value    vid_out_tpg          C_OMNI_CAP_ID_COMPONENT       {2}
      set_instance_parameter_value    vid_out_tpg          C_OMNI_CAP_IRQ                {255}
      set_instance_parameter_value    vid_out_tpg          C_OMNI_CAP_IRQ_ENABLE         {0}
      set_instance_parameter_value    vid_out_tpg          C_OMNI_CAP_IRQ_ENABLE_EN      {0}
      set_instance_parameter_value    vid_out_tpg          C_OMNI_CAP_IRQ_STATUS         {0}
      set_instance_parameter_value    vid_out_tpg          C_OMNI_CAP_IRQ_STATUS_EN      {0}
      set_instance_parameter_value    vid_out_tpg          C_OMNI_CAP_TAG                {0}
      set_instance_parameter_value    vid_out_tpg          C_OMNI_CAP_TYPE               {566}
      set_instance_parameter_value    vid_out_tpg          C_OMNI_CAP_VERSION            {1}
      set_instance_parameter_value    vid_out_tpg          ENABLE_CTRL_IN                {0}
      set_instance_parameter_value    vid_out_tpg          ENABLE_DEBUG                  ${v_enable_debug}
      set_instance_parameter_value    vid_out_tpg          EXTERNAL_MODE                 {1}
      set_instance_parameter_value    vid_out_tpg          FIXED_BARS_MODE               {0}
      set_instance_parameter_value    vid_out_tpg          FIXED_B_BACKGROUND            {255}
      set_instance_parameter_value    vid_out_tpg          FIXED_B_CB                    {16}
      set_instance_parameter_value    vid_out_tpg          FIXED_B_FONT                  {0}
      set_instance_parameter_value    vid_out_tpg          FIXED_FINE_FACTOR             {256}
      set_instance_parameter_value    vid_out_tpg          FIXED_FPS                     {60}
      set_instance_parameter_value    vid_out_tpg          FIXED_G_BACKGROUND            {0}
      set_instance_parameter_value    vid_out_tpg          FIXED_G_FONT                  {255}
      set_instance_parameter_value    vid_out_tpg          FIXED_G_Y                     {16}
      set_instance_parameter_value    vid_out_tpg          FIXED_HEIGHT                  {2160}
      set_instance_parameter_value    vid_out_tpg          FIXED_INTERLACE               {0}
      set_instance_parameter_value    vid_out_tpg          FIXED_LOCATION_X              {1000}
      set_instance_parameter_value    vid_out_tpg          FIXED_LOCATION_Y              {500}
      set_instance_parameter_value    vid_out_tpg          FIXED_POWER_FACTOR            {16}
      set_instance_parameter_value    vid_out_tpg          FIXED_R_BACKGROUND            {255}
      set_instance_parameter_value    vid_out_tpg          FIXED_R_CR                    {16}
      set_instance_parameter_value    vid_out_tpg          FIXED_R_FONT                  {0}
      set_instance_parameter_value    vid_out_tpg          FIXED_SCALE_FACTOR            {100}
      set_instance_parameter_value    vid_out_tpg          FIXED_WIDTH                   {3840}
      set_instance_parameter_value    vid_out_tpg          NUM_CORES                     {2}
      set_instance_parameter_value    vid_out_tpg          OUTPUT_FORMAT                 {4.4.4}
      set_instance_parameter_value    vid_out_tpg          PIPELINE_READY                {1}
      set_instance_parameter_value    vid_out_tpg          PIXELS_IN_PARALLEL            ${v_pip}
      set_instance_parameter_value    vid_out_tpg          RUNTIME_CONTROL               {1}
      set_instance_parameter_value    vid_out_tpg          SEPARATE_SLAVE_CLOCK          {1}
      set_instance_parameter_value    vid_out_tpg          SLAVE_PROTOCOL                {Avalon}

      # vid_out_switch
      set_instance_parameter_value    vid_out_switch       BPS                           ${v_vid_out_bps}
      set_instance_parameter_value    vid_out_switch       CRASH_SWITCH                  ${v_async_ip_sw}
      set_instance_parameter_value    vid_out_switch       C_OMNI_CAP_ID_ASSOCIATED      {0}
      set_instance_parameter_value    vid_out_switch       C_OMNI_CAP_ID_COMPONENT       {2}
      set_instance_parameter_value    vid_out_switch       C_OMNI_CAP_IRQ                {255}
      set_instance_parameter_value    vid_out_switch       C_OMNI_CAP_IRQ_ENABLE         {0}
      set_instance_parameter_value    vid_out_switch       C_OMNI_CAP_IRQ_ENABLE_EN      {0}
      set_instance_parameter_value    vid_out_switch       C_OMNI_CAP_IRQ_STATUS         {0}
      set_instance_parameter_value    vid_out_switch       C_OMNI_CAP_IRQ_STATUS_EN      {0}
      set_instance_parameter_value    vid_out_switch       C_OMNI_CAP_TAG                {0}
      set_instance_parameter_value    vid_out_switch       C_OMNI_CAP_TYPE               {565}
      set_instance_parameter_value    vid_out_switch       C_OMNI_CAP_VERSION            {2}
      set_instance_parameter_value    vid_out_switch       ENABLE_DEBUG                  ${v_enable_debug}
      set_instance_parameter_value    vid_out_switch       EXTERNAL_MODE                 {1}
      set_instance_parameter_value    vid_out_switch       NUMBER_OF_COLOR_PLANES        ${v_cppp}
      set_instance_parameter_value    vid_out_switch       NUM_INPUTS                    {2}
      set_instance_parameter_value    vid_out_switch       NUM_OUTPUTS                   {1}
      set_instance_parameter_value    vid_out_switch       PIXELS_IN_PARALLEL            ${v_pip}
      set_instance_parameter_value    vid_out_switch       SEPARATE_SLAVE_CLOCK          {1}
      set_instance_parameter_value    vid_out_switch       SLAVE_PROTOCOL                {Avalon}
      set_instance_parameter_value    vid_out_switch       UNINTERRUPTED_INPUTS          ${v_sync_ip_sw}
      set_instance_parameter_value    vid_out_switch       USE_OP_RESP                   {0}
      set_instance_parameter_value    vid_out_switch       USE_TREADIES                  {1}
      set_instance_parameter_value    vid_out_switch       VVP_INTF_TYPE                 {VVP_LITE}
    }

    # vid_out_pip_conv
    set_instance_parameter_value    vid_out_pip_conv     BPS                           ${v_vid_out_bps}
    set_instance_parameter_value    vid_out_pip_conv     C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value    vid_out_pip_conv     C_OMNI_CAP_ID_COMPONENT       {2}
    set_instance_parameter_value    vid_out_pip_conv     C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value    vid_out_pip_conv     C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value    vid_out_pip_conv     C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value    vid_out_pip_conv     C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value    vid_out_pip_conv     C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value    vid_out_pip_conv     C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value    vid_out_pip_conv     C_OMNI_CAP_TYPE               {569}
    set_instance_parameter_value    vid_out_pip_conv     C_OMNI_CAP_VERSION            {1}
    if {${v_dual_clock_en} == 1} {
        set_instance_parameter_value    vid_out_pip_conv     DUAL_CLOCK                    {1}
    } else {
        set_instance_parameter_value    vid_out_pip_conv     DUAL_CLOCK                    {0}
    }
    set_instance_parameter_value    vid_out_pip_conv     FIFO_DEPTH                    ${v_pip_conv_fifo_depth}
    set_instance_parameter_value    vid_out_pip_conv     ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value    vid_out_pip_conv     EXTERNAL_MODE                 {1}
    set_instance_parameter_value    vid_out_pip_conv     NUMBER_OF_COLOR_PLANES        ${v_cppp}
    set_instance_parameter_value    vid_out_pip_conv     PIPELINE_READY                ${v_pipeline_ready}
    set_instance_parameter_value    vid_out_pip_conv     PIXELS_IN_PARALLEL_IN         ${v_pip}
    set_instance_parameter_value    vid_out_pip_conv     PIXELS_IN_PARALLEL_OUT        ${v_vid_out_if_pip}
    set_instance_parameter_value    vid_out_pip_conv     SEPARATE_SLAVE_CLOCK          {1}
    set_instance_parameter_value    vid_out_pip_conv     SLAVE_PROTOCOL                {Avalon}

    # vid_out_proto_conv
    set_instance_parameter_value    vid_out_proto_conv     BPS                         ${v_vid_out_bps}
    set_instance_parameter_value    vid_out_proto_conv     CHROMA_SAMPLING             {444}
    set_instance_parameter_value    vid_out_proto_conv     CHROMA_SITING               {TOP_LEFT}
    set_instance_parameter_value    vid_out_proto_conv     CLIP_LONG_FIELDS            {0}
    set_instance_parameter_value    vid_out_proto_conv     COLOR_SPACE                 {RGB}
    set_instance_parameter_value    vid_out_proto_conv     C_OMNI_CAP_ID_ASSOCIATED    {0}
    set_instance_parameter_value    vid_out_proto_conv     C_OMNI_CAP_ID_COMPONENT     {4}
    set_instance_parameter_value    vid_out_proto_conv     C_OMNI_CAP_IRQ              {255}
    set_instance_parameter_value    vid_out_proto_conv     C_OMNI_CAP_IRQ_ENABLE       {0}
    set_instance_parameter_value    vid_out_proto_conv     C_OMNI_CAP_IRQ_ENABLE_EN    {0}
    set_instance_parameter_value    vid_out_proto_conv     C_OMNI_CAP_IRQ_STATUS       {0}
    set_instance_parameter_value    vid_out_proto_conv     C_OMNI_CAP_IRQ_STATUS_EN    {0}
    set_instance_parameter_value    vid_out_proto_conv     C_OMNI_CAP_TAG              {0}
    set_instance_parameter_value    vid_out_proto_conv     C_OMNI_CAP_TYPE             {573}
    set_instance_parameter_value    vid_out_proto_conv     C_OMNI_CAP_VERSION          {1}
    set_instance_parameter_value    vid_out_proto_conv     ENABLE_DEBUG                ${v_enable_debug}
    set_instance_parameter_value    vid_out_proto_conv     ENABLE_TIMEOUT              {0}
    set_instance_parameter_value    vid_out_proto_conv     ENABLE_YCBCR_SWAP           {0}
    set_instance_parameter_value    vid_out_proto_conv     INPUT_MODE                  {EXTERNAL}
    set_instance_parameter_value    vid_out_proto_conv     NUMBER_OF_COLOR_PLANES      ${v_cppp}
    set_instance_parameter_value    vid_out_proto_conv     OUTPUT_MODE                 {INTERNAL}
    set_instance_parameter_value    vid_out_proto_conv     PIPELINE_READY              ${v_pipeline_ready}
    set_instance_parameter_value    vid_out_proto_conv     PIXELS_IN_PARALLEL          ${v_vid_out_if_pip}
    set_instance_parameter_value    vid_out_proto_conv     RUNTIME_CONTROL             {1}
    set_instance_parameter_value    vid_out_proto_conv     SEPARATE_SLAVE_CLOCK        {1}
    set_instance_parameter_value    vid_out_proto_conv     SLAVE_PROTOCOL              {Avalon}
    set_instance_parameter_value    vid_out_proto_conv     VIP_USER_SUPPORT            {DISCARD}
    set_instance_parameter_value    vid_out_proto_conv     VVP_USER_SUPPORT            {NONE_ALLOWED}

    # vid_out_pio_board
    set_instance_parameter_value  vid_out_pio_board             bitClearingEdgeCapReg         {0}
    set_instance_parameter_value  vid_out_pio_board             bitModifyingOutReg            {0}
    set_instance_parameter_value  vid_out_pio_board             captureEdge                   {0}
    set_instance_parameter_value  vid_out_pio_board             direction                     {Input}
    set_instance_parameter_value  vid_out_pio_board             edgeType                      {RISING}
    set_instance_parameter_value  vid_out_pio_board             generateIRQ                   {0}
    set_instance_parameter_value  vid_out_pio_board             irqType                       {LEVEL}
    set_instance_parameter_value  vid_out_pio_board             resetValue                    {0.0}
    set_instance_parameter_value  vid_out_pio_board             simDoTestBenchWiring          {0}
    set_instance_parameter_value  vid_out_pio_board             simDrivenValue                {0.0}
    set_instance_parameter_value  vid_out_pio_board             width                         {32}

    # vid_out_pio_status
    set_instance_parameter_value  vid_out_pio_status            bitClearingEdgeCapReg         {0}
    set_instance_parameter_value  vid_out_pio_status            bitModifyingOutReg            {0}
    set_instance_parameter_value  vid_out_pio_status            captureEdge                   {0}
    set_instance_parameter_value  vid_out_pio_status            direction                     {Input}
    set_instance_parameter_value  vid_out_pio_status            edgeType                      {RISING}
    set_instance_parameter_value  vid_out_pio_status            generateIRQ                   {0}
    set_instance_parameter_value  vid_out_pio_status            irqType                       {LEVEL}
    set_instance_parameter_value  vid_out_pio_status            resetValue                    {0.0}
    set_instance_parameter_value  vid_out_pio_status            simDoTestBenchWiring          {0}
    set_instance_parameter_value  vid_out_pio_status            simDrivenValue                {0.0}
    set_instance_parameter_value  vid_out_pio_status            width                         {32}

    # vid_out_pio_supportd_fmats
    set_instance_parameter_value  vid_out_pio_supportd_fmats    bitClearingEdgeCapReg         {0}
    set_instance_parameter_value  vid_out_pio_supportd_fmats    bitModifyingOutReg            {0}
    set_instance_parameter_value  vid_out_pio_supportd_fmats    captureEdge                   {0}
    set_instance_parameter_value  vid_out_pio_supportd_fmats    direction                     {Input}
    set_instance_parameter_value  vid_out_pio_supportd_fmats    edgeType                      {RISING}
    set_instance_parameter_value  vid_out_pio_supportd_fmats    generateIRQ                   {0}
    set_instance_parameter_value  vid_out_pio_supportd_fmats    irqType                       {LEVEL}
    set_instance_parameter_value  vid_out_pio_supportd_fmats    resetValue                    {0.0}
    set_instance_parameter_value  vid_out_pio_supportd_fmats    simDoTestBenchWiring          {0}
    set_instance_parameter_value  vid_out_pio_supportd_fmats    simDrivenValue                {0.0}
    set_instance_parameter_value  vid_out_pio_supportd_fmats    width                         {32}

    # vid_out_pio_curr_format
    set_instance_parameter_value  vid_out_pio_curr_format       bitClearingEdgeCapReg         {0}
    set_instance_parameter_value  vid_out_pio_curr_format       bitModifyingOutReg            {0}
    set_instance_parameter_value  vid_out_pio_curr_format       captureEdge                   {0}
    set_instance_parameter_value  vid_out_pio_curr_format       direction                     {Input}
    set_instance_parameter_value  vid_out_pio_curr_format       edgeType                      {RISING}
    set_instance_parameter_value  vid_out_pio_curr_format       generateIRQ                   {0}
    set_instance_parameter_value  vid_out_pio_curr_format       irqType                       {LEVEL}
    set_instance_parameter_value  vid_out_pio_curr_format       resetValue                    {0.0}
    set_instance_parameter_value  vid_out_pio_curr_format       simDoTestBenchWiring          {0}
    set_instance_parameter_value  vid_out_pio_curr_format       simDrivenValue                {0.0}
    set_instance_parameter_value  vid_out_pio_curr_format       width                         {32}

    # vid_out_pio_format_ovrride
    set_instance_parameter_value  vid_out_pio_format_ovrride    bitClearingEdgeCapReg         {0}
    set_instance_parameter_value  vid_out_pio_format_ovrride    bitModifyingOutReg            {0}
    set_instance_parameter_value  vid_out_pio_format_ovrride    captureEdge                   {0}
    set_instance_parameter_value  vid_out_pio_format_ovrride    direction                     {Output}
    set_instance_parameter_value  vid_out_pio_format_ovrride    edgeType                      {RISING}
    set_instance_parameter_value  vid_out_pio_format_ovrride    generateIRQ                   {0}
    set_instance_parameter_value  vid_out_pio_format_ovrride    irqType                       {LEVEL}
    set_instance_parameter_value  vid_out_pio_format_ovrride    resetValue                    {0.0}
    set_instance_parameter_value  vid_out_pio_format_ovrride    simDoTestBenchWiring          {0}
    set_instance_parameter_value  vid_out_pio_format_ovrride    simDrivenValue                {0.0}
    set_instance_parameter_value  vid_out_pio_format_ovrride    width                         {32}


    ############################
    #### Create Connections ####
    ############################

    # vid_out_cpu_clk_bridge
    add_connection          vid_out_cpu_clk_bridge.out_clk         vid_out_cpu_rst_bridge.clk
    add_connection          vid_out_cpu_clk_bridge.out_clk         vid_out_mm_bridge.clk
    if {${v_output_tpg_en}} {
        add_connection          vid_out_cpu_clk_bridge.out_clk         vid_out_tpg.agent_clock
        add_connection          vid_out_cpu_clk_bridge.out_clk         vid_out_switch.agent_clock
    }
    add_connection          vid_out_cpu_clk_bridge.out_clk         vid_out_pip_conv.agent_clock
    add_connection          vid_out_cpu_clk_bridge.out_clk         vid_out_proto_conv.agent_clock
    add_connection          vid_out_cpu_clk_bridge.out_clk         vid_out_pio_board.clk
    add_connection          vid_out_cpu_clk_bridge.out_clk         vid_out_pio_status.clk
    add_connection          vid_out_cpu_clk_bridge.out_clk         vid_out_pio_supportd_fmats.clk
    add_connection          vid_out_cpu_clk_bridge.out_clk         vid_out_pio_curr_format.clk
    add_connection          vid_out_cpu_clk_bridge.out_clk         vid_out_pio_format_ovrride.clk

    # vid_out_cpu_rst_bridge
    add_connection          vid_out_cpu_rst_bridge.out_reset       vid_out_mm_bridge.reset
    if {${v_output_tpg_en}} {
        add_connection          vid_out_cpu_rst_bridge.out_reset       vid_out_tpg.agent_reset
        add_connection          vid_out_cpu_rst_bridge.out_reset       vid_out_switch.agent_reset
    }
    add_connection          vid_out_cpu_rst_bridge.out_reset       vid_out_pip_conv.agent_reset
    add_connection          vid_out_cpu_rst_bridge.out_reset       vid_out_proto_conv.agent_reset
    add_connection          vid_out_cpu_rst_bridge.out_reset       vid_out_pio_board.reset
    add_connection          vid_out_cpu_rst_bridge.out_reset       vid_out_pio_status.reset
    add_connection          vid_out_cpu_rst_bridge.out_reset       vid_out_pio_supportd_fmats.reset
    add_connection          vid_out_cpu_rst_bridge.out_reset       vid_out_pio_curr_format.reset
    add_connection          vid_out_cpu_rst_bridge.out_reset       vid_out_pio_format_ovrride.reset

    # vid_out_mm_bridge
    if {${v_output_tpg_en}} {
        add_connection          vid_out_mm_bridge.m0            vid_out_tpg.av_mm_control_agent
        add_connection          vid_out_mm_bridge.m0            vid_out_switch.av_mm_control_agent
    }
    add_connection          vid_out_mm_bridge.m0            vid_out_pip_conv.av_mm_control_agent
    add_connection          vid_out_mm_bridge.m0            vid_out_proto_conv.av_mm_control_agent
    add_connection          vid_out_mm_bridge.m0            vid_out_pio_board.s1
    add_connection          vid_out_mm_bridge.m0            vid_out_pio_status.s1
    add_connection          vid_out_mm_bridge.m0            vid_out_pio_supportd_fmats.s1
    add_connection          vid_out_mm_bridge.m0            vid_out_pio_curr_format.s1
    add_connection          vid_out_mm_bridge.m0            vid_out_pio_format_ovrride.s1

    # vid_out_vid_clk_bridge
    add_connection          vid_out_vid_clk_bridge.out_clk         vid_out_vid_rst_bridge.clk
    if {${v_output_tpg_en}} {
        add_connection          vid_out_vid_clk_bridge.out_clk         vid_out_tpg.main_clock
        add_connection          vid_out_vid_clk_bridge.out_clk         vid_out_switch.main_clock
    }
    if {${v_dual_clock_en} == 1} {
        add_connection          vid_out_vid_clk_bridge.out_clk         vid_out_pip_conv.in_clock
    } else {
        add_connection          vid_out_vid_clk_bridge.out_clk         vid_out_pip_conv.main_clock
    }
        add_connection          vid_out_vid_clk_bridge.out_clk         vid_out_proto_conv.main_clock

    # vid_out_vid_rst_bridge
    if {${v_output_tpg_en}} {
        add_connection          vid_out_vid_rst_bridge.out_reset       vid_out_tpg.main_reset
        add_connection          vid_out_vid_rst_bridge.out_reset       vid_out_switch.main_reset
    }
    if {${v_dual_clock_en} == 1} {
        add_connection          vid_out_vid_rst_bridge.out_reset       vid_out_pip_conv.in_reset
    } else {
        add_connection          vid_out_vid_rst_bridge.out_reset       vid_out_pip_conv.main_reset
    }
        add_connection          vid_out_vid_rst_bridge.out_reset       vid_out_proto_conv.main_reset

    # vid_out_tpg
    if {${v_output_tpg_en}} {
        add_connection          vid_out_tpg.axi4s_vid_out              vid_out_switch.axi4s_vid_in_0

        # vid_out_switch
        add_connection          vid_out_switch.axi4s_vid_out_0         vid_out_pip_conv.axi4s_vid_in
    }

    if {${v_dual_clock_en} == 1} {
        # vid_out_if_clk_bridge
        add_connection          vid_out_if_clk_bridge.out_clk          vid_out_if_rst_bridge.clk
        add_connection          vid_out_if_clk_bridge.out_clk          vid_out_pip_conv.out_clock

        # vid_out_if_rst_bridge
        add_connection          vid_out_if_rst_bridge.out_reset        vid_out_pip_conv.out_reset
    }

    # vid_out_pip_conv
    add_connection          vid_out_pip_conv.axi4s_vid_out          vid_out_proto_conv.axi4s_vid_in


    ##########################
    ##### Create Exports #####
    ##########################

    # vid_out_cpu_clk_bridge
    add_interface           cpu_clk_in_clk        clock         sink
    set_interface_property  cpu_clk_in_clk        export_of     vid_out_cpu_clk_bridge.in_clk

    # vid_out_cpu_rst_bridge
    add_interface           cpu_reset_in_reset    reset         sink
    set_interface_property  cpu_reset_in_reset    export_of     vid_out_cpu_rst_bridge.in_reset

    # vid_out_mm_bridge
    add_interface           mm_ctrl_in            avalon        slave
    set_interface_property  mm_ctrl_in            export_of     vid_out_mm_bridge.s0

    # vid_out_vid_clk_bridge
    add_interface           vid_clk_in            clock         sink
    set_interface_property  vid_clk_in            export_of     vid_out_vid_clk_bridge.in_clk

    # vid_out_vid_rst_bridge
    add_interface           vid_rst_in            reset         sink
    set_interface_property  vid_rst_in            export_of     vid_out_vid_rst_bridge.in_reset

    if {${v_output_tpg_en}} {
        # vid_out_switch
        add_interface           vid_in            axi4stream    subordinate
        set_interface_property  vid_in            export_of     vid_out_switch.axi4s_vid_in_1
    } else {
        add_interface           vid_in            axi4stream    subordinate
        set_interface_property  vid_in            export_of     vid_out_pip_conv.axi4s_vid_in
    }

    if {${v_dual_clock_en} == 1} {
        # vid_out_if_clk_bridge
        add_interface           vid_out_if_clk_in     clock         sink
        set_interface_property  vid_out_if_clk_in     export_of     vid_out_if_clk_bridge.in_clk

        # vid_out_if_rst_bridge
        add_interface           vid_out_if_rst_in     reset         sink
        set_interface_property  vid_out_if_rst_in     export_of     vid_out_if_rst_bridge.in_reset
    }

    # vid_out_proto_conv
    add_interface           vid_out               axi4stream    manager
    set_interface_property  vid_out               export_of     vid_out_proto_conv.axi4s_vid_out

    # vid_out_pio_board
    add_interface             vid_out_board_pio           conduit     end
    set_interface_property    vid_out_board_pio           export_of   vid_out_pio_board.external_connection

    # vid_out_pio_status
    add_interface             vid_out_status_pio          conduit     end
    set_interface_property    vid_out_status_pio          export_of   vid_out_pio_status.external_connection

    # vid_out_pio_supportd_fmats
    add_interface           vid_out_supportd_fmats_pio    conduit     end
    set_interface_property  vid_out_supportd_fmats_pio    export_of   vid_out_pio_supportd_fmats.external_connection

    # vid_out_pio_curr_format
    add_interface             vid_out_curr_format_pio     conduit     end
    set_interface_property    vid_out_curr_format_pio     export_of   vid_out_pio_curr_format.external_connection

    # vid_out_pio_format_ovrride
    add_interface             vid_out_format_ovrride_pio  conduit     end
    set_interface_property    vid_out_format_ovrride_pio  export_of   vid_out_pio_format_ovrride.external_connection


    #################################
    ##### Assign Base Addresses #####
    #################################

    if {${v_output_tpg_en}} {
        set_connection_parameter_value vid_out_mm_bridge.m0/vid_out_tpg.av_mm_control_agent \
                                                                                            baseAddress "0x00000000"
        set_connection_parameter_value vid_out_mm_bridge.m0/vid_out_switch.av_mm_control_agent \
                                                                                            baseAddress "0x00000200"
    }
    set_connection_parameter_value vid_out_mm_bridge.m0/vid_out_pip_conv.av_mm_control_agent \
                                                                                            baseAddress "0x00000400"
    set_connection_parameter_value vid_out_mm_bridge.m0/vid_out_proto_conv.av_mm_control_agent \
                                                                                            baseAddress "0x00000a00"
    set_connection_parameter_value  vid_out_mm_bridge.m0/vid_out_pio_board.s1               baseAddress "0x00000800"
    set_connection_parameter_value  vid_out_mm_bridge.m0/vid_out_pio_status.s1              baseAddress "0x00000810"
    set_connection_parameter_value  vid_out_mm_bridge.m0/vid_out_pio_supportd_fmats.s1      baseAddress "0x00000820"
    set_connection_parameter_value  vid_out_mm_bridge.m0/vid_out_pio_curr_format.s1         baseAddress "0x00000830"
    set_connection_parameter_value  vid_out_mm_bridge.m0/vid_out_pio_format_ovrride.s1      baseAddress "0x00000840"

    if {${v_output_tpg_en}} {
        lock_avalon_base_address  vid_out_tpg.av_mm_control_agent
        lock_avalon_base_address  vid_out_switch.av_mm_control_agent
    }
    lock_avalon_base_address  vid_out_pip_conv.av_mm_control_agent
    lock_avalon_base_address  vid_out_proto_conv.av_mm_control_agent
    lock_avalon_base_address  vid_out_pio_board.s1
    lock_avalon_base_address  vid_out_pio_status.s1
    lock_avalon_base_address  vid_out_pio_supportd_fmats.s1
    lock_avalon_base_address  vid_out_pio_curr_format.s1
    lock_avalon_base_address  vid_out_pio_format_ovrride.s1


    #############################
    ##### Sync / Validation #####
    #############################

    sync_sysinfo_parameters
    save_system
}

proc edit_top_level_qsys {} {
    set v_project_name      [get_shell_parameter PROJECT_NAME]
    set v_project_path      [get_shell_parameter PROJECT_PATH]
    set v_instance_name     [get_shell_parameter INSTANCE_NAME]

    load_system ${v_project_path}/rtl/${v_project_name}_qsys.qsys

    add_instance ${v_instance_name}   ${v_instance_name}

    # vid_out_pio_board
    add_interface             "${v_instance_name}_vid_out_board_pio"         conduit     end
    set_interface_property    "${v_instance_name}_vid_out_board_pio" \
                              export_of   ${v_instance_name}.vid_out_board_pio

    # vid_out_pio_status
    add_interface             "${v_instance_name}_vid_out_status_pio"         conduit     end
    set_interface_property    "${v_instance_name}_vid_out_status_pio" \
                              export_of   ${v_instance_name}.vid_out_status_pio

    # vid_out_pio_supportd_fmats
    add_interface             "${v_instance_name}_vid_out_supportd_fmats_pio"     conduit     end
    set_interface_property    "${v_instance_name}_vid_out_supportd_fmats_pio" \
                              export_of   ${v_instance_name}.vid_out_supportd_fmats_pio

    # vid_out_pio_curr_format
    add_interface             "${v_instance_name}_vid_out_curr_format_pio"        conduit     end
    set_interface_property    "${v_instance_name}_vid_out_curr_format_pio" \
                              export_of   ${v_instance_name}.vid_out_curr_format_pio

    # vid_out_pio_format_ovrride
    add_interface             "${v_instance_name}_vid_out_format_ovrride_pio"     conduit     end
    set_interface_property    "${v_instance_name}_vid_out_format_ovrride_pio" \
                              export_of   ${v_instance_name}.vid_out_format_ovrride_pio

    sync_sysinfo_parameters
    save_system
}

proc add_auto_connections {} {
    set v_instance_name           [get_shell_parameter INSTANCE_NAME]
    set v_avmm_host               [get_shell_parameter AVMM_HOST]
    set v_vid_out_rate            [get_shell_parameter VID_OUT_RATE]
    set v_pip                     [get_shell_parameter PIP]
    set v_dual_clock_en           [get_shell_parameter DUAL_CLOCK_EN]

    add_auto_connection   ${v_instance_name}    cpu_clk_in_clk      200000000
    add_auto_connection   ${v_instance_name}    cpu_reset_in_reset  200000000

    if {(${v_vid_out_rate} == "p60") || (${v_pip} == 1)} {
        add_auto_connection   ${v_instance_name}    vid_clk_in          297000000
        add_auto_connection   ${v_instance_name}    vid_rst_in          297000000
    } else {
        add_auto_connection   ${v_instance_name}    vid_clk_in          148500000
        add_auto_connection   ${v_instance_name}    vid_rst_in          148500000
    }

    if {${v_dual_clock_en} == 1} {
        add_auto_connection   ${v_instance_name}    vid_out_if_clk_in           297000000
        add_auto_connection   ${v_instance_name}    vid_out_if_rst_in           297000000
    }

    # Vid In
    add_auto_connection   ${v_instance_name}    vid_in      full_isp_out_vid_axis

    # Pip Converter Out
    add_auto_connection   ${v_instance_name}    vid_out     vid_out_if_vid_in

    # HPS to mm bridge
    add_avmm_connections  mm_ctrl_in      ${v_avmm_host}
}


proc edit_top_v_file {} {
    set v_instance_name     [get_shell_parameter INSTANCE_NAME]

    # PIO
    add_declaration_list  reg "\[31:0\]"  vid_out_pio_board_i
    add_declaration_list  reg "\[31:0\]"  vid_out_status_i
    add_declaration_list  reg "\[31:0\]"  vid_out_supportd_fmats_i
    add_declaration_list  reg "\[31:0\]"  vid_out_curr_format_i
    add_declaration_list  reg "\[31:0\]"  vid_out_format_ovrride_o

    # PIO
    add_qsys_inst_exports_list  ${v_instance_name}_vid_out_board_pio_export             vid_out_pio_board_i
    add_qsys_inst_exports_list  ${v_instance_name}_vid_out_status_pio_export            vid_out_status_i
    add_qsys_inst_exports_list  ${v_instance_name}_vid_out_supportd_fmats_pio_export    vid_out_supportd_fmats_i
    add_qsys_inst_exports_list  ${v_instance_name}_vid_out_curr_format_pio_export       vid_out_curr_format_i
    add_qsys_inst_exports_list  ${v_instance_name}_vid_out_format_ovrride_pio_export    vid_out_format_ovrride_o
}
