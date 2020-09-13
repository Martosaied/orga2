#include <stdio.h>

extern double sumar_doubles(double entero_1, double entero_2);

int main(int argc, char *argv[]) {
    double rta = sumar_doubles(10.1, 23.1);
    printf("La respuesta es %f \n", rta);
    return 0;
}