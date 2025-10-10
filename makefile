##################################################################################################
# Copyright (c) 2022-2023, Laboratorio de Microprocesadores
# Facultad de Ciencias Exactas y Tecnología, Universidad Nacional de Tucumán
# https://www.microprocesadores.unt.edu.ar/
#
# Copyright (c) 2022-2023, Esteban Volentini <evolentini@herrera.unt.edu.ar>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute,
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial
# portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
# OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# SPDX-License-Identifier: MIT
##################################################################################################

DEFINES += USE_DRIVERS

MODULES := core-rv32 nuclei-n200 gd32vf103/device gd32vf103/drivers

BOARD := edu-unt-rv
MCU := gd32vf103cbt6

-include proyecto.mk

include modules/gmsl/gmsl
include modules/gd32vf103/makefile
include modules/nuclei-n200/makefile
include modules/core-rv32/makefile

##################################################################################################
# Defintion of project name based on project paths if it was not defined in
# project makefile, used to define binary file and default target
ifneq ($(PROYECTO), )
    -include $(PROYECTO)/makefile
    PROJECT_NAME ?= $(lastword $(subst /, , $(PROYECTO)))
    PROJECT_DIR = $(abspath $(PROYECTO))
else
    PROYECTO = .
    PROJECT_NAME ?= $(lastword $(subst /, , $(CURDIR)))
    PROJECT_DIR = $(PROYECTO)
endif

##################################################################################################
# Function to generate the full path of directory
define full_path
$(strip $1)
endef

##################################################################################################
# Function to generate the short path of directory
define short_path
$(strip $1)
endef

##################################################################################################
# Function to display info messages when dynamic rules are generated
define show_message
$(if $(findstring Y,$(call uc,$(VERBOSE))),$(info $1))
endef

##################################################################################################
# Function to display info messages when rules are executed
define show_action
$(strip \
    $(if $(findstring Y,$(call uc,$(VERBOSE))),\
        @echo $(DIVISION_LINE), \
        @echo $1 \
    )
)
endef

##################################################################################################
# Variable to separate every comand when execution rules are show
DIVISION_LINE = ===============================================================================

##################################################################################################
# Variable to show or hide command lines when rules are executed
ifeq ($(call uc,$(VERBOSE)),Y)
    QUIET =
else
    QUIET = @
endif

##################################################################################################
# Function to generate the compilation parameters with the list of include paths
define include_directories
$(strip \
    $(foreach path,$(sort $1 $(PROJECT_INC)),-I $(call full_path,$(path)))
)
endef

##################################################################################################
# Function to generate the compilation parameters with the list of include paths
define defines_list
$(strip \
    $(foreach define,$(DEFINES),-D $(define))
)
endef

##################################################################################################
# Function to generate defines from make variable
define convert_defines
$(strip \
    $(foreach word,$1,$(subst -,_,$(call uc,$(word))))
)
endef


