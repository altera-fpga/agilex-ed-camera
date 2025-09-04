# *******************************************************************************
# Copyright (C) Altera Corporation
#
# This code and the related documents are Altera copyrighted materials and your
# use of them is governed by the express license under which they were provided to
# you ("License"). This code and the related documents are provided as is, with no
# express or implied warranties other than those that are expressly stated in the 
# License.
# *******************************************************************************/

#
# Omnitek kernel modules
#
#
inherit module
inherit externalsrc

SUMMARY = "Omnitek Modules"
SECTION = "modules"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

# Set default value for OMNITEK_IP_DRIVER_SRC - this is required because build will fail if
# this is not set even if this package is not included in the final image
OMNITEK_IP_DRIVER_SRC ?= "${S}"
# Set source paths
EXTERNALSRC = "${OMNITEK_IP_DRIVER_SRC}/drivers"
EXTERNALSRC_BUILD = "${OMNITEK_IP_DRIVER_SRC}/drivers"

# Default is to create release build
# To build this recipe as a debug build add 'debug' to PACKAGECONFIG
# This can be in local.conf as PACKAGECONFIG_pn-omnitek-modules = "debug"
EXTRA_OEMAKE = "${@bb.utils.contains('PACKAGECONFIG', 'debug',   'DEBUG=y ', 'DEBUG=n ', d)} \
	        ${@bb.utils.contains('PACKAGECONFIG', 'release', 'RELEASE_BUILD=y', '', d)} \
               "

PACKAGECONFIG[debug] = ""
PACKAGECONFIG[release] = ""

RPROVIDES:${PN} += " \
	kernel-module-omnitekfpgabus-${KERNEL_VERSION} \
	kernel-module-ot-cap-mdma-${KERNEL_VERSION} \
	kernel-module-ot-cap-omnifb-${KERNEL_VERSION} \
	kernel-module-ot-cap-registeraccess-${KERNEL_VERSION} \
	kernel-module-ot-cap-videofdma-${KERNEL_VERSION} \
	kernel-module-ot-hc-localfpga-${KERNEL_VERSION} \
	kernel-module-ot-hc-omnitek-${KERNEL_VERSION} \
	" 

FILES:${PN} += " \
	${libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek/OmniTekFPGABus.ko \
	${libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek/OT_Cap_MDMA.ko \
	${libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek/OT_Cap_OmniFB.ko \
	${libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek/OT_Cap_RegisterAccess.ko \
	${libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek/OT_Cap_VideoFDMA.ko \
	${libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek/OT_HC_LocalFPGA.ko \
	${libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek/OT_HC_OmniTek.ko \
	"

do_compile() {
	     unset LDFLAGS
	     current_dir="$PWD"
	     oe_runmake ARCH=${ARCH} KERNELDIR="${STAGING_KERNEL_DIR}" OMNI_DRIVER_INTERFACE="${current_dir}/DriverInterface" \
	     -f Makefile.linux
}

do_install() {
	     install -d ${D}${libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek
	     install -m 0644 bus/OmniTekBus/linux/OmniTekFPGABus.ko ${D}${libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek
	     install -m 0644 capability/MDMA/linux/OT_Cap_MDMA.ko ${D}${libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek
	     install -m 0644 capability/OmniFB/linux/OT_Cap_OmniFB.ko ${D}${libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek
	     install -m 0644 capability/RegisterAccess/linux/OT_Cap_RegisterAccess.ko ${D}${libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek
	     install -m 0644 capability/VideoFDMA/linux/OT_Cap_VideoFDMA.ko ${D}${libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek
	     install -m 0644 host_controller/LocalFPGA/linux/OT_HC_LocalFPGA.ko ${D}${libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek
	     install -m 0644 host_controller/OmniTek/linux/OT_HC_OmniTek.ko ${D}${libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek
}

externalsrc_do_buildclean() {
           oe_runmake ARCH=${ARCH} KERNELDIR="${STAGING_KERNEL_DIR}" -f Makefile.linux clean
}

