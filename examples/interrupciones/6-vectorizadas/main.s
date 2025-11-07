##################################################################################################
# Copyright (c) 2025, Laboratorio de Microprocesadores
# Facultad de Ciencias Exactas y Tecnología, Universidad Nacional de Tucumán
# https: //www.microprocesadores.unt.edu.ar/
#
# Copyright (c) 2025, Esteban Volentini <evolentini@herrera.unt.edu.ar>
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

    .text

    .equ    CSR_MHARTID, 0xF14
    .equ    CSR_MSTATUS, 0x300
    .equ    CSR_MIE, 0x304
    .equ    CSR_MTVEC, 0x305
    .equ    CSR_MTVT, 0x307
    .equ    CSR_MTVT2, 0x7EC
    .equ    CSR_MMISC_CTL,0x7D0
    .equ    CSR_MIP, 0x344

    .equ    MIE_MTIE, (1 << 7)
    .equ    MIE_MEIE, (1 << 11)

    .equ    MSTATUS_MIE, 0x00000008

    .equ    PERIODO, 500000

    .equ    SYSTIMER_BASE, 0xD1000000
    .equ    MTIMER, 0x000                # Offset: 0x000 (R/W) System Timer current value 64bits Register
    .equ    MTIMERCMP, 0x008             # Offset: 0x008 (R/W) System Timer compare Value 64bits Register
    .equ    MTIME_SRW_CTRL, 0xFEC        # Offset: 0xFEC (R/W) Control S-mode can access this timer or not.
    .equ    MSFTRST, 0xFF0               # Offset: 0xFF0 (R/W) System Timer Software Core Reset Register
    .equ    SSIP, 0xFF4                  # Offset: 0xFF4 (R/W) S-Mode System Timer SW interrupt Register
    .equ    MTIMECTL, 0xFF8              # Offset: 0xFF8 (R/W) System Timer Control Register, previously MSTOP register
    .equ    MSIP, 0xFFC                  # Offset: 0xFFC (R/W) M-Mode System Timer SW interrupt Register
    .equ    SYSTIMER_MSIP_MASK, 1

    .equ    EXTI10_15_IRQn, 59
    .equ    CLIC_INT_TMR, 7

# ================================================================================================
# Función para generar una demora constante
# ================================================================================================
delay:
    la      t0,PERIODO
loop_delay:
    nop
    addi    t0, t0, -1
    bne     t0, zero, loop_delay
    ret

# ================================================================================================
# Función para habilitar las interrupciones globales en el ECLIC
# ================================================================================================
    .global interrupts_enable
    .type   interrupts_enable,@function
interrupts_enable:
    csrsi   CSR_MSTATUS,MSTATUS_MIE
    ret

# ================================================================================================
# Rutinas de servicio para interrupciónes
# ================================================================================================
    .global exception_handler
    .type   exception_handler,@function
    .align  6
exception_handler:
    li      a0, 3
    jal     apagar_salida                # Apaga el led verde de la placa
    li      a0, 1
    jal     cambiar_salida               # Prende el led rojo de la placa
halt:
    j       halt                         # Lazo infinito

    .global eclic_mtip_handler
    .type   eclic_mtip_handler,@function
eclic_mtip_handler:
    li      a0, PERIODO
    jal     timer_update

    li      a0, 3
    jal     cambiar_salida

    mret

# ================================================================================================
# Función principal que se ejecuta justo al completar el reset
# ================================================================================================
    .globl  _start
    .type   _start,@function
_start:
    jal     configurar_placa             # Configura el hardware de la placa

    jal     eclic_mode_enable            # Habilita el ECLIC para las interrupciones

    li      a0, PERIODO
    jal     timer_start                  # Define el valor inicial del comparador

    li      a0, CLIC_INT_TMR             # Selecciona la interrupcion a configurar
    jal     eclic_enable_vectored        # Habilita el modo vectorizado en el eclic
    jal     eclic_enable_interrupt       # Habilita la interrupcion en el eclic
    jal     interrupts_enable            # Habilita las interrupciones del procesador

main_loop:
    wfi                                  # Espera una interupcion

    li      a0, 10
    jal     leer_entrada                 # Lee el estado de la tecla cancelar
    beqz    a0, main_loop                # Repite el lazo si la tecla no esta apretada

    .word   0xFFFFFFFF                   # Ejecuta una instrucción invalida

##################################################################################################
# ATENCION!!! Para compilar este proyecto se debe insertar en el archivo proyecto.mk
# una linea que defina la variable NAKED = YES antes de la definición de la variable PROYECTO
##################################################################################################
