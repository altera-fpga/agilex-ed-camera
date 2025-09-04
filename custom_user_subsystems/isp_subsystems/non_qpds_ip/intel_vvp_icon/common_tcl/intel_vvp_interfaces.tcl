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
# -- Port declarations for the most common port types used by VIP components and Megacores        --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

set common_tcl_dir [file dirname [info script]]
set intel_vvp_protocols_file [file join ${common_tcl_dir} "intel_vvp_protocols.tcl"]
source ${intel_vvp_protocols_file}
package require intel_vvp_st_format 1.0
package require intel_vvp_mm_format 1.0

set intel_vvp_generic_interfaces_file [file join ${common_tcl_dir} "intel_vvp_generic_interfaces.tcl"]
source $intel_vvp_generic_interfaces_file

# --------------------------------------------------------------------------------------------------
# -- Video & Vision processing CCD interfaces
# --------------------------------------------------------------------------------------------------

# add_axi_st_vvp_ccd_port
# \param     interface_name,                   name of the vvp ccd streaming interface
#                                                                         (vvp_ccd_in/vvp_ccd_out recommended)
# \param     direction                         master or slave
# \param     clock_intf,                       clock/reset interfaces associated with the vvp streaming interface
# \param     bits_per_sample,                  number of bits per color sample
# \param     number_of_color_planes,           number of color planes per pixel
# \param     pixels_in_parallel,               number of pixels transmitted per data beat
# Add a vvp ccd (combined control-data) axi streaming interface to the component
proc add_axi_st_vvp_ccd_port { interface_name  direction  clock_intf  bits_per_sample \
                                                          number_of_color_planes  pixels_in_parallel } {

    set v_pixel_width           [expr {${bits_per_sample} * ${number_of_color_planes}}]
    set v_symbol_width_in_bytes [vvp_max  [vvp_ceil ${v_pixel_width} 8]    2]
    set v_data_width_in_bytes   [expr {${v_symbol_width_in_bytes} * ${pixels_in_parallel}}]

    # axi-st input with tready, tlast and 1 tuser bit per byte (no tkeep, tstrb tid or tdest)
    add_axi_st_port ${interface_name}  ${direction}  ${clock_intf}  ${v_data_width_in_bytes}  1 1 0 0 0 0 1

    ::intel_vvp_st_format::set_intf_type          ${interface_name}   vvp_ccd
    ::intel_vvp_st_format::set_intf_property      ${interface_name}   BITS_PER_SAMPLE        ${bits_per_sample}
    ::intel_vvp_st_format::set_intf_property      ${interface_name}   NUMBER_OF_COLOR_PLANES ${number_of_color_planes}
    ::intel_vvp_st_format::set_intf_property      ${interface_name}   PIXELS_IN_PARALLEL     ${pixels_in_parallel}
    ::intel_vvp_st_format::intf_validate          ${interface_name}
}

# add_axi_st_vvp_ccd_input_port
# \see add_axi_st_vvp_ccd_port
proc add_axi_st_vvp_ccd_input_port { input_name clock_intf bits_per_sample number_of_color_planes \
                                                                                pixels_in_parallel } {
    add_axi_st_vvp_ccd_port   ${input_name}  slave  ${clock_intf}  ${bits_per_sample}  \
                                                            ${number_of_color_planes}  ${pixels_in_parallel}
}

# add_axi_st_vvp_ccd_output_port
# \see add_axi_st_vvp_ccd_port
proc add_axi_st_vvp_ccd_output_port { output_name clock_intf bits_per_sample number_of_color_planes \
                                                                                pixels_in_parallel } {
    add_axi_st_vvp_ccd_port   ${output_name}  master  ${clock_intf}  ${bits_per_sample}  \
                                                            ${number_of_color_planes}  ${pixels_in_parallel}
}

# add_axi_st_vvp_ccd_port_array
# \param     interface_name,                   name of the vvp ccd streaming interface (vvp_ccd_in/vvp_ccd_out
#                                                                                         recommended)
# \param     direction                         master(s) or slave(s)
# \param     v_array_size,                     number of interfaces to declare (${interface_name}_0,
#                                                                                         ${interface_name}_1,...)
# \param     clock_intf,                       clock/reset interfaces associated with the vvp streaming interface
# \param     bits_per_sample,                  number of bits per color sample
# \param     number_of_color_planes,           number of color planes per pixel
# \param     pixels_in_parallel,               number of pixels transmitted per data beat
# Add multiple vvp ccd (combined control-data) axi streaming inputs or outputs to the component, written as an 
#                                                                                         array in the SystemVerilog
proc add_axi_st_vvp_ccd_port_array { interface_name  direction  v_array_size  clock_intf bits_per_sample \
                                                                number_of_color_planes pixels_in_parallel } {

    set v_pixel_width           [expr (${bits_per_sample} * ${number_of_color_planes} )]
    set v_symbol_width_in_bytes [vvp_max  [vvp_ceil ${v_pixel_width} 8]   2]
    set v_data_width            [expr ${v_symbol_width_in_bytes} * ${pixels_in_parallel} * 8]
    set v_data_width_in_bytes   [expr {${v_symbol_width_in_bytes} * ${pixels_in_parallel}}]

    for { set v_i 0 } { ${v_i} < ${v_array_size} } { incr v_i } {

        add_axi_st_vvp_ccd_port      ${interface_name}_${v_i}  ${direction}   ${clock_intf} ${bits_per_sample} \
                                                                ${number_of_color_planes} ${pixels_in_parallel}

        set_port_property ${interface_name}_${v_i}_tdata       FRAGMENT_LIST \
          "${interface_name}_tdata@[expr (${v_i} +1) * ${v_data_width} - 1]:[expr ${v_i} * ${v_data_width}]"
        set_port_property ${interface_name}_${v_i}_tvalid      FRAGMENT_LIST "${interface_name}_tvalid@${v_i}"
        set_port_property ${interface_name}_${v_i}_tready      FRAGMENT_LIST "${interface_name}_tready@${v_i}"
        set_port_property ${interface_name}_${v_i}_tlast       FRAGMENT_LIST "${interface_name}_tlast@${v_i}"
        set_port_property ${interface_name}_${v_i}_tuser       FRAGMENT_LIST \
          "${interface_name}_tuser@[expr (${v_i} +1) * ${v_data_width_in_bytes} - 1]:[expr ${v_i} * ${v_data_width_in_bytes}]"
    }
}

