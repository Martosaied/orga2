/* void diagonal(short* matriz, short n, short* vector);
Dada una matriz de nˆn enteros de 16 bits, devolver los elementos de la diagonal en el vector pasado
por parametro. */

#include <stdio.h>

extern void diagonal(short (*matriz)[3], short lado, short d[]);

int main() {
    short vector[5];
    short matriz[3][3] = {{1,2,3},{4,5,6},{7,8,9}};

    printf("Una matriz:\n");
    int i, j;
    for (i = 0; i < 3; i++) {
        for (j = 0; j < 3; j++) {
            printf("%d ", matriz[i][j]);
        }
        printf("\n");
    }

    diagonal(matriz, 3, vector);

    printf("Su diagonal:\n");
    for (i = 0; i < 3; i++) {
        printf("%d ", vector[i]);
    }
    printf("\n");

    return 0;
}