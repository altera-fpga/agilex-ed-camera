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
# -- Helper function to create all VVP cores and sub-components                                   --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------------
# -- Some global variables                                                                        --
# --------------------------------------------------------------------------------------------------
# -- internal_components              Whether sub-components should be hidden in platform designer--
# -- internal_verification_components Whether verification should be hidden in platform designer  --
# -- __ACDS_INTERNAL_DEVELOPMENT__    is set to 0 in a QPDS build or default qshell build (IPUTF) --
# --                                  this hides the sub-components and give them a default       --
# --                                  version number                                              --
# -- __ACDS_REGULAR_BUILD__           is left unchanged in a QPDS build or default qshell build   --
# --                                  but it can be set to 0 for a custom qshell build to ensure  --
# --                                  the version number used will take precedence over the       --
# --                                  default version number and the IP in the qshell is          --
# --                                  preferred over the IP in the QPDS installation              --
# --------------------------------------------------------------------------------------------------

set internal_components               true
set internal_verification_components  true


# --------------------------------------------------------------------------------------------------
# -- Component declarations                                                                       --
# --------------------------------------------------------------------------------------------------
# -- declare_common_props               Shared setup for all IP/components in the release         --
# --                                    (should not be called directly)                           --
# -- declare_common_ip_props            Shared setup for all IP in the release                    --
# --                                    (should not be called directly)                           --
# -- declare_common_component_props     Shared setup for all components in the release            --
# --                                    (should not be called directly)                           --
# -- declare_vvp_component_properties   declare a VVP sub-component                               --
# --                                    the NAME, DISPLAY_NAME and DESCRIPTION module             --
# --                                    properties have to be declared independently              --
# -- declare_cvg_component_properties   declare a CVG sub-component                               --
# --                                    the NAME, DISPLAY_NAME and DESCRIPTION module             --
# --                                    properties have to be declared independently              --
# -- declare_vvp_ip_properties          declare a top-level VVP IP core                           --
# --                                    the NAME, DISPLAY_NAME and DESCRIPTION module             --
# --                                    properties have to be declared independently              --
# -- declare_cvg_ip_properties          declare a top-level CVG IP core                           --
# --                                    the NAME, DISPLAY_NAME and DESCRIPTION module             --
# --                                    properties have to be declared independently              --
# --------------------------------------------------------------------------------------------------
proc declare_common_props {released} {

    set_module_property     VERSION                   99.0
    set_module_property     AUTHOR                    "Intel Corporation"
    set_module_property     HIDE_FROM_QUARTUS         true
    set_module_property     SUPPORTED_DEVICE_FAMILIES {{Cyclone 10 GX} {Arria 10} {Stratix 10} {Agilex 7} {Agilex 5}}
}

proc declare_common_ip_props {released} {
    declare_common_props ${released}
}


proc declare_common_component_props {released} {
    global internal_components

    declare_common_props ${released}
    set_module_property     INTERNAL                         ${internal_components}
}

proc declare_vvp_component_properties {{released 1}} {
    declare_common_component_props ${released}
    set_module_property     GROUP \
    [expr {${released} ? "DSP/Video and Vision Processing/Component Library" :  "DSP/Video and Vision Processing/Non-released/Component Library"}]
    if {${released}} {
        add_documentation_link  "User Guide" \
        https://www.intel.com/content/www/us/en/programmable/documentation/end1618909612955.html
    }
}

proc declare_cvg_component_properties {{released 1}} {
    declare_common_component_props ${released}
    set_module_property     GROUP \
    [expr {${released} ? "DSP/Video and Vision Processing/Clocked Video and Genlock/Component Library" :  "DSP/Video and Vision Processing/Clocked Video and Genlock/Non-released/Component Library"}]
    if {${released}} {
        add_documentation_link  "User Guide" \
        https://www.intel.com/content/www/us/en/programmable/documentation/end1618909612955.html
    }
}

