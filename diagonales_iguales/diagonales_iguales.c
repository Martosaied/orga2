#include <stdio.h>

long diagonal_iguales(long *M, unsigned short n);

void main(int argc, char* argv[]) {
	long matriz[4] = {0, 0, 1, 1};
	printf("Es diagonales iguales? %ld\n", diagonal_iguales(matriz, 2));
}