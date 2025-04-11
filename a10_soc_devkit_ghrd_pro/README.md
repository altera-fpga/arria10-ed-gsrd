# Arria 10 (A10) Golden Hardware Reference Design (GHRD)

The GHRD is part of the Golden System Reference Design (GSRD), which provides a complete solution, including exercising soft IP in the fabric, booting to U-Boot, then Linux, and running sample Linux applications.

Refer to the [Arria 10 SoC GSRD](https://www.rocketboards.org/foswiki/Documentation/Arria10SoCGSRD) for information about GSRD.

## Build Steps
1) Customize the GHRD settings in Makefile. Only necessary when the defaults are not suitable.
2) Generate the Quartus Project and source files.
   - Use target from [Supported Designs](#supported-designs)
3) Compile Quartus Project and generate the configuration file
   - $ `make sof` or $ `make all`

## Supported Designs
### Baseline
This design boots from SD/MMC.
```bash
make generate-a10-soc-devkit-sdmmc-baseline
```
### QSPI
This design boots from QSPI.
```bash
make generate-a10-soc-devkit-qspi-baseline
```
### NAND
This design boots from NAND.
```bash
make generate-a10-soc-devkit-nand-baseline
```
### PCIe
This design boots from SD/MMC and has PCIe RootPort IP.
```bash
make generate-a10-soc-devkit-sdmmc-pcie-gen2x8
```
### HPS Serial Gigabit Media Independent Interface (SGMII)
This design boots from SD/MMC and enabled SGMII with HPS EMAC and Triple-Speed Ethernet Intel FPGA IP (PHY).
```bash
make generate-a10-soc-devkit-sdmmc-sgmii
```

## GHRD Overview

### Hard Processor System (HPS)
The GHRD HPS configuration matches the board schematic. Refer to [Arria 10 Hard Processor System Technical Reference Manual](https://www.intel.com/content/www/us/en/docs/programmable/683711/latest) for more information on HPS configuration.

### HPS External Memory Interfaces (EMIF)
The GHRD HPS EMIF configuration matches the board schematic. Refer to
[External Memory Interfaces Arria 10 FPGA IP User Guide](https://www.intel.com/content/www/us/en/docs/programmable/683106/latest)
for more information on HPS EMIF configuration.

### HPS-to-FPGA Address Map
The memory map of soft IP peripherals, as viewed by the microprocessor unit (MPU) of the HPS, starts at HPS-to-FPGA base address of 0xC000_0000.

Refer to [Intel Arria 10 HPS Register Address Map and Definitions](https://www.intel.com/content/www/us/en/programmable/hps/arria-10/hps.html) for details.

| Peripheral | Address Offset | Size (bytes) | Attribute |
| :-- | :-- | :-- | :-- |
| ocm_0 | 0x0 | 256K | On-chip RAM as scratch pad |

### System peripherals
The memory map of system peripherals in the FPGA portion of the SoC as viewed by the MPU, which starts at the lightweight HPS-to-FPGA base address of 0xFF20_0000, is listed in the following table.

Note: All interrupt sources are also connected to an interrupt latency counter (ILC) module in the system, which enables System Console to be aware of the interrupt status of each peripheral in the FPGA portion of the SoC.

#### Lightweight HPS-to-FPGA Address Map for all designs
| Peripheral | Address Offset | Size (bytes) | Attribute | Interrupt Num |
| :-- | :-- | :-- | :-- | :-- |
| sysid | 0x0000_0000 | 8 | Unique system ID   | None |
| led_pio | 0x0000_0010 | 16 | 4 x LED outputs   | None |
| button_pio | 0x0000_0020 | 16 | 4 x Push button inputs | 1 |
| dipsw_pio | 0x0000_0030 | 16 | 4 x DIP switch inputs | 0 |
| ILC | 0x0000_0100 | 256 | Interrupt latency counter | None |

#### Lightweight HPS-to-FPGA Address Map for PCIe design
| Peripheral | Address Offset | Size (bytes) | Attribute | Interrupt Num |
| :-- | :-- | :-- | :-- | :-- |
| pcie_0 | 0x0001_0000 | 32K | CSR for PCIe Subsys | 2 |

#### Lightweight HPS-to-FPGA Address Map for SGMII design
| Peripheral | Address Offset | Size (bytes) | Attribute | Interrupt Num |
| :-- | :-- | :-- | :-- | :-- |
| sgmii_1_adapter | 0x0000_0240 | 8 | CSR for GMII to SGMII adapter | None |
| sgmii_1_pcs | 0x0000_0200 | 64 | CSR for ethernet controller | None |
| sgmii_2_adapter | 0x0000_0440 | 8 | CSR for GMII to SGMII adapter | None |
| sgmii_2_pcs | 0x0000_0400 | 64 | CSR for ethernet controller | None |

### JTAG master interfaces
The GHRD JTAG master interfaces allows you to access peripherals in the FPGA with System Console, through the JTAG master module. This access does not rely on HPS software drivers.

Refer to this [Guide](https://www.intel.com/content/www/us/en/docs/programmable/683819/current/analyzing-and-debugging-designs-with-84752.html) for information about system console.

### Interrupt Num
The Interrupt Num in this readme are FPGA IRQ. offset of 19 when mapped to Generic Interrupt Controller (GIC) in device tree structure(dts). Refer to F2S_FPGA_IRQ0 in [GIC Interrupt Map for the Arria 10 SoC HPS](https://www.intel.com/content/www/us/en/docs/programmable/683711/current/gic-interrupt-map-for-the-arria-10-soc-hps.html).
Number 51 is shown for F2H FPGA Interrupt[0] as the first 32 IRQ is reserved. (51 - 32 = 19).

## Binaries location
After build, the design files (sof and rbf) can be found in output_files folder.
