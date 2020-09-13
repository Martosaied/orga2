#include <stdio.h>

extern int sumar_enteros(int entero_1, int entero_2);

int main(int argc, char *argv[]) {
    int rta = sumar_enteros(10, 23);
    printf("La respuesta es %d \n", rta);
    return 0;
}