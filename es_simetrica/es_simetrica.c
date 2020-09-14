#include <stdio.h>

long es_simetrica(long *M, unsigned short n);

void main(int argc, char* argv[]) {
	long matriz[4] = {0, 1, 1, 0};
	printf("Es simetrica? %ld\n", es_simetrica(matriz, 2));
}