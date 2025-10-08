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

/** Valor para configurar un terminal como salida push-pull con velocidad de hasta 2 MHz */
#define GPIO_OUTPUT_2MHZ_PUSH_PULL 0x02

/** Permite acceder a un registro del GPIOA */
#define GPIOA(offset) *(volatile unsigned int *)(GPIOA_BASE + offset)
/** Permite acceder a un registro del GPIOB */
#define GPIOB(offset) *(volatile unsigned int *)(GPIOB_BASE + offset)

/** Define los bit de configuracion de un terminal GPIO */
#define GPIO_CTL_SET(value, pin) (value << ((pin & 7) << 2))
/** Genera la mascara para borrar los bit de configuracion de un terminal GPIO */
#define GPIO_CTL_MASK(pin) ~GPIO_CTL_SET(0x0F, pin)
/** Genera la mascara para operar en un terminal GPIO */
#define GPIO_BIT_MASK(pin) (1 << pin)

/* === Private data type declarations ========================================================== */

/* === Private variable declarations =========================================================== */

/* === Private function declarations =========================================================== */

/* === Public variable definitions ============================================================= */

/* === Private variable definitions ============================================================ */

/* === Private function implementation ========================================================= */

/* === Public function implementation ========================================================== */

void configurar_led(int terminal) {
    unsigned int valor = GPIOA(GPIO_CTL0);
    valor &= GPIO_CTL_MASK(terminal);
    valor |= GPIO_CTL_SET(GPIO_OUTPUT_2MHZ_PUSH_PULL, terminal);
    GPIOA(GPIO_CTL0) = valor;
}

void prender_led(int terminal) {
    GPIOA(GPIO_BOP) = GPIO_BIT_MASK(terminal);
}

void apagar_led(int terminal) {
    GPIOA(GPIO_BC) = GPIO_BIT_MASK(terminal);
}

/* === End of file ============================================================================= */
