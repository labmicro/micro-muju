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

    .equ     ECLIC_BASE, 0xD2000000
    .equ     ECLIC_INT_IP, 0x1000
    .equ     ECLIC_INT_IE, 0x1001
    .equ     ECLIC_INT_ATTR, 0x1002
    .equ     ECLIC_INT_CTL, 0x1003

    .equ     CSR_MSTATUS, 0x300
    .equ     CSR_MIE, 0x304
    .equ     CSR_MTVEC, 0x305
    .equ     CSR_MTVT, 0x307
    .equ     CSR_MTVT2, 0x7EC

    .equ     MSTATUS_MIE, 0x00000008

# ================================================================================================
# Función para habilitar una interrupción en el ECLIC
# a0: Numero de la interrupción que se quiere habilitar
# ================================================================================================
    .global  eclic_enable_interrupt
    .type    eclic_enable_interrupt,@function
eclic_enable_interrupt:
    la       t0,ECLIC_BASE                    # Se carga la dirección base del ECLIC
    li       t1,ECLIC_INT_IE                  # Se carga el desplazamiento del primer registro IE
    add      t0, t0, t1                       # Se calcula la dirección del primer registro IE
    slli     t1,a0,2                          # Se desplazamiento para la interupción
    add      t0,t0,t1                         # Se calcula la dirección efectiva del registro IE
    li       t1,1                             # Máscara para habilitar la interrupción
    sb       t1,0(t0)                         # Se habilita la interrupción
    ret

# ================================================================================================
# Función para habilitar el modo vectorizado en un interupción del ECLIC
# a0: Numero de la interrupción a la que se quiere habilitar el modo vectorizado
# ================================================================================================
    .global  eclic_enable_vectored
    .type    eclic_enable_vectored,@function
eclic_enable_vectored:
    la       t0,ECLIC_BASE                    # Se carga la dirección base del ECLIC
    li       t1,ECLIC_INT_ATTR                # Se carga el desplazamiento del primer registro IE
    add      t0, t0, t1                       # Se calcula la dirección del primer registro IE
    slli     t1,a0,2                          # Se desplazamiento para la interupción
    add      t0,t0,t1                         # Se calcula la dirección efectiva del registro IE
    li       t1,1                             # Máscara para habilitar el modo vectorizado
    sb       t1,0(t0)                         # Se habilita el modo vectorizado para la interrupción
    ret
# ================================================================================================
# Función para obtener la interrupción pendiente en el ECLIC
# a0: Numero de la interrupción que se quiere consultar
# ================================================================================================
    .global  eclic_get_pending
    .type    eclic_get_pending,@function
eclic_get_pending:
    la       t0,ECLIC_BASE                    # Se carga la dirección base del ECLIC
    li       t1,ECLIC_INT_IP                  # Se carga el desplazamiento del primer registro IE
    add      t0, t0, t1                       # Se calcula la dirección del primer registro IE
    slli     t1,a0,2                          # Se desplazamiento para la interupción
    add      t0,t0,t1                         # Se calcula la dirección efectiva del registro IE
    lb       a0,0(t0)                         # Se habilita la interrupción
    ret

# ================================================================================================
# Función para obtener la interrupción pendiente en el ECLIC
# a0: Numero de la interrupción que se quiere consultar
# ================================================================================================
    .global  eclic_clear_pending
    .type    eclic_clear_pending,@function
eclic_clear_pending:
    la       t0,ECLIC_BASE                    # Se carga la dirección base del ECLIC
    li       t1,ECLIC_INT_IP                  # Se carga el desplazamiento del primer registro IE
    add      t0, t0, t1                       # Se calcula la dirección del primer registro IE
    slli     t1,a0,2                          # Se desplazamiento para la interupción
    add      t0,t0,t1                         # Se calcula la dirección efectiva del registro IE
    sb       zero,0(t0)                       # Se limpia la interrupción pendiente
    ret

# ================================================================================================
# Función para configurar el modo ECLIC en el CSR_MTVEC
# ================================================================================================
    .global  eclic_mode_enable
    .type    eclic_mode_enable,@function

eclic_mode_enable:
    la       t0,vector_base
    csrw     CSR_MTVT, t0                     # De define la base de vector de interupciones

    /*       Intial the mtvt2 and enable it*/
    la       t0, default_handler
    csrw     CSR_MTVT2, t0
    csrs     CSR_MTVT2, 0x1                   # Se define la rutina comun para las interrupciones

    la       t0,exception_handler
    andi     t0,t0,0xFFFFFFC0                 # Se limpian los dos bits menos significativos
    ori      t0,t0,0x00000003                 # Se configuran los bits para modo ECLIC
    csrw     CSR_MTVEC,t0                     # Se escribe el CSR_MTVEC
    ret

# ================================================================================================
# Rutinas de servicio para interrupciónes
# ================================================================================================

    .align   6
default_handler:
    li       a0, 2
    jal      prender_salida
    j        default_handler

    .align   6
    .type    exception_handler,@function
    .weak    exception_handler