# add_axi_st_vvp_ccd_input_port_array
# \see add_axi_st_vvp_ccd_port_array
proc add_axi_st_vvp_ccd_input_port_array { input_name v_array_size clock_intf bits_per_sample \
                                                    number_of_color_planes pixels_in_parallel } {
    add_axi_st_vvp_ccd_port_array   ${input_name}   slave   ${v_array_size}  ${clock_intf}  \
                                                ${bits_per_sample}  ${number_of_color_planes}  ${pixels_in_parallel}
}

# add_axi_st_vvp_ccd_output_port_array
# \see add_axi_st_vvp_ccd_port_array
proc add_axi_st_vvp_ccd_output_port_array { output_name v_array_size clock_intf bits_per_sample \
                                                                      number_of_color_planes pixels_in_parallel } {
    add_axi_st_vvp_ccd_port_array   ${output_name}  master  ${v_array_size}  ${clock_intf}  ${bits_per_sample}  \
                                                                    ${number_of_color_planes}  ${pixels_in_parallel}
}


# --------------------------------------------------------------------------------------------------
# -- Video & Vision processing data interfaces
# --------------------------------------------------------------------------------------------------

# add_axi_st_vvp_data_port
# \param     interface_name,                   name of the vvp data streaming interface
#                                                                           (vvp_data_in/vvp_data_out recommended)
# \param     direction                         master or slave
# \param     clock_intf,                       clock/reset interfaces associated with the vvp streaming interface
# \param     bits_per_sample,                  number of bits per color sample
# \param     number_of_color_planes,           number of color planes per pixel
# \param     pixels_in_parallel,               number of pixels transmitted per data beat
# Add a vvp data (no control packet) axi streaming interface to the component
proc add_axi_st_vvp_data_port { interface_name  direction  clock_intf  bits_per_sample  number_of_color_planes \
                                                                                           pixels_in_parallel } {

    set v_pixel_width           [expr {${bits_per_sample} * ${number_of_color_planes}}]
    set v_symbol_width_in_bytes [vvp_max  [vvp_ceil ${v_pixel_width} 8]    2]
    set v_data_width_in_bytes   [expr {${v_symbol_width_in_bytes} * ${pixels_in_parallel}}]

    # axi-st input with tready, tlast and 1 tuser bit per byte (no tkeep, tstrb tid or tdest)
    add_axi_st_port ${interface_name}  ${direction}  ${clock_intf}  ${v_data_width_in_bytes}  1 1 0 0 0 0 1

    ::intel_vvp_st_format::set_intf_type          ${interface_name}   vvp_data
    ::intel_vvp_st_format::set_intf_property      ${interface_name}   BITS_PER_SAMPLE        ${bits_per_sample}
    ::intel_vvp_st_format::set_intf_property      ${interface_name}   NUMBER_OF_COLOR_PLANES ${number_of_color_planes}
    ::intel_vvp_st_format::set_intf_property      ${interface_name}   PIXELS_IN_PARALLEL     ${pixels_in_parallel}
    ::intel_vvp_st_format::intf_validate          ${interface_name}
}

# add_axi_st_vvp_data_input_port
# \see add_axi_st_vvp_data_port
proc add_axi_st_vvp_data_input_port { input_name clock_intf bits_per_sample number_of_color_planes \
                                                                                pixels_in_parallel } {
    add_axi_st_vvp_data_port   ${input_name}  slave  ${clock_intf}  ${bits_per_sample}  \
                                                                ${number_of_color_planes}  ${pixels_in_parallel}
}

# add_axi_st_vvp_data_output_port
# \see add_axi_st_vvp_data_port
proc add_axi_st_vvp_data_output_port { output_name clock_intf bits_per_sample number_of_color_planes \
                                                                                  pixels_in_parallel } {
    add_axi_st_vvp_data_port   ${output_name}  master  ${clock_intf}  ${bits_per_sample}  \
                                                                ${number_of_color_planes}  ${pixels_in_parallel}
}

