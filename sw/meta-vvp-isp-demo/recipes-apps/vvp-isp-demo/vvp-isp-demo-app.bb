# *******************************************************************************
# Copyright (C) Altera Corporation
#
# This code and the related documents are Altera copyrighted materials and your
# use of them is governed by the express license under which they were provided to
# you ("License"). This code and the related documents are provided as is, with no
# express or implied warranties other than those that are expressly stated in the 
# License.
# *******************************************************************************/

DESCRIPTION = "Builds the VVP ISP demo application"
LICENSE = "CLOSED"

S = "${WORKDIR}"
UNPACKDIR = "${S}"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += " \
             file://vvp-isp-application-src.tar.gz;subdir=${S}/vvp-isp-app-src \
             file://start.sh \
             file://21-vvp-isp \
             file://vvp-isp.service \
             file://start_icamera_proxy.sh \
             file://icamera-proxy.service \
            "

inherit cmake systemd pkgconfig

OECMAKE_SOURCEPATH = "${S}/vvp-isp-app-src"

BUILDDIR = "${WORKDIR}/build"

EXTRA_OECMAKE = "-DCMAKE_INSTALL_PREFIX=/home/root -DMACHINE:STRING=${MACHINE}"
OECMAKE_TARGET_INSTALL = "install_deploy"
do_install:append() {
    install -d ${D}${sysconfdir}/local.d
    install -m 0644 ${S}/21-vvp-isp ${D}${sysconfdir}/local.d

    install -m 0755 ${WORKDIR}/start.sh ${D}/home/root

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_system_unitdir}
        install -m 644 ${WORKDIR}/vvp-isp.service ${D}${systemd_system_unitdir}/vvp-isp.service
    fi

    install -d ${D}/home/root/ICameraProxyServer
    install -m 0755 ${WORKDIR}/start_icamera_proxy.sh ${D}/home/root/ICameraProxyServer

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_system_unitdir}
        install -m 644 ${WORKDIR}/icamera-proxy.service ${D}${systemd_system_unitdir}/icamera-proxy.service
    fi
}

DEPENDS = " fuse3 "
RDEPENDS_${PN} = " fuse3 "

FILES:${PN} += " \
    /home/root \
    /etc/local.d \
        ${@bb.utils.contains('DISTRO_FEATURES','systemd','${systemd_system_unitdir}/vvp-isp.service ${systemd_system_unitdir}/icamera-proxy.service','',d)} \
"

SYSTEMD_SERVICE:${PN} = "${@bb.utils.contains('DISTRO_FEATURES','systemd','vvp-isp.service icamera-proxy.service','',d)}"
SYSTEMD_AUTO_ENABLE = "enable"
