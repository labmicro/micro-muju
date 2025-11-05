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

    .equ    CSR_MIE, 0x304
    .equ    MIE_MTIE, 0x00000040


    .equ    SYSTIMER_BASE, 0xD1000000
    .equ    MTIMER, 0x000              # Offset: 0x000 (R/W) System Timer current value 64bits Register
    .equ    MTIMERCMP, 0x008           # Offset: 0x008 (R/W) System Timer compare Value 64bits Register
    .equ    MTIME_SRW_CTRL, 0xFEC      # Offset: 0xFEC (R/W) Control S-mode can access this timer or not.
    .equ    MSFTRST, 0xFF0             # Offset: 0xFF0 (R/W) System Timer Software Core Reset Register
    .equ    SSIP, 0xFF4                # Offset: 0xFF4 (R/W) S-Mode System Timer SW interrupt Register
    .equ    MTIMECTL, 0xFF8            # Offset: 0xFF8 (R/W) System Timer Control Register, previously MSTOP register
    .equ    MSIP, 0xFFC                # Offset: 0xFFC (R/W) M-Mode System Timer SW interrupt Register
    .equ    SYSTIMER_MSIP_MASK, 1


# ================================================================================================
# Función para sumar un numero de 32 bits a un entero de 64 bits en memoria
# a0: Parte baja del numero a sumar
# a1: Dirección del entero de 64 bits en memoria
# a2: Dirección donde se guarda el resultado
# a3: Dirección a la que se retorna al finalizar la función
# ================================================================================================
# .global add_double
    .type   add_double,@function
add_double:
    lw      t0,0(a1)                   # Carga la parte baja del numero
    lw      t1,4(a1)                   # Carga la parte alta del numero
    add     t2, t0, a0                 # Suma la parte baja del numero
    sltu    t3, t2, t0                 # Acarreo si el resultado es menor que el operando
    add     t1,t1,t3                   # Suma el acarreo generado
    li      t3,-1                      # Genera un patron de 0xFFFFFFF
    sw      t3,0(a2)                   # Guarda 0xFFFFFFF en la parte baja del numero
    sw      t1,4(a2)                   # Guarda la parte alta del numero
    sw      t2,0(a2)                   # Guarda la parte baja del numero
    ret                                # Se retorna al programa principal

# ================================================================================================
# Función para inicializar el timer con un periodo determinado
# a0: Valor del periodo del temporizador
# ================================================================================================
    .global timer_start
    .type   timer_start,@function
timer_start:
    la      t0, SYSTIMER_BASE          # Se apunta a la base del timer
    addi    a1, t0, MTIMER             # se calcula la dirección del registro MTIMER
    addi    a2, t0, MTIMERCMP          # se calcula la dirección del registro MTIMERCMP
    j       add_double                 # Se suma el valor del periodo al registro MTIMERCMP

# ================================================================================================
# Rutina de atención de la interrupción del timer
# a0: Valor del periodo del temporizador
# ================================================================================================
    .global timer_update
    .type   timer_update,@function
timer_update:
    la      t0, SYSTIMER_BASE          # Se apunta a la base del timer
    addi    a1, t0, MTIMERCMP          # se calcula la dirección del registro MTIMER
    addi    a2, t0, MTIMERCMP          # se calcula la dirección del registro MTIMERCMP
    j       add_double                 # Se suma el valor del periodo al registro MTIMERCMP

# ===============================================================================================
# Rutina para limpiar la interupción por software del timer
# ===============================================================================================
    .global timer_clear_msip
    .type   timer_clear_msip,@function
timer_clear_msip:
    la      t0, SYSTIMER_BASE
    li      t1, MSIP
    add     t0,t0,t1
    lw      t1,0(t0)
    li      t2, SYSTIMER_MSIP_MASK
    not     t2, t2
    and     t1, t1, t2
    sw      t1,0(t0)
    ret