# add_axi_st_vvp_data_port_array
# \param     interface_name,                   name of the vvp data streaming interface (vvp_data_in/vvp_data_out
#                                                                                           recommended)
# \param     direction                         master(s) or slave(s)
# \param     v_array_size,                     number of interfaces to declare (${interface_name}_0,
#                                                                                           ${interface_name}_1,...)
# \param     clock_intf,                       clock/reset interfaces associated with the vvp streaming interface
# \param     bits_per_sample,                  number of bits per color sample
# \param     number_of_color_planes,           number of color planes per pixel
# \param     pixels_in_parallel,               number of pixels transmitted per data beat
# Add multiple vvp data (no control packet) axi streaming inputs or outputs to the component, written as an array
#                                                                                               in the SystemVerilog
proc add_axi_st_vvp_data_port_array { interface_name  direction  v_array_size  clock_intf  \
                                                  bits_per_sample number_of_color_planes pixels_in_parallel } {

    set v_pixel_width           [expr (${bits_per_sample} * ${number_of_color_planes} )]
    set v_symbol_width_in_bytes [vvp_max  [vvp_ceil ${v_pixel_width} 8]       2]
    set v_data_width            [expr ${v_symbol_width_in_bytes} * ${pixels_in_parallel} * 8]
    set v_data_width_in_bytes   [expr {${v_symbol_width_in_bytes} * ${pixels_in_parallel}}]

    for { set v_i 0 } { ${v_i} < ${v_array_size} } { incr v_i } {

        add_axi_st_vvp_data_port      ${interface_name}_${v_i}  ${direction}   ${clock_intf} ${bits_per_sample} \
                                                                  ${number_of_color_planes} ${pixels_in_parallel}

        set_port_property ${interface_name}_${v_i}_tdata       FRAGMENT_LIST \
          "${interface_name}_tdata@[expr (${v_i} +1) * ${v_data_width} - 1]:[expr ${v_i} * ${v_data_width}]"
        set_port_property ${interface_name}_${v_i}_tvalid      FRAGMENT_LIST "${interface_name}_tvalid@${v_i}"
        set_port_property ${interface_name}_${v_i}_tready      FRAGMENT_LIST "${interface_name}_tready@${v_i}"
        set_port_property ${interface_name}_${v_i}_tlast       FRAGMENT_LIST "${interface_name}_tlast@${v_i}"
        set_port_property ${interface_name}_${v_i}_tuser       FRAGMENT_LIST \
          "${interface_name}_tuser@[expr (${v_i} +1) * ${v_data_width_in_bytes} - 1]:[expr ${v_i} * ${v_data_width_in_bytes}]"
    }
}

# add_axi_st_vvp_data_input_port_array
# \see add_axi_st_vvp_data_port_array
proc add_axi_st_vvp_data_input_port_array { input_name v_array_size clock_intf bits_per_sample \
                                                                      number_of_color_planes pixels_in_parallel } {
    add_axi_st_vvp_data_port_array   ${input_name}   slave   ${v_array_size}  ${clock_intf}  ${bits_per_sample} \
                                                                  ${number_of_color_planes}  ${pixels_in_parallel}
}

# add_axi_st_vvp_data_output_port_array
# \see add_axi_st_vvp_data_port_array
proc add_axi_st_vvp_data_output_port_array { output_name v_array_size clock_intf bits_per_sample \
                                                                    number_of_color_planes pixels_in_parallel } {
    add_axi_st_vvp_data_port_array   ${output_name}  master  ${v_array_size}  ${clock_intf}  ${bits_per_sample} \
                                                                  ${number_of_color_planes}  ${pixels_in_parallel}
}


# --------------------------------------------------------------------------------------------------
# -- Video & Vision processing control interfaces
# --------------------------------------------------------------------------------------------------

# add_axi_st_vvp_ctrl_port
# \param     interface_name,                   name of the vvp ctrl streaming interface (vvp_ctrl_in/vvp_ctrl_out
#                                                                                                     recommended)
# \param     direction                         master or slave
# \param     clock_intf,                       clock/reset interfaces associated with the vvp streaming interface
# Add a vvp control axi streaming interface to the component
proc add_axi_st_vvp_ctrl_port { interface_name  direction  clock_intf } {

    set v_ctrl_width_in_bytes 2

    # axi-st input with tready, tlast and 1 tuser bit per byte (no tkeep, tstrb tid or tdest)
    add_axi_st_port ${interface_name}  ${direction}  ${clock_intf}  ${v_ctrl_width_in_bytes}  1 1 0 0 0 0 1

    ::intel_vvp_st_format::set_intf_type          ${interface_name}     vvp_ctrl
    ::intel_vvp_st_format::intf_validate          ${interface_name}
}

# add_axi_st_vvp_ctrl_input_port
# \see add_axi_st_vvp_ctrl_port
proc add_axi_st_vvp_ctrl_input_port { input_name clock_intf } {
    add_axi_st_vvp_ctrl_port   ${input_name}  slave  ${clock_intf}
}

# add_axi_st_vvp_ctrl_output_port
# \see add_axi_st_vvp_ctrl_port
proc add_axi_st_vvp_ctrl_output_port { output_name clock_intf } {
    add_axi_st_vvp_ctrl_port   ${output_name}  master  ${clock_intf}
}

