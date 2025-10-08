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

# ================================================================================================
# Declaraciones con las direcciones de los puertos del dispositivo RCU
# ================================================================================================
    .equ    RCU_BASE, 0x40021000 # Dirección base del dispositivo
    .equ    RCU_CTL, 0x00        # Registro de control
    .equ    RCU_CFG0, 0x04       # Primer registro de configuración del reloj
    .equ    RCU_INT, 0x08        # Control de interrupciones
    .equ    RCU_APB2RST, 0x0C    # Reinicio de dispositivos del APB2
    .equ    RCU_APB1RST, 0x10    # Reinicio de dispositivos del APB2
    .equ    RCU_AHBEN, 0x14      # Habilitción de reloj en dispositivos del AHB
    .equ    RCU_APB2EN, 0x18     # Habilitción de reloj en dispositivos del APB2
    .equ    RCU_APB1EN, 0x1C     # Habilitción de reloj en dispositivos del APB1
    .equ    RCU_BDCTL, 0x20      # Control del dominio de alimntación del backup
    .equ    RCU_RSTSCK, 0x24     # Fuente de reloj y de reinicio
    .equ    RCU_AHBRST, 0x28     # Reinicio de dispositivos del AHB
    .equ    RCU_CFG1, 0x2C       # Segundo registro de configuración del reloj
    .equ    RCU_DSV, 0x34        # Configuración de la tensión en modo deep-sleep

# ================================================================================================
# Función para habilitar el reloj en los puertos GPIOA y GPIOB
# ================================================================================================
    .global habilitar_reloj
habilitar_reloj:
    la      t0,RCU_BASE          # Se apunta a la base del RCU
    lw      t2,RCU_APB2EN(t0)    # Se carga el registro APB2EN
    addi    a2,a0,2              # El puerto A es el 2, el B es el 3
    ori     t2,t2,0x06           # Se habilita el reloj para los puertos A y B
    sw      t2,RCU_APB2EN(t0)    # Se escribe el nuevo valor en APB2EN
    ret
