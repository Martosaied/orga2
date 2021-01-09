/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
*/

#include "game.h"
#include "prng.h"
#include "types.h"
#include "screen.h"
#include "defines.h"
#include "i386.h"

#define mem_range_base (0x1D00000)
#define mem_range_end (0x1D03FFF)
#define puntaje_a_sumar 425

coordenate_t megaSemillas[40] = { 0 };
uint16_t puntaje_rick = 0;
uint16_t puntaje_morty = 0;

uint8_t _abs(int8_t x) {
  return x < 0 ? (-1) * x : x;
}

uint32_t _resto(int32_t a, int32_t b) {
  int32_t res = a % b;
  if (res < 0) {
    res += b;
  }
  return res;
}

void _move_meeseeks(page_directory_entry *cr3, uint8_t currX, uint8_t currY, uint8_t idx_meeseeks) {

  // uint8_t idx_meeseeks = (ultimo_fue_rick ? idx_rick : idx_morty) - 1;
  vaddr_t mem_slot = MEESEEKS_VIRT_START + 2 * PAGE_SIZE * idx_meeseeks;
  uint32_t new_map_cell = MAP_PHY_START + 0x2000 /* 8Kib */ * currY * 80 + 0x2000 /* 8Kib */ * currX;
  uint32_t new_virt_start = new_map_cell;


  mmu_map_page(cr3, new_virt_start, new_map_cell, 0, 1); //mapeo la celda nueva
  mmu_map_page(cr3, new_virt_start + PAGE_SIZE, new_map_cell + PAGE_SIZE, 0, 1);

  char *src = (char *)mem_slot;
  char *dst = (char *)new_virt_start;
  uint32_t current = rcr3();
  lcr3((uint32_t)cr3);
  for (int i = 0; i < 2 * PAGE_SIZE; ++i) { //copio el codigo
    dst[i] = src[i];
  }
  lcr3(current);

  mmu_map_page(cr3, mem_slot, new_map_cell, 1, 1);
  mmu_map_page(cr3, mem_slot + PAGE_SIZE, new_map_cell + PAGE_SIZE, 1, 1);


  mmu_unmap_page(cr3, new_virt_start);
  mmu_unmap_page(cr3, new_virt_start + PAGE_SIZE);
}

void _clear_cell(uint8_t x, uint8_t y) {
  print("0", x, y, C_FG_GREEN | C_BG_GREEN);
}

void _print_meesek(uint8_t x, uint8_t y, uint8_t es_rick) {
  print("K", x, y, es_rick ? C_BG_GREEN | C_FG_RED : C_BG_GREEN | C_FG_BLUE);
}

void _print_puntaje() {
  print_dec(puntaje_rick, 7, 8, 44, C_FG_WHITE | C_BG_RED);
  print_dec(puntaje_morty, 7, 65, 44, C_FG_WHITE | C_BG_BLUE);
}

coordenate_t *_search_semilla(uint8_t x, uint8_t y) {
  for (uint8_t i = 0; i < 40; i++) {
    if (megaSemillas[i].present && megaSemillas[i].x == x && megaSemillas[i].y == y) {
      return &megaSemillas[i];
    }
  }
  return 0;
}

void game_init(void) {
  for (int i = 0; i < 40; i++) {
    megaSemillas[i].x = _resto(rand(), SIZE_M);
    megaSemillas[i].y = _resto(rand(), SIZE_N);
    megaSemillas[i].present = 1;
    print("s", megaSemillas[i].x, megaSemillas[i].y, C_FG_LIGHT_BROWN | C_BG_GREEN);
  }
  _print_puntaje();
}