exception_handler:
    li       a0, 2
    jal      prender_salida
    j        exception_handler

# ================================================================================================
# Vector de interrupciones y punto de entrada
# ================================================================================================

    .section .init

    .weak    eclic_msip_handler
    .weak    eclic_mtip_handler
    .weak    eclic_bwei_handler
    .weak    eclic_pmovi_handler
    .weak    WWDGT_IRQHandler
    .weak    LVD_IRQHandler
    .weak    TAMPER_IRQHandler
    .weak    RTC_IRQHandler
    .weak    FMC_IRQHandler
    .weak    RCU_IRQHandler
    .weak    EXTI0_IRQHandler
    .weak    EXTI1_IRQHandler
    .weak    EXTI2_IRQHandler
    .weak    EXTI3_IRQHandler
    .weak    EXTI4_IRQHandler
    .weak    DMA0_Channel0_IRQHandler
    .weak    DMA0_Channel1_IRQHandler
    .weak    DMA0_Channel2_IRQHandler
    .weak    DMA0_Channel3_IRQHandler
    .weak    DMA0_Channel4_IRQHandler
    .weak    DMA0_Channel5_IRQHandler
    .weak    DMA0_Channel6_IRQHandler
    .weak    ADC0_1_IRQHandler
    .weak    CAN0_TX_IRQHandler
    .weak    CAN0_RX0_IRQHandler
    .weak    CAN0_RX1_IRQHandler
    .weak    CAN0_EWMC_IRQHandler
    .weak    EXTI5_9_IRQHandler
    .weak    TIMER0_BRK_IRQHandler
    .weak    TIMER0_UP_IRQHandler
    .weak    TIMER0_TRG_CMT_IRQHandler
    .weak    TIMER0_Channel_IRQHandler
    .weak    TIMER1_IRQHandler
    .weak    TIMER2_IRQHandler
    .weak    TIMER3_IRQHandler
    .weak    I2C0_EV_IRQHandler
    .weak    I2C0_ER_IRQHandler
    .weak    I2C1_EV_IRQHandler
    .weak    I2C1_ER_IRQHandler
    .weak    SPI0_IRQHandler
    .weak    SPI1_IRQHandler
    .weak    USART0_IRQHandler
    .weak    USART1_IRQHandler
    .weak    USART2_IRQHandler
    .weak    EXTI10_15_IRQHandler
    .weak    RTC_Alarm_IRQHandler
    .weak    USBFS_WKUP_IRQHandler
    .weak    EXMC_IRQHandler
    .weak    TIMER4_IRQHandler
    .weak    SPI2_IRQHandler
    .weak    UART3_IRQHandler
    .weak    UART4_IRQHandler
    .weak    TIMER5_IRQHandler
    .weak    TIMER6_IRQHandler
    .weak    DMA1_Channel0_IRQHandler
    .weak    DMA1_Channel1_IRQHandler
    .weak    DMA1_Channel2_IRQHandler
    .weak    DMA1_Channel3_IRQHandler
    .weak    DMA1_Channel4_IRQHandler
    .weak    CAN1_TX_IRQHandler
    .weak    CAN1_RX0_IRQHandler
    .weak    CAN1_RX1_IRQHandler
    .weak    CAN1_EWMC_IRQHandler
    .weak    USBFS_IRQHandler

    .global  vector_base
