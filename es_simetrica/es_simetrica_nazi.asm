; Ejercicio 13 - Guia 1
; long esSimetrica(long *M, unsigned short n);

; Una funcion que indique si la matriz M es simetrica.


; RDI -> long* M
; RSI -> unsigned short n

%define argMatriz    (rdi)
%define argN         (rsi)

%define indiceFila      (rcx)
%define indiceColumna   (r9)
%define offsetFila      (r8)
%define direccionIJ     (r15)
%define elementoIJ      (r11)
%define elementoJI      (r12)

%define contadorCeldas    (r13)
%define numeroCeldas      (r14)


global es_simetrica

section .text
es_simetrica: 
    ; Armo Stackframe
    push rbp
    mov rbp, rsp

    xor indiceFila, indiceFila
    xor indiceColumna, indiceColumna
    mov rax, 1
    
    mov numeroCeldas, argN
    imul numeroCeldas, numeroCeldas

    xor contadorCeldas, contadorCeldas
.ciclo:
    mov offsetFila, indiceFila
    imul offsetFila, 8
    imul offsetFila, argN
    lea direccionIJ, [offsetFila + indiceColumna * 8] 
    mov elementoIJ, [argMatriz + direccionIJ]

    mov offsetFila, indiceColumna
    imul offsetFila, 8
    imul offsetFila, argN
    lea direccionJI, [offsetFila + indiceFila * 8] 
    mov elementoJI, [argMatriz + direccionIJ]

    cmp elementoIJ, elementoIJ ; if(mat[i, j] == mat[j, i])
    jne .falso  ; si no son iguales, ya se que el resultado es falso 
    inc indiceFila
    cmp contadorCeldas, numeroCeldas ; while(contadorCeldas < (n*n))
    je  .fin    ; si son iguales, termino
    jmp .ciclo
.falso:    
    xor rax, rax
    mov al, 0

.fin:
    pop rbp
    ret


; Primero obtengo el offset de la fila
; <indiceFila> * <tamañoDato * tamañoFila>
; ejemplo
; mul rax, rdx ; ojo! modifica rdx tambien

; Segundo el offset dentro de la fila
; [<indiceFila * tamañoDato * tamañoFila> + <indiceColumna> * <tamañoDato>]
; ejemplo
; lea rsi, [rax+rcx*2]; rsi <= rax+rcx*2

; Tercero, accedo al dato
; [<base> + < ́ındiceFila*tama ̃noDato*tama ̃noFila+ ́ındiceColumna*tama ̃noDato>]
; ejemplo
; mov rdx, [rbx+rsi]