# add_axi_st_vvp_ctrl_port_array
# \param     interface_name,                   name of the vvp ctrl streaming interface (vvp_ctrl_in/vvp_ctrl_out
#                                                                                         recommended)
# \param     direction                         master(s) or slave(s)
# \param     v_array_size,                     number of interfaces to declare (${interface_name}_0,
#                                                                                         ${interface_name}_1,...)
# \param     clock_intf,                       clock/reset interfaces associated with the vvp streaming interface
# Add multiple vvp ctrl axi streaming inputs or outputs to the component, written as an array in the SystemVerilog
proc add_axi_st_vvp_ctrl_port_array { interface_name  direction  v_array_size  clock_intf  } {

    set v_ctrl_width            16
    set v_user_width            [expr (${v_ctrl_width} + 7)/8]

    for { set v_i 0 } { ${v_i} < ${v_array_size} } { incr v_i } {

        add_axi_st_vvp_ctrl_port      ${interface_name}_${v_i}  ${direction}   ${clock_intf}

        set_port_property ${interface_name}_${v_i}_tdata       FRAGMENT_LIST \
          "${interface_name}_tdata@[expr (${v_i} +1) * ${v_ctrl_width} - 1]:[expr ${v_i} * ${v_ctrl_width}]"
        set_port_property ${interface_name}_${v_i}_tvalid      FRAGMENT_LIST "${interface_name}_tvalid@${v_i}"
        set_port_property ${interface_name}_${v_i}_tready      FRAGMENT_LIST "${interface_name}_tready@${v_i}"
        set_port_property ${interface_name}_${v_i}_tlast       FRAGMENT_LIST "${interface_name}_tlast@${v_i}"
        set_port_property ${interface_name}_${v_i}_tuser       FRAGMENT_LIST \
          "${interface_name}_tuser@[expr (${v_i} +1) * ${v_user_width} - 1]:[expr ${v_i} * ${v_user_width}]"
    }
}

# add_axi_st_vvp_ctrl_input_port_array
# \see add_axi_st_vvp_ctrl_port_array
proc add_axi_st_vvp_ctrl_input_port_array  { input_name   v_array_size  clock_intf  } {
    add_axi_st_vvp_ctrl_port_array   ${input_name}   slave   ${v_array_size}  ${clock_intf}
}

# add_axi_st_vvp_ctrl_output_port_array
# \see add_axi_st_vvp_ctrl_port_array
proc add_axi_st_vvp_ctrl_output_port_array { output_name  v_array_size  clock_intf  } {
    add_axi_st_vvp_ctrl_port_array   ${output_name}  master  ${v_array_size}  ${clock_intf}
}



# --------------------------------------------------------------------------------------------------
# -- Video & Vision processing token interfaces
# --------------------------------------------------------------------------------------------------

# add_axi_st_vvp_token_port
# \param     interface_name,                   name of the vvp token streaming interface (vvp_token_in/vvp_token_out
#                                                                                                       recommended)
# \param     direction                         master or slave
# \param     clock_intf,                       clock/reset interfaces associated with the vvp streaming interface
# \param     token_width,                      width of the token in bits (will be rounded up to the next byte
# Add a vvp control axi streaming interface to the component
proc add_axi_st_vvp_token_port { interface_name  direction  clock_intf  token_width } {

    set v_token_width_in_bytes   [vvp_ceil ${token_width} 8]

    # axi-st input with tready (no tkeep, tstrb tid or tdest; no tlast or tuser)
    add_axi_st_port ${interface_name}  ${direction}  ${clock_intf}  ${v_token_width_in_bytes}  1 0 0 0 0 0 0

    ::intel_vvp_st_format::set_intf_type          ${interface_name}     vvp_token
    ::intel_vvp_st_format::intf_validate          ${interface_name}
}


# add_axi_st_vvp_token_input_port
# \see add_axi_st_vvp_token_port
proc add_axi_st_vvp_token_input_port { input_name    clock_intf  token_width } {
    add_axi_st_vvp_token_port   ${input_name}   slave   ${clock_intf}  ${token_width}
}

# add_axi_st_vvp_token_output_port
# \see add_axi_st_vvp_token_port
proc add_axi_st_vvp_token_output_port { output_name  clock_intf  token_width } {
    add_axi_st_vvp_token_port   ${output_name}  master  ${clock_intf}  ${token_width}
}

