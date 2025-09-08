SUMMARY = "Implementation of a fully functional filesystem in a userspace program"
DESCRIPTION = "FUSE (Filesystem in Userspace) is a simple interface for userspace \
               programs to export a virtual filesystem to the Linux kernel. FUSE \
               also aims to provide a secure method for non privileged users to \
               create and mount their own filesystem implementations. \
              "
HOMEPAGE = "https://github.com/libfuse/libfuse"
SECTION = "libs"
LICENSE = "GPL-2.0-only & LGPL-2.0-only"
LIC_FILES_CHKSUM = " \
    file://GPL2.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
    file://LGPL2.txt;md5=4fbd65380cdd255951079008b364516c \
    file://LICENSE;md5=a55c12a2d7d742ecb41ca9ae0a6ddc66 \
"

SRC_URI = "https://github.com/libfuse/libfuse/releases/download/fuse-${PV}/fuse-${PV}.tar.gz \
           file://fuse3.conf \
"
SRC_URI[sha256sum] = "f797055d9296b275e981f5f62d4e32e089614fc253d1ef2985851025b8a0ce87"

S = "${WORKDIR}/fuse-${PV}"

UPSTREAM_CHECK_URI = "https://github.com/libfuse/libfuse/releases"
UPSTREAM_CHECK_REGEX = "fuse\-(?P<pver>3(\.\d+)+).tar.xz"

CVE_PRODUCT = "fuse_project:fuse"

inherit meson pkgconfig

DEPENDS = "udev"

PACKAGES =+ "fuse3-utils"

RPROVIDES:${PN}-dbg += "fuse3-utils-dbg"

RRECOMMENDS:${PN}:class-target = "kernel-module-fuse fuse3-utils"

FILES:${PN} += "${libdir}/libfuse3.so.*"
FILES:${PN}-dev += "${libdir}/libfuse3*.la"

# Forbid auto-renaming to libfuse3-utils
FILES:fuse3-utils = "${bindir} ${base_sbindir}"
DEBIAN_NOAUTONAME:fuse3-utils = "1"
DEBIAN_NOAUTONAME:${PN}-dbg = "1"

SYSTEMD_SERVICE:${PN} = ""

do_install:append() {
    rm -rf ${D}${base_prefix}/dev

    # systemd class remove the sysv_initddir only if systemd_system_unitdir
    # contains anything, but it's not needed if sysvinit is not in DISTRO_FEATURES
    if ${@bb.utils.contains('DISTRO_FEATURES', 'sysvinit', 'false', 'true', d)}; then
        rm -rf ${D}${sysconfdir}/init.d/
    fi

    # Install systemd related configuration file
    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -d ${D}${sysconfdir}/modules-load.d
        install -m 0644 ${WORKDIR}/fuse3.conf ${D}${sysconfdir}/modules-load.d
    fi
}
