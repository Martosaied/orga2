/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Declaracion de las rutinas asociadas al juego.
*/

#ifndef __GAME_H__
#define __GAME_H__

#include "sched.h"
#include "tss.h"
#include "mmu.h"

typedef enum e_task_type {
  Rick = 1,
  Morty = 2,
  Meeseeks = 3,
} task_type_t;

typedef struct coor_s {
  uint8_t x;
  uint8_t y;
  uint8_t present;
} coordenate_t;

void game_init(void);
void use_portal_gun(void);

void game_checkEndOfGame();
uint8_t create_mrmeeseeks(uint32_t* code, uint8_t x, uint8_t y);
void _clear_cell(uint8_t x, uint8_t y);
void comer_semilla(coordenate_t *semilla);

extern task_t* current;
extern uint8_t ultimo_fue_rick;

#endif //  __GAME_H__