# add_axi_st_vvp_token_port_array
# \param     interface_name,                   name of the vvp ctrl streaming interface (vvp_ctrl_in/vvp_ctrl_out
#                                                                                       recommended)
# \param     direction                         master(s) or slave(s)
# \param     v_array_size,                     number of interfaces to declare (${interface_name}_0,
#                                                                                       ${interface_name}_1,...)
# \param     clock_intf,                       clock/reset interfaces associated with the vvp streaming interface
# \param     token_width,                      width of the token in bits (will be rounded up to the next byte
proc add_axi_st_vvp_token_port_array { interface_name  direction  v_array_size  clock_intf token_width } {

    set v_token_width_in_bytes   [vvp_ceil ${token_width} 8]
    set v_full_token_width       [expr ${v_token_width_in_bytes} * 8]

    for { set v_i 0 } { ${v_i} < ${v_array_size} } { incr v_i } {

        add_axi_st_vvp_token_port       ${interface_name}_${v_i}  ${direction}   ${clock_intf} ${token_width}

        set_port_property ${interface_name}_${v_i}_tdata       FRAGMENT_LIST \
          "${interface_name}_tdata@[expr (${v_i} +1) * ${v_full_token_width} - 1]:[expr ${v_i} * ${v_full_token_width}]"
        set_port_property ${interface_name}_${v_i}_tvalid      FRAGMENT_LIST "${interface_name}_tvalid@${v_i}"
        set_port_property ${interface_name}_${v_i}_tready      FRAGMENT_LIST "${interface_name}_tready@${v_i}"
    }
}

# add_axi_st_vvp_token_input_port_array
# \see add_axi_st_vvp_token_port_array
proc add_axi_st_vvp_token_input_port_array  { input_name   v_array_size  clock_intf token_width } {
    add_axi_st_vvp_token_port_array   ${input_name}   slave   ${v_array_size}  ${clock_intf} ${token_width}
}

# add_axi_st_vvp_token_output_port_array
# \see add_axi_st_vvp_token_port_array
proc add_axi_st_vvp_token_output_port_array { output_name  v_array_size  clock_intf token_width } {
    add_axi_st_vvp_token_port_array   ${output_name}  master  ${v_array_size}  ${clock_intf} ${token_width}
}



# get the read latency of the common slave interface module
proc get_common_slave_read_latency {num_read_only_reg    num_writeable_reg    enable_debug} {

   set v_img_info_params   8

   if { ${enable_debug} > 0 } {
      set v_num_readable_reg    [expr ${num_read_only_reg} + ${num_writeable_reg} + ${v_img_info_params} + 1]
   } else {
      set v_num_readable_reg    [expr ${num_read_only_reg} + 1]
   }

   if { ${v_num_readable_reg} == 1 } {
      return 1
   } else {
      set   v_read_addr_width   [vvp_clog2 ${v_num_readable_reg}]
      set   v_mux_latency       [expr (${v_read_addr_width} + 1)/2]
      set   v_read_latency      [expr ${v_mux_latency} + 2]
      return ${v_read_latency}
   }

}

# add_slave_port
# Add a slave port to the component
# \param     control_name,           name of the Avalon-MM slave interface (typically, "control")
# \param     v_addr_width            width of the address signal (slaves use word addressing; usually tied to the
#                                    maximum depth of the slave interface so as to reserve a fixed space in the
#                                    address map independently from what the current parameterization requires)
# \param     max_pending_reads,      The maximum number of reads pending, often the same thing as the v_read_latency
#                                    if wait_request is tied low
# \param     has_interrupt,          use 1 to create an additional ${control_name}_interrupt interface linked with
#                                    this slave interface; the interrupt signal is named ${control_name}_irq
# \param     minimumResponseLatency, optional, the minimum guaranteed read latency before _readdatavalid is asserted,
#                                    perhaps platform designer can optimize better if you can set this higher than 1?
# It was agreed that:
# 1) All our slaves will use dynamic address alignment to ensure master/slave interfaces can have different sizes
#                                    (native alignment is deprecated)
# 2) For the same reasons, all slaves must implement byteenable
# 3) All our slaves will use readdatavalid (even for slaves with a constant read latency). Note: platform designer
#                                    implies readdatavalid is compulsory for pipelined reads
# 4) All our slaves will implement the waitrequest signal (possibly tying it to zero) since this is a side effect of
#                                    guaranteeing a maximumPendingReadTransactions
#    rather than a readLatency. A slave MUST use waitrequest to guarantee that maximumPendingReadTransactions will
#                                    not go over range or the interconnect may lose track of read transactions
# 5) We don't do write responses, we don't do burst (for run-time control slave)
#
# * Note that we disregard one of Platform Designer recommendations: "To avoid system lockup a slave device should
#   assert waitrequest when in reset"
# * There must be at least one cycle between acceptance of the read and assertion of readdatavalid so
#   max_pending_reads >= 1
# * The slave may assert readdatavalid and return a read reply independently of whether waitrequest is asserted
# * The address unit for slaves is words by default (not bytes)
#
# \see   See add_runtime_control for
proc add_slave_port {control_name clock_intf v_addr_width {max_pending_reads 1}  {has_interrupt 0} \
                                                                        {minimumResponseLatency 1}} {

    add_interface ${control_name} avalon slave ${clock_intf}_clock

    add_interface_port ${control_name}  ${control_name}_address       address        Input     ${v_addr_width}
    add_interface_port ${control_name}  ${control_name}_write         write          Input     1
    add_interface_port ${control_name}  ${control_name}_byteenable    byteenable     Input \
                                                $::intel_vvp_mm_format::slave_bus_byte_width
    add_interface_port ${control_name}  ${control_name}_writedata     writedata      Input \
                                                $::intel_vvp_mm_format::slave_width
    add_interface_port ${control_name}  ${control_name}_read          read           Input     1
    add_interface_port ${control_name}  ${control_name}_readdata      readdata       Output \
                                                $::intel_vvp_mm_format::slave_width
    add_interface_port ${control_name}  ${control_name}_readdatavalid readdatavalid  Output    1
    add_interface_port ${control_name}  ${control_name}_waitrequest   waitrequest    Output    1

    if {${has_interrupt}} {
        add_interface ${control_name}_interrupt interrupt sender ${clock}
        set_interface_property ${control_name}_interrupt associatedAddressablePoint ${control_name}
        add_interface_port ${control_name}_interrupt ${control_name}_irq irq Output 1
    }

    set_interface_property ${control_name} addressAlignment DYNAMIC

    # Extra number of cycles, or nanoseconds for async devices, where address and data holds their value before
    # and after a write, we don't use this
    set_interface_property ${control_name}   setupTime 0
    set_interface_property ${control_name}   holdTime 0
    set_interface_property ${control_name}   timingUnits Cycles

    # Unused when waitrequest is enabled
    set_interface_property ${control_name}   readWaitTime 0
    set_interface_property ${control_name}   writeWaitTime 0

    # Unused when not bursting
    set_interface_property ${control_name}   alwaysBurstMaxBurst words
    set_interface_property ${control_name}   burstcountUnits words
    set_interface_property ${control_name}   burstOnBurstBoundariesOnly false
    set_interface_property ${control_name}   linewrapBursts false

    set_interface_property ${control_name}   isMemoryDevice false
    set_interface_property ${control_name}   isNonVolatileStorage false
    set_interface_property ${control_name}   minimumUninterruptedRunLength 1
    set_interface_property ${control_name}   printableDevice false

    set_interface_property ${control_name}   readLatency                    0
    set_interface_property ${control_name}   maximumPendingReadTransactions ${max_pending_reads}

}

