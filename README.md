# 4Kp60 Multi-Sensor HDR Camera Solution Reference Design for Agilex™ 5 Devices - Repository

## Overview

This repository contains the necessary files and collateral to create and build
the 4Kp60 Multi-Sensor HDR Camera Solution Reference Design.

The products of this repository are generated using both a Software and
Hardware flow, and are:

| Product | Type | Description |
|----|----|----|
| `.sof` | SRAM Object File | FPGA bitstream to be loadeded over JTAG |
| `.rbf` | Raw Binary File | FPGA bitstream file to be loaded from the microSD Card |
| `.jic` | JTAG Indirect Configuration File | QSPI Flash programming file for booting from microSD Card |
| `.wiz.gz` | Image File | microSD Card Image file containing the Linux embedded system and Camera Software Application |

<br>

### License Requirements

The Reference Design supports the OpenCore Plus (OCP) evaluation license. The
resulting `.sof` can be tested on Hardware using both the time limited and JTAG
tethered features of the license.

Alternatively, full licenses for the VVP IP Suite, VVP Tone Mapping Operator
(TMO) IP, VVP Warp IP, and 3D LUT IP are required to produce a `.jic` and
`.rbf` for a Hardware, SD Card turnkey solution.

Note that for all cases, free licenses for MIPI D-Phy IP, MIPI CSI-2 IP, and
Nios® V Processor must be downloaded and installed.

Additional licensing information can be found here:

