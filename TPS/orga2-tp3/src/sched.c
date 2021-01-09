/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Definicion de funciones del scheduler
*/

#include "sched.h"

#include "colors.h"
#include "screen.h"
#include "defines.h"
#include "mmu.h"
#include "i386.h"
#include "game.h"

task_t tasks_rick[11] = { 0 };
task_t tasks_morty[11] = { 0 };

void sched_init(void) {
  tasks_rick[0].es_jugador = 0x1;
  tasks_morty[0].es_jugador = 0x1;
  tasks_rick[0].status = 0x1;
  tasks_morty[0].status = 0x1;
  tasks_rick[0].idx_gdt = ((GDT_INDEX_TSS_RICK) << 3) | GDT_RPL_RING_0;
  tasks_morty[0].idx_gdt = ((GDT_INDEX_TSS_MORTY) << 3) | GDT_RPL_RING_0;

  for (int i = 1; i < 11; i++) {
    tasks_rick[i].idx_gdt = ((GDT_INDEX_TSS_RICK + i) << 3) | GDT_RPL_RING_0;
    tasks_morty[i].idx_gdt = ((GDT_INDEX_TSS_MORTY + i) << 3) | GDT_RPL_RING_0;
    tasks_rick[i].esp0Orig = tss_meeseeks_rick[i - 1].esp0;
    tasks_morty[i].esp0Orig = tss_meeseeks_morty[i - 1].esp0;
    tasks_morty[i].status = tasks_rick[i].status = 0x0;
  }
}

uint8_t ultimo_fue_rick = 0;
uint8_t idx_rick = 0;
uint8_t idx_morty = 0;

task_t *current = 0;
uint8_t game_ended = 0;

void _maybe_degradar_cap() {
  int8_t cap = current->cap_movimiento;

  if (current != (task_t *)&tasks_morty && current != (task_t *)&tasks_rick && cap != 1) { //es lo mismo poner el & y no ponerlo
    if (cap > 0) {
      current->cap_movimiento = (-1) * cap;
    }
    else {
      current->cap_movimiento = ((-1) * cap) - 1;
    }
  }
}

uint16_t sched_next_task(void) {
  if (ultimo_fue_rick) {
    ultimo_fue_rick = 0;

    do {
      idx_morty = (idx_morty + 1) % 11;
    } while (tasks_morty[idx_morty].status == 0);

    current = &tasks_morty[idx_morty];
    _maybe_degradar_cap();
    return tasks_morty[idx_morty].idx_gdt;
  }
  else {
    ultimo_fue_rick = 1;

    do {
      idx_rick = (idx_rick + 1) % 11;
    } while (tasks_rick[idx_rick].status == 0);

    current = &tasks_rick[idx_rick];
    _maybe_degradar_cap();
    return tasks_rick[idx_rick].idx_gdt;
  }
}


void desalojar_tarea() {
  current->status = 0;

  if (!current->es_jugador) {
    _clear_cell(current->x, current->y);
  }
}

void desalojar_tarea_indice(task_t *task, tss_t *tss) {

  task->status = 0;
  tss->esp0 = task->esp0Orig;

  //mmu_unmap_page((page_directory_entry *)tss_desalojar->cr3, MEESEEKS_VIRT_START + 2 * PAGE_SIZE * indice);
  //mmu_unmap_page((page_directory_entry *)tss_desalojar->cr3, MEESEEKS_VIRT_START + 2 * PAGE_SIZE * indice + PAGE_SIZE);
}

