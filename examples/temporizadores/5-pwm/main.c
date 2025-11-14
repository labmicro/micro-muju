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

#define LED_ROJO  1     /**< Numero de terminal que controla el led verde */
#define LED_VERDE 3     /**< Numero de terminal que controla el led rojo */
#define LED_AZUL  2     /**< Numero de terminal que controla el led azul */
#define PERIODO   10000 /**< Valor de recarga del contador principal */
/* === Private data type declarations ========================================================== */

/* === Private variable declarations =========================================================== */

/* === Private function declarations =========================================================== */

/* === Public variable definitions ============================================================= */

/* === Private variable definitions ============================================================ */

/* === Private function implementation ========================================================= */

/* === Public function implementation ========================================================== */

int main(void) {
    unsigned int r = 0;
    unsigned int b = 0;
    unsigned int g = 0;

    unsigned int value = 0;
    signed int delta = 10;
    unsigned int ciclo = 0;

    SystemInit();
    SystemCoreClockUpdate();

    rcu_periph_clock_enable(RCU_AF);
    rcu_periph_clock_enable(RCU_GPIOA);
    gpio_init(GPIOA, GPIO_MODE_AF_PP, GPIO_OSPEED_2MHZ,
              BIT(LED_ROJO) | BIT(LED_VERDE) | BIT(LED_AZUL));

    rcu_periph_clock_enable(RCU_TIMER1);
    timer_internal_clock_config(TIMER1);
    timer_prescaler_config(TIMER1, SystemCoreClock / 10000000, TIMER_PSC_RELOAD_NOW);
    timer_autoreload_value_config(TIMER1, PERIODO);
    timer_update_event_enable(TIMER1);

    // Control del canal rojo del led RGB
    timer_channel_output_state_config(TIMER1, TIMER_CH_1, TIMER_CCX_ENABLE);
    timer_channel_output_polarity_config(TIMER1, TIMER_CH_1, TIMER_OC_POLARITY_HIGH);
    timer_channel_output_mode_config(TIMER1, TIMER_CH_1, TIMER_OC_MODE_PWM0);
    timer_channel_output_pulse_value_config(TIMER1, TIMER_CH_1, r);

    // Control del canal azul del led RGB
    timer_channel_output_state_config(TIMER1, TIMER_CH_2, TIMER_CCX_ENABLE);
    timer_channel_output_polarity_config(TIMER1, TIMER_CH_2, TIMER_OC_POLARITY_HIGH);
    timer_channel_output_mode_config(TIMER1, TIMER_CH_2, TIMER_OC_MODE_PWM0);
    timer_channel_output_pulse_value_config(TIMER1, TIMER_CH_2, b);

    // Control del canal verde del led RGB
    timer_channel_output_state_config(TIMER1, TIMER_CH_3, TIMER_CCX_ENABLE);
    timer_channel_output_polarity_config(TIMER1, TIMER_CH_3, TIMER_OC_POLARITY_HIGH);
    timer_channel_output_mode_config(TIMER1, TIMER_CH_3, TIMER_OC_MODE_PWM0);
    timer_channel_output_pulse_value_config(TIMER1, TIMER_CH_3, g);

    timer_enable(TIMER1);
    while (1) {
        if (timer_flag_get(TIMER1, TIMER_INT_UP)) {
            timer_interrupt_flag_clear(TIMER1, TIMER_INT_UP);

            if (value >= PERIODO) {
                delta = -delta;
            }
            value = value + delta;
            if (value == 0) {
                delta = -delta;
                ciclo = (ciclo + 1) % 6;
            }

            switch (ciclo) {
            case 1:
                r = value;
                g = value;
                break;
            case 2:
                g = value;
                break;
            case 3:
                g = value;
                b = value;
                break;
            case 4:
                b = value;
                break;
            case 5:
                b = value;
                r = value;
                break;
            default:
                r = value;
                break;
            }
            timer_channel_output_pulse_value_config(TIMER1, TIMER_CH_1, r);
            timer_channel_output_pulse_value_config(TIMER1, TIMER_CH_2, b);
            timer_channel_output_pulse_value_config(TIMER1, TIMER_CH_3, g);
        }
    }
}

/* === End of file ============================================================================= */
