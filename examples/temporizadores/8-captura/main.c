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

#include "board.h"
#include <gd32vf103.h>

/* === Macros definitions ====================================================================== */

#define LED_ROJO  1 /**< Numero de terminal que controla el led verde */
#define LED_VERDE 3 /**< Numero de terminal que controla el led rojo */
#define LED_AZUL  2 /**< Numero de terminal que controla el led azul */

/* === Private data type declarations ========================================================== */

/**
 * @brief Estructura con las variables para el estado de cada tecla
 */
typedef struct key_status_s {
    bool pressed;         /**< Variable para distingir el primer flanco del segundo */
    uint16_t start_value; /**< Valor del contador en el primer flanco */
    bool measured;        /**< Variable para confirmar que la duración es válida */
    uint16_t duration;    /**< Valor con la duración de la ultima pulsación */
} * key_status_t;

/* === Private variable declarations =========================================================== */

/**
 * @brief Arreglo de variables para almacenar el estado de cada tecla
 */
static struct key_status_s keys_status[2] = {0};

/* === Private function declarations =========================================================== */

/* === Public variable definitions ============================================================= */

/* === Private variable definitions ============================================================ */

/**
 * @brief Función para procesar el valor capturado y actualizar el estado de la tecla
 *
 * @param key Puntero a la estructura con el estado de la tecla
 * @param current_value Valor capturado por el canal del temporizador
 */
void UpdateStatus(key_status_t key, uint16_t current_value) {
    if (!key->pressed) {
        key->start_value = current_value;
        key->pressed = true;
    } else {
        key->duration = current_value - key->start_value;
        if (key->duration > 9999) {
            key->duration = 9999;
        }
        key->pressed = false;
        key->measured = true;
    }
}
/* === Private function implementation ========================================================= */

/**
 * @brief Rutin de servicio de la interrupción del temporizador
 */
void TIMER1_IRQHandler(void) {
    if (timer_flag_get(TIMER1, TIMER_INT_CH2)) {
        timer_interrupt_flag_clear(TIMER1, TIMER_INT_CH2);
        UpdateStatus(&keys_status[0], TIMER_CH2CV(TIMER1));
        TIMER_CHCTL2(TIMER1) ^= TIMER_CHCTL2_CH2P;
    }
    if (timer_flag_get(TIMER1, TIMER_INT_CH3)) {
        timer_interrupt_flag_clear(TIMER1, TIMER_INT_CH3);
        UpdateStatus(&keys_status[0], TIMER_CH3CV(TIMER1));
        TIMER_CHCTL2(TIMER1) ^= TIMER_CHCTL2_CH3P;
    }
}

/* === Public function implementation ========================================================== */

int main(void) {
    board_t board = BoardCreate();
    DisplayWriteValue(board->display, 0);
    DisplaySetDot(board->display, 2);

    rcu_periph_clock_enable(RCU_AF);
    rcu_periph_clock_enable(RCU_TIMER1);
    gpio_pin_remap_config(GPIO_TIMER1_PARTIAL_REMAP1, ENABLE);

    timer_internal_clock_config(TIMER1);
    timer_prescaler_config(TIMER1, SystemCoreClock / 100000, TIMER_PSC_RELOAD_NOW);
    timer_autoreload_value_config(TIMER1, 0xFFFF);

    // Control de la tecla Aceptar
    timer_input_capture_config(TIMER1, TIMER_CH_2,
                               &(timer_ic_parameter_struct){
                                   .icpolarity = TIMER_IC_POLARITY_RISING,
                                   .icselection = TIMER_IC_SELECTION_DIRECTTI,
                                   .icprescaler = TIMER_IC_PSC_DIV1,
                                   .icfilter = 15,
                               });

    // Control de la tecla Cancelar
    timer_input_capture_config(TIMER1, TIMER_CH_3,
                               &(timer_ic_parameter_struct){
                                   .icpolarity = TIMER_IC_POLARITY_RISING,
                                   .icselection = TIMER_IC_SELECTION_DIRECTTI,
                                   .icprescaler = TIMER_IC_PSC_DIV1,
                                   .icfilter = 15,
                               });

    timer_interrupt_enable(TIMER1, TIMER_INT_CH2);
    timer_interrupt_enable(TIMER1, TIMER_INT_CH3);
    timer_enable(TIMER1);

    timer_interrupt_flag_clear(TIMER1, TIMER_INT_CH2);
    timer_interrupt_flag_clear(TIMER1, TIMER_INT_CH3);
    eclic_irq_enable(TIMER1_IRQn, 1, 1);

    while (1) {
        asm("wfi");
        if (keys_status[0].measured) {
            keys_status[0].measured = false;
            DisplayWriteValue(board->display, keys_status[0].duration);
        }
        if (keys_status[1].measured) {
            keys_status[1].measured = false;
            DisplayWriteValue(board->display, keys_status[1].duration);
        }
        DisplaySetDot(board->display, 2);
    }
}

/* === End of file ============================================================================= */
