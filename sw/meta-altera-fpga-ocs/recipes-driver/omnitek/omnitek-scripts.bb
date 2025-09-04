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
# This file is the omnitek-scripts recipe.
#

SUMMARY = "omnitek-scripts"
SECTION = "initscripts"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

FILESEXTRAPATHS:append := ":${THISDIR}/files"
SRC_URI = " \
	file://omnitek-modules \
	file://local-scripts \
	file://20-app \
	file://omnitek-modules.service \
	"

S = "${WORKDIR}"
UNPACKDIR = "${S}"

inherit update-rc.d
inherit systemd

INITSCRIPT_NAME = "omnitek-modules"
INITSCRIPT_PARAMS = "start 50 2 . stop 50 2 ."
do_install() {
	if ${@bb.utils.contains('DISTRO_FEATURES','sysvinit','true','false',d)}; then
		install -d ${D}${sysconfdir}/init.d
		ln -s ../../usr/bin/omnitek-modules ${D}${sysconfdir}/init.d/omnitek-modules
		install -d ${D}${sysconfdir}/rc5.d
		ln -s ../init.d/omnitek-modules ${D}${sysconfdir}/rc5.d/S50omnitek-modules
		install -m 0755 ${S}/local-scripts ${D}${sysconfdir}/init.d/local-scripts
		install -d ${D}${sysconfdir}/rc3.d
		install -d ${D}${sysconfdir}/rc5.d
		install -d ${D}${sysconfdir}/rc6.d
		install -d ${D}${sysconfdir}/rc0.d
		ln -s ../init.d/local-scripts ${D}${sysconfdir}/rc3.d/S00local-scripts
		ln -s ../init.d/local-scripts ${D}${sysconfdir}/rc5.d/S00local-scripts
		ln -s ../init.d/local-scripts ${D}${sysconfdir}/rc6.d/K01local-scripts
		ln -s ../init.d/local-scripts ${D}${sysconfdir}/rc0.d/K01local-scripts
		install -d ${D}${sysconfdir}/local.d
		install -m 0755 ${S}/20-app ${D}${sysconfdir}/local.d
	fi

	if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
       		install -d ${D}${systemd_system_unitdir}
		install -m 644 ${S}/omnitek-modules.service ${D}${systemd_system_unitdir}/omnitek-modules.service
	fi

	install -d ${D}/usr/bin
	install -m 755 ${S}/omnitek-modules ${D}/usr/bin/omnitek-modules
}
FILES:${PN} += "${sysconfdir}/*"
FILES:${PN} += "${@bb.utils.contains('DISTRO_FEATURES','systemd','/usr/bin/omnitek-modules ${systemd_system_unitdir}/omnitek-modules.service','',d)}"

SYSTEMD_SERVICE:${PN} = "${@bb.utils.contains('DISTRO_FEATURES','systemd','omnitek-modules.service','',d)}"
