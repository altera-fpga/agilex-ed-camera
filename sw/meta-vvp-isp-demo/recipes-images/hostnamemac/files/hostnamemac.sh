#!/bin/sh
# *******************************************************************************
# Copyright (C) Altera Corporation
#
# This code and the related documents are Altera copyrighted materials and your
# use of them is governed by the express license under which they were provided to
# you ("License"). This code and the related documents are provided as is, with no
# express or implied warranties other than those that are expressly stated in the 
# License.
# *******************************************************************************/

#Append MAC address to hostname

if [ -e /etc/ethernetmac.eth0 ] ; then
    HOSTNAME_STEM="$(hostname | sed -e 's/\-.*//')"
    HOSTNAME_MAC="${HOSTNAME_STEM}-$(cat /etc/ethernetmac.eth0 | sed -e "s/\://g" -e "y/ABCDEF/abcdef/")"
    hostname ${HOSTNAME_MAC}
fi
