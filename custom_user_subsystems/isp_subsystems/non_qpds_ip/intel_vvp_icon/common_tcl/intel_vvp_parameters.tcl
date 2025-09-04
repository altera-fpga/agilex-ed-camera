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

package require -exact qsys 22.1

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Declaration for the common parameters used by the VIP cores and component;                   --
# -- includes default valid range and description                                                 --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------------------
# -- Global parameters for all cores                                                              --
# --------------------------------------------------------------------------------------------------
# -- vvp_max_colors/vvp_max_pip                                                                   --
# -- vvp_min_bps/vvp_max_bps                                                                      --
# -- vvp_max_width/vvp_max_height                                                                 --
# --------------------------------------------------------------------------------------------------
set vvp_max_colors 4
set vvp_max_pip 8
set vvp_min_bps 8
set vvp_max_bps 16
set vvp_max_width 16384
set vvp_max_height 16384
set vip_max_width 8192
set vip_max_height 8192


# --------------------------------------------------------------------------------------------------
# -- Common parameters                                                                            --
# --------------------------------------------------------------------------------------------------
# -- add_device_family_parameters             DEVICE_FAMILY                                       --
# --------------------------------------------------------------------------------------------------

proc add_device_family_parameters {{family_name "Stratix_10"}} {
    add_parameter             DEVICE_FAMILY            STRING                  ${family_name}
    set_parameter_property    DEVICE_FAMILY            SYSTEM_INFO             {DEVICE_FAMILY}
    set_parameter_property    DEVICE_FAMILY            VISIBLE                 false
    set_parameter_property    DEVICE_FAMILY            HDL_PARAMETER           true
    set_parameter_property    DEVICE_FAMILY            AFFECTS_ELABORATION     false
}




# --------------------------------------------------------------------------------------------------
# -- Video & Vision processing data parameters                                                    --
# --------------------------------------------------------------------------------------------------
# -- add_bps_parameters                       BPS                                                 --
# -- add_bps_in_parameters                    BPS_IN                                              --
# -- add_bps_out_parameters                   BPS_OUT                                             --
# -- add_num_colors_parameters                NUMBER_OF_COLOR_PLANES                              --
# -- add_pixels_in_parallel_parameters        PIXELS_IN_PARALLEL                                  --
# -- add_max_width_parameters                 MAX_WIDTH                                           --
# -- add_max_height_parameters                MAX_HEIGHT                                          --
# -- add_max_dim_parameters                   MAX_WIDTH, MAX_HEIGHT                               --
# -- add_is_422_parameters                    IS_422                                              --
# --------------------------------------------------------------------------------------------------

proc add_bps_parameters {{v_bps_min 0} {v_bps_max 0}} {
    global vvp_min_bps
    global vvp_max_bps

    # Apply default if no args used
    if {${v_bps_min} == 0} {
       set v_bps_min ${vvp_min_bps}
    }
    if {${v_bps_max} == 0} {
       set v_bps_max ${vvp_max_bps}
    }

    add_parameter             BPS                      INTEGER                 8
    set_parameter_property    BPS                      DISPLAY_NAME            "Bits per color sample"
    set_parameter_property    BPS                      ALLOWED_RANGES          ${v_bps_min}:${v_bps_max}
    set_parameter_property    BPS                      DESCRIPTION             "The number of bits per color sample"
    set_parameter_property    BPS                      HDL_PARAMETER           true
    set_parameter_property    BPS                      AFFECTS_ELABORATION     true
}

proc add_bps_in_parameters {{v_bps_min 0} {v_bps_max 0}} {
    global vvp_min_bps
    global vvp_max_bps

    # Apply default if no args used
    if {${v_bps_min} == 0} {
       set v_bps_min ${vvp_min_bps}
    }
    if {${v_bps_max} == 0} {
       set v_bps_max ${vvp_max_bps}
    }

    add_parameter             BPS_IN                   INTEGER                 8
    set_parameter_property    BPS_IN                   DISPLAY_NAME            "Input bits per color sample"
    set_parameter_property    BPS_IN                   ALLOWED_RANGES          ${v_bps_min}:${v_bps_max}
    set_parameter_property    BPS_IN                   DESCRIPTION \
                                                            "The number of bits per color sample at the input"
    set_parameter_property    BPS_IN                   HDL_PARAMETER           true
    set_parameter_property    BPS_IN                   AFFECTS_ELABORATION     true
}

