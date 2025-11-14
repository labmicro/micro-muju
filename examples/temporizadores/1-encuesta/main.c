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

#define LED_ROJO  1 /**< Numero de terminal que controla el led verde */
#define LED_VERDE 3 /**< Numero de terminal que controla el led rojo */
#define LED_AZUL  2 /**< Numero de terminal que controla el led azul */

/* === Private data type declarations ========================================================== */

/* === Private variable declarations =========================================================== */

/* === Private function declarations =========================================================== */

/* === Public variable definitions ============================================================= */

/* === Private variable definitions ============================================================ */

/* === Private function implementation ========================================================= */

/* === Public function implementation ========================================================== */

int main(void) {
    SystemCoreClockUpdate();

    rcu_periph_clock_enable(RCU_GPIOA);
    gpio_init(GPIOA, GPIO_MODE_OUT_PP, GPIO_OSPEED_2MHZ,
              BIT(LED_ROJO) | BIT(LED_VERDE) | BIT(LED_AZUL));

    rcu_periph_clock_enable(RCU_TIMER1);
    timer_internal_clock_config(TIMER1);
    timer_prescaler_config(TIMER1, SystemCoreClock / 1000, TIMER_PSC_RELOAD_NOW);
    timer_autoreload_value_config(TIMER1, 500);
    timer_update_event_enable(TIMER1);

    timer_enable(TIMER1);
    while (1) {
        if (timer_flag_get(TIMER1, TIMER_INT_UP)) {
            timer_interrupt_flag_clear(TIMER1, TIMER_INT_UP);
            if (gpio_output_bit_get(GPIOA, BIT(LED_ROJO))) {
                gpio_bit_reset(GPIOA, BIT(LED_ROJO));
            } else {
                gpio_bit_set(GPIOA, BIT(LED_ROJO));
            }
        }
    }
}

/* === End of file ============================================================================= */
