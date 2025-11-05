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
    .equ    RCU_BASE, 0x40021000        # Dirección base del dispositivo
    .equ    RCU_CTL, 0x00               # Registro de control
    .equ    RCU_CFG0, 0x04              # Primer registro de configuración del reloj
    .equ    RCU_INT, 0x08               # Control de interrupciones
    .equ    RCU_APB2RST, 0x0C           # Reinicio de dispositivos del APB2
    .equ    RCU_APB1RST, 0x10           # Reinicio de dispositivos del APB2
    .equ    RCU_AHBEN, 0x14             # Habilitción de reloj en dispositivos del AHB
    .equ    RCU_APB2EN, 0x18            # Habilitción de reloj en dispositivos del APB2
    .equ    RCU_APB1EN, 0x1C            # Habilitción de reloj en dispositivos del APB1
    .equ    RCU_BDCTL, 0x20             # Control del dominio de alimntación del backup
    .equ    RCU_RSTSCK, 0x24            # Fuente de reloj y de reinicio
    .equ    RCU_AHBRST, 0x28            # Reinicio de dispositivos del AHB
    .equ    RCU_CFG1, 0x2C              # Segundo registro de configuración del reloj
    .equ    RCU_DSV, 0x34               # Configuración de la tensión en modo deep-sleep

# ================================================================================================
# Declaraciones con las direcciones de los puertos de los dispositivos GPIO
# ================================================================================================
    .equ    GPIOA_BASE, 0x40010800      # Dirección base del dispositivo GPIOA
    .equ    GPIOB_BASE, 0x40010C00      # Dirección base del dispositivo GPIOB
    .equ    GPIOC_BASE, 0x40011000      # Dirección base del dispositivo GPIOB
    .equ    GPIOD_BASE, 0x40011400      # Dirección base del dispositivo GPIOB
    .equ    GPIOE_BASE, 0x40011800      # Dirección base del dispositivo GPIOB

    .equ    GPIO_CTL0, 0x00             # Primer registro de control (terminales 0 a 7)
    .equ    GPIO_CTL1, 0x04             # Segundo registro de control (terminales 8 a 15)
    .equ    GPIO_ISTAT, 0x08            # Registro de estado de las entradas
    .equ    GPIO_OCTL, 0x0C             # Registro de control de las salidas
    .equ    GPIO_BOP, 0x10              # Registro de puesta a 1 de las salidas
    .equ    GPIO_BC, 0x14               # Registro de puesta a 0 de las salidas
    .equ    GPIO_LOCK, 0x1C             # Registro de bloqueo de configuración

# ================================================================================================
# Función para habilitar el reloj en los puertos GPIOA y GPIOB
# ================================================================================================
habilitar_reloj:
    la      t0,RCU_BASE                 # Se apunta a la base del RCU
    lw      t2,RCU_APB2EN(t0)           # Se carga el registro APB2EN
    addi    a2,a0,2                     # El puerto A es el 2, el B es el 3
    ori     t2,t2,0x7D                  # Se habilita el reloj para los puertos A y B
    sw      t2,RCU_APB2EN(t0)           # Se escribe el nuevo valor en APB2EN
    ret

# ================================================================================================
# Función para configurar un terminal como salida
# a0: Numero del terminal que se configura como salida
# ================================================================================================
    .global configurar_salida
    .type   configurar_salida,@function
configurar_salida:
    la      t0,GPIOA_BASE               # Se apunta a la base de puerto GPIOA

    addi    t0,t0, GPIO_CTL0            # Se apunta al registro de control de los primeros 8 pines
    sltiu   t1,a0,8                     # Se verifica si el pin es menor a 8
    xor     t1,t1,1                     # Si es menor a 8 t1=0, sino t1=1
    slli    t1,t1,2                     # Si t1=1 se multiplica por 4
    add     t0,t0,t1                    # Se ajusta la dirección al registro de control correcto

    lw      t2,0(t0)                    # Se carga el registro de control 0
    andi    a0, a0, 0x7                 # Se ajusta el número de pin (0 a 7)
    slli    t4,a0,2                     # Se multiplica por 4 (4 bits por pin)

    li      t3,0xF                      # Máscara para limpiar los 4 bits del pin
    sll     t3,t3,t4                    # Se ajusta el valor al pin
    not     t3,t3                       # Se invierte la máscara
    and     t2,t2,t3                    # Se limpian los 4 bits del pin

    li      t3,0x2                      # Modo salida 2MHz (0b0010)
    sll     t3,t3,t4                    # Se ajusta el valor al pin
    or      t2,t2,t3                    # Se ajusta el valor en el campo del pin

    sw      t2,0(t0)                    # Se actualiza el registro de control 0
    ret

# ================================================================================================
# Función que pone un valor alto en un terminal del GPIOA para prender un led
# a0: Numero del puerto (0=A, 1=B, 2=C, 3=D, 4=E)
# a0: Numero del terminal del puerto GPIO que controla al led
# ================================================================================================
    .global prender_salida
    .type   prender_salida,@function
prender_salida:
    la      t0,GPIOA_BASE               # Se apunta a la base de puerto GPIOA
    li      t2,1                        # Valor para prender el LED
    sll     t2,t2,a0                    # Se ajusta el valor al pin
    sw      t2,GPIO_BOP(t0)             # Se escribe el nuevo valor en octl
    ret

# ================================================================================================
# Función que pone un valor bajo en un terminal del GPIOA para prender un led
# a0: Numero del terminal del puerto GPIO que controla al led
# ================================================================================================
    .global apagar_salida
    .type   apagar_salida,@function
apagar_salida:
    la      t0,GPIOA_BASE               # Se apunta a la base de puerto GPIOA
    li      t2,1                        # Valor para prender el LED
    sll     t2,t2,a0                    # Se ajusta el valor al pin
    sw      t2,GPIO_BC(t0)              # Se escribe el nuevo valor en octl
    ret


# ================================================================================================
# Función que pone un valor bajo en un terminal del GPIOA para prender un led
# a0: Numero del terminal del puerto GPIO que controla al led
# ================================================================================================
    .global cambiar_salida
    .type   cambiar_salida,@function
cambiar_salida:
    la      t0,GPIOA_BASE               # Se apunta a la base de puerto GPIOB
    li      t2,1                        # Valor para prender el LED
    sll     t2,t2,a0                    # Se ajusta el valor al pin
    lw      t1,GPIO_OCTL(t0)            # Se carga el valor actual de las salidas
    xor     t1, t1, t2                  # Se invirte el bit correspondiente
    sw      t1,GPIO_OCTL(t0)            # Se escribe el nuevo valor en octl
    ret


# ================================================================================================
# Función que retorna el estado de una tecla conectada a un terminal del GPIOB
# a0: Numero del terminal del puerto GPIO al que está conectado la tecla
# ================================================================================================
    .global leer_entrada
    .type   leer_entrada,@function
leer_entrada:
    la      t0,GPIOB_BASE               # Se apunta a la base de puerto GPIOB
    lw      t1,GPIO_ISTAT(t0)           # Se carga el valor actual de las salidas
    srl     t1,t1,a0                    # Se ajusta el valor del pin al bit cero
    andi    a0, t1, 1                   # Se enmascara el bit cero y se usa como resultado
    ret

# ================================================================================================
# Función para configurar los leds y las teclas de la placa
# ================================================================================================
    .global configurar_placa
    .type   configurar_placa,@function
configurar_placa:
    mv      s0,ra
    jal     habilitar_reloj
    li      a0, 1
    jal     configurar_salida
    li      a0, 2
    jal     configurar_salida
    li      a0, 3
    jal     configurar_salida
    jr      s0
