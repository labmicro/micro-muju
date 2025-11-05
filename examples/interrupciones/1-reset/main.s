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

# ================================================================================================
# Función para generar una demora constante
# ================================================================================================
    .text
delay:
    la       t0, 500000
loop_delay:
    nop
    addi     t0, t0, -1
    bne      t0, zero, loop_delay
    ret

# ================================================================================================
# Función principal que se ejecuta justo al completar el reset
# ================================================================================================
    .section .init
    .global  _start
    .type    _start,@function
_start:
    jal      configurar_placa
main_loop:
    li       a0, 1
    jal      cambiar_salida
    jal      delay
    j        main_loop

##################################################################################################
# ATENCION!!! Para compilar este proyecto se debe insertar en el archivo proyecto.mk
# una linea que defina la variable NAKED = YES antes de la definición de la variable PROYECTO
##################################################################################################
