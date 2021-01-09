/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Definicion de funciones del manejador de memoria
*/

#include "mmu.h"
#include "i386.h"

#include "kassert.h"

unsigned int proxima_pagina_libre;
#define INICIO_DE_PAGINAS_LIBRES 0x100000

#define PRESENT 1
#define READWRITE 1
#define SUPERVISOR 0
#define USER 1

void mmu_init(void) {
  proxima_pagina_libre = INICIO_DE_PAGINAS_LIBRES;
}

paddr_t mmu_next_free_kernel_page(void) {
  unsigned int pagina_libre = proxima_pagina_libre;
  proxima_pagina_libre += PAGE_SIZE;
  return pagina_libre;
}


paddr_t mmu_init_kernel_dir(void) {
  page_directory_entry *PD = (page_directory_entry *)KERNEL_PAGE_DIR;
  page_table_entry *PT = (page_table_entry *)KERNEL_PAGE_TABLE_0;

  //inicializarlas en 0
  for (int i = 0; i < 1024; i++)   {
    PD[i] = (page_directory_entry){ 0 };
    PT[i] = (page_table_entry){ 0 };
  }

  PD[0].present = 1;
  PD[0].user_supervisor = 0;
  PD[0].read_write = 1;
  PD[0].page_table_base = ((uint32_t)PT) >> 12;

  for (int i = 0; i < 1024; i++)   {
    PT[i].present = 1;
    PT[i].user_supervisor = 0;
    PT[i].read_write = 1;
    PT[i].physical_address_base = i;
  }

  return (paddr_t)PD;
}

void mmu_map_page(page_directory_entry *cr3, vaddr_t virt, paddr_t phy, uint8_t us, uint8_t rw) {
  uint32_t directoryIdx = virt >> 22;
  uint32_t tableIdx = (virt >> 12) & 0X3FF;

  if (cr3[directoryIdx].present == 0)   {
    paddr_t newPT = mmu_next_free_kernel_page();
    for (int i = 0; i < 1024; i++)     {
      ((paddr_t *)newPT)[i] = 0;
    }
    cr3[directoryIdx].page_table_base = newPT >> 12;
    cr3[directoryIdx].present = 1;
    cr3[directoryIdx].user_supervisor = us;
    cr3[directoryIdx].read_write = rw;
  }

  uint32_t PT = cr3[directoryIdx].page_table_base << 12;
  ((page_table_entry *)PT)[tableIdx].physical_address_base = phy >> 12;
  ((page_table_entry *)PT)[tableIdx].present = 1;
  ((page_table_entry *)PT)[tableIdx].user_supervisor = us;
  ((page_table_entry *)PT)[tableIdx].read_write = rw;
  tlbflush();
}

void mmu_unmap_page(page_directory_entry *cr3, vaddr_t virt) {

  uint32_t directoryIdx = virt >> 22;                                      //calculo el indice dentro del page directory
  uint32_t tableIdx = (virt >> 12) & 0X3FF;                                //calculo el indice dentro de la page table
  page_directory_entry PDE = cr3[directoryIdx];                            //calculo el puntero a la entrada del page directory
  uint32_t PT = PDE.page_table_base << 12;                                 //calculo el puntero a la page table
  ((page_table_entry *)PT)[tableIdx].present = 0;                          //le pongo el bit de presente en 0 a la entrada de la page table


  tlbflush();
}

paddr_t mmu_init_task_dir(paddr_t phy_start, paddr_t code_start) {
  page_directory_entry *page_directory = (page_directory_entry *)mmu_next_free_kernel_page();
  //inicializarlas en 0
  for (int i = 0; i < 1024; i++)   {
    page_directory[i] = (page_directory_entry){ 0 };
  }
  page_directory[0].present = 1;
  page_directory[0].user_supervisor = 1;
  page_directory[0].read_write = 1;
  page_directory[0].page_table_base = ((uint32_t)KERNEL_PAGE_TABLE_0 >> 12);


  // Mapeamos el código de la tarea (16KB) en el directorio de la tarea
  mmu_map_page(page_directory, TASK_VIRTUAL, phy_start, 1, 1);
  mmu_map_page(page_directory, TASK_VIRTUAL + PAGE_SIZE, phy_start + PAGE_SIZE, 1, 1);
  mmu_map_page(page_directory, TASK_VIRTUAL + 2 * PAGE_SIZE, phy_start + 2 * PAGE_SIZE, 1, 1);
  mmu_map_page(page_directory, TASK_VIRTUAL + 3 * PAGE_SIZE, phy_start + 3 * PAGE_SIZE, 1, 1);

  uint32_t virt_start = phy_start; //no importa cual sea la direccion virtual mientras que no pisemos ninguna preexistente

  // hacemos un identity mapping de toda esta wea para el kernel
  mmu_map_page((page_directory_entry *)rcr3(), virt_start, phy_start, 1, 1);
  mmu_map_page((page_directory_entry *)rcr3(), virt_start + PAGE_SIZE, phy_start + PAGE_SIZE, 1, 1);
  mmu_map_page((page_directory_entry *)rcr3(), virt_start + 2 * PAGE_SIZE, phy_start + 2 * PAGE_SIZE, 1, 1);
  mmu_map_page((page_directory_entry *)rcr3(), virt_start + 3 * PAGE_SIZE, phy_start + 3 * PAGE_SIZE, 1, 1);

  char *src = (char *)code_start;
  char *dst = (char *)virt_start;

  for (int i = 0; i < 4 * PAGE_SIZE; ++i)
    dst[i] = src[i];

  mmu_unmap_page((page_directory_entry *)rcr3(), virt_start);
  mmu_unmap_page((page_directory_entry *)rcr3(), virt_start + PAGE_SIZE);
  mmu_unmap_page((page_directory_entry *)rcr3(), virt_start + 2 * PAGE_SIZE);
  mmu_unmap_page((page_directory_entry *)rcr3(), virt_start + 3 * PAGE_SIZE);

  tlbflush();

  return (uint32_t)page_directory;
}
