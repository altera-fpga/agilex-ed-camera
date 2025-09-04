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

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Helper functions to add files to a component file list                                       --
# -- Helper functions to add shared SV packages and HDL files                                     --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------------
# -- Helper functions to add files to a component file list                                       --
# --------------------------------------------------------------------------------------------------
# -- add_static_sv_file                declare an encrypted SystemVerilog file for the component  --
# -- add_static_vhdl_file              declare an encrypted VHDL file for the component           --
# -- add_static_ver_file               declare an encrypted VERILOG file for the component        --
# -- add_static_unencrypted_sv_file    declare an encrypted SystemVerilog file for the component  --
# -- add_static_unencrypted_vhdl_file  declare an encrypted VHDL file for the component           --
# -- add_static_unencrypted_ver_file   declare an encrypted VERILOG file for the component        --
# -- add_static_sdc_file               declare an SDC file for the component                      --
# -- add_static_misc_file              declare an miscellaneous file for the component            --
# -- add_static_hex_file               declare a memory initialization HEX file for the component --
# -- setup_filesets                    create synthesis and simul filesets with declared files    --
# --------------------------------------------------------------------------------------------------

set sv_files_list {}
set vhdl_files_list {}
set ver_files_list {}
set unenc_sv_files_list {}
set unenc_vhdl_files_list {}
set unenc_ver_files_list {}
set sdc_files_list {}
set hex_files_list {}
set mif_files_list {}
set ocp_files_list {}
set misc_files_list {}

proc add_static_sv_file {filename {rel_path "."} {package_name ""} } {
    global sv_files_list
    lappend sv_files_list ${filename} ${rel_path} ${package_name}
}
proc add_static_vhdl_file {filename {rel_path "."}} {
    global vhdl_files_list
    lappend vhdl_files_list ${filename} ${rel_path}
}
proc add_static_ver_file {filename {rel_path "."}} {
    global ver_files_list
    lappend ver_files_list ${filename} ${rel_path}
}
proc add_static_unencrypted_sv_file {filename {rel_path "."} {package_name ""} } {
    global unenc_sv_files_list
    lappend unenc_sv_files_list ${filename} ${rel_path} ${package_name}
}
proc add_static_unencrypted_vhdl_file {filename {rel_path "."}} {
    global unenc_vhdl_files_list
    lappend unenc_vhdl_files_list ${filename} ${rel_path}
}
proc add_static_unencrypted_ver_file {filename {rel_path "."}} {
    global unenc_ver_files_list
    lappend unenc_ver_files_list ${filename} ${rel_path}
}
proc add_static_sdc_file {filename {rel_path "."}} {
    global sdc_files_list
    lappend sdc_files_list ${filename} ${rel_path}
}
proc add_static_hex_file {filename {rel_path "."}} {
    global hex_files_list
    if {[string first "/" ${filename}] != -1} {
        error [format "A file of type HEX should be added at the root of the \
                                                generated IP: %s is invalid." ${filename}]
    }
    lappend hex_files_list ${filename} ${rel_path}
}
proc add_static_mif_file {filename {rel_path "."}} {
    global mif_files_list
    if {[string first "/" ${filename}] != -1} {
        error [format "A file of type MIF should be added at the root of the \
                                                generated IP: %s is invalid." ${filename}]
    }
    lappend mif_files_list ${filename} ${rel_path}
}
proc add_static_ocp_file {filename {rel_path "."}} {
    global ocp_files_list
    lappend ocp_files_list ${filename} ${rel_path}
}
proc add_static_misc_file {filename {rel_path "."}} {
    global misc_files_list
    lappend misc_files_list ${filename} ${rel_path}
}

