/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Definicion de la tabla de descriptores globales
*/

#include "gdt.h"
#include "tss.h"

gdt_entry_t gdt[GDT_COUNT] = {
    /* Descriptor nulo*/
    /* Offset = 0x00 */
    [GDT_IDX_NULL_DESC] =
        {
            .limit_15_0 = 0x0000,
            .base_15_0 = 0x0000,
            .base_23_16 = 0x00,
            .type = 0x0,
            .s = 0x00,
            .dpl = 0x00,
            .p = 0x00,
            .limit_19_16 = 0x00,
            .avl = 0x0,
            .l = 0x0,
            .db = 0x1,
            .g = 0x00,
            .base_31_24 = 0x00,
        },
    [10] =
        {
            .limit_15_0 = 0xC8FF,
            .base_15_0 = 0x0000,
            .base_23_16 = 0x00,
            .type = 0x8, //code, execute
            .s = 0x1,    //data segmente (not system)
            .dpl = 0x00,
            .p = 0x1, //esta presente
            .limit_19_16 = 0x00,
            .avl = 0x0,
            .l = 0x0,  //32 bits
            .db = 0x1, //32-bit code and data segments
            .g = 0x1,
            .base_31_24 = 0x00,
        },
    [11] =
        {
            .limit_15_0 = 0xC8FF,
            .base_15_0 = 0x0000,
            .base_23_16 = 0x00,
            .type = 0x8, //code, execute
            .s = 0x1,    //data segmente (not system)
            .dpl = 0x03,
            .p = 0x1, //esta presente
            .limit_19_16 = 0x00,
            .avl = 0x0,
            .l = 0x0,  //32 bits
            .db = 0x1, //32-bit code and data segments
            .g = 0x1,
            .base_31_24 = 0x00,
        },
    [12] =
        {
            .limit_15_0 = 0xC8FF,
            .base_15_0 = 0x0000,
            .base_23_16 = 0x00,
            .type = 0x2, //data, read/write
            .s = 0x1,    //data segmente (not system)
            .dpl = 0x00,
            .p = 0x1, //esta presente
            .limit_19_16 = 0x00,
            .avl = 0x0,
            .l = 0x0,  //32 bits
            .db = 0x1, //32-bit code and data segments
            .g = 0x1,
            .base_31_24 = 0x00,
        },
    [13] =
        {
            .limit_15_0 = 0xC8FF,
            .base_15_0 = 0x0000,
            .base_23_16 = 0x00,
            .type = 0x2, //data, read/write
            .s = 0x1,    //data segmente (not system)
            .dpl = 0x03,
            .p = 0x1, //esta presente
            .limit_19_16 = 0x00,
            .avl = 0x0,
            .l = 0x0,  //32 bits
            .db = 0x1, //32-bit code and data segments
            .g = 0x1,
            .base_31_24 = 0x00,
        },
    [14] =
        {
            .limit_15_0 = 0x7FFF,
            .base_15_0 = 0x8000,
            .base_23_16 = 0xB,
            .type = 0x2, //data, read/write
            .s = 0x1,    //data segmente (not system)
            .dpl = 0x03,
            .p = 0x1, //esta presente
            .limit_19_16 = 0x00,
            .avl = 0x0,
            .l = 0x0,  //32 bits
            .db = 0x1, //32-bit code and data segments
            .g = 0x0,
            .base_31_24 = 0x00,
        },
    [GDT_INDEX_TSS_INIT] = {
        .limit_15_0 = sizeof(tss_t) - 1,
        .base_15_0 = 0x000,
        .base_23_16 = 0x0,
        .type = GDT_TSS_32_BITS_TYPE, //data, read/write  (el valor es 0x09 = 1001)
        .s = 0x0,                     //system
        .dpl = 0x00,
        .p = 0x1, //esta presente
        .limit_19_16 = 0x00,
        .avl = 0x0,
        .l = 0x0, //32 bits
        .db = 0x0,
        .g = 0x0,
        .base_31_24 = 0x00,
    },
    [GDT_INDEX_TSS_IDLE] = {
        .limit_15_0 = sizeof(tss_t) - 1,
        .base_15_0 = 0x000,
        .base_23_16 = 0x0,
        .type = GDT_TSS_32_BITS_TYPE, //data, read/write  (el valor es 0x09 = 1001)
        .s = 0x0,                     //system
        .dpl = 0x00,
        .p = 0x1, //esta presente
        .limit_19_16 = 0x00,
        .avl = 0x0,
        .l = 0x0, //32 bits
        .db = 0x0,
        .g = 0x0,
        .base_31_24 = 0x00,
    },
    [GDT_INDEX_TSS_RICK] = {
        .limit_15_0 = sizeof(tss_t) - 1,
        .base_15_0 = 0x000,
        .base_23_16 = 0x0,
        .type = GDT_TSS_32_BITS_TYPE, //data, read/write  (el valor es 0x09 = 1001)
        .s = 0x0,                     //system
        .dpl = 0x00,
        .p = 0x1, //esta presente
        .limit_19_16 = 0x00,
        .avl = 0x0,
        .l = 0x0, //32 bits
        .db = 0x0,
        .g = 0x0,
        .base_31_24 = 0x00,
    },
    [GDT_INDEX_TSS_MORTY] = {
        .limit_15_0 = sizeof(tss_t) - 1,
        .base_15_0 = 0x000,
        .base_23_16 = 0x0,
        .type = GDT_TSS_32_BITS_TYPE, //data, read/write  (el valor es 0x09 = 1001)
        .s = 0x0,                     //system
        .dpl = 0x00,
        .p = 0x1, //esta presente
        .limit_19_16 = 0x00,
        .avl = 0x0,
        .l = 0x0, //32 bits
        .db = 0x0,
        .g = 0x0,
        .base_31_24 = 0x00,
    },
    [GDT_INDEX_TSS_RICK + 1] = {
        .limit_15_0 = sizeof(tss_t) - 1,
        .base_15_0 = 0x000,
        .base_23_16 = 0x0,
        .type = GDT_TSS_32_BITS_TYPE, //data, read/write  (el valor es 0x09 = 1001)
        .s = 0x0,                     //system
        .dpl = 0x00,
        .p = 0x1, //esta presente
        .limit_19_16 = 0x00,
        .avl = 0x0,
        .l = 0x0, //32 bits
        .db = 0x0,
        .g = 0x0,
        .base_31_24 = 0x00,
    },
    [GDT_INDEX_TSS_MORTY + 1] = {
        .limit_15_0 = sizeof(tss_t) - 1,
        .base_15_0 = 0x000,
        .base_23_16 = 0x0,
        .type = GDT_TSS_32_BITS_TYPE, //data, read/write  (el valor es 0x09 = 1001)
        .s = 0x0,                     //system
        .dpl = 0x00,
        .p = 0x1, //esta presente
        .limit_19_16 = 0x00,
        .avl = 0x0,
        .l = 0x0, //32 bits
        .db = 0x0,
        .g = 0x0,
        .base_31_24 = 0x00,
    },
    [GDT_INDEX_TSS_RICK + 2] = {
        .limit_15_0 = sizeof(tss_t) - 1,
        .base_15_0 = 0x000,
        .base_23_16 = 0x0,
        .type = GDT_TSS_32_BITS_TYPE, //data, read/write  (el valor es 0x09 = 1001)
        .s = 0x0,                     //system
        .dpl = 0x00,
        .p = 0x1, //esta presente
        .limit_19_16 = 0x00,
        .avl = 0x0,
        .l = 0x0, //32 bits
        .db = 0x0,
        .g = 0x0,
        .base_31_24 = 0x00,
    },
    [GDT_INDEX_TSS_MORTY + 2] = {
        .limit_15_0 = sizeof(tss_t) - 1,
        .base_15_0 = 0x000,
        .base_23_16 = 0x0,
        .type = GDT_TSS_32_BITS_TYPE, //data, read/write  (el valor es 0x09 = 1001)
        .s = 0x0,                     //system
        .dpl = 0x00,
        .p = 0x1, //esta presente
        .limit_19_16 = 0x00,
        .avl = 0x0,
        .l = 0x0, //32 bits
        .db = 0x0,
        .g = 0x0,
        .base_31_24 = 0x00,
    },
    [GDT_INDEX_TSS_RICK + 3] = {
        .limit_15_0 = sizeof(tss_t) - 1,
        .base_15_0 = 0x000,
        .base_23_16 = 0x0,
        .type = GDT_TSS_32_BITS_TYPE, //data, read/write  (el valor es 0x09 = 1001)
        .s = 0x0,                     //system
        .dpl = 0x00,
        .p = 0x1, //esta presente
        .limit_19_16 = 0x00,
        .avl = 0x0,
        .l = 0x0, //32 bits
        .db = 0x0,
        .g = 0x0,
        .base_31_24 = 0x00,
    },
    [GDT_INDEX_TSS_MORTY + 3] = {
        .limit_15_0 = sizeof(tss_t) - 1,
        .base_15_0 = 0x000,
        .base_23_16 = 0x0,
        .type = GDT_TSS_32_BITS_TYPE, //data, read/write  (el valor es 0x09 = 1001)
        .s = 0x0,                     //system
        .dpl = 0x00,
        .p = 0x1, //esta presente
        .limit_19_16 = 0x00,
        .avl = 0x0,
        .l = 0x0, //32 bits
        .db = 0x0,
        .g = 0x0,
        .base_31_24 = 0x00,
    },
    [GDT_INDEX_TSS_RICK + 4] = {
        .limit_15_0 = sizeof(tss_t) - 1,
        .base_15_0 = 0x000,
        .base_23_16 = 0x0,
        .type = GDT_TSS_32_BITS_TYPE, //data, read/write  (el valor es 0x09 = 1001)
        .s = 0x0,                     //system
        .dpl = 0x00,
        .p = 0x1, //esta presente
        .limit_19_16 = 0x00,
        .avl = 0x0,
        .l = 0x0, //32 bits
        .db = 0x0,
        .g = 0x0,
        .base_31_24 = 0x00,
    },
    [GDT_INDEX_TSS_MORTY + 4] = {
        .limit_15_0 = sizeof(tss_t) - 1,
        .base_15_0 = 0x000,
        .base_23_16 = 0x0,
        .type = GDT_TSS_32_BITS_TYPE, //data, read/write  (el valor es 0x09 = 1001)
        .s = 0x0,                     //system
        .dpl = 0x00,
        .p = 0x1, //esta presente
        .limit_19_16 = 0x00,
        .avl = 0x0,
        .l = 0x0, //32 bits
        .db = 0x0,
        .g = 0x0,
        .base_31_24 = 0x00,
    },
    [GDT_INDEX_TSS_RICK + 5] = {
        .limit_15_0 = sizeof(tss_t) - 1,
        .base_15_0 = 0x000,
        .base_23_16 = 0x0,
        .type = GDT_TSS_32_BITS_TYPE, //data, read/write  (el valor es 0x09 = 1001)
        .s = 0x0,                     //system
        .dpl = 0x00,
        .p = 0x1, //esta presente
        .limit_19_16 = 0x00,
        .avl = 0x0,
        .l = 0x0, //32 bits
        .db = 0x0,
        .g = 0x0,
        .base_31_24 = 0x00,
    },
    [GDT_INDEX_TSS_MORTY + 5] = {
        .limit_15_0 = sizeof(tss_t) - 1,
        .base_15_0 = 0x000,
        .base_23_16 = 0x0,
        .type = GDT_TSS_32_BITS_TYPE, //data, read/write  (el valor es 0x09 = 1001)
        .s = 0x0,                     //system
        .dpl = 0x00,
        .p = 0x1, //esta presente
        .limit_19_16 = 0x00,
        .avl = 0x0,
        .l = 0x0, //32 bits
        .db = 0x0,
        .g = 0x0,
        .base_31_24 = 0x00,
    },
    [GDT_INDEX_TSS_RICK + 6] = {
        .limit_15_0 = sizeof(tss_t) - 1,
        .base_15_0 = 0x000,
        .base_23_16 = 0x0,
        .type = GDT_TSS_32_BITS_TYPE, //data, read/write  (el valor es 0x09 = 1001)
        .s = 0x0,                     //system
        .dpl = 0x00,
        .p = 0x1, //esta presente
        .limit_19_16 = 0x00,
        .avl = 0x0,
        .l = 0x0, //32 bits
        .db = 0x0,
        .g = 0x0,
        .base_31_24 = 0x00,
    },
    [GDT_INDEX_TSS_MORTY + 6] = {
        .limit_15_0 = sizeof(tss_t) - 1,
        .base_15_0 = 0x000,
        .base_23_16 = 0x0,
        .type = GDT_TSS_32_BITS_TYPE, //data, read/write  (el valor es 0x09 = 1001)
        .s = 0x0,                     //system
        .dpl = 0x00,
        .p = 0x1, //esta presente
        .limit_19_16 = 0x00,
        .avl = 0x0,
        .l = 0x0, //32 bits
        .db = 0x0,
        .g = 0x0,
        .base_31_24 = 0x00,
    },
    [GDT_INDEX_TSS_RICK + 7] = {
        .limit_15_0 = sizeof(tss_t) - 1,
        .base_15_0 = 0x000,
        .base_23_16 = 0x0,
        .type = GDT_TSS_32_BITS_TYPE, //data, read/write  (el valor es 0x09 = 1001)
        .s = 0x0,                     //system
        .dpl = 0x00,
        .p = 0x1, //esta presente
        .limit_19_16 = 0x00,
        .avl = 0x0,
        .l = 0x0, //32 bits
        .db = 0x0,
        .g = 0x0,
        .base_31_24 = 0x00,
    },
    [GDT_INDEX_TSS_MORTY + 7] = {
        .limit_15_0 = sizeof(tss_t) - 1,
        .base_15_0 = 0x000,
        .base_23_16 = 0x0,
        .type = GDT_TSS_32_BITS_TYPE, //data, read/write  (el valor es 0x09 = 1001)
        .s = 0x0,                     //system
        .dpl = 0x00,
        .p = 0x1, //esta presente
        .limit_19_16 = 0x00,
        .avl = 0x0,
        .l = 0x0, //32 bits
        .db = 0x0,
        .g = 0x0,
        .base_31_24 = 0x00,
    },
    [GDT_INDEX_TSS_RICK + 8] = {
        .limit_15_0 = sizeof(tss_t) - 1,
        .base_15_0 = 0x000,
        .base_23_16 = 0x0,
        .type = GDT_TSS_32_BITS_TYPE, //data, read/write  (el valor es 0x09 = 1001)
        .s = 0x0,                     //system
        .dpl = 0x00,
        .p = 0x1, //esta presente
        .limit_19_16 = 0x00,
        .avl = 0x0,
        .l = 0x0, //32 bits
        .db = 0x0,
        .g = 0x0,
        .base_31_24 = 0x00,
    },
    [GDT_INDEX_TSS_MORTY + 8] = {
        .limit_15_0 = sizeof(tss_t) - 1,
        .base_15_0 = 0x000,
        .base_23_16 = 0x0,
        .type = GDT_TSS_32_BITS_TYPE, //data, read/write  (el valor es 0x09 = 1001)
        .s = 0x0,                     //system
        .dpl = 0x00,
        .p = 0x1, //esta presente
        .limit_19_16 = 0x00,
        .avl = 0x0,
        .l = 0x0, //32 bits
        .db = 0x0,
        .g = 0x0,
        .base_31_24 = 0x00,
    },
    [GDT_INDEX_TSS_RICK + 9] = {
        .limit_15_0 = sizeof(tss_t) - 1,
        .base_15_0 = 0x000,
        .base_23_16 = 0x0,
        .type = GDT_TSS_32_BITS_TYPE, //data, read/write  (el valor es 0x09 = 1001)
        .s = 0x0,                     //system
        .dpl = 0x00,
        .p = 0x1, //esta presente
        .limit_19_16 = 0x00,
        .avl = 0x0,
        .l = 0x0, //32 bits
        .db = 0x0,
        .g = 0x0,
        .base_31_24 = 0x00,
    },
    [GDT_INDEX_TSS_MORTY + 9] = {
        .limit_15_0 = sizeof(tss_t) - 1,
        .base_15_0 = 0x000,
        .base_23_16 = 0x0,
        .type = GDT_TSS_32_BITS_TYPE, //data, read/write  (el valor es 0x09 = 1001)
        .s = 0x0,                     //system
        .dpl = 0x00,
        .p = 0x1, //esta presente
        .limit_19_16 = 0x00,
        .avl = 0x0,
        .l = 0x0, //32 bits
        .db = 0x0,
        .g = 0x0,
        .base_31_24 = 0x00,
    },
    [GDT_INDEX_TSS_RICK + 10] = {
        .limit_15_0 = sizeof(tss_t) - 1,
        .base_15_0 = 0x000,
        .base_23_16 = 0x0,
        .type = GDT_TSS_32_BITS_TYPE, //data, read/write  (el valor es 0x09 = 1001)
        .s = 0x0,                     //system
        .dpl = 0x00,
        .p = 0x1, //esta presente
        .limit_19_16 = 0x00,
        .avl = 0x0,
        .l = 0x0, //32 bits
        .db = 0x0,
        .g = 0x0,
        .base_31_24 = 0x00,
    },
    [GDT_INDEX_TSS_MORTY + 10] = {
        .limit_15_0 = sizeof(tss_t) - 1,
        .base_15_0 = 0x000,
        .base_23_16 = 0x0,
        .type = GDT_TSS_32_BITS_TYPE, //data, read/write  (el valor es 0x09 = 1001)
        .s = 0x0,                     //system
        .dpl = 0x00,
        .p = 0x1, //esta presente
        .limit_19_16 = 0x00,
        .avl = 0x0,
        .l = 0x0, //32 bits
        .db = 0x0,
        .g = 0x0,
        .base_31_24 = 0x00,
    },
};

gdt_descriptor_t GDT_DESC = {
    sizeof(gdt) - 1,
    (uint32_t)&gdt
};