proc declare_vvp_ip_properties {{released 1}} {
    declare_common_ip_props ${released}
    set_module_property     GROUP \
    [expr {${released} ? "DSP/Video and Vision Processing" : "DSP/Video and Vision Processing/Non-released"}]
    if {${released}} {
        add_documentation_link  "User Guide" \
        https://www.intel.com/content/www/us/en/programmable/documentation/end1618909612955.html
    }
}
proc declare_cvg_ip_properties {{released 1}} {
    declare_common_ip_props ${released}
    set_module_property     GROUP \
    [expr {${released} ? "DSP/Video and Vision Processing/Clocked Video and Genlock" : "DSP/Video and Vision Processing/Clocked Video and Genlock/Non-released"}]
    if {${released}} {
        add_documentation_link  "User Guide" \
        https://www.intel.com/content/www/us/en/programmable/documentation/end1618909612955.html
    }
}



proc declare_verification_component_properties {{released 1}} {
    global internal_verification_components

    declare_common_component_props ${released}
    set_module_property     GROUP \
    [expr {${released} ? "DSP/Video and Vision Processing/Verification Library" :  "DSP/Video and Vision Processing/Non-released/Verification Library"}]
    set_module_property     INTERNAL                         $internal_verification_components
}


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- General helper functions                                                                     --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
# -- vvp_log2                                                                                     --
# -- vvp_clog2                                                                                    --
# -- vvp_num_bits                                                                                 --
# -- vvp_max                                                                                      --
# -- vvp_min                                                                                      --
# -- vvp_power                                                                                    --
# --------------------------------------------------------------------------------------------------

# vvp_log2: log2(x) (integer math)
# pre: 1 <= x < 4294967296 (max allowed value is 2^32)
# log2(x) = 0 for x <= 1
# log2(x) = 1 for 2 <= x < 4
# log2(x) = 2 for 4 <= x < 8
# log2(x) = 32 for x == 4294967296
proc vvp_log2 {max_value} {
    if {[expr {${max_value} <= 1}]} {
        return 0
    } elseif {[expr ${max_value} == 4294967296]} {
        return 32
    } else {
        return [expr {1 + [vvp_log2 [expr ${max_value} >> 1]]}]
    }
}

# vvp_clog2: ceil(log2(x)) (integer math)
# pre: 1 <= x <= 4294967296 (max allowed value is 2^32)
# vvp_clog2(3) = vvp_clog2(4) = 2
# 2 bits are required to address a memory of depth 4
# clog2(x) = 32 for 2147483649 <= x <= 4294967296
proc vvp_clog2 {max_value} {
   if {[expr {${max_value} <= 1}]} {
        return 0
    } else {
        return [expr {1 + [vvp_num_bits [expr {${max_value} - 1} >> 1]]}]
    }
}

# vvp_num_bits: ceil(log2(x+1))
# pre: 1 <= x <= 4294967296 (==2^32)
# vvp_num_bits(4) = 3
# vvp_num_bits(4294967296) == 33
# 3 bits are required to represent the number 4 in binary format
proc vvp_num_bits {max_value} {
    if {[expr {${max_value} <= 0}]} {
        return 0
    } elseif {[expr ${max_value} == 4294967296]} {
        return 33
    } else {
        return [expr {1 + [vvp_num_bits [expr ${max_value} >> 1]]}]
    }
}

# vvp_max
proc vvp_max {a b} {
    if {${a} < ${b}} {
        return ${b}
    } else {
        return ${a}
    }
}

# vvp_min
proc vvp_min {a b} {
    if {${a} < ${b}} {
        return ${a}
    } else {
        return ${b}
    }
}

# vvp_power: vvp_power(n,v_p) == n ** v_p
proc vvp_power {n v_p} {
    set v_result 1
    while {${v_p} > 0} {
        set v_result [expr ${v_result} * ${n}]
        set v_p [expr ${v_p} - 1]
    }
    return ${v_result}
}

# vvp_ceil: vvp_ceil(a,b) == (a+b-1)/b   in other terms, considering the Euclidean division
# a = qb + r, vvp_ceil(a,b) = [q if r==0] or [q+1 if r!=0] a and b should be positive integer values
proc vvp_ceil {a b} {
    set v_result [expr {(${a} +${b} - 1) / ${b}}]
    return ${v_result}
}
