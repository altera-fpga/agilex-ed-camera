LINUX_VERSION = "6.12.11"
LINUX_VERSION_SUFFIX = "-lts"
RT_LINUX_VERSION = "6.12.8"
RT_PATCH_VERSION = "8"

LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

SRCREV = "2f0b0270dbabe9acc602bd269b4f85253e8a6e6d"

include linux-socfpga.inc

SRC_URI:append = " https://cdn.kernel.org/pub/linux/kernel/projects/rt/6.12/older/patch-${RT_LINUX_VERSION}-rt${RT_PATCH_VERSION}.patch.gz;name=rt-patch;apply=yes"

SRC_URI[rt-patch.sha256sum] = "81e08a6b8e324c08518b50256fb434b8b3fbf85618e08e99de106ce1ac4815b2"
