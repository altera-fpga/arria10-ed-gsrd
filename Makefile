THIS_MK_ABSPATH := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_MK_DIR := $(dir $(THIS_MK_ABSPATH))

# Enable pipefail for all commands
SHELL=/bin/bash -o pipefail

# Enable second expansion
.SECONDEXPANSION:

# Clear all built in suffixes
.SUFFIXES:

NOOP :=
SPACE := $(NOOP) $(NOOP)
COMMA := ,
HOSTNAME := $(shell hostname)

##############################################################################
# Environment check
##############################################################################


##############################################################################
# Configuration
##############################################################################
WORK_ROOT := $(abspath $(THIS_MK_DIR)/work)
INSTALL_RELATIVE_ROOT ?= install
INSTALL_ROOT ?= $(abspath $(THIS_MK_DIR)/$(INSTALL_RELATIVE_ROOT))

PYTHON3 ?= python3
VENV_DIR := venv
VENV_PY := $(VENV_DIR)/bin/python
VENV_PIP := $(VENV_DIR)/bin/pip
ifneq ($(https_proxy),)
PIP_PROXY := --proxy $(https_proxy)
else
PIP_PROXY :=
endif
VENV_PIP_INSTALL := $(VENV_PIP) install $(PIP_PROXY) --timeout 90 --trusted-host pypi.org --trusted-host files.pythonhosted.org

##############################################################################
# Set default goal before any targets. The default goal here is "test"
##############################################################################
DEFAULT_TARGET := help

.DEFAULT_GOAL := default
.PHONY: default
default: $(DEFAULT_TARGET)


##############################################################################
# Makefile starts here
##############################################################################


###############################################################################
#                          Design Targets
###############################################################################
%/output_files:
	mkdir -p $@

$(INSTALL_ROOT) $(INSTALL_ROOT)/designs $(INSTALL_ROOT)/not_shipped:
	mkdir -p $@

# Initialize variables
ALL_TARGET_STEM_NAMES =
ALL_TARGET_ALL_NAMES =

# Define function to create targets
# create_legacy_ghrd_target
# $(1) - Base directory name. i.e. a10_soc_devkit_ghrd_pro
# $(2) - Target name. i.e. a10-soc-devkit-sdmmc-baseline. Format is <devkit>-<daughter_card>-<name>
# $(3) - Revision name. i.e. ghrd_10as066n2
# $(4) - Config target. i.e. generate-a10-soc-devkit-sdmmc-baseline
# $(5) - Install location. i.e. $(INSTALL_ROOT)/designs
define create_legacy_ghrd_target
ALL_TARGET_STEM_NAMES += $(strip $(2))
ALL_TARGET_ALL_NAMES += $(strip $(2))-all

.PHONY: $(strip $(2))-prep
$(strip $(2))-prep: | $(strip $(1))/output_files
	cd $(strip $(1)) && quartus_ipgenerate $(strip $(3)) -c $(strip $(3)) --synthesis=verilog

.PHONY: $(strip $(2))-generate-design
$(strip $(2))-generate-design: prepare-tools | $(strip $(1))/output_files
	$(MAKE) -C $(strip $(1)) $(strip $(4))

.PHONY: $(strip $(2))-package-design
$(strip $(2))-package-design: | $(strip $(5))
	cd $(strip $(1)) && zip -r $(strip $(5))/$(subst -,_,$(strip $(2))).zip * -x .gitignore "output_files/*" "qdb/*" "dni/*" "tmp-clearbox/*"

.PHONY: $(strip $(2))-build
$(strip $(2))-build: | $(strip $(1))/output_files
	cd $(strip $(1)) && quartus_syn $(strip $(3))
	cd $(strip $(1)) && quartus_fit $(strip $(3))
	cd $(strip $(1)) && quartus_asm $(strip $(3))
	cd $(strip $(1)) && quartus_sta $(strip $(3)) --mode=finalize

.PHONY: $(strip $(2))-sw-build
$(strip $(2))-sw-build:

.PHONY: $(strip $(2))-test
$(strip $(2))-test:

.PHONY: $(strip $(2))-install-sof
$(strip $(2))-install-sof: | $(strip $(5))
	cp -f $(strip $(1))/output_files/$(strip $(3)).sof $(strip $(5))/$(subst -,_,$(strip $(2))).sof


.PHONY: $(strip $(2))-all
$(strip $(2))-all:
	$(MAKE) $(strip $(2))-generate-design
	$(MAKE) $(strip $(2))-package-design
	$(MAKE) $(strip $(2))-prep
	$(MAKE) $(strip $(2))-build
	$(MAKE) $(strip $(2))-sw-build
	$(MAKE) $(strip $(2))-test
	$(MAKE) $(strip $(2))-install-sof

endef

