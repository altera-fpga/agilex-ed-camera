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

source ./common_tcl/intel_vvp_helper.tcl
source ./common_tcl/intel_vvp_files.tcl
source ./common_tcl/intel_vvp_parameters.tcl
source ./common_tcl/intel_vvp_interfaces.tcl

# Common module properties for VVP top-level IP
declare_vvp_ip_properties
set_module_property NAME intel_vvp_icon
set_module_property DISPLAY_NAME "Icon generator Intel FPGA IP"

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Callbacks                                                                                    --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

set_module_property   VALIDATION_CALLBACK         validation_cb

set_module_property COMPOSITION_CALLBACK composition_cb

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Parameters                                                                                   --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
add_external_mode_parameters
add_bps_parameters
add_pixels_in_parallel_parameters
set_parameter_property  EXTERNAL_MODE             HDL_PARAMETER             false
set_parameter_property  BPS                       HDL_PARAMETER             false
set_parameter_property  PIXELS_IN_PARALLEL        HDL_PARAMETER             false
set_parameter_property  PIXELS_IN_PARALLEL        ALLOWED_RANGES            {1 2 4 8}

add_pipeline_ready_parameters
set_parameter_property  PIPELINE_READY            AFFECTS_ELABORATION       true
set_parameter_property  PIPELINE_READY            HDL_PARAMETER             false

add_display_item  "Video data format"   EXTERNAL_MODE                  parameter
add_display_item  "Video data format"   BPS                            parameter
add_display_item  "Video data format"   PIXELS_IN_PARALLEL             parameter

add_display_item  "General"             PIPELINE_READY                 parameter

proc validation_cb {} {

}


proc composition_cb {} {

   set v_reset_sync_vvp_version     "24.4.0"
   set v_output_bridge_vvp_version  "24.4.0"
   set v_clk_brdg_version           "19.2.0"

   set v_bps              [get_parameter_value BPS]
   set v_num_colours      3
   set v_pip              [get_parameter_value PIXELS_IN_PARALLEL]
   set v_external_mode    [get_parameter_value EXTERNAL_MODE]
   set v_icon_width       144
   set v_icon_height      144
   set v_pipeline         [get_parameter_value PIPELINE_READY]

   # The chain of components to compose :
   add_instance   main_clk_bridge      altera_clock_bridge                 ${v_clk_brdg_version}
   add_instance   main_rst_bridge      intel_vvp_reset_sync                ${v_reset_sync_vvp_version}
   add_instance   scheduler            intel_vvp_icon_scheduler            99.0
   add_instance   core                 intel_vvp_icon_algo_comp            99.0
   add_instance   out_bridge           intel_vvp_output_interface_bridge   ${v_output_bridge_vvp_version}

   set_instance_parameter_value  core        BPS                              ${v_bps}
   set_instance_parameter_value  core        PIXELS_IN_PARALLEL               ${v_pip}
   set_instance_parameter_value  core        ICON_WIDTH                       ${v_icon_width}
   set_instance_parameter_value  core        ICON_HEIGHT                      ${v_icon_height}

   set_instance_parameter_value  out_bridge  EXTERNAL_MODE                    ${v_external_mode}
   set_instance_parameter_value  out_bridge  BPS                              ${v_bps}
   set_instance_parameter_value  out_bridge  NUMBER_OF_COLOR_PLANES           ${v_num_colours}
   set_instance_parameter_value  out_bridge  PIXELS_IN_PARALLEL               ${v_pip}
   set_instance_parameter_value  out_bridge  PIPELINE_READY                   ${v_pipeline}

   set_instance_parameter_value  scheduler   EXTERNAL_MODE                    ${v_external_mode}
   set_instance_parameter_value  scheduler   BPS                              ${v_bps}
   set_instance_parameter_value  scheduler   ICON_WIDTH                       ${v_icon_width}
   set_instance_parameter_value  scheduler   ICON_HEIGHT                      ${v_icon_height}


   # --------------------------------------------------------------------------------------------------
   # --                                                                                              --
   # -- Top-level interfaces                                                                         --
   # --                                                                                              --
   # --------------------------------------------------------------------------------------------------

   add_interface           main_clock     clock             end
   add_interface           main_reset     reset             end
   set_interface_property  main_clock     export_of         main_clk_bridge.in_clk
   set_interface_property  main_reset     export_of         main_rst_bridge.in_reset

   add_interface           axi4s_vid_out  axi4stream        master
   set_interface_property  axi4s_vid_out  export_of         out_bridge.axi_st_ccd_out

   # --------------------------------------------------------------------------------------------------
   # --                                                                                              --
   # -- Connection of sub-components                                                                 --
   # --                                                                                              --
   # --------------------------------------------------------------------------------------------------

   add_connection   main_clk_bridge.out_clk       main_rst_bridge.clk
   add_connection   main_clk_bridge.out_clk       out_bridge.main_clock
   add_connection   main_clk_bridge.out_clk       scheduler.main_clock
   add_connection   main_clk_bridge.out_clk       core.main_clock

   add_connection   main_rst_bridge.out_reset     out_bridge.main_reset
   add_connection   main_rst_bridge.out_reset     scheduler.main_reset
   add_connection   main_rst_bridge.out_reset     core.main_reset

   add_connection   core.axi_st_data_out          out_bridge.axi_st_data_in

   add_connection   scheduler.axi_st_ctrl_out     out_bridge.axi_st_ctrl_in

}