##################################################################################################
# Function to generate the list of object files from a path list
define objects_list
$(strip \
    $(foreach path,$1,
        $(eval SOURCE_DIR = $(call full_path,$(path))) \
        $(eval OBJECT_DIR = $(OBJ_DIR)/$(call short_path,$(path))) \
        $(patsubst $(SOURCE_DIR)/%.$2,$(OBJECT_DIR)/%.o,$(wildcard $(SOURCE_DIR)/*.$2)) \
    )
)
endef

##################################################################################################
# Dynamic rule to compile single folder with c source files
define c_compiler_rule
    $(call show_message,Definiendo regla de compilacion para $1/*.c en $3)
$3/%.o: $(call full_path,$1)/%.c
	$$(call show_action,Compiling $$(call short_path,$$<))
	-@mkdir -p $$(@D)
	$$(QUIET) $$(CC) $$(strip $$(CFLAGS) $$(call defines_list) $$(call include_directories,$2)) -MMD -c $$< -o $$@
endef

##################################################################################################
# Dynamic rule to compile single folder with s source files
define assembler_rule
    $(call show_message,Definiendo regla de compilacion para $1/*.s en $3)
$3/%.o: $(call full_path,$1)/%.s
	$$(call show_action,Compiling $$(call short_path,$$<))
	-@mkdir -p $$(@D)
	$$(QUIET) $$(CC) $$(strip $$(AFLAGS) $$(call defines_list) $$(call include_directories,$2)) -MMD -c $$< -o $$@
endef

##################################################################################################
# Definition of directories variables
# out dir
# BUILD_DIR = $(PROJECT_DIR)/build
BUILD_DIR ?= build
# object dir
OBJ_DIR = $(BUILD_DIR)/obj
# lib dir
LIB_DIR = $(BUILD_DIR)/lib
# bin dir
BIN_DIR = $(BUILD_DIR)/bin
# rtos gen dir
GEN_DIR = $(BUILD_DIR)/gen
# etc dir (configuration dir)
ETC_DIR = $(BUILD_DIR)/etc

##################################################################################################
#
RTOS ?= BAREMETAL

export BOARD
export CPU
export SOC
export MCU
export RTOS

DEFINES += BOARD=$(BOARD)  MCU=$(MCU) SOC=$(SOC) CPU=$(CPU) ARCH=$(ARCH) RTOS=$(RTOS)
DEFINES += $(call convert_defines, $(BOARD) $(SOC) $(MCU) $(CPU) $(ARCH) $(RTOS))

##################################################################################################
#
TARGET_NAME ?= $(BIN_DIR)/$(PROJECT_NAME)
TARGET_ELF = $(TARGET_NAME).$(LD_EXTENSION)

PROJECT_SRC := $(PROYECTO) $(PROYECTO)/src $(foreach path,$(MODULES),modules/$(path)/src)
PROJECT_INC := $(PROYECTO) $(PROYECTO)/inc $(foreach path,$(MODULES),modules/$(path)/inc)

##################################################################################################
#
PROJECT_OBJ += $(call objects_list,$(PROJECT_SRC),c)
$(foreach path,$(PROJECT_SRC),$(eval $(call c_compiler_rule,$(path),$($1_INC),$(OBJ_DIR)/$(call short_path,$(path)))))

PROJECT_OBJ += $(call objects_list,$(PROJECT_SRC),s)
$(foreach path,$(PROJECT_SRC),$(eval $(call assembler_rule,$(path),$($1_INC),$(OBJ_DIR)/$(call short_path,$(path)))))

# Load project compile dependencies if present (must be placed after PROJECT_OBJ is completely defined)
-include $(patsubst %.o,%.d,$(PROJECT_OBJ))

##################################################################################################
$(TARGET_ELF): $(PROJECT_LIB) $(PROJECT_OBJ)
	$(call show_action,Linking $(call short_path,$(TARGET_ELF)))
	-@mkdir -p $(BIN_DIR)
	$(QUIET) $(CC) $(strip $(LFLAGS) $(PROJECT_OBJ) $(LFLAGS_BEGIN_LIBS) $(PROJECT_LIB) $(LFLAGS_END_LIBS)) -o $(TARGET_ELF)
	-@cp -f $(TARGET_ELF) $(BIN_DIR)/project.$(LD_EXTENSION)
	$(QUIET) $(OD) $(TARGET_ELF) -xS > $(TARGET_NAME).s

.DEFAULT_GOAL := all

all: $(TARGET_ELF) $(POST_BUILD_TARGET)

##################################################################################################
#
clean:
	-@rm -r $(BUILD_DIR)

gdbserver:
ifeq ($(GDB_SERVER),)
	$(error Flash write operation is not available for the board $(BOARD))
else
	$(QUIET) $(GDB_SERVER) $(GDB_SERVER_FLAGS)
endif

download: $(TARGET_ELF)
ifeq ($(FLASH_WRITER),)
	$(error Flash write operation is not available for the board $(BOARD))
else
	$(FLASH_WRITER) $(FLASH_WRITER_FLAGS) $(FLASH_WRITER_COMMANDS)
endif

##################################################################################################
#
info:
	@echo $(DIVISION_LINE)
	@echo Nombre del proyecto: $(PROJECT_NAME)
	@echo Ruta definida para el proyecto: $(PROJECT)
	@echo Ruta absoluta del Proyecto: $(PROJECT_DIR)
	@echo Binario final: $(TARGET_ELF)
	@echo -------------------------------------------------------------------------------
	@echo Modulos: $(MODULES)
	@echo Board: $(BOARD), Arch: $(ARCH), Cpu: $(CPU), Soc: $(SOC), Mcu: $(MCU)
	@echo -------------------------------------------------------------------------------
	@echo Fuentes: $(PROJECT_SRC)
	@echo Cabeceras: $(PROJECT_INC)
	@echo -------------------------------------------------------------------------------
	@echo Compilador: $(CC)
	@echo Flags Compilador: $(CFLAGS)
	@echo Flags Ensamblador: $(AFLAGS)
	@echo Flags Enlazador: $(LFLAGS)
	@echo Debug Server: $(GDB_SERVER)
	@echo -------------------------------------------------------------------------------
	@echo Objetos: $(PROJECT_OBJ)
	@echo -------------------------------------------------------------------------------
	@echo Definciones: $(DEFINES)
