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

# +--------------------------------------------------------------------------------------------------------------------
# |
# | Name:        intel_vvp_protocols.tcl
# |
# | Description: This package provides construction and validation procedures which should be used when constructing
# |              interfaces conforming to the VVP specifications.
# |
# | Notes:       Interface assignments are used to transfer information between each of the procedures in this
# |              package. They are also used to save information to the sopcinfo file for use by downstream tools.
# |
# | Author:      Vivek Gowri-Shankar
# |
# +--------------------------------------------------------------------------------------------------------------------

package provide intel_vvp_st_format 1.0
package provide intel_vvp_mm_format 1.0

# +--------------------------------------------------------------------------------------------------------------------
# | Define a namespace for this package to declare and define constants for the vvp protocols.
# +--------------------------------------------------------------------------------------------------------------------
namespace eval ::intel_vvp_st_format {

    # Package constants
    variable ctrl_length             4
    variable ctrl_width             16

    # Interface properties
    variable valid_intf_type                {vvp_ccd vvp_ctrl  vvp_data  vvp_token}
    variable valid_ccd_intf_properties      {BITS_PER_SAMPLE NUMBER_OF_COLOR_PLANES PIXELS_IN_PARALLEL}
    variable valid_ctrl_intf_properties     {}
    variable valid_data_intf_properties     {BITS_PER_SAMPLE NUMBER_OF_COLOR_PLANES PIXELS_IN_PARALLEL}
    variable valid_token_intf_properties    {}

    # Interface wire v_roles
    variable required_ccd_roles             {tdata tvalid tready tlast tuser}
    variable required_ctrl_roles            {tdata tvalid tready tlast tuser}
    variable required_data_roles            {tdata tvalid tready tlast tuser}
    variable required_token_roles           {tdata tvalid tready}
}


# +--------------------------------------------------------------------------------------------------------------------
# | is_vvp_intf    - this procedure allows you check whether the interface is declared as a video & vision
# |                  processing streaming interface. It does not check its initialization
# | v_interface_name   The name of the interface to check
# +--------------------------------------------------------------------------------------------------------------------
proc ::intel_vvp_st_format::is_vvp_intf { v_interface_name } {
    variable valid_intf_type

    set v_interface_type [get_interface_assignment ${v_interface_name} "intel_vvp_st_format.INTF_TYPE"]

    # Ensure that the vvp interface type is valid
    if {[lsearch -exact ${valid_intf_type} ${v_interface_type}] == -1} {
        return ""
    }

    return ${v_interface_type}
}


# +--------------------------------------------------------------------------------------------------------------------
# | get_intf_valid_properties - this procedure returns the valid properties for the given interface type
# |
# | v_interface_type   The type of the interface
# +--------------------------------------------------------------------------------------------------------------------
proc ::intel_vvp_st_format::get_intf_valid_properties {v_interface_type} {
    variable valid_ccd_intf_properties
    variable valid_ctrl_intf_properties
    variable valid_data_intf_properties
    variable valid_token_intf_properties

    if { [string equal ${v_interface_type} "vvp_ccd"] } {
        return ${valid_ccd_intf_properties}
    } elseif { [string equal ${v_interface_type} "vvp_ctrl"] } {
        return ${valid_ctrl_intf_properties}
    } elseif { [string equal ${v_interface_type} "vvp_data"] } {
        return ${valid_data_intf_properties}
    }  elseif { [string equal ${v_interface_type} "vvp_token"] } {
        return ${valid_token_intf_properties}
    } else {
        return ""
    }
}

# +--------------------------------------------------------------------------------------------------------------------
# | get_intf_required_roles - This procedure returns the wire v_roles required for the given interface.
# |                           The v_roles may vary depending on the interface property values which must be set
# |
# | v_interface_name   The name of the interface to validate
# +--------------------------------------------------------------------------------------------------------------------
proc ::intel_vvp_st_format::get_intf_required_roles {v_interface_name} {
    variable required_ccd_roles
    variable required_ctrl_roles
    variable required_data_roles
    variable required_token_roles

    set v_interface_type [get_intf_type ${v_interface_name}]

    if { [string equal ${v_interface_type} "vvp_ccd"] } {
        return ${required_ccd_roles}
    } elseif { [string equal ${v_interface_type} "vvp_ctrl"] } {
        return ${required_ctrl_roles}
    } elseif { [string equal ${v_interface_type} "vvp_data"] } {
        return ${required_data_roles}
    }  elseif { [string equal ${v_interface_type} "vvp_token"] } {
        return ${required_token_roles}
    } else {
        return ""
    }
}