# When IP is used locally, the non-encrypted source version is used for simulation
# the correct filetype is used in both cases
proc add_sim_encrypted_file {filename rel_path filetype enc_filetype {package_name ""}} {
    if {"__ACDS_HAS_MENTOR_ENCRYPTION__" == 1} {
        add_fileset_file mentor/${filename} ${enc_filetype} PATH \
                                        "${rel_path}/mentor/${filename}" {MENTOR_SPECIFIC}
    } else {
        add_fileset_file mentor/${filename} ${filetype} PATH \
                                        "${rel_path}/mentor/${filename}" {MENTOR_SPECIFIC}
    }
    if {"__ACDS_HAS_ALDEC_ENCRYPTION__" == 1} {
        add_fileset_file aldec/${filename} ${enc_filetype} PATH \
                                        "${rel_path}/aldec/${filename}" {ALDEC_SPECIFIC}
    } else {
        add_fileset_file aldec/${filename} ${filetype} PATH \
                                        "${rel_path}/aldec/${filename}" {ALDEC_SPECIFIC}
    }
    if {"__ACDS_HAS_CADENCE_ENCRYPTION__" == 1} {
        add_fileset_file cadence/${filename} ${enc_filetype} PATH \
                                        "${rel_path}/cadence/${filename}" {CADENCE_SPECIFIC}
    } else {
        add_fileset_file cadence/${filename} ${filetype} PATH \
                                        "${rel_path}/cadence/${filename}" {CADENCE_SPECIFIC}
    }
    if {"__ACDS_HAS_SYNOPSYS_ENCRYPTION__" == 1} {
        add_fileset_file synopsys/${filename} ${enc_filetype} PATH \
                                        "${rel_path}/synopsys/${filename}" {SYNOPSYS_SPECIFIC}
    } else {
        add_fileset_file synopsys/${filename} ${filetype} PATH \
                                        "${rel_path}/synopsys/${filename}" {SYNOPSYS_SPECIFIC}
    }
    if {[string compare ${package_name} ""] != 0} {
        set_fileset_file_attribute  mentor/${filename} \
                                      COMMON_SYSTEMVERILOG_PACKAGE mentor_${package_name}
        set_fileset_file_attribute  aldec/${filename} \
                                      COMMON_SYSTEMVERILOG_PACKAGE aldec_${package_name}
        set_fileset_file_attribute  cadence/${filename} \
                                      COMMON_SYSTEMVERILOG_PACKAGE cadence_${package_name}
        set_fileset_file_attribute  synopsys/${filename} \
                                      COMMON_SYSTEMVERILOG_PACKAGE synopsys_${package_name}
    }
}

proc add_sim_unencrypted_file {filename rel_path filetype {package_name ""}} {
    add_fileset_file common/${filename} ${filetype} PATH "${rel_path}/${filename}"
    if {[string compare ${package_name} ""] != 0} {
        set_fileset_file_attribute  common/${filename} \
                                      COMMON_SYSTEMVERILOG_PACKAGE common_${package_name}
    }
}

