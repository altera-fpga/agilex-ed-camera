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

SUMMARY = "Omnitek Modules"
SECTION = "modules"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

# Set source paths
FILESEXTRAPATHS:append := ":${THISDIR}/files"

SRC_URI = "file://OmnitekInterfaceSource.tar.gz "

# Remove the patch below once Omnitek interface upgraded to rel 1.4
# This will also require linux kernel upgrade to v6.6
SRC_URI:append:agilex5_devkit = " file://omnitek-modules-localfpga-irq.patch "
SRC_URI:append:agilex5_axe5_eagle = " file://omnitek-modules-localfpga-irq.patch "

S = "${WORKDIR}/OmnitekInterface/drivers"

# Default is to create release build
# To build this recipe as a debug build add 'debug' to PACKAGECONFIG
# This can be in local.conf as PACKAGECONFIG_pn-omnitek-modules = "debug"
EXTRA_OEMAKE = "${@bb.utils.contains('PACKAGECONFIG', 'debug',   'DEBUG=y ', 'DEBUG=n ', d)} \
	        ${@bb.utils.contains('PACKAGECONFIG', 'release', 'RELEASE_BUILD=y', '', d)} \
               "

PACKAGECONFIG[debug] = ""
PACKAGECONFIG[release] = ""
LIBCFGDIR = "${@bb.utils.contains('PACKAGECONFIG', 'debug', 'BuildDebug', 'BuildRelease', d)}"

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
	${nonarch_base_libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek/OmniTekFPGABus.ko \
	${nonarch_base_libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek/OT_Cap_MDMA.ko \
	${nonarch_base_libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek/OT_Cap_OmniFB.ko \
	${nonarch_base_libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek/OT_Cap_RegisterAccess.ko \
	${nonarch_base_libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek/OT_Cap_VideoFDMA.ko \
	${nonarch_base_libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek/OT_HC_LocalFPGA.ko \
	${nonarch_base_libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek/OT_HC_OmniTek.ko \
	"

do_compile() {
	     unset LDFLAGS
	     oe_runmake ARCH=${ARCH} KERNELDIR="${STAGING_KERNEL_DIR}" \
             OMNI_DRIVER_INTERFACE="${S}/DriverInterface" \
	     -f Makefile.linux
}

do_install() {
	     install -d ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek
	     install -m 0644 bus/OmniTekBus/linux/OmniTekFPGABus.ko ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek
	     install -m 0644 capability/MDMA/linux/OT_Cap_MDMA.ko ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek
	     install -m 0644 capability/OmniFB/linux/OT_Cap_OmniFB.ko ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek
	     install -m 0644 capability/RegisterAccess/linux/OT_Cap_RegisterAccess.ko ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek
	     install -m 0644 capability/VideoFDMA/linux/OT_Cap_VideoFDMA.ko ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek
	     install -m 0644 host_controller/LocalFPGA/linux/OT_HC_LocalFPGA.ko ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek
	     install -m 0644 host_controller/OmniTek/linux/OT_HC_OmniTek.ko ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/kernel/drivers/omnitek
}
