; /*
;  * 0205
;  * Dada una matriz de f x c enteros de 32 bits, encontrar el primer máximo buscando en el orden de la memoria.
;  * Devuelve un puntero a este valor y sus coordenadas en f y c.
;  * El prototipo de la función es: int* primerMaximo(int (*matriz)[sizeC], int* f, int* c);
;  */

; RDI 
; RSI
; RDX

%define argMatriz   (rdi)
%define filas       (rsi)
%define columnas    (rdx)

%define INT_SIZE 4
%define indiceFilas     (rcx)
%define indiceColumnas  (rbx)
%define cantidadCeldas  (r11)

%define indiceCeldas    (r9)

global primer_maximo

section .text
primer_maximo:
    push rbp
    mov rbp, rsp

    xor indiceFilas, indiceFilas
    xor indiceColumnas, indiceColumnas
    xor indiceCeldas, indiceCeldas
    mov rax, argMatriz

    mov cantidadCeldas, [filas]
    mov r12, [columnas]
    imul cantidadCeldas, r12 

.ciclo:
    cmp indiceCeldas, cantidadCeldas
    je  .fin_ciclo

    mov r8, [rax]
    cmp r8, [argMatriz + indiceCeldas * INT_SIZE]
    jl  set_maximo

    inc indiceCeldas
    jmp .ciclo

.fin_ciclo:
    pop rbp 
    ret
    
set_maximo: 
    lea rax, [argMatriz + indiceCeldas * INT_SIZE]
    inc indiceCeldas
    jmp primer_maximo.ciclo