proc setup_filesets {top_level {generate_cb_synth ""} {generate_cb_sim ""}} {
    global sv_files_list
    global vhdl_files_list
    global ver_files_list
    global unenc_sv_files_list
    global unenc_vhdl_files_list
    global unenc_ver_files_list
    global sdc_files_list
    global hex_files_list
    global mif_files_list
    global ocp_files_list
    global misc_files_list

    # Quartus synth
    add_fileset synth_fileset QUARTUS_SYNTH ${generate_cb_synth}
    if {[string compare ${top_level} ""] != 0} {
        set_fileset_property synth_fileset TOP_LEVEL ${top_level}
    }

    if { "__ACDS_INTERNAL_DEVELOPMENT__" == 0 } {
        # IP built with IEEE encryption flow (enabled or not)
        foreach {filename path package_name} ${sv_files_list} {
            add_fileset_file ${filename} SYSTEM_VERILOG_ENCRYPT PATH "${path}/${filename}"
            # No COMMON_SYSTEMVERILOG_PACKAGE attribute for QUARTUS_SYNTH
        }
        foreach {filename path} ${ver_files_list} {
            add_fileset_file ${filename} VERILOG_ENCRYPT PATH "${path}/${filename}"
        }
        foreach {filename path} ${vhdl_files_list} {
            add_fileset_file ${filename} VHDL_ENCRYPT PATH "${path}/${filename}"
        }
    } else {
        # unencrypted IP
        foreach {filename path package_name} ${sv_files_list} {
            add_fileset_file ${filename} SYSTEM_VERILOG PATH "${path}/${filename}"
            # No COMMON_SYSTEMVERILOG_PACKAGE attribute for QUARTUS_SYNTH
        }
        foreach {filename path} ${ver_files_list} {
            add_fileset_file ${filename} VERILOG PATH "${path}/${filename}"
        }
        foreach {filename path} ${vhdl_files_list} {
            add_fileset_file ${filename} VHDL PATH "${path}/${filename}"
        }
    }
    foreach {filename path package_name} ${unenc_sv_files_list} {
        add_fileset_file ${filename} SYSTEM_VERILOG PATH "${path}/${filename}"
        # No COMMON_SYSTEMVERILOG_PACKAGE attribute for QUARTUS_SYNTH
    }
    foreach {filename path} ${unenc_ver_files_list} {
        add_fileset_file ${filename} VERILOG PATH "${path}/${filename}"
    }
    foreach {filename path} ${unenc_vhdl_files_list} {
        add_fileset_file ${filename} VHDL PATH "${path}/${filename}"
    }
    foreach {filename path} ${sdc_files_list} {
        add_fileset_file ${filename} SDC_ENTITY PATH "${path}/${filename}"
    }
    foreach {filename path} ${hex_files_list} {
        add_fileset_file ${filename} HEX PATH "${path}/${filename}"
    }
    foreach {filename path} ${mif_files_list} {
        add_fileset_file ${filename} MIF PATH "${path}/${filename}"
    }
    foreach {filename path} ${ocp_files_list} {
        add_fileset_file ${filename} OTHER PATH "${path}/${filename}"
    }
    foreach {filename path} ${misc_files_list} {
        add_fileset_file ${filename} OTHER PATH "${path}/${filename}"
    }

    # Sim verilog
    # Use specific callback if defined, otherwise use the original one
    if {[string compare ${generate_cb_sim} ""] != 0} {
        add_fileset sim_verilog_fileset SIM_VERILOG ${generate_cb_sim}
    } else {
        add_fileset sim_verilog_fileset SIM_VERILOG ${generate_cb_synth}
    }
    if {[string compare ${top_level} ""] != 0} {
        set_fileset_property sim_verilog_fileset TOP_LEVEL ${top_level}
    }

    if { "__ACDS_INTERNAL_DEVELOPMENT__" == 0 } {
        # IP built with simulation encryption flow (enabled or not)
        foreach {filename path package_name} ${sv_files_list} {
            add_sim_encrypted_file ${filename} ${path} SYSTEM_VERILOG SYSTEM_VERILOG_ENCRYPT ${package_name}
        }
        foreach {filename path} ${ver_files_list} {
            add_sim_encrypted_file ${filename} ${path} VERILOG VERILOG_ENCRYPT
        }
        foreach {filename path} ${vhdl_files_list} {
            add_sim_encrypted_file ${filename} ${path} VHDL VHDL_ENCRYPT
        }
    } else {
        # unencrypted IP
        foreach {filename path package_name} ${sv_files_list} {
            add_sim_unencrypted_file ${filename} ${path} SYSTEM_VERILOG ${package_name}
        }
        foreach {filename path} ${ver_files_list} {
            add_sim_unencrypted_file ${filename} ${path} VERILOG
        }
        foreach {filename path} ${vhdl_files_list} {
            add_sim_unencrypted_file ${filename} ${path} VHDL
        }
    }
    foreach {filename path package_name} ${unenc_sv_files_list} {
        add_sim_unencrypted_file ${filename} ${path} SYSTEM_VERILOG ${package_name}
    }
    foreach {filename path} ${unenc_vhdl_files_list} {
        add_sim_unencrypted_file ${filename} ${path} VHDL
    }
    foreach {filename path} ${unenc_ver_files_list} {
        add_sim_unencrypted_file ${filename} ${path} VERILOG
    }
    foreach {filename path} ${hex_files_list} {
        add_fileset_file common/${filename} HEX PATH "${path}/${filename}"
    }
    foreach {filename path} ${mif_files_list} {
        add_fileset_file common/${filename} MIF PATH "${path}/${filename}"
    }
    foreach {filename path} ${misc_files_list} {
        add_fileset_file common/${filename} OTHER PATH "${path}/${filename}"
    }

    # Sim vhdl
    if {[string compare ${generate_cb_sim} ""] != 0} {
        add_fileset sim_vhdl_fileset SIM_VHDL ${generate_cb_sim}
    } else {
        add_fileset sim_vhdl_fileset SIM_VHDL ${generate_cb_synth}
    }
    if {[string compare ${top_level} ""] != 0} {
        set_fileset_property sim_vhdl_fileset TOP_LEVEL ${top_level}
    }
    if { "__ACDS_INTERNAL_DEVELOPMENT__" == 0 } {
        # IP built with simulation encryption flow (enabled or not)
        foreach {filename path package_name} ${sv_files_list} {
            add_sim_encrypted_file ${filename} ${path} SYSTEM_VERILOG SYSTEM_VERILOG_ENCRYPT ${package_name}
        }
        foreach {filename path} ${ver_files_list} {
            add_sim_encrypted_file ${filename} ${path} VERILOG VERILOG_ENCRYPT
        }
        foreach {filename path} ${vhdl_files_list} {
            add_sim_encrypted_file ${filename} ${path} VHDL VHDL_ENCRYPT
        }
    } else {
        # unencrypted IP
        foreach {filename path package_name} ${sv_files_list} {
            add_sim_unencrypted_file ${filename} ${path} SYSTEM_VERILOG ${package_name}
        }
        foreach {filename path} ${ver_files_list} {
            add_sim_unencrypted_file ${filename} ${path} VERILOG
        }
        foreach {filename path} ${vhdl_files_list} {
            add_sim_unencrypted_file ${filename} ${path} VHDL
        }
    }
    foreach {filename path} ${unenc_ver_files_list} {
        add_sim_unencrypted_file ${filename} ${path} VERILOG
    }
    foreach {filename path package_name} ${unenc_sv_files_list} {
        add_sim_unencrypted_file ${filename} ${path} SYSTEM_VERILOG ${package_name}
    }
    foreach {filename path} ${unenc_vhdl_files_list} {
        add_sim_unencrypted_file ${filename} ${path} VHDL
    }
    foreach {filename path} ${hex_files_list} {
        add_fileset_file common/${filename} HEX PATH "${path}/${filename}"
    }
    foreach {filename path} ${mif_files_list} {
        add_fileset_file common/${filename} MIF PATH "${path}/${filename}"
    }
    foreach {filename path} ${misc_files_list} {
        add_fileset_file common/${filename} OTHER PATH "${path}/${filename}"
    }
}


