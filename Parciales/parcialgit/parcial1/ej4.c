#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern double* calculation(float* matriz, int n);

int main(void) {
  // Construir dos imagenes al azar
  srand(12345);
  int n = 128;
  float* matriz = malloc(sizeof(float) * (long unsigned int)(n * n));
  for (int i = 0; i < n * n; i++) {
      float number = ((float)(rand() % 255)) / ((float)(rand() % 511));
    matriz[i] = number;
  }

  // Ejecutar funcion
  double* result = calculation(matriz, n);

  printf("El primer dato de la matriz: %f\n", matriz[0]);

  if (result != 0)
    printf("El primer dato del resultado: %f\n", result[0]);

  // Borrar imagenes
  free(matriz);
  if (result != 0)
    free(result);

  return 0;
}