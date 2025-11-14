/************************************************************************************************
Copyright (c) 2022-2024, Laboratorio de Microprocesadores
Facultad de Ciencias Exactas y Tecnología, Universidad Nacional de Tucumán
https://www.microprocesadores.unt.edu.ar/

Copyright (c) 2022-2024, Esteban Volentini <evolentini@herrera.unt.edu.ar>

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

/** \brief Longan NANO board configuration implementation
 **
 ** \addtogroup board Board support
 ** \brief Board agnostic configuration module
 ** @{ */

/* === Headers files inclusions =============================================================== */

#include "board.h"
#include "pantalla.h"
#include <gd32vf103.h>

/* === Macros definitions ====================================================================== */

// Definiciones de los recursos asociados a los DIGITs de la pantalla
#define DIGIT_1_BIT  8
#define DIGIT_1_MASK (1 << DIGIT_1_BIT)

#define DIGIT_2_BIT  9
#define DIGIT_2_MASK (1 << DIGIT_2_BIT)

#define DIGIT_3_BIT  10
#define DIGIT_3_MASK (1 << DIGIT_3_BIT)

#define DIGIT_4_BIT  11
#define DIGIT_4_MASK (1 << DIGIT_4_BIT)

#define DIGITS_GPIO  GPIOC
#define DIGITS_CLK   RCU_GPIOC
#define DIGITS_MASK  (DIGIT_1_MASK | DIGIT_2_MASK | DIGIT_3_MASK | DIGIT_4_MASK)

// Definiciones de los recursos asociados a los SEGMENTs de la pantalla

#define SEGMENT_A_BIT  0
#define SEGMENT_A_MASK (1 << SEGMENT_A_BIT)

#define SEGMENT_B_BIT  1
#define SEGMENT_B_MASK (1 << SEGMENT_B_BIT)

#define SEGMENT_C_BIT  2
#define SEGMENT_C_MASK (1 << SEGMENT_C_BIT)

#define SEGMENT_D_BIT  3
#define SEGMENT_D_MASK (1 << SEGMENT_D_BIT)

#define SEGMENT_E_BIT  4
#define SEGMENT_E_MASK (1 << SEGMENT_E_BIT)

#define SEGMENT_F_BIT  5
#define SEGMENT_F_MASK (1 << SEGMENT_F_BIT)

#define SEGMENT_G_BIT  6
#define SEGMENT_G_MASK (1 << SEGMENT_G_BIT)

#define SEGMENTS_GPIO  GPIOC
#define SEGMENTS_CLK   RCU_GPIOC
#define SEGMENTS_MASK                                                                              \
    (SEGMENT_A_MASK | SEGMENT_B_MASK | SEGMENT_C_MASK | SEGMENT_D_MASK | SEGMENT_E_MASK |          \
     SEGMENT_F_MASK | SEGMENT_G_MASK)

#define SEGMENT_DOT_BIT  13
#define SEGMENT_DOT_MASK (1 << SEGMENT_DOT_BIT)
#define SEGMENT_DOT_GPIO GPIOC
#define SEGMENT_DOT_CLK  RCU_GPIOC

/* --- GPIO Direct Functions Keyboard ----------------------------------------------------------- */

#define KEY_ENC_BIT     5
#define KEY_ENC_MASK    (1 << KEY_ENC_BIT)

#define KEY_ACEPT_BIT   10
#define KEY_ACEPT_MASK  (1 << KEY_ACEPT_BIT)

#define KEY_CANCEL_BIT  11
#define KEY_CANCEL_MASK (1 << KEY_CANCEL_BIT)

#define KEY_F1_BIT      12
#define KEY_F1_MASK     (1 << KEY_F1_BIT)

#define KEY_F2_BIT      13
#define KEY_F2_MASK     (1 << KEY_F2_BIT)

#define KEY_F3_BIT      14
#define KEY_F3_MASK     (1 << KEY_F3_BIT)

#define KEY_F4_BIT      15
#define KEY_F4_MASK     (1 << KEY_F4_BIT)

#define KEYS_GPIO       GPIOB
#define KEYS_CLK        RCU_GPIOB
#define KEYS_MASK                                                                                  \
    (KEY_ENC_MASK | KEY_ACEPT_MASK | KEY_CANCEL_MASK | KEY_F1_MASK | KEY_F2_MASK | KEY_F3_MASK |   \
     KEY_F4_MASK)

/* --- Operational parameter ------------------------------------------------------------------- */

#define SCREEN_REFRESH_RATE   40
#define SCREEN_REFRESH_PERIOD (1000 / 4 / SCREEN_REFRESH_RATE)
/* === Private data type declarations ========================================================== */