####################################################################################################


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- The common System Verilog packages                                                           --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
proc add_intel_vvp_common_pkg_files {root_rel_path} {
    add_static_sv_file    intel_vvp_common_pkg.sv   ${root_rel_path}/sv_packages  "intel_vvp_common_pkg"
}

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- The common System Verilog packages for the verification BFMs                                 --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
proc add_intel_vvp_common_verif_pkg_files {root_rel_path} {
    add_static_unencrypted_sv_file    intel_vvp_verif_pkg.sv \
                                      ${root_rel_path}/sv_packages      "intel_vvp_verif_pkg"
}

proc add_intel_vvp_common_axi4_streaming_verif_pkg_files {root_rel_path} {
    add_intel_vvp_common_verif_pkg_files                                ${root_rel_path}
    add_static_unencrypted_sv_file    intel_vvp_axi4_stream_pkg.sv \
                                      ${root_rel_path}/sv_packages     "intel_vvp_axi4_stream_pkg"
}

proc add_intel_vvp_common_clocked_video_verif_pkg_files {root_rel_path} {
    add_intel_vvp_common_verif_pkg_files                                ${root_rel_path}
    add_static_unencrypted_sv_file    intel_vvp_clocked_video_pkg.sv \
                                      ${root_rel_path}/sv_packages     "intel_vvp_clocked_video_pkg"
}

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- The core specific System Verilog packages                                                    --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
proc add_intel_vvp_cleaner_pkg_files {root_rel_path} {
    add_static_sv_file  intel_vvp_cleaner_pkg.sv \
                                          ${root_rel_path}/sv_packages      "intel_vvp_cleaner_pkg"
}

proc add_intel_vvp_tmo_pkg_files {root_rel_path} {
    add_static_sv_file  intel_vvp_tmo_pkg.sv \
                                          ${root_rel_path}/sv_packages      "intel_vvp_tmo_pkg"
}