# add_scheduler_runtime_control
# Add a run-time control slave port to the scheduler
# \param     control_name,           name of the Avalon-MM slave interface (typically, "control")
# \param     clock_intf              clock
# \param     max_num_ro_regs         maximum number of read-only registers (core-specific registers, this exludes
#                                    the read-only parameterization,
#                                    the interrupt regs and the image_info regs)
# \param     max_num_rw_regs         maximum number of write-only or read-write registers (excluding image_info and
#                                    interrupt registers)
# \param     max_pending_reads,      The maximum number of reads pending, often the same thing as the v_read_latency
#                                    if wait_request is tied low
# \param     has_interrupt,          use 1 to create an additional ${control_name}_interrupt interface linked with
#                                    this slave interface;
#                                    the interrupt signal is named ${control_name}_irq TODO!!!!!
# \param     minimumResponseLatency, optional, the minimum guaranteed read latency before _readdatavalid is asserted,
#                                    perhaps platform designer can optimize better
#                                    if you can set this higher than 1 (?)
# \see   add_scheduler_runtime_control
# The slave use dynamic address alignment and must implement byteenable, readdatavalid and waitrequest (and guarantee
# max_pending_reads will not overflow)
# \return    the minimus width of the address port to address these registers. As befit a slave port, note that this
# is the appropriate width for word addressing
proc add_scheduler_runtime_control {control_name clock_intf max_num_ro_regs max_num_rw_regs {max_pending_reads 1} \
                                                                    {has_interrupt 0} {minimumResponseLatency 1}} {

    # word0 -> word7:             interrupt_params R, W and RW (?)
    set v_interrupts_num_regs       $::intel_vvp_mm_format::v_interrupts_num_regs
    # word8 -> word15:            v_img_info_params, writable when the IP is configured in external mode, readable
    # if debug is enabled
    set v_image_info_num_regs       $::intel_vvp_mm_format::v_image_info_num_regs

    set v_total_num_regs    [expr ${v_interrupts_num_regs} + ${v_image_info_num_regs} + ${max_num_ro_regs} + \
                                                                                        ${max_num_rw_regs}]

    set v_addr_width                [vvp_clog2 ${v_total_num_regs}]
    add_slave_port ${control_name}   ${clock_intf}  ${v_addr_width}  ${max_pending_reads}  \
                                                                          ${has_interrupt}  ${minimumResponseLatency}
    return ${v_addr_width}
}