# Create the recipes by calling create_ghrd_target on each design
# Arria 10
$(eval $(call create_legacy_ghrd_target, a10_soc_devkit_ghrd_pro, a10-soc-devkit-sdmmc-baseline, ghrd_10as066n2, generate-a10-soc-devkit-sdmmc-baseline, $(INSTALL_ROOT)/designs))
$(eval $(call create_legacy_ghrd_target, a10_soc_devkit_ghrd_pro, a10-soc-devkit-qspi-baseline, ghrd_10as066n2, generate-a10-soc-devkit-qspi-baseline, $(INSTALL_ROOT)/designs))
$(eval $(call create_legacy_ghrd_target, a10_soc_devkit_ghrd_pro, a10-soc-devkit-nand-baseline, ghrd_10as066n2, generate-a10-soc-devkit-nand-baseline, $(INSTALL_ROOT)/designs))
$(eval $(call create_legacy_ghrd_target, a10_soc_devkit_ghrd_pro, a10-soc-devkit-sdmmc-pcie-gen2x8, ghrd_10as066n2, generate-a10-soc-devkit-sdmmc-pcie-gen2x8, $(INSTALL_ROOT)/designs))
$(eval $(call create_legacy_ghrd_target, a10_soc_devkit_ghrd_pro, a10-soc-devkit-sdmmc-sgmii, ghrd_10as066n2, generate-a10-soc-devkit-sdmmc-sgmii, $(INSTALL_ROOT)/designs))

###############################################################################
#                          UTILITY TARGETS
###############################################################################
# Deep clean using git
.PHONY: dev-clean
dev-clean :
	git clean -dfx --exclude=/.vscode --exclude=.lfsconfig

# Using git
.PHONY: dev-update
dev-update :
	git pull
	git submodule update --init --recursive

.PHONY: clean
clean:
	git clean -dfx --exclude=/.vscode --exclude=.lfsconfig --exclude=$(VENV_DIR)

# Prep workspace
venv:
	$(PYTHON3) -m venv $(VENV_DIR)
	$(VENV_PIP_INSTALL) --upgrade pip
	$(VENV_PIP_INSTALL) -r requirements.txt


.PHONY: venv-freeze
venv-freeze:
	$(VENV_PIP) freeze > requirements.txt
	sed -i -e 's/==/~=/g' requirements.txt

.PHONY: prepare-tools
prepare-tools : venv

###############################################################################
#                          Toplevel Targets
###############################################################################

.PHONY: prep
prep: prepare-tools

.PHONY: pre-prep
pre-prep:

.PHONY: package-designs
package-designs: $(addsuffix -package-designs,$(ALL_TARGET_STEM_NAMES))


###############################################################################
#                          SW Targets
###############################################################################


###############################################################################
#                   Insert Core and Peripheral RBF
###############################################################################
# $(1) - Base directory name. i.e. a10_soc_devkit_ghrd_pro
# $(2) - Target name. i.e. a10-soc-devkit-baseline. Format is <devkit>-<daughter_card>-<name>
# $(3) - Revision name. i.e. ghrd_10as066n2
# $(4) - Core RBF basename suffix i.e. core
# $(5) - Peripheral RBF basename suffix i.e. periph
# $(6) - Install location. i.e. $(INSTALL_ROOT)/designs
define create_core_periph_rbf_target

$(strip $(2))-build-rbf : | $(strip $(1))/output_files
	quartus_cpf --convert --hps -o bitstream_compression=on $(strip $(1))/output_files/$(strip $(3)).sof $(strip $(1))/output_files/$(strip $(3)).rbf

$(strip $(2))-$(strip $(3))-install-rbf : $(strip $(2))-build-rbf | $(strip $(1))/output_files $(strip $(1))/hps_isw_handoff $(INSTALL_ROOT)
	cp -f $(strip $(1))/output_files/$(strip $(3)).$(strip $(4)).rbf $(strip $(6))/$(subst -,_,$(strip $(2)))_$(strip $(4)).rbf
	cp -f $(strip $(1))/output_files/$(strip $(3)).$(strip $(5)).rbf $(strip $(6))/$(subst -,_,$(strip $(2)))_$(strip $(5)).rbf
	cp -f -r $(strip $(1))/hps_isw_handoff $(strip $(6))/$(subst -,_,$(strip $(2)))_hps_isw_handoff

# Link the core and peripheral RBF to the base SOF install recipe
$(strip $(2))-install-sof : $(strip $(2))-$(strip $(3))-install-rbf

endef

# Create Core and Periph RBF target
$(eval $(call create_core_periph_rbf_target, a10_soc_devkit_ghrd_pro, a10-soc-devkit-sdmmc-baseline, ghrd_10as066n2, core, periph, $(INSTALL_ROOT)/designs))
$(eval $(call create_core_periph_rbf_target, a10_soc_devkit_ghrd_pro, a10-soc-devkit-qspi-baseline, ghrd_10as066n2, core, periph, $(INSTALL_ROOT)/designs))
$(eval $(call create_core_periph_rbf_target, a10_soc_devkit_ghrd_pro, a10-soc-devkit-nand-baseline, ghrd_10as066n2, core, periph, $(INSTALL_ROOT)/designs))
$(eval $(call create_core_periph_rbf_target, a10_soc_devkit_ghrd_pro, a10-soc-devkit-sdmmc-pcie-gen2x8, ghrd_10as066n2, core, periph, $(INSTALL_ROOT)/designs))
$(eval $(call create_core_periph_rbf_target, a10_soc_devkit_ghrd_pro, a10-soc-devkit-sdmmc-sgmii, ghrd_10as066n2, core, periph, $(INSTALL_ROOT)/designs))

# Include not_shipped Makefile if present
-include not_shipped/Makefile.mk

###############################################################################
#                                HELP
###############################################################################
.PHONY: help
help:
	$(info GHRD Build)
	$(info ----------------)
	$(info ALL Targets         : $(ALL_TARGET_ALL_NAMES))
	$(info Stem names          : $(ALL_TARGET_STEM_NAMES))
