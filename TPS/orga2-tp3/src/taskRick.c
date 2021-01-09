#include "stddef.h"
#include "syscall.h"

void meeseks1_func(void);
void meeseks2_func(void);

void task(void) {
  int8_t x, y;
  for (int i = 0; i < 50; i++) {
    syscall_look(&x, &y);
  }
  syscall_meeseeks((uint32_t)&meeseks1_func, 2, 2);

  while (1) {
    __asm volatile("nop");
  }
}

void meeseks1_func(void) {
  while (1) {
    syscall_use_portal_gun();
    int8_t x, y;
    for (int i = 0; i < 50; i++) {
      syscall_look(&x, &y);
    }
  }
}