proc add_intel_vvp_clipper_pkg_files {root_rel_path} {
    add_static_sv_file  intel_vvp_clipper_pkg.sv \
                                          ${root_rel_path}/sv_packages      "intel_vvp_clipper_pkg"
}

proc add_intel_vvp_crs_pkg_files {root_rel_path} {
    add_static_sv_file  intel_vvp_crs_pkg.sv \
                                          ${root_rel_path}/sv_packages      "intel_vvp_crs_pkg"
}

proc add_intel_vvp_dil_bob_pkg_files {root_rel_path} {
    add_static_sv_file  intel_vvp_dil_bob_pkg.sv \
                                          ${root_rel_path}/sv_packages      "intel_vvp_dil_bob_pkg"
}

proc add_intel_vvp_interlacer_pkg_files {root_rel_path} {
    add_static_sv_file  intel_vvp_interlacer_pkg.sv \
                                          ${root_rel_path}/sv_packages      "intel_vvp_interlacer_pkg"
}

proc add_intel_vvp_rgb_convertor_pkg_files {root_rel_path} {
    add_static_sv_file  intel_vvp_rgb_convertor_pkg.sv \
                                          ${root_rel_path}/sv_packages      "intel_vvp_rgb_convertor_pkg"
}

proc add_intel_vvp_legalizer_pkg_files {root_rel_path} {
    add_static_sv_file  intel_vvp_legalizer_pkg.sv \
                                          ${root_rel_path}/sv_packages      "intel_vvp_legalizer_pkg"
}

proc add_intel_vvp_mixer_pkg_files {root_rel_path} {
    add_static_sv_file  intel_vvp_mixer_pkg.sv \
                                          ${root_rel_path}/sv_packages      "intel_vvp_mixer_pkg"
}

proc add_intel_vvp_scaler_pkg_files {root_rel_path} {
    add_static_sv_file  intel_vvp_scaler_pkg.sv \
                                          ${root_rel_path}/sv_packages      "intel_vvp_scaler_pkg"
}

proc add_intel_vvp_snoop_pkg_files {root_rel_path} {
    add_static_sv_file  intel_vvp_snoop_pkg.sv \
                                          ${root_rel_path}/sv_packages      "intel_vvp_snoop_pkg"
}

proc add_intel_vvp_swi_pkg_files {root_rel_path} {
    add_static_sv_file  intel_vvp_swi_pkg.sv \
                                          ${root_rel_path}/sv_packages      "intel_vvp_swi_pkg"
}

proc add_intel_vvp_utility_pkg_files {root_rel_path} {
    add_static_sv_file  intel_vvp_utility_pkg.sv \
                                          ${root_rel_path}/sv_packages      "intel_vvp_utility_pkg"
}

proc add_intel_vvp_pip_conv_pkg_files {root_rel_path} {
    add_static_sv_file  intel_vvp_pip_conv_pkg.sv \
                                          ${root_rel_path}/sv_packages      "intel_vvp_pip_conv_pkg"
}

proc add_intel_vvp_protocol_conv_pkg_files {root_rel_path} {
    add_static_sv_file  intel_vvp_protocol_conv_pkg.sv \
                                          ${root_rel_path}/sv_packages     "intel_vvp_protocol_conv_pkg"
}

proc add_intel_vvp_tpg_pkg_files {root_rel_path} {
    add_static_sv_file  intel_vvp_tpg_pkg.sv \
                                          ${root_rel_path}/sv_packages     "intel_vvp_tpg_pkg"
}

proc add_intel_vvp_mpvdma_pkg_files {root_rel_path} {
    add_static_sv_file  intel_vvp_mpvdma_pkg.sv \
                                          ${root_rel_path}/sv_packages     "intel_vvp_mpvdma_pkg"
}

proc add_intel_vvp_vfb_pkg_files {root_rel_path} {
    add_static_sv_file  intel_vvp_vfb_pkg.sv \
                                          ${root_rel_path}/sv_packages     "intel_vvp_vfb_pkg"
}

proc add_intel_vvp_guard_bands_pkg_files {root_rel_path} {
    add_static_sv_file  intel_vvp_guard_bands_pkg.sv \
                                          ${root_rel_path}/sv_packages     "intel_vvp_guard_bands_pkg"
}