proc add_bps_out_parameters {{v_bps_min 0} {v_bps_max 0}} {
    global vvp_min_bps
    global vvp_max_bps

    # Apply default if no args used
    if {${v_bps_min} == 0} {
       set v_bps_min ${vvp_min_bps}
    }
    if {${v_bps_max} == 0} {
       set v_bps_max ${vvp_max_bps}
    }

    add_parameter             BPS_OUT                  INTEGER                 8
    set_parameter_property    BPS_OUT                  DISPLAY_NAME            "Output bits per color sample"
    set_parameter_property    BPS_OUT                  ALLOWED_RANGES          ${v_bps_min}:${v_bps_max}
    set_parameter_property    BPS_OUT                  DESCRIPTION \
                                                          "The number of bits per color sample at the output"
    set_parameter_property    BPS_OUT                  HDL_PARAMETER           true
    set_parameter_property    BPS_OUT                  AFFECTS_ELABORATION     true
}

proc add_num_colors_parameters {{v_max_colors 0}} {
    global vvp_max_colors

    # Apply default if no args used
    if {${v_max_colors} == 0} {
       set v_max_colors ${vvp_max_colors}
    }

    add_parameter            NUMBER_OF_COLOR_PLANES    INTEGER                 [vvp_min 2 ${v_max_colors}]
    set_parameter_property   NUMBER_OF_COLOR_PLANES    DISPLAY_NAME            "Number of color planes"
    set_parameter_property   NUMBER_OF_COLOR_PLANES    ALLOWED_RANGES          1:${v_max_colors}
    set_parameter_property   NUMBER_OF_COLOR_PLANES    DESCRIPTION             "The number of color planes per pixel"
    set_parameter_property   NUMBER_OF_COLOR_PLANES    HDL_PARAMETER           true
    set_parameter_property   NUMBER_OF_COLOR_PLANES    AFFECTS_ELABORATION     true
}

proc add_pixels_in_parallel_parameters {{v_max_pip 0}} {
    global vvp_max_pip

    # Apply default if no args used
    if {${v_max_pip} == 0} {
       set v_max_pip ${vvp_max_pip}
    }

    add_parameter             PIXELS_IN_PARALLEL       INTEGER                 1
    set_parameter_property    PIXELS_IN_PARALLEL       DISPLAY_NAME            "Number of pixels in parallel"
    set_parameter_property    PIXELS_IN_PARALLEL       ALLOWED_RANGES          1:${v_max_pip}
    set_parameter_property    PIXELS_IN_PARALLEL       DESCRIPTION \
                                                          "The number of pixels transmitted every clock cycle."
    set_parameter_property    PIXELS_IN_PARALLEL       HDL_PARAMETER           true
    set_parameter_property    PIXELS_IN_PARALLEL       AFFECTS_ELABORATION     true
}

proc add_max_width_parameters {{v_x_min 0} {v_x_max 0}} {

    global vvp_max_width

    # Apply default if no args used
    if {${v_x_min} == 0} {
        set v_x_min 32
    }
    if {${v_x_max} == 0} {
       set v_x_max ${vvp_max_width}
    }

    add_parameter             MAX_WIDTH                INTEGER                 ${v_x_max}
    set_parameter_property    MAX_WIDTH                DISPLAY_NAME            "Maximum field width"
    set_parameter_property    MAX_WIDTH                ALLOWED_RANGES          ${v_x_min}:${v_x_max}
    set_parameter_property    MAX_WIDTH                DESCRIPTION \
                                                          "The maximum width of images / video fields"
    set_parameter_property    MAX_WIDTH                HDL_PARAMETER           true
    set_parameter_property    MAX_WIDTH                AFFECTS_ELABORATION     true
}

proc add_max_height_parameters {{v_y_min 0} {v_y_max 0}} {

    global vvp_max_height

    # Apply default if no args used
    if {${v_y_min} == 0} {
        set v_y_min 32
    }
    if {${v_y_max} == 0} {
       set v_y_max ${vvp_max_height}
    }

    add_parameter             MAX_HEIGHT               INTEGER                 ${v_y_max}
    set_parameter_property    MAX_HEIGHT               DISPLAY_NAME            "Maximum field height"
    set_parameter_property    MAX_HEIGHT               ALLOWED_RANGES          ${v_y_min}:${v_y_max}
    set_parameter_property    MAX_HEIGHT               DESCRIPTION \
                                                        "The maximum height of images / video fields"
    set_parameter_property    MAX_HEIGHT               HDL_PARAMETER           true
    set_parameter_property    MAX_HEIGHT               AFFECTS_ELABORATION     true
}

