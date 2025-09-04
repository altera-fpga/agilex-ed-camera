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

# Common module properties for VIP components
declare_vvp_component_properties

set_module_property NAME intel_vvp_icon_scheduler
set_module_property DISPLAY_NAME "Icon Scheduler"
set_module_property DESCRIPTION "Scheduler for the icon generator"

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Callbacks                                                                                    --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

# Validation callback to check legality of parameter set
set_module_property   VALIDATION_CALLBACK         validation_cb

# Callback for the elaboration of this component
set_module_property   ELABORATION_CALLBACK        elaboration_cb


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Files                                                                                        --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
add_static_sv_file src_hdl/intel_vvp_icon_pkg.sv
add_static_sv_file src_hdl/intel_vvp_icon_axi_pipeline_stage.sv
add_static_sv_file src_hdl/intel_vvp_icon_axi_master.sv
add_static_sv_file src_hdl/intel_vvp_icon_scheduler.sv

setup_filesets intel_vvp_icon_scheduler

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Parameters                                                                                   --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
add_external_mode_parameters
add_bps_parameters

add_parameter           ICON_WIDTH           INTEGER                 128
set_parameter_property  ICON_WIDTH           DISPLAY_NAME            "Icon width"
set_parameter_property  ICON_WIDTH           ALLOWED_RANGES          16:1024
set_parameter_property  ICON_WIDTH           HDL_PARAMETER           true
set_parameter_property  ICON_WIDTH           AFFECTS_ELABORATION     false

add_parameter           ICON_HEIGHT          INTEGER                 128
set_parameter_property  ICON_HEIGHT          DISPLAY_NAME            "Icon height"
set_parameter_property  ICON_HEIGHT          ALLOWED_RANGES          16:1024
set_parameter_property  ICON_HEIGHT          HDL_PARAMETER           true
set_parameter_property  ICON_HEIGHT          AFFECTS_ELABORATION     false

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Validation callback                                                                          --
# -- Checking the legality of the parameter set chosen by the user                                --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

proc validation_cb {} {

}

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Dynamic ports (elaboration callback)                                                         --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
proc elaboration_cb {} {

   add_clock_reset_intf   main

   add_axi_st_vvp_ctrl_output_port   axi_st_ctrl_out       main
}