proc add_intel_vvp_3d_lut_pkg_files {root_rel_path} {
    add_static_sv_file  intel_vvp_3d_lut_pkg.sv \
                                          ${root_rel_path}/sv_packages     "intel_vvp_3d_lut_pkg"
}

proc add_intel_vvp_csc_pkg_files {root_rel_path} {
    add_static_sv_file  intel_vvp_csc_pkg.sv \
                                          ${root_rel_path}/sv_packages     "intel_vvp_csc_pkg"
}

proc add_intel_vvp_anr_pkg_files {root_rel_path} {
    add_static_sv_file  intel_vvp_anr_pkg.sv \
                                          ${root_rel_path}/sv_packages     "intel_vvp_anr_pkg"
}

proc add_intel_vvp_warp_pkg_files {root_rel_path} {
    add_static_sv_file  intel_vvp_warp_pkg.sv \
                                          ${root_rel_path}/sv_packages     "intel_vvp_warp_pkg"
}

proc add_intel_vvp_fir_pkg_files {root_rel_path} {
    add_static_sv_file  intel_vvp_fir_pkg.sv \
                                          ${root_rel_path}/sv_packages     "intel_vvp_fir_pkg"
}

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- The common System Verilog modules                                                            --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

proc add_intel_vvp_axi_zero_pad_files {root_rel_path} {
    add_static_sv_file  intel_vvp_axi_zero_pad.sv                 ${root_rel_path}/hdl_modules/zero_pad
    add_static_sv_file  intel_vvp_axi_zero_strip.sv               ${root_rel_path}/hdl_modules/zero_pad
}

proc add_intel_vvp_axi_pipeline_stage_files {root_rel_path} {
    add_static_sv_file  intel_vvp_axi_pipeline_stage.sv           ${root_rel_path}/hdl_modules/pipeline
}

proc add_intel_vvp_axi_master_files {root_rel_path} {
    add_intel_vvp_axi_pipeline_stage_files                        ${root_rel_path}
    add_static_sv_file  intel_vvp_axi_master.sv                   ${root_rel_path}/hdl_modules/pipeline
}

proc add_intel_vvp_counter_clock_crosser_files {root_rel_path} {
    add_static_sv_file  intel_vvp_binary_to_gray.sv               ${root_rel_path}/hdl_modules/clock_crossing
    add_static_sv_file  intel_vvp_gray_to_binary.sv               ${root_rel_path}/hdl_modules/clock_crossing
    add_static_sv_file  intel_vvp_counter_clock_crosser.sv        ${root_rel_path}/hdl_modules/clock_crossing
}

proc add_intel_vvp_ring_clock_crosser_files {root_rel_path} {
    add_static_sv_file  intel_vvp_ring_clock_crosser.sv           ${root_rel_path}/hdl_modules/clock_crossing
}

proc add_intel_vvp_clock_crosser_files {root_rel_path} {
    add_static_sv_file  intel_vvp_flop_primitive.sv               ${root_rel_path}/hdl_modules/clock_crossing
    add_static_sv_file  intel_vvp_synchronizer_flop.sv            ${root_rel_path}/hdl_modules/clock_crossing
    add_static_sv_file  intel_vvp_clock_crosser.sv                ${root_rel_path}/hdl_modules/clock_crossing
}

proc add_intel_vvp_enabled_cdc_files {root_rel_path} {
    add_static_sv_file  intel_vvp_flop_enable_reset_primitive.sv  ${root_rel_path}/hdl_modules/clock_crossing
    add_static_sv_file  intel_vvp_enabled_cdc.sv                  ${root_rel_path}/hdl_modules/clock_crossing
}

proc add_intel_vvp_fifo_component_files {root_rel_path} {
    add_intel_vvp_counter_clock_crosser_files                     ${root_rel_path}
    add_static_sv_file  intel_vvp_fifo_input.sv                   ${root_rel_path}/hdl_modules/fifos
    add_static_sv_file  intel_vvp_fifo_output.sv                  ${root_rel_path}/hdl_modules/fifos
    add_static_sv_file  intel_vvp_common_fifo.sv                  ${root_rel_path}/hdl_modules/fifos
}

