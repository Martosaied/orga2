#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern void hide(uint32_t* imagen, uint8_t* t, int m, int n);

int main(void) {
  // Construir dos imagenes al azar
  srand(12345);
  int n = 128;
  int m = 64;
  uint8_t* img = malloc(sizeof(uint8_t) * (long unsigned int)(4 * n * m));
  uint8_t* t = malloc(sizeof(uint8_t) * (long unsigned int)(n * m));
  for (int i = 0; i < m * n * 4; i++) {
    img[i] = (uint8_t)(rand() % 255);
  }
  for (int i = 0; i < m * n; i++) {
    t[i] = (uint8_t)(rand() % 255);
  }

  // Ejecutar funcion
  hide((uint32_t*)img, t, m, n);

  printf("Primeros cuatro bytes: %x %x %x %x\n", img[0], img[1], img[2],
         img[3]);
  printf("Primeros cuatro bytes: %x %x %x %x\n", img[4], img[5], img[6],
         img[7]);

  // Borrar imagenes
  free(img);
  free(t);

  return 0;
}