vector_base:
    j        _start
    .align   2
    .word    0                                # 1: Reserved
    .word    0                                # 2: Reserved
    .word    eclic_msip_handler               # 3: Machine Software Interrupt
    .word    0                                # 4: Reserved
    .word    0                                # 5: Reserved
    .word    0                                # 6: Reserved
    .word    eclic_mtip_handler               # 7: Machine Timer Interrupt
    .word    0                                # 8: Reserved
    .word    0                                # 9: Reserved
    .word    0                                # 10: Reserved
    .word    0                                # 11: Reserved
    .word    0                                # 12: Reserved
    .word    0                                # 13: Reserved
    .word    0                                # 14: Reserved
    .word    0                                # 15: Reserved
    .word    0                                # 16: Reserved
    .word    eclic_bwei_handler               # 17: Machine Bus Error Interrupt
    .word    eclic_pmovi_handler              # 18: Machine Pseudo-Interrupt
    .word    WWDGT_IRQHandler                 # 19: Window Watchdog Timer Interrupt
    .word    LVD_IRQHandler                   # 20: Low Voltage Detector Interrupt
    .word    TAMPER_IRQHandler                # 21: Tamper Interrupt
    .word    RTC_IRQHandler                   # 22: Real-Time Clock Interrupt
    .word    FMC_IRQHandler                   # 23: Flash Memory Controller Interrupt
    .word    RCU_IRQHandler                   # 24: Reset and Clock Control Interrupt
    .word    EXTI0_IRQHandler                 # 25: External Line 0 Interrupt
    .word    EXTI1_IRQHandler                 # 26: External Line 1 Interrupt
    .word    EXTI2_IRQHandler                 # 27: External Line 2 Interrupt
    .word    EXTI3_IRQHandler                 # 28: External Line 3 Interrupt
    .word    EXTI4_IRQHandler                 # 29: External Line 4 Interrupt
    .word    DMA0_Channel0_IRQHandler         # 30: DMA0 Channel 0 Interrupt
    .word    DMA0_Channel1_IRQHandler         # 31: DMA0 Channel 1 Interrupt
    .word    DMA0_Channel2_IRQHandler         # 32: DMA0 Channel 2 Interrupt
    .word    DMA0_Channel3_IRQHandler         # 33: DMA0 Channel 3 Interrupt
    .word    DMA0_Channel4_IRQHandler         # 34: DMA0 Channel 4 Interrupt
    .word    DMA0_Channel5_IRQHandler         # 35: DMA0 Channel 5 Interrupt
    .word    DMA0_Channel6_IRQHandler         # 36: DMA0 Channel 6 Interrupt
    .word    ADC0_1_IRQHandler                # 37: ADC0 and ADC1 Interrupt
    .word    CAN0_TX_IRQHandler               # 38: CAN0 TX Interrupt
    .word    CAN0_RX0_IRQHandler              # 39: CAN0 RX0 Interrupt
    .word    CAN0_RX1_IRQHandler              # 40: CAN0 RX1 Interrupt
    .word    CAN0_EWMC_IRQHandler             # 41: CAN0 EWMC Interrupt
    .word    EXTI5_9_IRQHandler               # 42: External Lines 5 to 9 Interrupt
    .word    TIMER0_BRK_IRQHandler            # 43: TIMER0 Break Interrupt
    .word    TIMER0_UP_IRQHandler             # 44: TIMER0 Update Interrupt
    .word    TIMER0_TRG_CMT_IRQHandler        # 45: TIMER0 Trigger and Commutation Interrupt
    .word    TIMER0_Channel_IRQHandler        # 46: TIMER0 Channel Capture/Compare Interrupt
    .word    TIMER1_IRQHandler                # 47: TIMER1 Interrupt
    .word    TIMER2_IRQHandler                # 48: TIMER2 Interrupt
    .word    TIMER3_IRQHandler                # 49: TIMER3 Interrupt
    .word    I2C0_EV_IRQHandler               # 50: I2C0 Event Interrupt
    .word    I2C0_ER_IRQHandler               # 51: I2C0 Error Interrupt
    .word    I2C1_EV_IRQHandler               # 52: I2C1 Event Interrupt
    .word    I2C1_ER_IRQHandler               # 53: I2C1 Error Interrupt
    .word    SPI0_IRQHandler                  # 54: SPI0 Interrupt
    .word    SPI1_IRQHandler                  # 55: SPI1 Interrupt
    .word    USART0_IRQHandler                # 56: USART0 Interrupt
    .word    USART1_IRQHandler                # 57: USART1 Interrupt
    .word    USART2_IRQHandler                # 58: USART2 Interrupt
    .word    EXTI10_15_IRQHandler             # 59: External Lines 10 to 15 Interrupt
    .word    RTC_Alarm_IRQHandler             # 60: RTC Alarm Interrupt
    .word    USBFS_WKUP_IRQHandler            # 61: USBFS Wakeup Interrupt
    .word    0                                # 62: Reserved
    .word    0                                # 63: Reserved
    .word    0                                # 64: Reserved
    .word    0                                # 65: Reserved
    .word    0                                # 66: Reserved
    .word    EXMC_IRQHandler                  # 67: EXMC Interrupt
    .word    0                                # 68: Reserved
    .word    TIMER4_IRQHandler                # 69: TIMER4 Interrupt
    .word    SPI2_IRQHandler                  # 70: SPI2 Interrupt
    .word    UART3_IRQHandler                 # 71: UART3 Interrupt
    .word    UART4_IRQHandler                 # 72: UART4 Interrupt
    .word    TIMER5_IRQHandler                # 73: TIMER5 Interrupt
    .word    TIMER6_IRQHandler                # 74: TIMER6 Interrupt
    .word    DMA1_Channel0_IRQHandler         # 75: DMA1 Channel 0 Interrupt
    .word    DMA1_Channel1_IRQHandler         # 76: DMA1 Channel 1 Interrupt
    .word    DMA1_Channel2_IRQHandler         # 77: DMA1 Channel 2 Interrupt
    .word    DMA1_Channel3_IRQHandler         # 78: DMA1 Channel 3 Interrupt
    .word    DMA1_Channel4_IRQHandler         # 79: DMA1 Channel 4 Interrupt
    .word    0                                # 80: Reserved
    .word    0                                # 81: Reserved
    .word    CAN1_TX_IRQHandler               # 82: CAN1 TX Interrupt
    .word    CAN1_RX0_IRQHandler              # 83: CAN1 RX0 Interrupt
    .word    CAN1_RX1_IRQHandler              # 84: CAN1 RX1 Interrupt
    .word    CAN1_EWMC_IRQHandler             # 85: CAN1 EWMC Interrupt
    .word    USBFS_IRQHandler                 # 86: USBFS Interrupt