# add_master_port
# add an Avalon MM write/read/write-read port to the component (with optional bursting support)
# \param     master_name          name of the Avalon-MM master interface
# \param     clock,               clock associated with the Avalon-MM interface
# \param     mem_port_width       width of the data port
# \param     mem_addr_width       address port width
# \param     byteenable_width     width of the byteenable port (optional)
# \param     burst_align          0 or 1, if 1 starting read/write address are assumed to be on burst boundaries only
# \param     max_burst_size       Maximum burst size, in words
# \param     enable_write         0 or 1, if 1 enable the write function for the MM Master port
# \param     enable_read          0 or 1, if 1 enable the read function for the MM Master port
# \param     max_pending_reads    compulsory parameter for a read master, max number of outstanding read transactions
proc add_master_port {master_name clock_intf  mem_port_width mem_addr_width byteenable_width max_burst_size \
                                                burst_align enable_write enable_read  {max_pending_reads 0}} {

    add_interface ${master_name} avalon master ${clock_intf}_clock

    if {${enable_read} == 1} {
        if {${max_pending_reads} == 0} {
            error "add_master_port: max_pending_reads must be configured for read masters"
        }
        set_interface_property ${master_name} maximumPendingReadTransactions     ${max_pending_reads}
    }

    add_interface_port ${master_name} ${master_name}_address address Output $mem_addr_width
    add_interface_port ${master_name} ${master_name}_waitrequest waitrequest Input 1

    if {${max_burst_size} > 1} {
        add_interface_port ${master_name} ${master_name}_burstcount burstcount Output [vvp_num_bits ${max_burst_size}]
        set_interface_property ${master_name} burstOnBurstBoundariesOnly         $burst_align
     }

    if {${enable_write} > 0} {
        add_interface_port ${master_name} ${master_name}_write write Output 1
        add_interface_port ${master_name} ${master_name}_writedata writedata Output $mem_port_width
        if {${byteenable_width}} {
            add_interface_port ${master_name} ${master_name}_byteenable byteenable output ${byteenable_width}
        }
    }

    if {${enable_read} > 0} {
        add_interface_port ${master_name} ${master_name}_read read Output 1
        add_interface_port ${master_name} ${master_name}_readdata readdata Input $mem_port_width
        add_interface_port ${master_name} ${master_name}_readdatavalid readdatavalid Input 1
    }
}

proc add_axi4_mm_master_port {master_name axi_thread_id_width axi_data_width enable_user enable_region \
                                  write_issuing_cap read_issuing_cap {clock main_clock} {v_addr_width 32}} {

    add_interface ${master_name} axi4 master ${clock}

    # do we need burstOnBurstBoundariesOnly setting?

    # AW channel (write address/burst)
    add_interface_port ${master_name} ${master_name}_awid     awid      Output ${axi_thread_id_width}
    add_interface_port ${master_name} ${master_name}_awaddr   awaddr    Output ${v_addr_width}
    add_interface_port ${master_name} ${master_name}_awlen    awlen     Output 8
    add_interface_port ${master_name} ${master_name}_awsize   awsize    Output 3
    add_interface_port ${master_name} ${master_name}_awburst  awburst   Output 2
    add_interface_port ${master_name} ${master_name}_awlock   awlock    Output 1
    add_interface_port ${master_name} ${master_name}_awcache  awcache   Output 4
    add_interface_port ${master_name} ${master_name}_awprot   awprot    Output 3
    add_interface_port ${master_name} ${master_name}_awqos    awqos     Output 4
    add_interface_port ${master_name} ${master_name}_awvalid  awvalid   Output 1
    add_interface_port ${master_name} ${master_name}_awready  awready   Input  1

    # W channel (write data)
    add_interface_port ${master_name} ${master_name}_wdata    wdata     Output ${axi_data_width}
    add_interface_port ${master_name} ${master_name}_wstrb    wstrb     Output [expr ${axi_data_width}/8]
    add_interface_port ${master_name} ${master_name}_wlast    wlast     Output 1
    add_interface_port ${master_name} ${master_name}_wvalid   wvalid    Output 1
    add_interface_port ${master_name} ${master_name}_wready   wready    Input  1

    # B channel (write response)
    add_interface_port ${master_name} ${master_name}_bid      bid       Input  ${axi_thread_id_width}
    add_interface_port ${master_name} ${master_name}_bresp    bresp     Input  2
    add_interface_port ${master_name} ${master_name}_bvalid   bvalid    Input  1
    add_interface_port ${master_name} ${master_name}_bready   bready    Output 1

    # AR channel (read address/burst)
    add_interface_port ${master_name} ${master_name}_arid    arid     Output ${axi_thread_id_width}
    add_interface_port ${master_name} ${master_name}_araddr  araddr   Output ${v_addr_width}
    add_interface_port ${master_name} ${master_name}_arlen   arlen    Output 8
    add_interface_port ${master_name} ${master_name}_arsize  arsize   Output 3
    add_interface_port ${master_name} ${master_name}_arburst arburst  Output 2
    add_interface_port ${master_name} ${master_name}_arlock  arlock   Output 1
    add_interface_port ${master_name} ${master_name}_arcache arcache  Output 4
    add_interface_port ${master_name} ${master_name}_arprot  arprot   Output 3
    add_interface_port ${master_name} ${master_name}_arqos   arqos    Output 4
    add_interface_port ${master_name} ${master_name}_arvalid arvalid  Output 1
    add_interface_port ${master_name} ${master_name}_arready arready  Input  1

    # R channel (read data return)
    add_interface_port ${master_name} ${master_name}_rdata   rdata    Input  ${axi_data_width}
    add_interface_port ${master_name} ${master_name}_rresp   rresp    Input  2
    add_interface_port ${master_name} ${master_name}_rlast   rlast    Input  1
    add_interface_port ${master_name} ${master_name}_rvalid  rvalid   Input  1
    add_interface_port ${master_name} ${master_name}_rready  rready   Output 1
    add_interface_port ${master_name} ${master_name}_rid     rid      Input ${axi_thread_id_width}


    # The following is a signal for compatibility with AXI3. We shouldn't need it.
    # It get's tied low locally and Platform Designer doesn't support it.
    add_interface      hide_wid_${master_name} conduit                 start
    add_interface_port hide_wid_${master_name} ${master_name}_wid      write       Output ${axi_thread_id_width}
    set_port_property  ${master_name}_wid      TERMINATION   true

    # Optional ports that may not be present
    if {${enable_user} > 0 } {
        add_interface_port ${master_name} ${master_name}_aruser aruser      Output 1
        add_interface_port ${master_name} ${master_name}_awuser awuser      Output 1
        add_interface_port ${master_name} ${master_name}_buser  buser       Input  1
        add_interface_port ${master_name} ${master_name}_ruser  ruser       Input  1
        add_interface_port ${master_name} ${master_name}_wuser  wuser       Output 1
    }

    if {${enable_region} > 0 } {
        add_interface_port ${master_name} ${master_name}_arregion arregion    Output  4
        add_interface_port ${master_name} ${master_name}_awregion awregion    Output  4
    }

    set_interface_property ${master_name} writeIssuingCapability     ${write_issuing_cap}
    set_interface_property ${master_name} readIssuingCapability      ${read_issuing_cap}
}