# +--------------------------------------------------------------------------------------------------------------------
# | get_intf_tag - this procedure returns the tag for the given interface type
# |
# | v_interface_type   The type of the interface
# +--------------------------------------------------------------------------------------------------------------------
proc ::intel_vvp_st_format::get_intf_tag {v_interface_type} {

    if { [string equal ${v_interface_type} "vvp_ccd"] } {
        return "ccd"
    } elseif { [string equal ${v_interface_type} "vvp_ctrl"] } {
        return "ctrl"
    } elseif { [string equal ${v_interface_type} "vvp_data"] } {
        return "data"
    }  elseif { [string equal ${v_interface_type} "vvp_token"] } {
        return "token"
    } else {
        return ""
    }
}


# +--------------------------------------------------------------------------------------------------------------------
# | set_intf_type  - this procedure allows you to configure the type of a video & vision processing streaming interface.
# |
# | v_interface_name   The name of the interface to configure
# | v_interface_type   The type to set (vvp_ccd, vvp_ctrl, vvp_data or vvp_token)
# +--------------------------------------------------------------------------------------------------------------------
proc ::intel_vvp_st_format::set_intf_type { v_interface_name v_interface_type } {
    variable valid_intf_type

    # Ensure that the vvp interface type is valid
    if {[lsearch -exact ${valid_intf_type} ${v_interface_type}] == -1} {
        error [format "intel_vvp_st_format::set_intf_type: The interface type %s is not allowed for %s. Permitted values are: %s." ${v_interface_type} ${v_interface_name} ${valid_intf_type}]
    }

    set_interface_assignment ${v_interface_name} "intel_vvp_st_format.INTF_TYPE" ${v_interface_type}
}


# +--------------------------------------------------------------------------------------------------------------------
# | get_intf_type - this procedure allows you to query the type of a video & vision processing streaming interface.
# |                 The type must have been set prior to calling this function
# |
# | v_interface_name   The name of the interface to query
# +--------------------------------------------------------------------------------------------------------------------
proc ::intel_vvp_st_format::get_intf_type { v_interface_name } {
    variable valid_intf_type

    set v_interface_type [is_vvp_intf ${v_interface_name}]

    # Ensure that the vvp interface type is valid
    if {[string equal ${v_interface_type} ""]} {
        error [format "intel_vvp_st_format::get_intf_type: The interface type of %s was not initialized properly. Permitted values are: %s." ${v_interface_name} ${valid_intf_type}]
    }

    return ${v_interface_type}
}


# +--------------------------------------------------------------------------------------------------------------------
# | set_intf_property - this procedure allows you to configure the top level properties of a typed
# |                     video & vision processing streaming interface.
# |
# | v_interface_name   The name of the interface to configure
# | property_name    The name of the property to set (
# | v_value            The v_value of the property
# +--------------------------------------------------------------------------------------------------------------------
proc ::intel_vvp_st_format::set_intf_property {v_interface_name property_name v_value} {

    set v_interface_type [get_intf_type ${v_interface_name}]
    set v_valid_intf_properties [get_intf_valid_properties ${v_interface_type}]
    set v_interface_tag [get_intf_tag ${v_interface_type}]


    # Check that the property name is valid
    if {[lsearch -exact ${v_valid_intf_properties} ${property_name}] == -1} {
        error [format "intel_vvp_st_format::set_intf_property: The property %s is not a valid property for a video & vision processing %s interface. Permitted values are %s" ${property_name} ${v_interface_type} ${v_valid_intf_properties}]
    }

    # Store the property
    set_interface_assignment ${v_interface_name} "intel_vvp_st_format.${v_interface_tag}.${property_name}" ${v_value}
}


# +--------------------------------------------------------------------------------------------------------------------
# | get_intf_property - this procedure allows you to query the top level properties of a video & vision processing
# |                     streaming interface.
# |
# | v_interface_name   The name of the interface to configure
# | property_name    The name of the property to get
# +--------------------------------------------------------------------------------------------------------------------
proc ::intel_vvp_st_format::get_intf_property {v_interface_name property_name} {

    set v_interface_type [get_intf_type ${v_interface_name}]
    set v_valid_intf_properties [get_intf_valid_properties ${v_interface_type}]
    set v_interface_tag [get_intf_tag ${v_interface_type}]


    # Check that the property name is valid
    if {[lsearch -exact ${v_valid_intf_properties} ${property_name}] == -1} {
        error [format "intel_vvp_st_format::get_intf_property: The property %s is not a valid property for a video & vision processing %s interface. Permitted values are %s." ${property_name} ${v_interface_type} ${v_valid_intf_properties}]
    }

    set v_value [get_interface_assignment ${v_interface_name} "intel_vvp_st_format.${v_interface_tag}.${property_name}"]

    return ${v_value}
}


