/************************************************************************************************
Copyright (c) 2025, Laboratorio de Microprocesadores
Facultad de Ciencias Exactas y Tecnología, Universidad Nacional de Tucumán
https://www.microprocesadores.unt.edu.ar/

Copyright (c) 2025, Esteban Volentini <evolentini@herrera.unt.edu.ar>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

SPDX-License-Identifier: MIT
*************************************************************************************************/

/* === Headers files inclusions =============================================================== */

#include <gd32vf103.h>

/* === Macros definitions ====================================================================== */

#define LED_ROJO 1        /**< Numero de terminal que controla el led verde */
#define LED_VERDE 3       /**< Numero de terminal que controla el led rojo */
#define LED_AZUL 2        /**< Numero de terminal que controla el led azul */
#define TECLA_CANCELAR 10 /**< Numero de terminal de la tecla cancelar */
#define TECLA_ACEPTAR 11  /**< Numero de terminal de la tecla aceptar */

/* === Private data type declarations ========================================================== */

/* === Private variable declarations =========================================================== */

/* === Private function declarations =========================================================== */

/* === Public variable definitions ============================================================= */

/* === Private variable definitions ============================================================ */

/* === Private function implementation ========================================================= */

void EXTI10_15_IRQHandler(void) {
    uint32_t pendientes = EXTI_PD;
    EXTI_PD = pendientes;

    if (pendientes & EXTI_10) {
        gpio_bit_reset(GPIOA, BIT(LED_AZUL));
    }

    if (pendientes & EXTI_11) {
        gpio_bit_set(GPIOA, BIT(LED_AZUL));
    }
}

/* === Public function implementation ========================================================== */

int main(void) {
    SystemCoreClockUpdate();

    rcu_periph_clock_enable(RCU_GPIOA);
    rcu_periph_clock_enable(RCU_GPIOB);
    rcu_periph_clock_enable(RCU_AF);
    gpio_init(GPIOA, GPIO_MODE_OUT_PP, GPIO_OSPEED_2MHZ,
              BIT(LED_ROJO) | BIT(LED_VERDE) | BIT(LED_AZUL));
    gpio_init(GPIOB, GPIO_MODE_IN_FLOATING, GPIO_OSPEED_2MHZ,
              BIT(TECLA_ACEPTAR) | BIT(TECLA_CANCELAR));

    eclic_mode_enable();
    eclic_set_nlbits(0);
    eclic_global_interrupt_enable();

    gpio_exti_source_select(GPIO_PORT_SOURCE_GPIOB, GPIO_PIN_SOURCE_10);
    gpio_exti_source_select(GPIO_PORT_SOURCE_GPIOB, GPIO_PIN_SOURCE_11);

    exti_init(EXTI_10, EXTI_INTERRUPT, EXTI_TRIG_FALLING);
    exti_init(EXTI_11, EXTI_INTERRUPT, EXTI_TRIG_RISING);
    eclic_irq_enable(EXTI10_15_IRQn, 1, 1);

    while (1) {
        asm("wfi");
    }
}

/* === End of file ============================================================================= */