# add_wr_only_slave_port
# Add a write only slave port to the component
# \param     control_name,           name of the Avalon-MM slave interface (typically, "control")
# \param     v_addr_width            width of the address signal (slaves use word addressing; usually tied to the
#                                    maximum depth of the slave interface so as to reserve a fixed space in the
#                                    address map independently from what the current parameterization requires)
# \param     max_pending_reads,      The maximum number of reads pending, often the same thing as the v_read_latency
#                                    if wait_request is tied low
# \param     has_interrupt,          use 1 to create an additional ${control_name}_interrupt interface linked with
#                                    this slave interface; the interrupt signal is named ${control_name}_irq
# \param     minimumResponseLatency, optional, the minimum guaranteed read latency before _readdatavalid is asserted,
#                                    perhaps Platform Designer can optimize better if you can set this higher than 1(?)
# It was agreed that:
# 1) All our slaves will use dynamic address alignment to ensure master/slave interfaces can have different sizes
#   (native alignment is deprecated)
# 2) For the same reasons, all slaves must implement byteenable
# 3) All our slaves will use readdatavalid (even for slaves with a constant read latency). Note: platform designer
#   implies readdatavalid is compulsory for pipelined reads
# 4) All our slaves will implement the waitrequest signal (possibly tying it to zero) since this is a side effect
#    of guaranteeing a maximumPendingReadTransactions rather than a readLatency. A slave MUST use waitrequest to
#    guarantee that maximumPendingReadTransactions will not go over range or the interconnect may lose track of read
#    transactions
# 5) We don't do write responses, we don't do burst (for run-time control slave)
#
# * Note that we disregard one of Platform Designer recommendations: "To avoid system lockup a slave device should
#   assert waitrequest when in reset"
# * There must be at least one cycle between acceptance of the read and assertion of readdatavalid so
#   max_pending_reads >= 1
# * The slave may assert readdatavalid and return a read reply independently of whether waitrequest is asserted
# * The address unit for slaves is words by default (not bytes)
#
# \see   See add_runtime_control for
proc add_wr_only_slave_port {control_name clock_intf v_addr_width {has_interrupt 0}  {minimumResponseLatency 1}} {

    add_interface ${control_name} avalon slave ${clock_intf}_clock

    add_interface_port ${control_name}  ${control_name}_address       address        Input     ${v_addr_width}
    add_interface_port ${control_name}  ${control_name}_write         write          Input     1
    add_interface_port ${control_name}  ${control_name}_byteenable    byteenable     Input \
                                                      $::intel_vvp_mm_format::slave_bus_byte_width
    add_interface_port ${control_name}  ${control_name}_writedata     writedata      Input \
                                                      $::intel_vvp_mm_format::slave_width
    add_interface_port ${control_name}  ${control_name}_waitrequest   waitrequest    Output    1

    if {${has_interrupt}} {
        add_interface ${control_name}_interrupt interrupt sender ${clock}
        set_interface_property ${control_name}_interrupt associatedAddressablePoint ${control_name}
        add_interface_port ${control_name}_interrupt ${control_name}_irq irq Output 1
    }

    set_interface_property ${control_name} addressAlignment DYNAMIC

    # Extra number of cycles, or nanoseconds for async devices, where address and data holds their value before and
    # after a write, we don't use this
    set_interface_property ${control_name}   setupTime 0
    set_interface_property ${control_name}   holdTime 0
    set_interface_property ${control_name}   timingUnits Cycles

    # Unused when waitrequest is enabled
    set_interface_property ${control_name}   writeWaitTime 0

    # Unused when not bursting
    set_interface_property ${control_name}   alwaysBurstMaxBurst words
    set_interface_property ${control_name}   burstcountUnits words
    set_interface_property ${control_name}   burstOnBurstBoundariesOnly false
    set_interface_property ${control_name}   linewrapBursts false

    set_interface_property ${control_name}   isMemoryDevice false
    set_interface_property ${control_name}   isNonVolatileStorage false
    set_interface_property ${control_name}   minimumUninterruptedRunLength 1
    set_interface_property ${control_name}   printableDevice false

}
