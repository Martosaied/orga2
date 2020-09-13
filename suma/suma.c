#include <stdio.h>

short suma(short* vector, short n);

void main(int argc, char* argv[]) {
	short v[4] = {1, 2, 3, 4}; 
	printf("Suma %hd\n", suma(v, 4));
}