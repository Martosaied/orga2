#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

extern double *calculation(float *matriz, int n);
double *calculationC(float *matriz, int n);
int main(void)
{
  // Construir dos imagenes al azar
  for (int i = 0; i < 20; i++)
  {
    srand((unsigned int)i);
    int n = 8 * i;
    float *matriz = malloc(sizeof(float) * (long unsigned int)(n * n));
    for (int j = 0; j < n * n; j++)
    {
      matriz[j] = ((float)(rand() % 255)) / ((float)(rand() % 511));
    }

    // Ejecutar funcion
    double *result = calculation(matriz, n);
    double *resultC = calculationC(matriz, n);
    for (int j = 0; j < n / 4; j++)
    {
      double err = result[j] - resultC[j];
      if (fabs(err) > 0.01)
      {
        printf("error bebe: %f\n", err);
      }
    }

    // Borrar imagenes
    free(matriz);
    free(result);
    free(resultC);
  }

  return 0;
}
double *calculationC(float *matriz, int n)
{
  float(*src)[n] = (float(*)[n])matriz;
  double *result = malloc(sizeof(double) * (long unsigned int)(n / 4 * n / 4));
  int k = 0;
  for (int i = 0; i < n; i += 4)
  {
    for (int j = 0; j < n; j += 4)
    {
      float a0 = src[i][j];
      float b0 = src[i][j + 1];
      float c0 = src[i][j + 2];
      float d0 = src[i][j + 3];
      float a1 = src[i + 1][j];
      float b1 = src[i + 1][j + 1];
      float c1 = src[i + 1][j + 2];
      float d1 = src[i + 1][j + 3];
      float a2 = src[i + 2][j];
      float b2 = src[i + 2][j + 1];
      float c2 = src[i + 2][j + 2];
      float d2 = src[i + 2][j + 3];
      float a3 = src[i + 3][j];
      float b3 = src[i + 3][j + 1];
      float c3 = src[i + 3][j + 2];
      float d3 = src[i + 3][j + 3];
      result[k++] = (double)(b0 + c0 + a1 + d1 + a2 + d2 + b3 + c3) / ((a0 + d0 + a3 + d3) * (c1 + b1 + c2 + b2));
    }
  }

  return result;
}