proc add_intel_vvp_axi_fifo_files {root_rel_path} {
    add_intel_vvp_fifo_component_files                            ${root_rel_path}
    add_intel_vvp_axi_master_files                                ${root_rel_path}
    add_static_sv_file  intel_vvp_axi_fifo_input.sv               ${root_rel_path}/hdl_modules/fifos
    add_static_sv_file  intel_vvp_axi_fifo_output.sv              ${root_rel_path}/hdl_modules/fifos
    add_static_sv_file  intel_vvp_axi_fifo.sv                     ${root_rel_path}/hdl_modules/fifos
}

proc add_intel_vvp_token_files {root_rel_path} {
    add_static_sv_file  intel_vvp_token_fifo_input.sv             ${root_rel_path}/hdl_modules/fifos
}

proc add_intel_vvp_streaming_fifo_files {root_rel_path} {
    add_static_sv_file  intel_vvp_streaming_fifo.sv               ${root_rel_path}/hdl_modules/fifos
}

proc add_intel_vvp_axi_streaming_fifo_files {root_rel_path} {
    add_intel_vvp_streaming_fifo_files                            ${root_rel_path}
    add_static_sv_file  intel_vvp_axi_streaming_fifo.sv           ${root_rel_path}/hdl_modules/fifos
}

proc add_intel_vvp_pipelined_mux_files {root_rel_path} {
    add_static_sv_file  intel_vvp_pipelined_mux.sv                ${root_rel_path}/hdl_modules/pixel_shift
}

proc add_intel_vvp_shift_mux_files {root_rel_path} {
    add_static_sv_file  intel_vvp_shift_mux.sv                    ${root_rel_path}/hdl_modules/pixel_shift
}

proc add_intel_vvp_rotate_mux_files {root_rel_path} {
    add_static_sv_file  intel_vvp_rotate_mux.sv                   ${root_rel_path}/hdl_modules/pixel_shift
}

proc add_intel_vvp_legacy_files {root_rel_path} {
    add_intel_vvp_shift_mux_files                                 ${root_rel_path}
    add_static_sv_file  intel_vvp_message_packet_align.sv         ${root_rel_path}/hdl_modules/legacy
    add_static_sv_file  intel_vvp_message_packet_decode.sv        ${root_rel_path}/hdl_modules/legacy
    add_static_sv_file  intel_vvp_message_packet_encode.sv        ${root_rel_path}/hdl_modules/legacy
}

proc add_intel_vvp_pip_conv_files {root_rel_path} {
    add_intel_vvp_shift_mux_files                                 ${root_rel_path}
    add_static_sv_file  intel_vvp_pack_simple.sv                  ${root_rel_path}/hdl_modules/pip_conv
    add_static_sv_file  intel_vvp_unpack_simple.sv                ${root_rel_path}/hdl_modules/pip_conv
    add_static_sv_file  intel_vvp_pack_hard.sv                    ${root_rel_path}/hdl_modules/pip_conv
    add_static_sv_file  intel_vvp_unpack_hard.sv                  ${root_rel_path}/hdl_modules/pip_conv
}

proc add_intel_vvp_add_tree_files {root_rel_path} {
    add_static_sv_file  intel_vvp_add_tree.sv                     ${root_rel_path}/hdl_modules/arithmetic
}

proc add_intel_vvp_mult_files {root_rel_path} {
    add_static_sv_file  intel_vvp_mult.sv                         ${root_rel_path}/hdl_modules/arithmetic
}

proc add_intel_vvp_mult_add_files {root_rel_path} {
    add_intel_vvp_add_tree_files                                  ${root_rel_path}
    add_intel_vvp_mult_files                                      ${root_rel_path}
    add_static_sv_file  intel_vvp_2_mult_add.sv                   ${root_rel_path}/hdl_modules/arithmetic
    add_static_sv_file  intel_vvp_3_mult_add.sv                   ${root_rel_path}/hdl_modules/arithmetic
    add_static_sv_file  intel_vvp_4_mult_add.sv                   ${root_rel_path}/hdl_modules/arithmetic
    add_static_sv_file  intel_vvp_mult_add.sv                     ${root_rel_path}/hdl_modules/arithmetic
}

proc add_intel_vvp_common_ram_files {root_rel_path} {
    add_static_sv_file  intel_vvp_common_simple_dpram.sv          ${root_rel_path}/hdl_modules/rams
}