proc add_max_dim_parameters {{v_x_min 0} {v_y_min 0} {v_x_max 0} {v_y_max 0}} {
    add_max_width_parameters   ${v_x_min}  ${v_x_max}
    add_max_height_parameters  ${v_y_min}  ${v_y_max}
}

proc add_external_mode_parameters {} {

   add_parameter            EXTERNAL_MODE            INTEGER                   0
   set_parameter_property   EXTERNAL_MODE            DISPLAY_NAME              "Lite mode"
   set_parameter_property   EXTERNAL_MODE            ALLOWED_RANGES            0:1
   set_parameter_property   EXTERNAL_MODE            DISPLAY_HINT              boolean
   set_parameter_property   EXTERNAL_MODE            DESCRIPTION \
                                      "Run the core in Lite mode, with no support for control packets"
   set_parameter_property   EXTERNAL_MODE            HDL_PARAMETER             true
   set_parameter_property   EXTERNAL_MODE            AFFECTS_ELABORATION       true
}

proc add_is_422_parameters {} {
    # IS_422 parameter for the cases where the algorithm needs to know it is handling 422 data
    add_parameter             IS_422                   INTEGER                 1
    set_parameter_property    IS_422                   DISPLAY_NAME            "4:2:2 support"
    set_parameter_property    IS_422                   ALLOWED_RANGES          0:1
    set_parameter_property    IS_422                   DISPLAY_HINT            boolean
    set_parameter_property    IS_422                   DESCRIPTION \
                                        "Adapt the processing algorithm for 4:2:2 subsampled data"
    set_parameter_property    IS_422                   HDL_PARAMETER           true
    set_parameter_property    IS_422                   AFFECTS_ELABORATION     true

    add_display_item          "Video Data Format"      IS_422                  parameter
}


# --------------------------------------------------------------------------------------------------
# -- Master/Slave parameters                                                                      --
# --------------------------------------------------------------------------------------------------
# -- add_runtime_control_parameters           RUNTIME_CONTROL                                     --
# -- add_common_master_parameters             CLOCKS_ARE_SEPARATE/MEM_PORT_WIDTH/MEM_ADDR_WIDTH   --
# -- add_bursting_master_parameters           {master}_BURST_TARGET                               --
# --------------------------------------------------------------------------------------------------

proc add_enable_debug_parameters {} {
    add_parameter             ENABLE_DEBUG          INTEGER                 0
    set_parameter_property    ENABLE_DEBUG          DISPLAY_NAME            "Debug features"
    set_parameter_property    ENABLE_DEBUG          ALLOWED_RANGES          0:1
    set_parameter_property    ENABLE_DEBUG          DISPLAY_HINT            boolean
    set_parameter_property    ENABLE_DEBUG          DESCRIPTION             "Enable debug features"
    set_parameter_property    ENABLE_DEBUG          HDL_PARAMETER           true
    set_parameter_property    ENABLE_DEBUG          AFFECTS_ELABORATION     true
}

proc add_separate_slave_clock_parameters {} {
    add_parameter             SEPARATE_SLAVE_CLOCK  INTEGER                   0
    set_parameter_property    SEPARATE_SLAVE_CLOCK  DISPLAY_NAME \
                                             "Separate clock for control interface"
    set_parameter_property    SEPARATE_SLAVE_CLOCK  ALLOWED_RANGES            0:1
    set_parameter_property    SEPARATE_SLAVE_CLOCK  HDL_PARAMETER             false
    set_parameter_property    SEPARATE_SLAVE_CLOCK  DISPLAY_HINT              boolean
    set_parameter_property    SEPARATE_SLAVE_CLOCK  DESCRIPTION \
                                            "Run the run-time control interface on a different clock domain"
    set_parameter_property    SEPARATE_SLAVE_CLOCK  AFFECTS_ELABORATION       true
}

