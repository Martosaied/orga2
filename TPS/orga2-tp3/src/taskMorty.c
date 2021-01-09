#include "syscall.h"

void meeseks1_func(void);

void task(void) {
  syscall_meeseeks((uint32_t)&meeseks1_func, 1, 1);

  while (1) {
    __asm volatile("nop");
  }
}

void meeseks1_func(void) {
  // Do Nothing!
  while (1) {
    __asm volatile("nop");
  }
}
