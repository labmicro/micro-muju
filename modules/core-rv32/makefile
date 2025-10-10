##################################################################################################
# Copyright (c) 2022-2024, Laboratorio de Microprocesadores
# Facultad de Ciencias Exactas y Tecnología, Universidad Nacional de Tucumán
# https://www.microprocesadores.unt.edu.ar/
#
# Copyright (c) 2022-2024, Esteban Volentini <evolentini@herrera.unt.edu.ar>
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

##################################################################################################
# Toolchain settings

OPENOCD_LOCATION ?= ~/.local/xPacks/@xpack-dev-tools/openocd/0.12.0-6.1/.content/bin/
ifeq ("$(wildcard $(OPENOCD_LOCATION)openocd)","")
    OPENOCD_LOCATION :=
endif

TOOLCHAIN_PREFIX ?= riscv-none-elf-
TOOLCHAIN_LOCATION ?= ~/.local/xPacks/@xpack-dev-tools/riscv-none-elf-gcc/14.2.0-3.1/.content/bin/
ifeq ("$(wildcard $(TOOLCHAIN_LOCATION)$(TOOLCHAIN_PREFIX)gcc)","")
    TOOLCHAIN_PREFIX := riscv64-unknown-elf-
    TOOLCHAIN_LOCATION :=
endif

##################################################################################################
# Toolchain commands
# Preprocesor command
PP = $(TOOLCHAIN_LOCATION)$(TOOLCHAIN_PREFIX)gcc
# C compiler command
CC = $(TOOLCHAIN_LOCATION)$(TOOLCHAIN_PREFIX)gcc
# Library builder command
AR = $(TOOLCHAIN_LOCATION)$(TOOLCHAIN_PREFIX)ar
# Linker command
LD = $(TOOLCHAIN_LOCATION)$(TOOLCHAIN_PREFIX)gcc
# Assembler command
AS = $(TOOLCHAIN_LOCATION)$(TOOLCHAIN_PREFIX)as
# Debbuger command
GDB = $(TOOLCHAIN_LOCATION)$(TOOLCHAIN_PREFIX)gdb
# List simbols command
NM = $(TOOLCHAIN_LOCATION)$(TOOLCHAIN_PREFIX)nm
# Object dump command
OD = $(TOOLCHAIN_LOCATION)$(TOOLCHAIN_PREFIX)objdump

##################################################################################################
# Toolchain settings
# Preprocesor definitions

# Compiler flags
CFLAGS += -mabi=ilp32 -g3

# Assembler flags
AFLAGS += -mabi=ilp32  -x assembler-with-cpp -g

# Linker flags
LFLAGS += -mabi=ilp32 -Wl,--Map="$(TARGET_NAME).map",--gc-sections,--cref,--no-relax,--no-warn-rwx-segments
LFLAGS += --specs=nano.specs --specs=nosys.specs -T $(LINKSCRIPT)

# define linker extension
LD_EXTENSION = elf

# Debugger flags
GDB_FLAGS = $(TARGET_ELF) -ex "target remote-extended localhost:3333"

# Debug server
GDB_SERVER = $(OPENOCD_LOCATION)openocd

FLASH_WRITER = $(OPENOCD_LOCATION)openocd
