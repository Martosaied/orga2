    /* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Definicion de estructuras para administrar tareas
*/

#include "tss.h"
#include "defines.h"
#include "kassert.h"
#include "mmu.h"

tss_t tss_initial = { 0 };
tss_t tss_idle = {
    .ss = GDT_OFF_DS_RING_0 | GDT_RPL_RING_0,
    .ds = GDT_OFF_DS_RING_0 | GDT_RPL_RING_0,
    .es = GDT_OFF_DS_RING_0 | GDT_RPL_RING_0,
    .fs = GDT_OFF_DS_RING_0 | GDT_RPL_RING_0,
    .gs = GDT_OFF_DS_RING_0 | GDT_RPL_RING_0,
    .cs = GDT_OFF_CS_RING_0 | GDT_RPL_RING_0,
    .cr3 = KERNEL_PAGE_DIR,
    .eip = IDLE_START,
    .ebp = 0,
    .esp = KERNEL_STACK,
    .eflags = EFLAGS_DEFAULT_VALUE,
    .iomap = TSS_IOMAP_ALL_PORTS_DISABLED,
    .ss0 = GDT_OFF_DS_RING_0 | GDT_RPL_RING_0,
};
tss_t tss_rick = {
    .ss = GDT_OFF_DS_RING_3 | GDT_RPL_RING_3,
    .ds = GDT_OFF_DS_RING_3 | GDT_RPL_RING_3,
    .es = GDT_OFF_DS_RING_3 | GDT_RPL_RING_3,
    .fs = GDT_OFF_DS_RING_3 | GDT_RPL_RING_3,
    .gs = GDT_OFF_DS_RING_3 | GDT_RPL_RING_3,
    .cs = GDT_OFF_CS_RING_3 | GDT_RPL_RING_3,
    .cr3 = 0,
    .eip = VIRT_PLAYER_ADDRESS,
    .ebp = 0,
    .esp = TASK_VIRTUAL + PAGE_SIZE,
    .eflags = EFLAGS_DEFAULT_VALUE,
    .iomap = TSS_IOMAP_ALL_PORTS_DISABLED,
    .ss0 = GDT_OFF_DS_RING_0 | GDT_RPL_RING_0,
};
tss_t tss_morty = {
    .ss = GDT_OFF_DS_RING_3 | GDT_RPL_RING_3,
    .ds = GDT_OFF_DS_RING_3 | GDT_RPL_RING_3,
    .es = GDT_OFF_DS_RING_3 | GDT_RPL_RING_3,
    .fs = GDT_OFF_DS_RING_3 | GDT_RPL_RING_3,
    .gs = GDT_OFF_DS_RING_3 | GDT_RPL_RING_3,
    .cs = GDT_OFF_CS_RING_3 | GDT_RPL_RING_3,
    .cr3 = 0,
    .eip = VIRT_PLAYER_ADDRESS,
    .ebp = 0,
    .esp = TASK_VIRTUAL + PAGE_SIZE,
    .eflags = EFLAGS_DEFAULT_VALUE,
    .iomap = TSS_IOMAP_ALL_PORTS_DISABLED,
    .ss0 = GDT_OFF_DS_RING_0 | GDT_RPL_RING_0,
};

tss_t tss_meeseeks_rick[10] = { 0 };
tss_t tss_meeseeks_morty[10] = { 0 };

