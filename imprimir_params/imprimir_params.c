#include <stdio.h>

extern void imprimir_params(int a, double f, char* s);

int main(int argc, char *argv[]) {
    imprimir_params(10, 2.5, "hola!");
    return 0;
}