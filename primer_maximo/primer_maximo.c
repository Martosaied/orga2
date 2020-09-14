#include <stdio.h>
#include <stdlib.h>

// Ejercicio 4
// int* primerMaximo(int (*matriz)[sizeC], int* f, int* c);
// Dada una matriz de fˆc enteros de 32 bits, encontrar el primer maximo buscando en el orden de la  
// memoria. Devuelve un puntero a este valor y sus coordenadas en f y c

extern int* primer_maximo(int *pMatriz, int *f, int *c);

int main(void) {
	int fila 	= 4;
	int columna = 3;
	int matriz[4][3] =
	{
			{0, 1, 2},
			{3, 5, 7},
			{0, 0, 0},
			{0, 0, 9},
	};

	int f, c;
	int *pMaximo;

	// f = fila;
	// c = columna;
	// pMaximo = primerMaximo_matriz((int*)matriz, &f, &c);
	// printf("C_matriz > el máximo: %d, esta en (%d,%d)\r\n", *pMaximo, f, c);

	// f = fila;
	// c = columna;
	// pMaximo = primerMaximo_vector((int*)matriz, &f, &c);
	// printf("C_vector > el máximo: %d, esta en (%d,%d)\r\n", *pMaximo, f, c);

	f = fila;
	c = columna;
	pMaximo = primer_maximo((int*)matriz, &f, &c);
	printf("ASM      > el máximo: %d, esta en (%d,%d)\r\n", *pMaximo, f, c);

	return EXIT_SUCCESS;
}