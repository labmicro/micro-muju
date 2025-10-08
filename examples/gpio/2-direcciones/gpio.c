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

/* === Macros definitions ====================================================================== */

#define GPIOA_BASE 0x40010800 /**< Dirección base del dispositivo GPIOA */
#define GPIOB_BASE 0x40010C00 /**< Dirección base del dispositivo GPIOB */
#define GPIO_CTL0  0x00       /**< Primer registro de control (terminales 0 a 7) */
#define GPIO_CTL1  0x04       /**< Segundo registro de control (terminales 8 a 15) */
#define GPIO_ISTAT 0x08       /**< Registro de estado de las entradas */
#define GPIO_OCTL  0x0C       /**< Registro de control de las salidas */
#define GPIO_BOP   0x10       /**< Registro de puesta a 1 de las salidas */
#define GPIO_BC    0x14       /**< Registro de puesta a 0 de las salidas */
#define GPIO_LOCK  0x1C       /**< Registro de bloqueo de configuración */

/* === Private data type declarations ========================================================== */

/* === Private variable declarations =========================================================== */

/* === Private function declarations =========================================================== */

/* === Public variable definitions ============================================================= */

/* === Private variable definitions ============================================================ */

/* === Private function implementation ========================================================= */

/* === Public function implementation ========================================================== */

void configurar_led(int terminal) {
    unsigned int valor = *(volatile unsigned int *)(GPIOA_BASE + GPIO_CTL0);
    valor &= ~(0xF << (terminal * 4));
    valor |= (0x2 << (terminal * 4));
    *(volatile unsigned int *)(GPIOA_BASE + GPIO_CTL0) = valor;
}

void prender_led(int terminal) {
    *(volatile unsigned int *)(GPIOA_BASE + GPIO_BOP) = (1 << terminal);
}

void apagar_led(int terminal) {
    *(volatile unsigned int *)(GPIOA_BASE + GPIO_BC) = (1 << terminal);
}

/* === End of file ============================================================================= */