proc add_axi_slave_parameters {} {
   add_parameter            SLAVE_PROTOCOL           STRING                    "Avalon"
   set_parameter_property   SLAVE_PROTOCOL           DISPLAY_NAME              "Control interface protocol"
   set_parameter_property   SLAVE_PROTOCOL           ALLOWED_RANGES            {"Avalon" "AXI"}
   set_parameter_property   SLAVE_PROTOCOL           HDL_PARAMETER             false
   set_parameter_property   SLAVE_PROTOCOL           AFFECTS_ELABORATION       true
   set_parameter_property   SLAVE_PROTOCOL           VISIBLE                   false
}

proc add_runtime_control_parameters {{add_enable_debug 0} {dual_clock 0} {add_slave_protocol 0}} {
    add_parameter             RUNTIME_CONTROL       INTEGER                 0
    set_parameter_property    RUNTIME_CONTROL       DISPLAY_NAME            "Memory mapped control interface"
    set_parameter_property    RUNTIME_CONTROL       ALLOWED_RANGES          0:1
    set_parameter_property    RUNTIME_CONTROL       DISPLAY_HINT            boolean
    set_parameter_property    RUNTIME_CONTROL       DESCRIPTION \
                                                            "Enable memory mapped run-time control interface"
    set_parameter_property    RUNTIME_CONTROL       HDL_PARAMETER           true
    set_parameter_property    RUNTIME_CONTROL       AFFECTS_ELABORATION     true

    if { ${add_enable_debug} > 0 } {
        add_enable_debug_parameters
    }
    if { ${dual_clock} > 0 } {
        add_separate_slave_clock_parameters
    }
    if { ${add_slave_protocol} > 0 } {
        add_axi_slave_parameters
    }

}

proc add_enable_control_sync_parameters {} {
   add_parameter             ENABLE_CONTROL_SYNC   INTEGER                 0
   set_parameter_property    ENABLE_CONTROL_SYNC   DISPLAY_NAME            "Control synchronization packets"
   set_parameter_property    ENABLE_CONTROL_SYNC   ALLOWED_RANGES          0:1
   set_parameter_property    ENABLE_CONTROL_SYNC   DISPLAY_HINT            boolean
   set_parameter_property    ENABLE_CONTROL_SYNC   DESCRIPTION \
                                                          "Enable support for control synchronization packets"
   set_parameter_property    ENABLE_CONTROL_SYNC   HDL_PARAMETER           true
   set_parameter_property    ENABLE_CONTROL_SYNC   AFFECTS_ELABORATION     false
}

proc add_support_update_cmd_parameters {} {
   add_parameter            P_UPDATE_CMD_SUPPORTED           INTEGER                   0
   set_parameter_property   P_UPDATE_CMD_SUPPORTED           DISPLAY_NAME \
                                                                "Support for update commands"
   set_parameter_property   P_UPDATE_CMD_SUPPORTED           DESCRIPTION \
                                                                "Enable support for register update commands"
   set_parameter_property   P_UPDATE_CMD_SUPPORTED           ALLOWED_RANGES            0:1
   set_parameter_property   P_UPDATE_CMD_SUPPORTED           HDL_PARAMETER             true
   set_parameter_property   P_UPDATE_CMD_SUPPORTED           DISPLAY_HINT              boolean
   set_parameter_property   P_UPDATE_CMD_SUPPORTED           AFFECTS_ELABORATION       false

   add_parameter            P_CORE_CTRL_ID           INTEGER                   0
   set_parameter_property   P_CORE_CTRL_ID           DISPLAY_NAME              "Register update core identifier"
   set_parameter_property   P_CORE_CTRL_ID           DESCRIPTION \
                                                "Identifier used to target the core in register update commands"
   set_parameter_property   P_CORE_CTRL_ID           HDL_PARAMETER             true
   set_parameter_property   P_CORE_CTRL_ID           AFFECTS_ELABORATION       false
   set_parameter_property   P_CORE_CTRL_ID           ALLOWED_RANGES            0:239
}

