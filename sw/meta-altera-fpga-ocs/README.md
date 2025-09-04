# meta-altera-fpga-omnitek

This layer provides the driver and application library for the Altera FPGA IP supporting OCS framework for communication between userspace software driver and FPGA IP core

The recipes for the kernel modules and library have two versions Standard and External Source

## Standard

Packages: omnitekinterface.bb, omnitek-modules.bb

These recipes require the source tarball OmnitekInterfaceSource.tar.gz to be added to the layer in the path:

        recipes-driver/omnitek/files/OmnitekInterfaceSource.tar.gz

For external distribution the tarball must be included in the layer

## External Source

Packages: omnitekinterface-extsrc.bb, omnitek-modules-extsrc.bb

These recipes build from an external source tree

The following environment variables must be defined from the BitBake build directory:

        export OMNITEK_IP_DRIVER_SRC=<Omnitek Driver/Lib source tree location>
        export BB_ENV_PASSTHROUGH_ADDITIONS="${BB_ENV_PASSTHROUGH_ADDITIONS} OMNITEK_IP_DRIVER_SRC"

## Adding to a Yocto Image

Add these lines to the Yocto Image recipe to include the Omnitek layer packages:

        IMAGE_INSTALL:append = " \
                omnitekinterface \
                omnitek-modules \
                omnitek-scripts \
        "

Replace the first two packages with the -extsrc versions if using an external source tree