proc add_intel_vvp_round_sat_files {root_rel_path} {
    add_static_sv_file  intel_vvp_round_sat.sv                    ${root_rel_path}/hdl_modules/arithmetic
}

proc add_intel_vvp_serial_divider_files {root_rel_path} {
    add_static_sv_file  intel_vvp_serial_divider.sv               ${root_rel_path}/hdl_modules/arithmetic
}

proc add_intel_vvp_edge_pad_files {root_rel_path} {
    add_static_sv_file  intel_vvp_edge_pad.sv                     ${root_rel_path}/hdl_modules/arithmetic
}

proc add_intel_vvp_ext_interlace_toggle_files {root_rel_path} {
    add_static_sv_file  intel_vvp_ext_interlace_toggle.sv         ${root_rel_path}/hdl_modules/slave_interface
}

proc add_intel_vvp_mirror_files {root_rel_path} {
    add_intel_vvp_pipelined_mux_files                             ${root_rel_path}
    add_static_sv_file  intel_vvp_mirror.sv                       ${root_rel_path}/hdl_modules/arithmetic
}

proc add_intel_vvp_edge_replicate_files {root_rel_path} {
    add_intel_vvp_edge_pad_files                                  ${root_rel_path}
    add_static_sv_file  intel_vvp_edge_replicate.sv               ${root_rel_path}/hdl_modules/arithmetic
}

proc add_intel_vvp_h_kernel_files {root_rel_path} {
    add_intel_vvp_mirror_files                                    ${root_rel_path}
    add_static_sv_file  intel_vvp_h_kernel_mirror.sv              ${root_rel_path}/hdl_modules/horizontal_kernel
    add_static_sv_file  intel_vvp_h_kernel.sv                     ${root_rel_path}/hdl_modules/horizontal_kernel
    add_static_sv_file  intel_vvp_h_kernel_422.sv                 ${root_rel_path}/hdl_modules/horizontal_kernel
}

proc add_intel_vvp_pip_bunch_merge_files {root_rel_path} {
    add_intel_vvp_add_tree_files                                  ${root_rel_path}
    add_intel_vvp_rotate_mux_files                                ${root_rel_path}
    add_static_sv_file  intel_vvp_pip_bunch.sv                    ${root_rel_path}/hdl_modules/pip_conv
    add_static_sv_file  intel_vvp_pip_merge.sv                    ${root_rel_path}/hdl_modules/pip_conv
}

proc add_intel_vvp_common_slave_interface_files {root_rel_path} {
    add_intel_vvp_ext_interlace_toggle_files                      ${root_rel_path}
    add_intel_vvp_pipelined_mux_files                             ${root_rel_path}
    add_static_sv_file  intel_vvp_common_slave_interface.sv       ${root_rel_path}/hdl_modules/slave_interface
}

proc add_intel_vvp_mpvdma_common_files {root_rel_path} {
    add_static_sv_file  intel_vvp_mpvdma_cmd_split.sv             ${root_rel_path}/hdl_modules/mpvdma_common
    add_static_sv_file  intel_vvp_mpvdma_resp_cc.sv               ${root_rel_path}/hdl_modules/mpvdma_common
}

proc add_intel_vvp_scaler_common_files {root_rel_path} {
    add_static_sv_file  intel_vvp_scaler_iterative_base.sv        ${root_rel_path}/hdl_modules/scaler_common
    add_static_sv_file  intel_vvp_scaler_iterative_init_ready.sv  ${root_rel_path}/hdl_modules/scaler_common
    add_static_sv_file  intel_vvp_scaler_iterative_init_valid.sv  ${root_rel_path}/hdl_modules/scaler_common
    add_static_sv_file  intel_vvp_scaler_iterative_init_phase.sv  ${root_rel_path}/hdl_modules/scaler_common
}

proc add_intel_vvp_vid_dimensions_files {root_rel_path} {
    add_static_sv_file  intel_vvp_vid_dimensions.sv               ${root_rel_path}/hdl_modules/vid_dimensions
}

proc add_intel_vvp_multibit_cdc_files {root_rel_path} {
    add_static_sv_file  intel_vvp_multibit_cdc.sv                 ${root_rel_path}/hdl_modules/clock_crossing
}
