# 4Kp60 Multi-Sensor HDR Camera Solution Reference Design for Agilex™ 5 Devices

# Camera Solution SD card build (Yocto Linux)
This folder contains all necessary files to build a bootable SD card image containing complete Linux system to run the 4Kp60 Multi-Sensor HDR Camera Solution on supported Agilex™ 5 SoC FPGA devkits.<br>
The build uses [Yocto project](https://www.yoctoproject.org/) along with [KAS](https://github.com/siemens/kas). This folder provides all necessary Yocto layers and KAS input files required to build the image.


## System requirements

The build process requires a Linux host (or a docker container) with at least 70 Gb of free disk storage and 32 Gb of RAM

To use Yocto on a Ubuntu linux host please use the command below to install required packages
```
sudo apt install build-essential chrpath cpio debianutils diffstat file gawk gcc git iputils-ping libacl1 liblz4-tool locales python3 python3-git python3-jinja2 python3-pexpect python3-pip python3-subunit socat texinfo unzip wget xz-utils zstd
```

To install KAS please run
```
sudo apt install -y python3 python3-pip
sudo pip3 install kas
```

For detailed information on system requirements and dependencies please refer to:

[Yocto system requirements](https://docs.yoctoproject.org/ref-manual/system-requirements.html)

[KAS dependencies and installation](https://kas.readthedocs.io/en/1.0/userguide.html#dependencies-installation)

## Folder Contents
- `kas`
  
  Input files for KAS tool. Required to set up and configure Yocto project
  
- `meta-altera-fpga`
  
  Yocto layer adding support for Altera® FPGAs to the system build
  
- `meta-altera-fpga-ocs`

  Yocto layer providing communication between the Camera Solution software application and the Programmable Logic
  
- `meta-vvp-isp-demo`

  Yocto layer containing Camera Solution software application as well as all other system configuration and runtime settings required to build and run the design.

## Supported Designs
 - `agilex_camera_ff`
 
   builds an SD card image for the FPGA configuration first mode. Use this for OpenCore Plus IP evaluation licensed build
   
 - `agilex_camera`
 
   builds an SD card image for the HPS boot first mode. Use this for fully licensed build, or prebuilt RBF and JIC binaries

## Supported Machines

 - `agilex5_mk_a5e065bb32aes1` alias `agilex5_modkit`

## Supported Image Types

 - `mmc` (SD Card)

## Building SD Card Image
 > **Make sure you have installed the [required dependencies](meta-altera-fpga/README.md#dependencies) before proceeding.**

```bash
KAS_MACHINE=${MACHINE} kas build kas/${DESIGN}.yml
```
For example:

```bash
KAS_MACHINE=agilex5_mk_a5e065bb32aes1 kas build kas/agilex_camera_ff.yml
```

See above for a list of supported `MACHINE` and `DESIGN` identifiers.

Once the build has finished successfully you will have a `.wic.gz` image available in `build/tmp/deploy/images/${MACHINE}` which can be [flashed to an SD card](meta-altera-fpga/docs/flash_sd_card.md).

## SD Card Contents

Generated SD card will contain two partitions:

- `boot` - FAT32 partition containing u-boot, Linux kernel and the device tree, the FPGA configuration file: top.core.rbf (for HPS boot first design variant)
- `root` - Linux EXT4 partition containing Linux root filesystem, which includes the Camera Solution software application

  Note for HPS boot first mode Yocto build uses a prebuilt FPGA configuration file top.core.rbf located in this folder under
  meta-vvp-isp-demo/recipes-bsp/u-boot/files

  If you have built the Camera Solution design yourself you can copy your FPGA RBF to this location before building the SD card or directly to the SD card's boot partition replacing the original file. Make sure you copy it under the original name: "top.core.rbf"