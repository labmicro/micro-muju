/************************************************************************************************
Copyright (c) 2022-2023, Laboratorio de Microprocesadores
Facultad de Ciencias Exactas y Tecnología, Universidad Nacional de Tucumán
https://www.microprocesadores.unt.edu.ar/

Copyright (c) 2022-2023, Esteban Volentini <evolentini@herrera.unt.edu.ar>

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

/** \brief Hello World sample application
 **
 ** \addtogroup samples Samples
 ** \brief Samples applications with MUJU Framwork
 ** @{ */

/* === Headers files inclusions =============================================================== */

#include "bsp.h"
#include "systick.h"

#include <stddef.h>
#include <stdio.h>
#include <string.h>

/* === Macros definitions ====================================================================== */

/* === Private data type declarations ========================================================== */

/* === Private variable declarations =========================================================== */

/* === Private function declarations =========================================================== */

/* === Public variable definitions ============================================================= */

/* === Private variable definitions ============================================================ */

/* === Private function implementation ========================================================= */

/* === Public function implementation ========================================================== */

int main(void) {
    uint32_t valor = 0;
    uint32_t divisor = 0;
    uint32_t contador = 0;
    uint8_t variable = 0;
    uint16_t temperatura = 0;
    uint16_t luminosidad = 0;
    uint16_t decimas = 0;
    uint16_t segundos = 0;
    uint8_t tecla;

    board_t board = BoardCreate();

    DisplayWriteValue(board->display, valor);
    adc_software_trigger_enable(ADC0, ADC_INSERTED_CHANNEL);

    while (1) {
        if (divisor == 0) {
            divisor = LedRgbDemoTick();
        } else {
            divisor--;
        }

        decimas = decimas + 1;
        if (decimas >= 100) {
            luminosidad = AnalogRead(ADC_INSERTED_CHANNEL_0);
            temperatura = AnalogRead(ADC_INSERTED_CHANNEL_1);
            adc_software_trigger_enable(ADC0, ADC_INSERTED_CHANNEL);
        }

        if (variable) {
            if (segundos == 0) {
                switch (variable) {
                case 1:
                    DisplayWriteValue(board->display, temperatura);
                    break;
                case 2:
                    DisplayWriteValue(board->display, luminosidad);
                    break;
                }
            }
            segundos = (segundos + 1) % 500;
        }

        contador = (contador + 1) % 50;
        if (contador == 0) {

            if (KeyboardScan(board->functions)) {
                if (KeyboardChangeToPressed(board->functions, 2)) {
                    valor = (valor + 1000) % 10000;
                    variable = 0;
                    SonidoPlayNote(SONIDO_DO_6, SONIDO_NEGRA);
                }
                if (KeyboardChangeToPressed(board->functions, 3)) {
                    valor = (valor + 100) % 10000;
                    variable = 0;
                    SonidoPlayNote(SONIDO_MI_6, SONIDO_NEGRA);
                }
                if (KeyboardChangeToPressed(board->functions, 4)) {
                    valor = (valor + 10) % 10000;
                    variable = 0;
                    SonidoPlayNote(SONIDO_SOL_6, SONIDO_NEGRA);
                }
                if (KeyboardChangeToPressed(board->functions, 5)) {
                    valor = (valor + 1) % 10000;
                    variable = 0;
                    SonidoPlayNote(SONIDO_SI_6, SONIDO_NEGRA);
                }
                if (KeyboardChangeToPressed(board->functions, 0)) {
                    // valor = 9999;
                    variable = 1;
                    segundos = 0;
                    SonidoPlayMelody(LA_CUCARACHA);
                }
                if (KeyboardChangeToPressed(board->functions, 1)) {
                    // valor = 0;
                    variable = 2;
                    segundos = 0;
                    SonidoPlayMelody(QUINTA);
                }
                if (KeyboardChangeToPressed(board->functions, 6)) {
                    // valor = 0;
                    variable = 3;
                    SonidoPlayMelody(ESCALA);
                }
                if (variable == 0) {
                    DisplayWriteValue(board->display, valor);
                }
            }
        }

        if (KeyboardScan(board->numeric)) {
            tecla = KeyboardGetFirstPressed(board->numeric);
            if (tecla != 0xFF) {
                valor = tecla + 1;
                variable = 0;
            }
            DisplayWriteValue(board->display, valor);
        }

        DisplayRefresh(board->display);

        delay_1ms(1);
    }
    return 0;
}

/* === End of documentation ==================================================================== */

/** @} End of module definition for doxygen */