/* === Private variable declarations =========================================================== */

/* === Private function declarations =========================================================== */

static void DigitsInit(void);

static void SegmentsInit(void);

static void ScreenTurnOff(void);

static void SegmentsTurnOn(uint8_t segments);

static void DigitTurnOn(uint8_t digit);

static void FunctionKeyboardInit(void);

static uint32_t FunctionKeyboardScan(uint8_t key_count);

/* === Public variable definitions ============================================================= */

/* === Private variable definitions ============================================================ */

static struct board_s self[1];

/* === Private function implementation ========================================================= */

static void DigitsInit(void) {
    /* enable the led clock */
    rcu_periph_clock_enable(DIGITS_CLK);

    /* configure led GPIO port */
    GPIO_BC(DIGITS_GPIO) = DIGITS_MASK;
    gpio_init(DIGITS_GPIO, GPIO_MODE_OUT_PP, GPIO_OSPEED_50MHZ, DIGITS_MASK);
}

static void SegmentsInit(void) {
    /* enable the led clock */
    rcu_periph_clock_enable(SEGMENTS_CLK);
    rcu_periph_clock_enable(SEGMENT_DOT_CLK);

    /* configure led GPIO port */
    GPIO_BC(SEGMENTS_GPIO) = SEGMENTS_MASK;
    GPIO_BC(SEGMENT_DOT_GPIO) = SEGMENT_DOT_MASK;
    gpio_init(SEGMENTS_GPIO, GPIO_MODE_OUT_PP, GPIO_OSPEED_50MHZ, SEGMENTS_MASK);
    gpio_init(SEGMENT_DOT_GPIO, GPIO_MODE_OUT_PP, GPIO_OSPEED_50MHZ, SEGMENT_DOT_MASK);
}

static void ScreenTurnOff(void) {
    GPIO_BC(SEGMENTS_GPIO) = SEGMENTS_MASK;
    GPIO_BC(SEGMENT_DOT_GPIO) = SEGMENT_DOT_MASK;
    GPIO_BC(DIGITS_GPIO) = DIGITS_MASK;
}

static void SegmentsTurnOn(uint8_t segments) {
    GPIO_BC(SEGMENTS_GPIO) = SEGMENTS_MASK;
    GPIO_BC(SEGMENT_DOT_GPIO) = SEGMENT_DOT_MASK;

    GPIO_BOP(SEGMENTS_GPIO) = (segments << SEGMENT_A_BIT) & SEGMENTS_MASK;
    if (segments & SEGMENT_P) {
        GPIO_BOP(SEGMENT_DOT_GPIO) = SEGMENT_DOT_MASK;
    }
}

static void DigitTurnOn(uint8_t digit) {
    GPIO_BC(DIGITS_GPIO) = DIGITS_MASK;
    GPIO_BOP(DIGITS_GPIO) = ((1 << digit) << DIGIT_1_BIT) & DIGITS_MASK;
}

static void FunctionKeyboardInit(void) {
    rcu_periph_clock_enable(KEYS_CLK);
    gpio_init(KEYS_GPIO, GPIO_MODE_IN_FLOATING, GPIO_OSPEED_50MHZ, KEYS_MASK);
}

static uint32_t FunctionKeyboardScan(uint8_t key_count) {
    uint32_t result = 0;

    result = (GPIO_ISTAT(KEYS_GPIO) & KEYS_MASK);
    result = (result >> KEY_ACEPT_BIT) | (((~result) & KEY_ENC_MASK) << 1);
    return result;
}

/* === Public function implementation ========================================================== */

void eclic_mtip_handler(void) {
    set_compare_value(get_compare_value() + ms_to_ticks(SCREEN_REFRESH_PERIOD));
    DisplayRefresh(self->display);
}

uint32_t ms_to_ticks(uint32_t value) {
    return ((SystemCoreClock / 4) * value) / 1000;
}

board_t BoardCreate(void) {
    SystemInit();
    SystemCoreClockUpdate();

    eclic_mode_enable();
    eclic_global_interrupt_enable();

    DigitsInit();
    SegmentsInit();
    FunctionKeyboardInit();

    self->display = DisplayCreate(4, &(struct display_driver_s){
                                         .ScreenTurnOff = ScreenTurnOff,
                                         .SegmentsTurnOn = SegmentsTurnOn,
                                         .DigitTurnOn = DigitTurnOn,
                                     });

    eclic_irq_enable(CLIC_INT_TMR, 1, 1);
    set_compare_value(get_timer_value() + ms_to_ticks(SCREEN_REFRESH_PERIOD));

    return self;
}

/* === End of documentation ==================================================================== */

/** @} End of module definition for doxygen */
