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

    .equ     CSR_MSTATUS, 0x300
    .equ     CSR_MIE, 0x304
    .equ     CSR_MTVEC, 0x305
    .equ     CSR_MCAUSE, 0x342
    .equ     CSR_MIP, 0x344

    .equ     MIE_MTIE, 0x00000080
    .equ     MSTATUS_MIE, 0x00000008

    .equ     PERIODO, 500000

# ================================================================================================
# Rutina de servicio para la interrupcion
# ================================================================================================
    .text
    .align   6
    .type    exception_handler,@function
exception_handler:
    csrr     a0, CSR_MCAUSE              # Lee el registro de causa
    la       a1, 0x80000007
    beq      a0, a1, timer_handler       # Si es la interrupción del temporizador

    li       a0, 3
    jal      apagar_salida               # Apaga el led verde de la placa
    li       a0, 1
    jal      cambiar_salida              # Prende el led rojo de la placa
halt:
    j        halt                        # Lazo infinito

timer_handler:
    li       a0, PERIODO
    jal      timer_update                # Define el nuevo valor para el comparador
    li       a0, 3
    jal      cambiar_salida              # Cambia el estado del led verde de la placa
    mret                                 # Retorna al programa principal

# ================================================================================================
# Función principal que se ejecuta justo al completar el reset
# ================================================================================================
    .globl   _start
    .type    _start,@function
    .section .init
_start:
    jal      configurar_placa            # Configura el hardware de la placa

    la       t0,exception_handler
    csrw     CSR_MTVEC, t0               # Define la rutina para las interupciones

    la       t0,PERIODO
    jal      timer_start                 # Define el valor inicial del comparador

    li       t0, MIE_MTIE
    csrs     CSR_MIE, t0                 # Habilita la interupción del temporizador
    csrsi    CSR_MSTATUS,MSTATUS_MIE     # Habilita las interrupciones del procesador

main_loop:
    wfi                                  # Espera una interupcion

    li       a0, 10
    jal      leer_entrada                # Lee el estado de la tecla cancelar
    beqz     a0, main_loop               # Repite el lazo si la tecla no esta apretada

    .word    0xFFFFFFFF                  # Ejecuta una instrucción invalida

##################################################################################################
# ATENCION!!! Para compilar este proyecto se debe insertar en el archivo proyecto.mk
# una linea que defina la variable NAKED = YES antes de la definición de la variable PROYECTO
##################################################################################################
