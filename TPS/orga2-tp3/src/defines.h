/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Definiciones globales del sistema.
*/

#ifndef __DEFINES_H__
#define __DEFINES_H__
/* MMU */
/* -------------------------------------------------------------------------- */

#define MMU_P (1 << 0)
#define MMU_W (1 << 1)
#define MMU_U (1 << 2)

#define PAGE_SIZE 4096

/* TAREAS */
/* -------------------------------------------------------------------------- */
#define TASK_VIRTUAL               0x1D00000

/* Misc */
/* -------------------------------------------------------------------------- */
// Y Filas
#define SIZE_N 40

// X Columnas
#define SIZE_M 80

/* Indices en la gdt */
/* -------------------------------------------------------------------------- */
#define GDT_IDX_NULL_DESC 0
#define GDT_COUNT         39


/* Offsets en la gdt */
/* -------------------------------------------------------------------------- */
#define GDT_OFF_NULL_DESC (GDT_IDX_NULL_DESC << 3)
#define GDT_OFF_DS_RING_3 (13 << 3)
#define GDT_OFF_CS_RING_3 (11 << 3)
#define GDT_OFF_DS_RING_0 (12 << 3)
#define GDT_OFF_CS_RING_0 (10 << 3)

#define GDT_RPL_RING_3 (0x3)
#define GDT_RPL_RING_0 (0x0)

/* Direcciones de memoria */
/* -------------------------------------------------------------------------- */

// direccion fisica de comienzo del bootsector (copiado)
#define BOOTSECTOR 0x00001000
// direccion fisica de comienzo del kernel
#define KERNEL 0x00001200
// direccion fisica del buffer de video
#define VIDEO 0x000B8000

/* Direcciones virtuales de código, pila y datos */
/* -------------------------------------------------------------------------- */

// direccion virtual del codigo
#define TASK_CODE_VIRTUAL 0x01D00000
#define TASK_PAGES        4

/* Direcciones fisicas de codigos */
/* -------------------------------------------------------------------------- */
/* En estas direcciones estan los códigos de todas las tareas. De aqui se
 * copiaran al destino indicado por TASK_<X>_PHY_START.
 */

/* Direcciones fisicas de directorios y tablas de paginas del KERNEL */
/* -------------------------------------------------------------------------- */
#define KERNEL_PAGE_DIR     (0x00025000)
#define KERNEL_PAGE_TABLE_0 (0x00026000)
#define KERNEL_STACK        (0x00025000)

#define GDT_INDEX_TSS_INIT 15
#define GDT_INDEX_TSS_IDLE 16
#define GDT_INDEX_TSS_RICK 17
#define GDT_INDEX_TSS_MORTY 28

#define IDLE_START 0x00018000
#define MAP_PHY_START 0x400000
#define MEESEEKS_VIRT_START 0x8000000
#define MORTY_PHY_ADDRESS 0x1D04000
#define RICK_PHY_ADDRESS 0x1D00000
#define VIRT_PLAYER_ADDRESS 0x1D00000
#define MORTY_CODE_START_ADDRESS 0x14000
#define RICK_CODE_START_ADDRESS 0x10000

#define GDT_TSS_32_BITS_TYPE (0x9)

#define TSS_IOMAP_ALL_PORTS_DISABLED (0xFFFF) 
#define EFLAGS_DEFAULT_VALUE (0x00000202)
#endif //  __DEFINES_H__