void game_checkEndOfGame() {
  uint8_t termino = 1;
  char *ganador = "GANO: RICK";
  for (int i = 0; i < SIZE_N; i++) {
    if (megaSemillas[i].present) {
      termino = 0;
    }
  }
  if (termino == 1) {
    if (puntaje_rick == puntaje_morty)
      ganador = "FUE EMPATE JU JU";
    if (puntaje_morty > puntaje_rick)
      ganador = "GANO: MORTY";
  }

  if (!tasks_morty[0].status) {
    ganador = "GANO: RICK";
    termino = 1;
  }
  if (!tasks_rick[0].status) {
    ganador = "GANO: MORTY";
    termino = 1;
  }
  if (!tasks_rick[0].status && !tasks_morty[0].status) {
    ganador = "FUE EMPATE JU JU";
    termino = 1;
  }
  if (!tasks_rick[0].status) {
    termino = 1;
  }
  if (termino) {
    print("                              ", 27, 7, C_FG_WHITE | C_BG_BLACK);
    print("                              ", 27, 8, C_FG_WHITE | C_BG_BLACK);
    print("      TERMINO Y ", 27, 8, C_FG_WHITE | C_BG_BLACK);
    print(ganador, 28 + 15, 8, C_FG_WHITE | C_BG_BLACK);
    print("                              ", 27, 9, C_FG_WHITE | C_BG_BLACK);
    while (1) {
    }
  }
}

uint8_t move(int8_t offsetX, int8_t offsetY) {
  if (current == (task_t *)&tasks_morty || current == (task_t *)&tasks_rick) { //recordar que las primeras posiciones de ambos arreglos son las tareas de los jugadores
    desalojar_tarea();
    return 0;
  }

  uint8_t oldX = current->x;
  uint8_t oldY = current->y;

  uint8_t currX = _resto(oldX + offsetX, SIZE_M);
  uint8_t currY = _resto(oldY + offsetY, SIZE_N);

  uint16_t manhattan = _abs(offsetX) + _abs(offsetY);
  if (manhattan > _abs(current->cap_movimiento)) {
    return 0;
  }
  current->x = currX;
  current->y = currY;
  _clear_cell(oldX, oldY);

  //checkear si en la nueva posicion hay una semilla
  coordenate_t *semilla = _search_semilla(currX, currY);
  if (semilla) {
    comer_semilla(semilla);
    desalojar_tarea();
    return 1;
  }

  _print_meesek(currX, currY, ultimo_fue_rick);

  //ahora quiero copiar el codigo desde *code hasta la posicion (x, y) del mapa
  page_directory_entry *cr3 = (page_directory_entry *)rcr3();

  _move_meeseeks(cr3, currX, currY, (ultimo_fue_rick ? idx_rick : idx_morty) - 1);

  return 1;
}

