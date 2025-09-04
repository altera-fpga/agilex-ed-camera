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
# -- Generic clock with synchronous reset
# --------------------------------------------------------------------------------------------------
# add_clock_reset_intf {string}
# Add clock and reset interfaces to the component
# \param     intf_name, basename for the two interfaces
#            sig_pref, optional prefix for the wire names (${sig_pref}_clk and ${sig_pref}_rst)
#                      the wires are assumed to be clk and rst if sig_pref is not provided
# output: Create two top-level interfaces: ${intf_name}_clock and ${intf_name}_reset with
#         associated wires ${sig_pref}_clk and ${sig_pref}_rst
proc add_clock_reset_intf { intf_name {sig_pref ""} } {
    add_interface          ${intf_name}_clock   clock                    end
    add_interface          ${intf_name}_reset   reset                    end
    set_interface_property ${intf_name}_reset   associatedClock          ${intf_name}_clock
    set_interface_property ${intf_name}_reset   synchronousEdges         BOTH

    if { ${sig_pref} == "" } {
        add_interface_port     ${intf_name}_clock   clk                      clk      Input    1
        add_interface_port     ${intf_name}_reset   rst                      reset    Input    1
    } else {
        add_interface_port     ${intf_name}_clock   ${sig_pref}_clk          clk      Input    1
        add_interface_port     ${intf_name}_reset   ${sig_pref}_rst          reset    Input    1
    }
}


# --------------------------------------------------------------------------------------------------
# -- Generic AXI Streaming
# --------------------------------------------------------------------------------------------------

# add_axi_st_port
# Add an axi4 streaming port (master or slave) to the component
# \param     interface_name,      name of the axi streaming interface
# \param     direction            master or slave
# \param     clock_intf,          clock/reset interfaces associated with the axi4 streaming interface
# \param     num_data_bytes,      number of bytes in the data bus
# \param     use_tready           whether the tready signal exists to allow a sink to apply backpressure
# \param     use_tlast            whether the tlast signal exists to delimit packet boundaries
# \param     use_tkeep            whether the tkeep signal exists to indicate null bytes
#                                                                   (can be used to indicate empty)
# \param     use_tstrb            whether the tstrb signal exists to indicate position bytes
#                                                                   (can be used as byte enable)
# \param     tid_bits,            number of bits for tid (1 to 8, 0 to disable the port)
# \param     tdest_bits,          number of bits for tdest (1 to 4, 0 to disable the port)
# \param     tuser_bits_per_byte, number of tuser bits *per byte of data* (1 to 8, 0 to disable the port)

proc add_axi_st_port { interface_name direction clock_intf num_data_bytes use_tready use_tlast \
                                      use_tkeep use_tstrb tid_bits tdest_bits tuser_bits_per_byte } {

    add_interface            ${interface_name}     axi4stream            ${direction}
    set_interface_property   ${interface_name}     associated_clock      ${clock_intf}_clock

    set v_data_dir             [expr {(${direction} == "master") ? "output" :  "input"}]
    set v_ready_dir            [expr {(${direction} == "master") ?  "input" : "output"}]

    add_interface_port           ${interface_name}     ${interface_name}_tdata   tdata \
                                              ${v_data_dir}     [expr {${num_data_bytes} * 8}]
    add_interface_port           ${interface_name}     ${interface_name}_tvalid  tvalid \
                                              ${v_data_dir}     1
    if {${use_tready}} {
        add_interface_port       ${interface_name}     ${interface_name}_tready   tready \
                                              ${v_ready_dir}    1
    }
    if {${use_tlast}} {
        add_interface_port       ${interface_name}     ${interface_name}_tlast    tlast \
                                              ${v_data_dir}     1
    }
    if {${use_tkeep}} {
        add_interface_port       ${interface_name}     ${interface_name}_tkeep    tkeep \
                                              ${v_data_dir}     ${num_data_bytes}
    }
    if {${use_tstrb}} {
        add_interface_port       ${interface_name}     ${interface_name}_tstrb    tstrb \
                                              ${v_data_dir}     ${num_data_bytes}
    }
    if {${tid_bits}} {
        add_interface_port       ${interface_name}     ${interface_name}_tid      tid \
                                              ${v_data_dir}     ${tid_bits}
    }
    if {${tdest_bits}} {
        add_interface_port       ${interface_name}     ${interface_name}_tdest    tdest \
                                              ${v_data_dir}     ${tdest_bits}
    }
    if {${tuser_bits_per_byte}} {
        add_interface_port       ${interface_name}     ${interface_name}_tuser    tuser \
                                              ${v_data_dir}     [expr {${num_data_bytes} * ${tuser_bits_per_byte}}]
    }
}


# add_axi_st_input_port/add_axi_st_slave_port
# Add an axi4 streaming input port (slave) to the component
# \see add_axi_st_port
proc add_axi_st_input_port { input_name clock_intf num_data_bytes use_tready \
                          use_tlast use_tkeep use_tstrb tid_bits tdest_bits tuser_bits_per_byte } {
    add_axi_st_slave_port  ${input_name}   ${clock_intf}  ${num_data_bytes} \
          ${use_tready} ${use_tlast}  ${use_tkeep}  ${use_tstrb}  ${tid_bits}  ${tdest_bits}  ${tuser_bits_per_byte}
}
proc add_axi_st_slave_port { slave_name clock_intf num_data_bytes use_tready use_tlast use_tkeep \
                          use_tstrb tid_bits tdest_bits tuser_bits_per_byte } {
    add_axi_st_port  ${slave_name}  slave  ${clock_intf}  ${num_data_bytes}  \
          ${use_tready}  ${use_tlast}  ${use_tkeep}  ${use_tstrb}  ${tid_bits}  ${tdest_bits}  ${tuser_bits_per_byte}
}



# add_axi_st_output_port/add_axi_st_master_port
# Add an axi4 streaming output port (master) to the component
# \see add_axi_st_port
proc add_axi_st_output_port { output_name clock_intf num_data_bytes use_tready \
                          use_tlast use_tkeep use_tstrb tid_bits tdest_bits tuser_bits_per_byte } {
    add_axi_st_master_port ${output_name}  ${clock_intf}  ${num_data_bytes}  \
          ${use_tready}  ${use_tlast}  ${use_tkeep}  ${use_tstrb}  ${tid_bits}  ${tdest_bits}  ${tuser_bits_per_byte}
}
proc add_axi_st_master_port { master_name clock_intf num_data_bytes use_tready \
                          use_tlast use_tkeep use_tstrb tid_bits tdest_bits tuser_bits_per_byte } {
    add_axi_st_port  ${master_name}  master  ${clock_intf}  ${num_data_bytes} \
          ${use_tready}  ${use_tlast}  ${use_tkeep}  ${use_tstrb}  ${tid_bits}  ${tdest_bits}  ${tuser_bits_per_byte}
}