proc add_common_master_width_parameters {} {

    add_parameter P_AV_MM_DATA_WIDTH INTEGER 32
    set_parameter_property   P_AV_MM_DATA_WIDTH        DISPLAY_NAME           "Avalon-MM host(s) local ports width"
    set_parameter_property   P_AV_MM_DATA_WIDTH        ALLOWED_RANGES \
                                                        {16 32 64 128 256 512 1024}
    set_parameter_property   P_AV_MM_DATA_WIDTH        DESCRIPTION \
                                                        "The width in bits of the Avalon-MM host port(s)"
    set_parameter_property   P_AV_MM_DATA_WIDTH        HDL_PARAMETER          true
    set_parameter_property   P_AV_MM_DATA_WIDTH        AFFECTS_ELABORATION    true

    add_parameter            P_AV_MM_ADDR_WIDTH        INTEGER                32
    set_parameter_property   P_AV_MM_ADDR_WIDTH        DISPLAY_NAME \
                                                        "Avalon-MM host(s) local ports address width"
    set_parameter_property   P_AV_MM_ADDR_WIDTH        ALLOWED_RANGES         16:32
    set_parameter_property   P_AV_MM_ADDR_WIDTH        HDL_PARAMETER          true
    set_parameter_property   P_AV_MM_ADDR_WIDTH        AFFECTS_ELABORATION    true
}


proc add_common_master_parameters {} {
    # CLOCKS_ARE_SEPARATE parameter, master bus clock rate is not the same as the core
    add_parameter CLOCKS_ARE_SEPARATE INTEGER 1
    set_parameter_property   CLOCKS_ARE_SEPARATE   DISPLAY_NAME \
                                              "Separate clock for the Avalon-MM host interface(s)"
    set_parameter_property   CLOCKS_ARE_SEPARATE   ALLOWED_RANGES         0:1
    set_parameter_property   CLOCKS_ARE_SEPARATE   DISPLAY_HINT           boolean
    set_parameter_property   CLOCKS_ARE_SEPARATE   DESCRIPTION \
                                              "Use separate clock for the Avalon-MM host interface(s)"
    set_parameter_property   CLOCKS_ARE_SEPARATE   HDL_PARAMETER          true
    set_parameter_property   CLOCKS_ARE_SEPARATE   AFFECTS_ELABORATION    true

    add_common_master_width_parameters
}

proc add_bursting_master_parameters { {master_name ""} } {
    if { ${master_name} == "" } {
        set v_burst_target_param_name BURST_TARGET
        set v_lc_master_name "master"
    } else {
        set v_burst_target_param_name ${master_name}_BURST_TARGET
        set v_lc_master_name [string tolower ${master_name}]
    }


    add_parameter ${v_burst_target_param_name} INTEGER 32
    set_parameter_property   ${v_burst_target_param_name}     DISPLAY_NAME \
                                                    "Av-MM ${v_lc_master_name} burst target"
    set_parameter_property   ${v_burst_target_param_name}     ALLOWED_RANGES \
                                                    {2 4 8 16 32 64}
    set_parameter_property   ${v_burst_target_param_name}     DESCRIPTION \
                                                    "The target burst size of the Av-MM ${v_lc_master_name}"
    set_parameter_property   ${v_burst_target_param_name}     HDL_PARAMETER             true
    set_parameter_property   ${v_burst_target_param_name}     AFFECTS_ELABORATION       true
}

proc add_pipeline_ready_parameters {} {
   add_parameter            PIPELINE_READY           INTEGER                   0
   set_parameter_property   PIPELINE_READY           DISPLAY_NAME              "Pipeline ready signals"
   set_parameter_property   PIPELINE_READY           ALLOWED_RANGES            0:1
   set_parameter_property   PIPELINE_READY           HDL_PARAMETER             true
   set_parameter_property   PIPELINE_READY           DISPLAY_HINT              boolean
   set_parameter_property   PIPELINE_READY           AFFECTS_ELABORATION       false
}



# --------------------------------------------------------------------------------------------------
# -- Assignment helpers (for embedded SW flows)                                                   --
# -- Make sure the functions are called from the generation/compose section                       --
# -- The selected parameters must have affects_[elaboration|generation] set to true               --
# -- set_dts_assignments  create dts assigments to build a linux driver                           --
# -- set_nios_assignments create macro assigments in system.h                                     --
# --------------------------------------------------------------------------------------------------
proc set_dts_assignments {dts_params} {
    set v_module_name          [get_module_property NAME]

    set_module_assignment embeddedsw.dts.vendor          "intel"
    set_module_assignment embeddedsw.dts.group           "vvp"
    set_module_assignment embeddedsw.dts.name            "${v_module_name}"
    set_module_assignment embeddedsw.dts.compatible      "intel,${v_module_name}"

    foreach param ${dts_params} {
        set_module_assignment     embeddedsw.dts.params.${param}       [get_parameter_value  ${param}]
    }
}

