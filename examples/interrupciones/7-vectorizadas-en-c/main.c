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

#include "placa.h"
#include "riscv_encoding.h"
#include <gd32vf103.h>

/* === Macros definitions ====================================================================== */

#define LED_ROJO       1  /**< Numero de terminal que controla el led verde */
#define LED_VERDE      3  /**< Numero de terminal que controla el led rojo */
#define LED_AZUL       2  /**< Numero de terminal que controla el led azul */
#define TECLA_CANCELAR 10 /**< Numero de terminal de la tecla que genere un error */

/* === Private data type declarations ========================================================== */

/* === Private variable declarations =========================================================== */

/* === Private function declarations =========================================================== */

/* === Public variable definitions ============================================================= */

/* === Private variable definitions ============================================================ */

/* === Private function implementation ========================================================= */

/**
 * @brief Rutina para obtener la cantidad de ciclos de reloj del temporizador del sistema a partir
 * de una cantidad de tiempo en milisengundos
 *
 * @param value Valor en milisegundos de la espera
 * @return Cantidad de ciclos en el termporizador del sistema
 */
uint32_t ms_to_ticks(uint32_t value) {
    return ((SystemCoreClock / 4) * value) / 1000;
}

/**
 * @brief Función para leer el valor del registro de comparación del temporizador del sistema
 *
 * @return Valor actual del registro de comparación del temporizador
 */
uint64_t timer_compare(void) {
    uint32_t hi = *(volatile uint32_t *)(TIMER_CTRL_ADDR + TIMER_MTIMECMP + 4);
    uint32_t lo = *(volatile uint32_t *)(TIMER_CTRL_ADDR + TIMER_MTIMECMP);
    return ((uint64_t)hi << 32) | lo;
}

/**
 * @brief Función para actualizar el registro de comparación del temporizador en forma segura
 *
 * @param value Nuevo valor para el registro de compraación del temporizador del sistema
 */
void timer_update(uint64_t value) {
    volatile void * addr = (uint8_t *)(TIMER_CTRL_ADDR + TIMER_MTIMECMP);
    // Se escribe la parte baja con 0xFFFFFFFF para prevenir una falsa comparación
    asm volatile("sw %0, 0(%1)" : : "r"(-1U), "r"(addr));
    // Se actualiza la parte alta
    asm volatile("sw %0, 0(%1)" : : "r"((uint32_t)(value >> 32)), "r"(addr + 4));
    // Se actualiza la parte baja
    asm volatile("sw %0, 0(%1)" : : "r"((uint32_t)(value)), "r"(addr));
}

/**
 * @brief Rutina de servicio para atender las excepciones e interrupciones
 */
__attribute__((interrupt("machine"), aligned(64))) void trap_entry(void) {
    apagar_salida(LED_VERDE);
    prender_salida(LED_ROJO);
    while (1);
}

void eclic_mtip_handler(void) {
    timer_update(timer_compare() + ms_to_ticks(500));
    cambiar_led(LED_VERDE);
}

/* === Public function implementation ========================================================== */

int main(void) {
    SystemCoreClockUpdate();
    configurar_placa();

    eclic_mode_enable();
    eclic_irq_enable(CLIC_INT_TMR, 1, 1);
    eclic_global_interrupt_enable();

    timer_update(get_timer_value() + ms_to_ticks(500));
    while (1) {
        asm("wfi");
        if (leer_entrada(TECLA_CANCELAR)) {
            asm volatile(".word 0xFFFFFFFF");
        }
    }
}

/* === End of file ============================================================================= */