uint8_t create_mrmeeseeks(uint32_t *code, uint8_t x, uint8_t y) {
  if ((uint32_t)code < mem_range_base || (uint32_t)code > mem_range_end) {
    desalojar_tarea();
    return 0;
  }

  //checkear que lo llamo rick o morty
  if (current != (task_t *)&tasks_morty && current != (task_t *)&tasks_rick) {
    desalojar_tarea();
    return 0;
  }
  //checkear que las coordenadas son validas
  if (SIZE_M - 1 < x || SIZE_N - 1 < y) {
    desalojar_tarea();
    return 0;
  }

  //checkear que no se llego al límite de meeseeks
  int8_t i = 1;

  task_t *tasks = ultimo_fue_rick ? tasks_rick : tasks_morty;

  while (i < 11 && tasks[i].status == 1)
    i++;

  if (i == 11) {
    return 0;
  }
  uint8_t tss_meeseeks_idx = i - 1; //porque el indice que acabamos de obtener es sobre un array donde la primera posicion no es un meeseeks. en los proximos usos de i, los arrays van a ser del 0 al 9 todos meeseeks

  //checkear si en la posicion pasada por parametro ya hay una semilla
  coordenate_t *semilla = _search_semilla(x, y);
  if (semilla) {
    comer_semilla(semilla);
    return 0;
  }
  //ahora quiero copiar el codigo desde *code hasta la posicion (x, y) del mapa

  uint32_t map_cell = MAP_PHY_START + 2 * PAGE_SIZE * y * SIZE_M + 2 * PAGE_SIZE * x;

  page_directory_entry *cr3 = (page_directory_entry *)rcr3();

  //mapeo la celda para poder escribir en ella

  uint32_t virt_start = map_cell;

  mmu_map_page(cr3, virt_start, map_cell, 0, 1);
  mmu_map_page(cr3, virt_start + PAGE_SIZE, map_cell + PAGE_SIZE, 0, 1);

  char *src = (char *)code;
  char *dst = (char *)virt_start;

  for (int j = 0; j < PAGE_SIZE; ++j)
    dst[j] = src[j];

  for (int j = PAGE_SIZE; j < 2 * PAGE_SIZE; ++j)
    dst[j] = 0;

  mmu_unmap_page(cr3, virt_start);
  mmu_unmap_page(cr3, virt_start + PAGE_SIZE);

  tss_t *tss = ultimo_fue_rick ? &tss_meeseeks_rick[tss_meeseeks_idx] : &tss_meeseeks_morty[tss_meeseeks_idx];
  vaddr_t mem_slot = MEESEEKS_VIRT_START + 2 * PAGE_SIZE * tss_meeseeks_idx;

  mmu_map_page(cr3, mem_slot, map_cell, 1, 1);
  mmu_map_page(cr3, mem_slot + PAGE_SIZE, map_cell + PAGE_SIZE, 1, 1);

  tss->eip = mem_slot;
  tss->esp = mem_slot + 2 * PAGE_SIZE;
  tss->cs = GDT_OFF_CS_RING_3 | GDT_RPL_RING_3;
  tss->ss = GDT_OFF_DS_RING_3 | GDT_RPL_RING_3;
  tss->esp0 = tasks[i].esp0Orig;

  _print_meesek(x, y, ultimo_fue_rick);

  task_t *newTask = ultimo_fue_rick ? &tasks_rick[i] : &tasks_morty[i];
  newTask->uso_portal_gun = 0;
  newTask->x = x;
  newTask->y = y;
  newTask->status = 1;
  newTask->cap_movimiento = 7;
  newTask->isrNumber = 0;
  return mem_slot;
}
void use_portal_gun() {
  if (current == (task_t *)&tasks_morty || current == (task_t *)&tasks_rick) {
    desalojar_tarea();
    return;
  }
  if(current->uso_portal_gun){
    return;
  }
  task_t *enemigos = ultimo_fue_rick ? tasks_morty : tasks_rick;

  uint8_t i = 1;
  uint8_t num_rand = rand();
  uint8_t num_rand2 = rand();
  uint8_t rand = _resto((uint32_t)num_rand, 10) + 1;
  if (enemigos[rand].status) {
    i = rand;
  }
  else {
    while (i < 11 && !enemigos[i].status) {
      i++;
    }
    if (i == 11) {
      return; //no hay meeseeks enemigos
    }
  }
  tss_t *tss_enemiga = ultimo_fue_rick ? &tss_meeseeks_morty[i - 1] : &tss_meeseeks_rick[i - 1];

  current->uso_portal_gun = 1;

  uint8_t oldY = enemigos[i].y;
  uint8_t oldX = enemigos[i].x;
  uint8_t currX = enemigos[i].x = _resto((uint32_t)num_rand, SIZE_M);
  uint8_t currY = enemigos[i].y = _resto((uint32_t)num_rand2, SIZE_N);

  _clear_cell(oldX, oldY);

  //checkear si en la nueva posicion hay una semilla

  coordenate_t *semilla = _search_semilla(currX, currY);
  if (semilla) {
    comer_semilla(semilla);
    desalojar_tarea_indice(&enemigos[i], tss_enemiga);
    return;
  }

  _print_meesek(currX, currY, 1 - ultimo_fue_rick);
  
  _move_meeseeks((page_directory_entry *)tss_enemiga->cr3, currX, currY, i - 1);
}

void look(int8_t *x, int8_t *y) {
  if (current == (task_t *)&tasks_morty || current == (task_t *)&tasks_rick) {
    *x = *y = -1;
  }
  else {
    uint16_t min = 0xFFFF;

    uint8_t currX = current->x;
    uint8_t currY = current->y;
    for (uint8_t i = 0; i < 40; i++) {
      if (megaSemillas[i].present == 1) {
        int8_t offsetX = megaSemillas[i].x - currX;
        int8_t offsetY = megaSemillas[i].y - currY;
        uint16_t manhattan = _abs(offsetX) + _abs(offsetY);
        if (manhattan < min) {
          min = manhattan;
          (*x) = offsetX;
          (*y) = offsetY;
        }
      }
    }
  }
}

void comer_semilla(coordenate_t *semilla) {
  _clear_cell(semilla->x, semilla->y);
  if (ultimo_fue_rick) {
    puntaje_rick += puntaje_a_sumar;
  }
  else {
    puntaje_morty += puntaje_a_sumar;
  }
  semilla->present = 0;
  _print_puntaje();
}