proc set_nios_assignments {nios_params} {
    set v_module_name          [get_module_property NAME]
    set v_uc_module_name       [string toupper ${v_module_name}]

    foreach param ${nios_params} {
        set v_macro_name            {${v_uc_module_name}}_{${param}}
        set_module_assignment     embeddedsw.CMacro.${v_macro_name}      [get_parameter_value  ${param}]
    }
}


# ------------------------------------------------------------------------------------------------------
# -- Add the Offset Capability Info to a core.                                                        --
# -- These functions are not meant to be called unless a specific Quartus ini is enabled              --
# -- They add a set of (non-HDL) parameters that can be probed through platform designer and are used --
# -- OCS IP when it builds the reference table                                                        --
# ------------------------------------------------------------------------------------------------------
proc add_ocs_param {gui_grp desc param_name default_val lower_val higher_val } {

    add_parameter           ${param_name}  INTEGER        ${default_val}
    set_parameter_property  ${param_name}  DISPLAY_NAME   ${desc}
    set_parameter_property  ${param_name}  ALLOWED_RANGES ${lower_val}:${higher_val}
    set_parameter_property  ${param_name}  ENABLED        true
    set_parameter_property  ${param_name}  VISIBLE        true
    set_parameter_property  ${param_name}  HDL_PARAMETER  false

    add_display_item        ${gui_grp}     ${param_name}    parameter
}

proc add_ocs_capability { value version {en 0} {st 0} } {

    # Derived parameters    C_OMNI_CAP_ENABLED  configured to 1 when the offset capabilities are enabled by ini and
    # when the core actually presents a slave interface
    add_ocs_param              "CapInfo"                 "Offset cap enabled"   C_OMNI_CAP_ENABLED     0    0    1
    set_parameter_property     C_OMNI_CAP_ENABLED        ENABLED                false
    set_parameter_property     C_OMNI_CAP_ENABLED        DERIVED                true
    set_parameter_property     C_OMNI_CAP_ENABLED        DISPLAY_HINT           boolean--

    # The QUARTUS_INI SYSTEM_INFO parameter used to display/hide the group of offset capability parameters and to configfure C_OMNI_CAP_ENABLED
    add_parameter          VVP_OCS_ENABLED_INI  BOOLEAN          false
    set_parameter_property VVP_OCS_ENABLED_INI  DESCRIPTION      "Whether the vvp_ocs_enabled ini was enabled"
    set_parameter_property VVP_OCS_ENABLED_INI  SYSTEM_INFO      QUARTUS_INI
    set_parameter_property VVP_OCS_ENABLED_INI  SYSTEM_INFO_ARG  "vvp_ocs_enabled"
    set_parameter_property VVP_OCS_ENABLED_INI  VISIBLE           false

    # CapInfo group, hidden by default
    add_display_item               ""      "CapInfo"     GROUP
    set_display_item_property              "CapInfo"     VISIBLE         false

    # Constant and/or derived parameters configured by the core (type, version, size of the register map)
    add_ocs_param      "CapInfo"    "Type"                  C_OMNI_CAP_TYPE       ${value}    0   1024
    add_ocs_param      "CapInfo"    "Version"               C_OMNI_CAP_VERSION    ${version}  1   255
    add_ocs_param      "CapInfo"    "Size (32-bit words)"   C_OMNI_CAP_SIZE       0         0   1073741824

    set_parameter_property     C_OMNI_CAP_TYPE             ENABLED         false
    set_parameter_property     C_OMNI_CAP_VERSION          ENABLED         false
    set_parameter_property     C_OMNI_CAP_SIZE             ENABLED         false
    set_parameter_property     C_OMNI_CAP_SIZE             DERIVED         true

    # User parameters to configure up the offset capability properly
    add_ocs_param      "CapInfo"    "Associated ID"             C_OMNI_CAP_ID_ASSOCIATED    0             0     255
    add_ocs_param      "CapInfo"    "Component ID"              C_OMNI_CAP_ID_COMPONENT     0             0     255
    add_ocs_param      "CapInfo"    "IRQ Vector (255:disabled)" C_OMNI_CAP_IRQ              255           0     255
    add_ocs_param      "CapInfo"    "Tag"                       C_OMNI_CAP_TAG              0             0     255

    add_ocs_param  "CapInfo"  "IRQ Enable Exists"     C_OMNI_CAP_IRQ_ENABLE_EN    [expr ${en}!=0 ? 1 : 0]   0  1
    add_ocs_param  "CapInfo"  "IRQ Enable Register"   C_OMNI_CAP_IRQ_ENABLE       ${en}                     0  32767
    set_parameter_property     C_OMNI_CAP_IRQ_ENABLE_EN    DISPLAY_HINT    boolean--
    if {${en}} {
        set_parameter_property     C_OMNI_CAP_IRQ_ENABLE_EN    VISIBLE  false
        set_parameter_property     C_OMNI_CAP_IRQ_ENABLE       VISIBLE  false
    }

    add_ocs_param  "CapInfo"  "IRQ Status Exists"       C_OMNI_CAP_IRQ_STATUS_EN  [expr ${st}!=0 ? 1 : 0]   0  1
    add_ocs_param  "CapInfo"  "IRQ Status Register"     C_OMNI_CAP_IRQ_STATUS     ${st}                     0  32767
    set_parameter_property     C_OMNI_CAP_IRQ_STATUS_EN    DISPLAY_HINT    boolean--
    if {${st}} {
        set_parameter_property     C_OMNI_CAP_IRQ_STATUS_EN    VISIBLE     false
        set_parameter_property     C_OMNI_CAP_IRQ_STATUS       VISIBLE     false
    }
}

