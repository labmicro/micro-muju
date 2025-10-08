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

#define RCU_BASE 0x40021000 /**< Dirección base del dispositivo */

typedef struct {
    volatile unsigned int CTL;     /**<  Registro de control */
    volatile unsigned int CFG0;    /**<  Primer registro de configuración del reloj */
    volatile unsigned int INT;     /**<  Control de interrupciones */
    volatile unsigned int APB2RST; /**<  Reinicio de dispositivos del APB2 */
    volatile unsigned int APB1RST; /**<  Reinicio de dispositivos del APB2 */
    volatile unsigned int AHBEN;   /**<  Habilitción de reloj en dispositivos del AHB */
    volatile unsigned int APB2EN;  /**<  Habilitción de reloj en dispositivos del APB2 */
    volatile unsigned int APB1EN;  /**<  Habilitción de reloj en dispositivos del APB1 */
    volatile unsigned int BDCTL;   /**<  Control del dominio de alimntación del backup */
    volatile unsigned int RSTSCK;  /**<  Fuente de reloj y de reinicio */
    volatile unsigned int AHBRST;  /**<  Reinicio de dispositivos del AHB */
    volatile unsigned int CFG1;    /**<  Segundo registro de configuración del reloj */
    volatile unsigned int DSV;     /**<  Configuración de la tensión en modo deep-sleep */
} RCU_TypeDef;

/* === Private data type declarations ========================================================== */

/* === Private variable declarations =========================================================== */

/** Puntero para acceder al dispositivo RCU */
RCU_TypeDef * const RCU = (RCU_TypeDef *)RCU_BASE;

/* === Private function declarations =========================================================== */

/* === Public variable definitions ============================================================= */

/* === Private variable definitions ============================================================ */

/* === Private function implementation ========================================================= */

/* === Public function implementation ========================================================== */

void habilitar_reloj(void) {
    RCU->APB2EN |= (3 << 2);
}

/* === End of file ============================================================================= */
