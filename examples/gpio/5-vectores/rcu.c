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

#define RCU_BASE    0x40021000 /**< Dirección base del dispositivo */
#define RCU_CTL     0          /**< Registro de control */
#define RCU_CFG0    1          /**< Primer registro de configuración del reloj */
#define RCU_INT     2          /**< Control de interrupciones */
#define RCU_APB2RST 3          /**< Reinicio de dispositivos del APB2 */
#define RCU_APB1RST 4          /**< Reinicio de dispositivos del APB2 */
#define RCU_AHBEN   5          /**< Habilitción de reloj en dispositivos del AHB */
#define RCU_APB2EN  6          /**< Habilitción de reloj en dispositivos del APB2 */
#define RCU_APB1EN  7          /**< Habilitción de reloj en dispositivos del APB1 */
#define RCU_BDCTL   8          /**< Control del dominio de alimntación del backup */
#define RCU_RSTSCK  9          /**< Fuente de reloj y de reinicio */
#define RCU_AHBRST  10         /**< Reinicio de dispositivos del AHB */
#define RCU_CFG1    11         /**< Segundo registro de configuración del reloj */
#define RCU_DSV     13         /**< Configuración de la tensión en modo deep-sleep */

/* === Private data type declarations ========================================================== */

/* === Private variable declarations =========================================================== */

/** Puntero para acceder al dispositivo RCU */
volatile unsigned int * const RCU = (volatile unsigned int *)RCU_BASE;

/* === Private function declarations =========================================================== */

/* === Public variable definitions ============================================================= */

/* === Private variable definitions ============================================================ */

/* === Private function implementation ========================================================= */

/* === Public function implementation ========================================================== */

void habilitar_reloj(void) {
    RCU[RCU_APB2EN] |= (3 << 2);
}

/* === End of file ============================================================================= */
