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

    .equ     CSR_MTVEC, 0x305

# ================================================================================================
# Función para generar una demora constante
# ================================================================================================
    .text
delay:
    la       t0,500000
loop_delay:
    nop
    addi     t0, t0, -1
    bne      t0, zero, loop_delay
    ret

# ================================================================================================
# Rutina de servicio que se ejecuta en respuesta a una excepcion
# ================================================================================================
    .type    error_handler,@function
    .align   6
error_handler:
    li       a0, 3
    jal      apagar_salida           # Apaga el led verde de la placa
    li       a0, 1
    jal      cambiar_salida          # Prende el led rojo de la placa
halt:
    j        halt                    # Lazo infinito

# ================================================================================================
# Función principal que se ejecuta al completar el reset
# ================================================================================================
    .section .init
    .global  _start
    .type    _start, @function

_start:
    jal      configurar_placa        # Configura el hardware de la placa

    la       t0,error_handler
    csrw     CSR_MTVEC, t0           # Define la rutina para gestionar las excepciones
main_loop:
    li       a0, 3
    jal      cambiar_salida          # Cambia el estado del led verde
    jal      delay                   # Genera una pausa de medio segundo

    li       a0, 10
    jal      leer_entrada            # Lee el estado de la tecla cancelar
    beqz     a0, main_loop           # Repite el lazo si la tecla no esta apretada

    .word    0xFFFFFFFF              # Ejecuta una instrucción invalida

##################################################################################################
# ATENCION!!! Para compilar este proyecto se debe insertar en el archivo proyecto.mk
# una linea que defina la variable NAKED = YES antes de la definición de la variable PROYECTO
##################################################################################################
