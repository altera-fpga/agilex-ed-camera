# *******************************************************************************
# Copyright (C) Altera Corporation
#
# This code and the related documents are Altera copyrighted materials and your
# use of them is governed by the express license under which they were provided to
# you ("License"). This code and the related documents are provided as is, with no
# express or implied warranties other than those that are expressly stated in the 
# License.
# *******************************************************************************/

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"


SRC_URI:append = "\
  file://agilex-disable-nand.cfg \
  file://u-boot-misc-config.cfg \
  file://${FPGA_CORE_FILE} \
"

# Remove the patch below if necessary after upgrading u-boot to the most recent version from meta-intel-fpga
SRC_URI:append:agilex5_axe5_eagle = " file://v1-0001-HSD-15015933655-ddr-altera-agilex5-Hack-dual-port-DO-NOT-MERGE.patch "

do_deploy:append() {
    #Default FPGA core image
    install -m 744 ${WORKDIR}/${FPGA_CORE_FILE} ${DEPLOYDIR}/${FPGA_CORE_FILE}
}

