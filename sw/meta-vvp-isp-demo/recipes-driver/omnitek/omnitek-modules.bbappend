# *******************************************************************************
# Copyright (C) Altera Corporation
#
# This code and the related documents are Altera copyrighted materials and your
# use of them is governed by the express license under which they were provided to
# you ("License"). This code and the related documents are provided as is, with no
# express or implied warranties other than those that are expressly stated in the 
# License.
# *******************************************************************************/

FILESEXTRAPATHS:append := ":${THISDIR}/files"

SRC_URI:append:agilex5_axe5_eagle = " file://0001-Fixes-for-the-build-errors-caused-by-extra-warnings-.patch;patchdir=.."