void tss_init(void) {
    gdt[GDT_INDEX_TSS_IDLE].base_15_0 = GDT_BASE_LOW((uint32_t)&tss_idle);
    gdt[GDT_INDEX_TSS_IDLE].base_23_16 = GDT_BASE_MID((uint32_t)&tss_idle);
    gdt[GDT_INDEX_TSS_IDLE].base_31_24 = GDT_BASE_HIGH((uint32_t)&tss_idle);

    gdt[GDT_INDEX_TSS_INIT].base_15_0 = GDT_BASE_LOW((uint32_t)&tss_initial);
    gdt[GDT_INDEX_TSS_INIT].base_23_16 = GDT_BASE_MID((uint32_t)&tss_initial);
    gdt[GDT_INDEX_TSS_INIT].base_31_24 = GDT_BASE_HIGH((uint32_t)&tss_initial);

    gdt[GDT_INDEX_TSS_MORTY].base_15_0 = GDT_BASE_LOW((uint32_t)&tss_morty);
    gdt[GDT_INDEX_TSS_MORTY].base_23_16 = GDT_BASE_MID((uint32_t)&tss_morty);
    gdt[GDT_INDEX_TSS_MORTY].base_31_24 = GDT_BASE_HIGH((uint32_t)&tss_morty);

    gdt[GDT_INDEX_TSS_RICK].base_15_0 = GDT_BASE_LOW((uint32_t)&tss_rick);
    gdt[GDT_INDEX_TSS_RICK].base_23_16 = GDT_BASE_MID((uint32_t)&tss_rick);
    gdt[GDT_INDEX_TSS_RICK].base_31_24 = GDT_BASE_HIGH((uint32_t)&tss_rick);

    tss_morty.ss0 = GDT_OFF_DS_RING_0 | GDT_RPL_RING_0;
    tss_rick.ss0 = GDT_OFF_DS_RING_0 | GDT_RPL_RING_0;

    tss_idle.ss0 = GDT_OFF_DS_RING_0 | GDT_RPL_RING_0;

    tss_morty.cr3 = mmu_init_task_dir(MORTY_PHY_ADDRESS, MORTY_CODE_START_ADDRESS);
    tss_rick.cr3 = mmu_init_task_dir(RICK_PHY_ADDRESS, RICK_CODE_START_ADDRESS);

    tss_morty.esp0 = mmu_next_free_kernel_page() + PAGE_SIZE;
    tss_rick.esp0 = mmu_next_free_kernel_page() + PAGE_SIZE;
    tss_idle.esp0 = mmu_next_free_kernel_page() + PAGE_SIZE;

    for (int i = 0; i < 10; i++) {
        tss_meeseeks_morty[i].ss = tss_meeseeks_rick[i].ss = GDT_OFF_DS_RING_3 | GDT_RPL_RING_3;
        tss_meeseeks_morty[i].ds = tss_meeseeks_rick[i].ds = GDT_OFF_DS_RING_3 | GDT_RPL_RING_3;
        tss_meeseeks_morty[i].es = tss_meeseeks_rick[i].es = GDT_OFF_DS_RING_3 | GDT_RPL_RING_3;
        tss_meeseeks_morty[i].fs = tss_meeseeks_rick[i].fs = GDT_OFF_DS_RING_3 | GDT_RPL_RING_3;
        tss_meeseeks_morty[i].gs = tss_meeseeks_rick[i].gs = GDT_OFF_DS_RING_3 | GDT_RPL_RING_3;
        tss_meeseeks_morty[i].cs = tss_meeseeks_rick[i].cs = GDT_OFF_CS_RING_3 | GDT_RPL_RING_3;
        tss_meeseeks_morty[i].eip = tss_meeseeks_rick[i].eip = 0;
        tss_meeseeks_morty[i].ebp = tss_meeseeks_rick[i].ebp = 0;
        tss_meeseeks_morty[i].esp = tss_meeseeks_rick[i].esp = 0;
        tss_meeseeks_morty[i].eflags = tss_meeseeks_rick[i].eflags = EFLAGS_DEFAULT_VALUE;
        tss_meeseeks_morty[i].iomap = tss_meeseeks_rick[i].iomap = TSS_IOMAP_ALL_PORTS_DISABLED;
        tss_meeseeks_rick[i].ss0 = tss_meeseeks_morty[i].ss0 = GDT_OFF_DS_RING_0 | GDT_RPL_RING_0;
        tss_meeseeks_rick[i].esp0 = mmu_next_free_kernel_page() + PAGE_SIZE;
        tss_meeseeks_morty[i].esp0 = mmu_next_free_kernel_page() + PAGE_SIZE;

        tss_meeseeks_rick[i].cr3 = tss_rick.cr3;
        tss_meeseeks_morty[i].cr3 = tss_morty.cr3;


        gdt[GDT_INDEX_TSS_MORTY + i + 1].base_15_0 = GDT_BASE_LOW((uint32_t)&tss_meeseeks_morty[i]);
        gdt[GDT_INDEX_TSS_MORTY + i + 1].base_23_16 = GDT_BASE_MID((uint32_t)&tss_meeseeks_morty[i]);
        gdt[GDT_INDEX_TSS_MORTY + i + 1].base_31_24 = GDT_BASE_HIGH((uint32_t)&tss_meeseeks_morty[i]);

        gdt[GDT_INDEX_TSS_RICK + i + 1].base_15_0 = GDT_BASE_LOW((uint32_t)&tss_meeseeks_rick[i]);
        gdt[GDT_INDEX_TSS_RICK + i + 1].base_23_16 = GDT_BASE_MID((uint32_t)&tss_meeseeks_rick[i]);
        gdt[GDT_INDEX_TSS_RICK + i + 1].base_31_24 = GDT_BASE_HIGH((uint32_t)&tss_meeseeks_rick[i]);
    }
}


uint16_t GDT_BASE_LOW(uint32_t tss) {
    return tss & 0x0000FFFF;
}

uint8_t GDT_BASE_MID(uint32_t tss) {
    return (tss & 0x00FF000) >> 16;
}

uint8_t GDT_BASE_HIGH(uint32_t tss) {
    return (tss >> 24);
}