# +--------------------------------------------------------------------------------------------------------------------
# | _validate_intf_property - this procedure checks that all the top level properties of a video & vision processing
# |                           streaming interface were set.
# |
# | v_interface_name   The name of the interface to validate
# +--------------------------------------------------------------------------------------------------------------------
proc ::intel_vvp_st_format::_validate_intf_property {v_interface_name} {

    set v_interface_type [get_intf_type ${v_interface_name}]
    set v_valid_intf_properties [get_intf_valid_properties ${v_interface_type}]
    set v_interface_tag [get_intf_tag ${v_interface_type}]

    foreach prop ${v_valid_intf_properties} {
        set v_value [get_interface_assignment ${v_interface_name} "intel_vvp_st_format.${v_interface_tag}.${prop}"]
        if {${v_value} == ""} {
            error [format "intel_vvp_st_format::_validate_intf_property: The %s property for the %s interface %s was not initialized." ${prop} ${v_interface_type} ${v_interface_name}]
        }
    }
}


# +--------------------------------------------------------------------------------------------------------------------
# | Check that the specified interface has the correct ports
# +--------------------------------------------------------------------------------------------------------------------
proc ::intel_vvp_st_format::_validate_intf_ports {v_interface_name} {
    set v_intf_required_roles [get_intf_required_roles ${v_interface_name}]

    foreach v_port [get_interface_ports ${v_interface_name}] {
        set v_role [get_port_property ${v_port} ROLE]
        set v_roles(${v_role}) true

        if { [lsearch -exact ${v_intf_required_roles} ${v_role}] == -1 } {
            error [format "intel_vvp_st_format::_validate_intf_ports: Interface %s has a v_port %s with unknown v_role %s." ${v_interface_name} ${v_port} ${v_role}]
        }
    }

    foreach required_role ${v_intf_required_roles} {
        if { ![info exists v_roles(${required_role})] } {
            error [format "intel_vvp_st_format::_validate_intf_ports: Interface %s does not have a v_port with the v_role %s." ${v_interface_name} ${required_role}]
        }
    }
}


