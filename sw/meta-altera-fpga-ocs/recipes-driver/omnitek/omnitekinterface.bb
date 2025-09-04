# *******************************************************************************
# Copyright (C) Altera Corporation
#
# This code and the related documents are Altera copyrighted materials and your
# use of them is governed by the express license under which they were provided to
# you ("License"). This code and the related documents are provided as is, with no
# express or implied warranties other than those that are expressly stated in the 
# License.
# *******************************************************************************/

# Build Omnitek Interface Library from OmnitekInterfaceSource.tar.gz file in Yocto recipe
SUMMARY = "omnitekinterface"
SECTION = "libs"
LICENSE = "Intel"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Intel;md5=ced5efc26449ecac834b4b71625a3410"

# Set source paths
FILESEXTRAPATHS:append := ":${THISDIR}/files"
SRC_URI = "file://OmnitekInterfaceSource.tar.gz"
S = "${WORKDIR}/OmnitekInterface/library"

# Default is to create release build
# To build this recipe as a debug build add 'debug' to PACKAGECONFIG
# This can be in local.conf as PACKAGECONFIG:pn-omnitekinterface = "debug"
EXTRA_OEMAKE = "${@bb.utils.contains('PACKAGECONFIG', 'debug', 'DEBUG=y ', 'DEBUG=n ', d)}"

PACKAGECONFIG[debug] = ""
LIBCFGDIR = "${@bb.utils.contains('PACKAGECONFIG', 'debug', 'BuildDebug', 'BuildRelease', d)}"

FILES:${PN} += " ${libdir}/libOmniTekInterface.so"

do_compile() {
	     export OMNI_DRIVER_INTERFACE="${WORKDIR}/OmnitekInterface/drivers/DriverInterface"
	     export EXTRA_LDFLAGS="${LDFLAGS}"
	     oe_runmake -C OmniTekInterface -f Makefile.linux libOmniTekInterface.so
}

do_install() {
	     install -d ${D}${libdir}
             install -m 0755 OmniTekInterface/linux/${LIBCFGDIR}/libOmniTekInterface.so.1 ${D}${libdir}
	     ln -s -r ${D}${libdir}/libOmniTekInterface.so.1 ${D}${libdir}/libOmniTekInterface.so
}
