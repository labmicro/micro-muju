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
# Declaraciones con las direcciones de los puertos de los dispositivos GPIO
# ================================================================================================
    .equ    GPIOA_BASE, 0x40010800 # Dirección base del dispositivo GPIOA
    .equ    GPIOB_BASE, 0x40010C00 # Dirección base del dispositivo GPIOB
    .equ    GPIO_CTL0, 0x00        # Primer registro de control (terminales 0 a 7)
    .equ    GPIO_CTL1, 0x04        # Segundo registro de control (terminales 8 a 15)
    .equ    GPIO_ISTAT, 0x08       # Registro de estado de las entradas
    .equ    GPIO_OCTL, 0x0C        # Registro de control de las salidas
    .equ    GPIO_BOP, 0x10         # Registro de puesta a 1 de las salidas
    .equ    GPIO_BC, 0x14          # Registro de puesta a 0 de las salidas
    .equ    GPIO_LOCK, 0x1C        # Registro de bloqueo de configuración

# ================================================================================================
# Función para configurar un terminal del GPIOA como salida
# a0: Numero del terminal que se configura como salida
# ================================================================================================
    .global configurar_led
configurar_led:
    la      t0,GPIOA_BASE          # Se apunta a la base de puerto GPIOA
    lw      t2,GPIO_CTL0(t0)       # Se carga el registro de control 0
    slli    t4,a0,2                # Se multiplica por 4 (4 bits por pin)

    li      t3,0xF                 # Máscara para limpiar los 4 bits del pin
    sll     t3,t3,t4               # Se ajusta el valor al pin
    not     t3,t3                  # Se invierte la máscara
    and     t2,t2,t3               # Se limpian los 4 bits del pin

    li      t3,0x2                 # Modo salida 2MHz (0b0010)
    sll     t3,t3,t4               # Se ajusta el valor al pin
    or      t2,t2,t3               # Se ajusta el valor en el campo del pin

    sw      t2,GPIO_CTL0(t0)       # Se actualiza el registro de control 0
    ret

# ================================================================================================
# Función que pone un valor alto en un terminal del GPIOA para prender un led
# a0: Numero del terminal del puerto GPIO que controla al led
# ================================================================================================
    .global prender_led
prender_led:
    la      t0,GPIOA_BASE          # Se apunta a la base de puerto GPIOB
    li      t2,1                   # Valor para prender el LED
    sll     t2,t2,a0               # Se ajusta el valor al pin
    sw      t2,GPIO_BOP(t0)        # Se escribe el nuevo valor en octl
    ret

# ================================================================================================
# Función que pone un valor bajo en un terminal del GPIOA para prender un led
# a0: Numero del terminal del puerto GPIO que controla al led
# ================================================================================================
    .global apagar_led
apagar_led:
    la      t0,GPIOA_BASE          # Se apunta a la base de puerto GPIOB
    li      t2,1                   # Valor para prender el LED
    sll     t2,t2,a0               # Se ajusta el valor al pin
    sw      t2,GPIO_BC(t0)         # Se escribe el nuevo valor en octl
    ret
