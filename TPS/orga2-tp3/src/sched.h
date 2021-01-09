/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Declaracion de funciones del scheduler.
*/

#ifndef __SCHED_H__
#define __SCHED_H__

#include "types.h"
#include "tss.h"

void sched_init();
void reset_esp();
uint16_t sched_next_task();
void desalojar_tarea();

uint8_t game_ended;


/* Estructura que describe una tarea activa de Rick/Morty */
typedef struct task_struct {
  uint16_t idx_gdt;
  uint8_t es_jugador : 1;
  uint8_t y;
  uint8_t x;
  int8_t cap_movimiento;
  uint8_t uso_portal_gun : 1;
  uint8_t status : 1;
  uint8_t isrNumber;
  uint32_t esp0Orig;
} task_t;

void desalojar_tarea_indice(task_t *task, tss_t *tss/* , uint8_t indice */);

extern uint8_t idx_morty;
extern uint8_t idx_rick;

extern task_t tasks_rick[];
extern task_t tasks_morty[];


#endif //  __SCHED_H__