# # vvp_next_power_of_two: vvp_next_power_of_two(n) == 2^p   with p chosen so that 2^(p-1) < n <= 2^p
proc vvp_next_power_of_two {n} {
    set v_result 1
    while {${v_result} < ${n}} {
        set v_result [expr ${v_result} * 2]
    }
    return ${v_result}
}

# --
# -- ocs_validation_callback_helper
# --
# -- is_rt_enabled   Is runtime control enabled
# -- size            The number of registers in words assuming the address bus is properly sized as tightly as possible.
# --                 If not, use size == 2^(address_width)
# --
proc ocs_validation_callback_helper { is_rt_enabled  size } {

    # Check the value of the quartus ini  vip_ocs_enabled
    set v_vvp_ocs_enabled_ini    [get_parameter_value VVP_OCS_ENABLED_INI]

    # Display/hide the CapInfo group of parameters accordingly
    set_display_item_property  "CapInfo"     VISIBLE        ${v_vvp_ocs_enabled_ini}

    # if enabled, display the cap info parameters (greyed out if the core
    # does not have a slave interface to implement the offset capability)
    if { ${v_vvp_ocs_enabled_ini} } {
        set_parameter_value      C_OMNI_CAP_ENABLED         ${is_rt_enabled}
        set_parameter_value      C_OMNI_CAP_SIZE            [vvp_next_power_of_two ${size}]
        if { ${is_rt_enabled} } {
            set_parameter_property   C_OMNI_CAP_ID_ASSOCIATED   ENABLED     true
            set_parameter_property   C_OMNI_CAP_ID_COMPONENT    ENABLED     true
            set_parameter_property   C_OMNI_CAP_IRQ             ENABLED     true
            set_parameter_property   C_OMNI_CAP_TAG             ENABLED     true
            set_parameter_property   C_OMNI_CAP_IRQ_ENABLE_EN   ENABLED     true
            set_parameter_property   C_OMNI_CAP_IRQ_ENABLE      ENABLED     true
            set_parameter_property   C_OMNI_CAP_IRQ_STATUS_EN   ENABLED     true
            set_parameter_property   C_OMNI_CAP_IRQ_STATUS      ENABLED     true

        } else {
            set_parameter_property   C_OMNI_CAP_ID_ASSOCIATED   ENABLED     false
            set_parameter_property   C_OMNI_CAP_ID_COMPONENT    ENABLED     false
            set_parameter_property   C_OMNI_CAP_IRQ             ENABLED     false
            set_parameter_property   C_OMNI_CAP_TAG             ENABLED     false
            set_parameter_property   C_OMNI_CAP_IRQ_ENABLE_EN   ENABLED     false
            set_parameter_property   C_OMNI_CAP_IRQ_ENABLE      ENABLED     false
            set_parameter_property   C_OMNI_CAP_IRQ_STATUS_EN   ENABLED     false
            set_parameter_property   C_OMNI_CAP_IRQ_STATUS      ENABLED     false
        }
    }
}