* [VVP IP Suite (including VVP TMO IP, VVP Warp IP, and VVP 3D LUT IP](https://www.intel.com/content/www/us/en/products/details/fpga/intellectual-property/dsp/video-vision-processing-suite.html)
* [MIPI IP](https://www.intel.com/content/www/us/en/products/details/fpga/intellectual-property/interface-protocols/mipi-d-phy.html#tab-blade-1-3)
* [Nios® V Processor](https://www.intel.com/content/www/us/en/products/details/fpga/intellectual-property/processors-peripherals/niosv/glossy.html)

<br>


## Software Flow

The [**Software flow**](./sw/README.md#4kp60-multi-sensor-hdr-camera-solution-reference-design-for-agilex-5-devices)
generates the appropriate microSD Card Image based on your license and solution
requirements.

<br>

## Hardware Flow

The Hardware flow uses the Modular Design Toolkit (MDT) to create and build the
Quartus® project for the 4Kp60 Multi-Sensor HDR Camera Solution Reference
Design.
<br>

### Software Requirements

The MDT requires the following Linux versions of software tools:

* Quartus® Prime Pro 25.1 with Agilex™ 5 E-Series support.
* Nios® V Open-Source Tools 25.1 (installed with Quartus® Prime).
<br>

### Creating and compiling the 4Kp60 Multi-Sensor HDR Camera Solution Reference Design

#### Create the design using the Modular Design Toolkit (MDT)

Follow the next steps to create the Quartus® and Platform Designer Project for
the 4Kp60 Multi-Sensor HDR Camera Solution Reference Design:

* Create your workspace and clone the repository using `--recurse-submodules`:

```bash
cd <workspace> 
git clone -b <TAG> --recurse-submodules https://github.com/altera-fpga/agilex-ed-camera.git agilex-ed-camera
```

* Define a `./<project>` location of your choice, creating directory structure
where necessary.
* Navigate to the `agilex-camera` directory containing the cloned
repository and create your project, selecting the XML variant based on your
license and solution requirements:

```bash
# SOF MDT Flow
cd agilex-ed-camera/AGX_5E_Altera_Modular_Dk_ISP_designs
quartus_sh -t ./modular-design-toolkit/scripts/create/create_shell.tcl -proj_path <project> -proj_name agilex5_modkit_vvpisp -xml_path ./AGX_5E_Altera_Modular_Dk_ISP_designs/AGX_5E_Modular_Devkit_ISP_FF_RD.xml
```

```bash
# RBF MDT Flow (not supported with OCP evaluation license)
cd agilex-ed-camera/AGX_5E_Altera_Modular_Dk_ISP_designs
quartus_sh -t ./modular-design-toolkit/scripts/create/create_shell.tcl -proj_path <project> -proj_name agilex5_modkit_vvpisp -xml_path ./AGX_5E_Altera_Modular_Dk_ISP_designs/AGX_5E_Modular_Devkit_ISP_RD.xml
```

This will create your Quartus® Prime and Platform Designer Project in
 `./<project>`. The folder structure is consistent with the MDT methodology.
<br>

#### Building the design using the Modular Design Toolkit (MDT)

Follow the next steps to build the 4Kp60 Multi-Sensor HDR Camera Solution
Reference Design:

* Navigate to the `./<project>/scripts` directory and build your project,
selecting the post processing step option for your chosen MDT flow:

```bash
cd ./<project>/scripts 
# SOF MDT Flow
quartus_sh -t build_shell.tcl -update_ocs -full_compile -ff_post_agx5e
```

```bash
cd ./<project>/scripts 
# RBF MDT Flow (not supported with OCP evaluation license)
quartus_sh -t build_shell.tcl -update_ocs -full_compile -hps_post_agx5e
```

The MDT build options (all of which are needed for a working build):

* `-update_ocs` is used to generate the automatic Offset Capability Structure
(OCS) ROM, which will be built into the project during compilation.
* `-full_compile` performs not just the full Quartus compilation, but also
compiles any Nios® V software into `.hex` ROM files built into the project
during compilation.
* `-ff_post_agx5e` option post processes the FPGA First `.sof` with a first
stage bootloader from a U-Boot secondary program loader binary file
`u-boot-spl-dtb_ff.hex`.
* `-hps_post_agx5e` option post processes the HPS first `.sof` with a U-Boot
secondary program loader binary file `u-boot-spl-dtb.hex`.

<br>

The FPGA programming file/s are located in the
`./<project>/quartus/output_files` directory and will differ depending on the
MDT flow used:

* For SOF MDT Flow:
  * `fsbl_agilex5_modkit_vvpisp_time_limited.sof`
* For RBF MDT Flow:
  * `agilex5_modkit_vvpisp.hps_first.hps.jic` and
`agilex5_modkit_vvpisp.hps_first.core.rbf`.

<br>

## Running the 4Kp60 Multi-Sensor HDR Camera Solution Reference Design

### Hardware Requirements

The following equipment is needed to test the 4Kp60 Multi-Sensor HDR Camera
Solution Reference Design on hardware:

* [Agilex™ 5 FPGA E-Series 065B Modular Development Kit](https://www.intel.com/content/www/us/en/products/details/fpga/development-kits/agilex/a5e065b-modular.html).
* 1 or 2 [Framos FSM:GO IMX678C Camera Modules](https://www.framos.com/en/fsmgo), with either:
  * [Wide 110deg HFOV (Horizontal Field of View) Lens](https://www.mouser.co.uk/ProductDetail/FRAMOS/FSMGO-IMX678C-M12-L110A-PM-A1Q1?qs=%252BHhoWzUJg4KQkNyKsCEDHw%3D%3D).
  * [Medium 100deg HFOV Lens](https://www.mouser.co.uk/ProductDetail/FRAMOS/FSMGO-IMX678C-M12-L100A-PM-A1Q1?qs=%252BHhoWzUJg4IesSwD2ACIBQ%3D%3D).
  * [Narrow 54deg HFOV Lens](https://www.mouser.co.uk/ProductDetail/FRAMOS/FSMGO-IMX678C-M12-L54A-PM-A1Q1?qs=%252BHhoWzUJg4L5yHZulKgVGA%3D%3D).
* Mount/Tripod
  * [Framos Tripod Mount Adapter](https://www.framos.com/en/products/fma-mnt-trp1-4-v1c-26333).
  * [Tripod](https://thepihut.com/products/small-tripod-for-raspberry-pi-hq-camera).
* A Framos cable for PixelMate MIPI-CSI-2 for each Camera Module.
  * [150mm flex-cable](https://www.mouser.co.uk/ProductDetail/FRAMOS/FMA-FC-150-60-V1A?qs=GedFDFLaBXGCmWApKt5QIQ%3D%3D&_gl=1*d93qim*_ga*MTkyOTE4MjMxNy4xNzQxMTcwMzQy*_ga_15W4STQT4T*MTc0MTE3MDM0Mi4xLjEuMTc0MTE3MDQ5OS40NS4wLjA.), or
  * [300mm micro-coax cable](https://www.mouser.co.uk/ProductDetail/FRAMOS/FFA-MC50-Kit-0.3m?qs=%252BHhoWzUJg4K3LtaE207mhw%3D%3D).
* Minimum 8GB U3 micro SD Card.
* DP Cable or HDMI Cable with [4Kp60 Coverter Dongle](https://www.amazon.co.uk/gp/product/B01M6WK3KU/ref=ppx_yo_dt_b_asin_title_o02_s00?ie=UTF8&psc=1).
* USB Micro B JTAG Cable.
* USB Micro B Serial Cable.
* RJ45 Ethernet Cable.
* 4Kp60 Monitor/TV.

<br>

In addition, the following Software tools might be useful:

  * [Quartus® Prime Pro Edition Programmer and Tools 25.1](https://www.intel.com/content/www/us/en/software-kit/851653/intel-quartus-prime-pro-edition-design-software-version-25-1-for-windows.html) Standalone.
  * [SD Card Formatter](https://www.sdcard.org/downloads/formatter/).
  * SD Card Imager such as [Win32DiskImager](https://win32diskimager.org/).
  * [Teraterm](https://download.cnet.com/tera-term/3000-2094_4-75766675.html?ex=RAMP-2012.3) or [Putty](https://www.putty.org/) for serial connection.
  * Web browser (i.e. Chrome) for Webserver connection.
<br>

<br>

### Hardware Setup

Ensure you Modular development board have these default switch settings (note
that the SOM is the mezzanine board):

| Switch | Board | Position |
|----|----|----|
| S4 | SOM | OFF-OFF |
| S1 | SOM | ON-ON |
| S7 | Carrier | OFF-OFF-OFF-ON |
| S13 | Carrier | OFF-OFF-ON-OFF |
| S1 | Carrier | OFF-OFF-OFF-OFF |
| S5 | Carrier | OFF-OFF-OFF-OFF |
| S2 | Carrier | OFF-OFF-OFF-OFF |
| S11 | Carrier (underside) | OFF-OFF-OFF-OFF |
| S6 | Carrier (underside) | OFF-OFF-OFF-OFF |
| S4 | Carrier | OFF |
<br>

Make the following connections on the board:
* Micro USB cable (carrier board J35) to Host PC
* Micro USB cable (SOM board J2 - HSP_UART) to Host PC
* RJ45 cable (ethernet port on the SOM board J6 - ETH 1G HPS) to Host PC
* Framos cable to Framos Camera Modules (ensure pin 1 aligns to pin 1)
* Display Port cable to Monitor (via HDMI converter dongle if using HDMI)

<br>

Burn your generated microSD Card image and insert it into the microSD Card slot
located on the SOM board. Ensure you are using the correct image for your
license and solution requirements and that it matches the Hardware Flow used.

<br>

If you are using the `.rbf` with full license flow, then you must program the
QSPI Flash which should only need to be done once: (skip this step if you are
using the `.sof` with OCP license flow)
* Power down the board.
* Set S4 on the SOM to OFF-OFF.
* Power up the board.
* Use the following command:

```bash
quartus_pgm -c 1 -m jtag -o "pvi;agilex5_modkit_vvpisp.hps_first.hps.jic"
```
* Alternatively use the Quartus® Programmer GUI
  * Configure the JTAG Hardware by selecting the boards byteBlaster hardware.
    The Hardware Frequency should be 24MHz.
  * Auto Detect and select the `A5EC065BB32AR0` device.
  * **Change File** and select `agilex5_modkit_vvpisp.hps_first.hps.jic`. The
    `MT25QU02G` device should be shown.
  * Check the **Program/Configure** box and press **Start** and wait until it
    completes (note that it can take several minutes).
* Power down the board.
* Set S4 on the SOM to ON-ON (enables booting from the microSD Card).

<br>

Power up the board and select the correct COMx port. Set up the serial terminal
emulator using 115200 baud rate, 8 Data bits, 1 Stop bit, CRC and Hardware flow
control disabled.

<br>

If you are using the `.sof` with OCP license flow, then you must program the
`.sof`: (skip this step is you are using the `.rbf` with full license flow)

* If S4 on the SOM is **NOT** set to OFF-OFF, follow these additional steps:
  * Power down the board
  * Set S4 on the SOM to OFF-OFF.
    (This prevents the starting of any bootloader and FPGA configuration after
    power up and until the SOF is programmed over JTAG).
  * Power up the board.
* Use the following command:

```bash
quartus_pgm -c 1 -m jtag -o "p;fsbl_agilex5_modkit_vvpisp_time_limited.sof"
```
* Alternatively use the Quartus® Programmer GUI
  * Configure the JTAG Hardware by selecting the boards byteBlaster hardware.
    The Hardware Frequency should be 24MHz.
  * Auto Detect and select the `A5EC065BB32AR0` device.
  * **Change File** and select `fsbl_agilex5_modkit_vvpisp_time_limited.sof`.
  * Check the **Program/Configure** box and press **Start** and wait until it completes.

<br>

The Linux OS will boot and the 4K Multi-Sensor HDR Camera Solution Reference
Design Application should run automatically. A few seconds after Linux boots,
the application will detect the attached Monitor and the ISP processed output
will be displayed using the best supported format. Take note of the board's IP
address during boot. Connect your web browser to the boards IP address so you
can interact with the 4K Multi-Sensor HDR Camera Solution Reference Design
using the GUI.

Note that the boards IP address can also be found by using the terminal,
logging in as `root` (no password required), and querying the Ethernet
controller:

```bash
root
ip a
```

`eth0` provides the IPv4 or IPv6 address to connect your web browser to.
Examples of web browser URLs are `http://192.168.0.1` for IPv4, and
`http://[fe80::a8bb:ccff:fe55:6688]` for IPv6 (note the square brackets).

