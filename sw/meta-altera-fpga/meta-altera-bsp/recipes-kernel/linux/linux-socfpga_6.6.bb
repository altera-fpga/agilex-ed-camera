LINUX_VERSION = "6.6.51"
LINUX_VERSION_SUFFIX = "-lts"
RT_LINUX_VERSION = "6.6.50"
RT_PATCH_VERSION = "42"

LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

SRCREV = "7dddbad0a3a725b140b8fc4621159cd4628374a8"

include linux-socfpga.inc

SRC_URI:append = "${@bb.utils.contains('SOCFPGA_FEATURES', 'rt', ' https://cdn.kernel.org/pub/linux/kernel/projects/rt/6.6/older/patch-${RT_LINUX_VERSION}-rt${RT_PATCH_VERSION}.patch.gz;name=rt-patch;apply=yes', '', d)}"

SRC_URI[rt-patch.sha256sum] = "8ec45aca0a21c7a1914b4d2ee42e8815e3e6ad3f25a46785a4415a04d23b4af7"
