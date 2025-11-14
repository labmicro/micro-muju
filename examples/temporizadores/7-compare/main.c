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

void TIMER1_IRQHandler(void) {
    if (timer_flag_get(TIMER1, TIMER_INT_CH1)) {
        timer_interrupt_flag_clear(TIMER1, TIMER_INT_CH1);
        timer_channel_output_pulse_value_config(
            TIMER1, TIMER_CH_1,
            timer_channel_capture_value_register_read(TIMER1, TIMER_CH_1) + 7500);
    }
    if (timer_flag_get(TIMER1, TIMER_INT_CH2)) {
        timer_interrupt_flag_clear(TIMER1, TIMER_INT_CH2);
        timer_channel_output_pulse_value_config(
            TIMER1, TIMER_CH_2,
            timer_channel_capture_value_register_read(TIMER1, TIMER_CH_2) + 5000);
    }
    if (timer_flag_get(TIMER1, TIMER_INT_CH3)) {
        timer_interrupt_flag_clear(TIMER1, TIMER_INT_CH3);
        timer_channel_output_pulse_value_config(
            TIMER1, TIMER_CH_3,
            timer_channel_capture_value_register_read(TIMER1, TIMER_CH_3) + 2500);
    }
}

/* === Public function implementation ========================================================== */

int main(void) {
    SystemInit();
    SystemCoreClockUpdate();

    rcu_periph_clock_enable(RCU_AF);
    rcu_periph_clock_enable(RCU_GPIOA);
    gpio_init(GPIOA, GPIO_MODE_AF_PP, GPIO_OSPEED_2MHZ,
              BIT(LED_ROJO) | BIT(LED_VERDE) | BIT(LED_AZUL));

    eclic_mode_enable();
    eclic_global_interrupt_enable();

    rcu_periph_clock_enable(RCU_TIMER1);
    timer_internal_clock_config(TIMER1);
    timer_prescaler_config(TIMER1, SystemCoreClock / 5000, TIMER_PSC_RELOAD_NOW);
    timer_autoreload_value_config(TIMER1, 0xFFFF);

    // Control del canal rojo del led RGB
    timer_channel_output_state_config(TIMER1, TIMER_CH_1, TIMER_CCX_ENABLE);
    timer_channel_output_polarity_config(TIMER1, TIMER_CH_1, TIMER_OC_POLARITY_HIGH);
    timer_channel_output_mode_config(TIMER1, TIMER_CH_1, TIMER_OC_MODE_TOGGLE);
    timer_channel_output_pulse_value_config(TIMER1, TIMER_CH_1, 7500);

    // Control del canal azul del led RGB
    timer_channel_output_state_config(TIMER1, TIMER_CH_2, TIMER_CCX_ENABLE);
    timer_channel_output_polarity_config(TIMER1, TIMER_CH_2, TIMER_OC_POLARITY_HIGH);
    timer_channel_output_mode_config(TIMER1, TIMER_CH_2, TIMER_OC_MODE_TOGGLE);
    timer_channel_output_pulse_value_config(TIMER1, TIMER_CH_2, 5000);

    // Control del canal verde del led RGB
    timer_channel_output_state_config(TIMER1, TIMER_CH_3, TIMER_CCX_ENABLE);
    timer_channel_output_polarity_config(TIMER1, TIMER_CH_3, TIMER_OC_POLARITY_HIGH);
    timer_channel_output_mode_config(TIMER1, TIMER_CH_3, TIMER_OC_MODE_TOGGLE);
    timer_channel_output_pulse_value_config(TIMER1, TIMER_CH_3, 2500);

    timer_interrupt_enable(TIMER1, TIMER_INT_CH1);
    timer_interrupt_enable(TIMER1, TIMER_INT_CH2);
    timer_interrupt_enable(TIMER1, TIMER_INT_CH3);
    eclic_irq_enable(TIMER1_IRQn, 1, 1);

    timer_enable(TIMER1);
    while (1) {
        asm("wfi");
    }
}

/* === End of file ============================================================================= */
