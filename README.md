# Arria 10 Baseline Hardware Reference Designs

This repository contains Baseline Hardware Reference Designs for Altera Arria 10 System On Chip (SoC) FPGA.
This repository is part of the Baseline System Example Design, which provides a complete solution, including exercising soft IP in the fabric, booting to U-Boot, then Linux, and running sample Linux applications.

Refer to the [HPS Baseline System Example Design User Guide: Arria 10 SoC Development Kit](https://www.rocketboards.org/foswiki/Documentation/Arria10SoCGSRD) for more information.

These reference designs demonstrate the system integration between Hard Processor System (HPS) and FPGA IPs.
## Baseline feature
This is applicable to all designs.
- Hard Processor System (HPS) enablement and configuration
  - HPS Peripheral and I/O (eg, NAND, SD/MMC, EMAC, USB, SPI, I2C, UART, and GPIO)
  - HPS Clock and Reset
  - HPS FPGA Bridge and Interrupt
- HPS EMIF configuration
- System integration with FPGA IPs
  - SYSID
  - Programmable I/O (PIO) IP for controlling DIPSW, PushButton, and LEDs)
  - FPGA On-Chip Memory
## Advanced feature
This is only applicable if the feature is enabled.
  - PCIe RootPort IP
  - SGMII with HPS EMAC and Triple-Speed Ethernet FPGA IP (PHY)

## Dependency
* Altera Quartus Prime 26.3
* Supported Board
  - Arria 10 SoC Development Kit

## Tested platform for the hardware build flow
* SUSE Linux Enterprise Server 15 SP4

## Supported Designs
### Baseline
This design boots from SD/MMC.
```bash
make a10-soc-devkit-sdmmc-baseline-all
```
### QSPI
This design boots from QSPI.
```bash
make a10-soc-devkit-qspi-baseline-all
```
### NAND
This design boots from NAND.
```bash
make a10-soc-devkit-nand-baseline-all
```
### PCIe
This design boots from SD/MMC and has PCIe RootPort IP.
```bash
make a10-soc-devkit-sdmmc-pcie-gen2x8-all
```
### HPS Serial Gigabit Media Independent Interface (SGMII)
This design boots from SD/MMC and enabled SGMII with HPS EMAC and Triple-Speed Ethernet FPGA IP (PHY).
```bash
make a10-soc-devkit-sdmmc-sgmii-all
```

## Install location
After build, the design files (zip, sof and rbf) can be found in install/designs folder.