# +--------------------------------------------------------------------------------------------------------------------
# | This procedure is used to actually validate the construction of the specified interface. This procedure
# | should be called after all calls to set_packet_property for the specified interface.
# +--------------------------------------------------------------------------------------------------------------------
proc ::intel_vvp_st_format::intf_validate {v_interface_name} {

    variable ctrl_width

    _validate_intf_property ${v_interface_name}

    _validate_intf_ports ${v_interface_name}

    set v_interface_type          [get_intf_type ${v_interface_name}]
    set v_ctrl_width_in_bytes     [vvp_ceil  ${ctrl_width}   8]

    foreach v_port [get_interface_ports ${v_interface_name}] {
        set v_role [get_port_property ${v_port} ROLE]
        if {${v_role} == "tdata"} {
            set v_data_width [get_port_property ${v_port} WIDTH_VALUE]
        }
        if {${v_role} == "tuser"} {
            set v_user_width [get_port_property ${v_port} WIDTH_VALUE]
        }
    }


    if { [string equal ${v_interface_type} "vvp_ccd"] } {

        set v_bps                    [get_intf_property   ${v_interface_name}   "BITS_PER_SAMPLE"]
        set v_ncol                   [get_intf_property   ${v_interface_name}   "NUMBER_OF_COLOR_PLANES"]
        set v_pip                    [get_intf_property   ${v_interface_name}   "PIXELS_IN_PARALLEL"]

        set v_bytes_per_pixel       [vvp_max   [vvp_ceil [expr {${v_bps} * ${v_ncol}}] 8] \
                                                                          ${v_ctrl_width_in_bytes}]
        set v_expected_byte_width   [expr {${v_bytes_per_pixel} * ${v_pip}}]
        set v_expected_width        [expr {${v_expected_byte_width} * 8}]

        if { ${v_data_width} != ${v_expected_width} } {
            error [format "intel_vvp_st_format::intf_validate: The video & vision processing ccd interface %s data v_port width (%d) does not match with its assignments: max(ceil(%d(v_bps) x %d(num colors), 8), 16) x %d(pix in parallel) x 8" ${v_interface_name} ${v_data_width} ${v_bps} ${v_ncol} ${v_pip}]
        }
        if { ${v_user_width} != ${v_expected_byte_width} } {
            error [format "intel_vvp_st_format::intf_validate: The video & vision processing data interface %s user v_port width (%d) does not match with its assignments: max(ceil(%d(v_bps) x %d(num colors), 8), 16) x %d(pix in parallel)" ${v_interface_name} ${v_user_width} ${v_bps} ${v_ncol} ${v_pip}]
        }

        # Tag the version once validated
        set_interface_assignment ${v_interface_name} intel_vvp_st_format.ccd.version 1.0

    } elseif { [string equal ${v_interface_type} "vvp_data"] } {

        set v_bps                    [get_intf_property   ${v_interface_name}   "BITS_PER_SAMPLE"]
        set v_ncol                   [get_intf_property   ${v_interface_name}   "NUMBER_OF_COLOR_PLANES"]
        set v_pip                    [get_intf_property   ${v_interface_name}   "PIXELS_IN_PARALLEL"]

        set v_bytes_per_pixel        [vvp_max   [vvp_ceil [expr {${v_bps} * ${v_ncol}}] 8] \
                                                                          ${v_ctrl_width_in_bytes}]
        set v_expected_byte_width    [expr {${v_bytes_per_pixel} * ${v_pip}}]
        set v_expected_width         [expr {${v_expected_byte_width} * 8}]

        if { ${v_data_width} != ${v_expected_width} } {
            error [format "intel_vvp_st_format::intf_validate: The video & vision processing data interface %s data v_port width (%d) does not match with its assignments: max(ceil(%d(v_bps) x %d(num colors), 8), 16) x %d(pix in parallel) x 8" ${v_interface_name} ${v_data_width} ${v_bps} ${v_ncol} ${v_pip}]
        }
        if { ${v_user_width} != ${v_expected_byte_width} } {
            error [format "intel_vvp_st_format::intf_validate: The video & vision processing data interface %s user v_port width (%d) does not match with its assignments: max(ceil(%d(v_bps) x %d(num colors), 8), 16) x %d(pix in parallel)" ${v_interface_name} ${v_user_width} ${v_bps} ${v_ncol} ${v_pip}]
        }

        # Tag the version once validated
        set_interface_assignment ${v_interface_name} intel_vvp_st_format.data.version 1.0


    } elseif { [string equal ${v_interface_type} "vvp_ctrl"] } {
        variable ctrl_width

        if { ${v_data_width} != ${ctrl_width} } {
            error [format "intel_vvp_st_format::intf_validate: The video & vision processing control interface %s, data v_port width (%d) does not match with the constant ctrl_width (%d)" ${v_interface_name} ${v_data_width} ${ctrl_width}]
        }
        if { ${v_user_width} != 2 } {
            error [format "intel_vvp_st_format::intf_validate: The video & vision processing control interface %s user v_port width (%d) does not match with its expected v_value 2" ${v_interface_name} ${v_user_width}]
        }

        # Tag the version once validated
        set_interface_assignment ${v_interface_name} intel_vvp_st_format.ctrl.version 1.0

    } elseif { [string equal ${v_interface_type} "vvp_st_token"] } {
        # Tag the version once validated
        set_interface_assignment ${v_interface_name} intel_vvp_st_format.token.version 1.0
    }
}

# +--------------------------------------------------------------------------------------------------------------------
# | Define a namespace for this package to declare and define constants for the vvp protocols.
# +--------------------------------------------------------------------------------------------------------------------
namespace eval ::intel_vvp_mm_format {

    # Package constants, the slave interfaces are 32 bits wide
    variable slave_width             32
    variable slave_bus_byte_width    [expr ${slave_width} / 8]

    # The first 64 registers are reserved for the compile-time parameterization (PID_VID and VERSION_NUMBER are common, the rest are core-specific)
    # These are serviced with the ro_reg_servicer front-end
    variable read_only_params        64

    # The next 8 registers are reserved for interrupts parameterization and handling, managed by core schedulers
    variable interrupts_num_regs     8

    # The next 8 registers are reserved for the image_info structure
    # These are write registers in external mode (with optional debug readback if requested) and optional read-only debug registers in internal mode
    variable image_info_num_regs     8

    # The remainder of the slave register map is core-specific
}
