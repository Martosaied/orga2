; [   
;     1, 2, 3, 5
;     4, 5, 6, 4
;     7, 8, 9, 3
;     2, 3, 4, 2
; ]

; 0 5 10 15
; 3 6 9  12

; matriz[i][i] == matriz[i][n-i-1] donde n es el largo de la fila

global diagonal_iguales

%define LONG_SIZE 8

%define actual_matriz (rdi)
%define actual_matriz_chota (r10)
%define largo_n     (rsi)

%define index

section .text

diagonal_iguales:

    ; long diagonalesIguales(long *M, unsigned short n)
    ; long* matriz -> RDI
    ; short n      -> SI

    ; Stack Frame (Armado)
    push rbp
    mov rbp, rsp

    ; Preparación
    and largo_n, 0xFFFF ; extensión sin signo a 64 bits ('n' no va a ser negativo)

    ; Ciclo
    mov rcx, 0 ; índice de ciclo
    mov rax, 1

    .ciclo:
        cmp rcx, largo_n
        je .fin_ciclo

        cmp actual_matriz, actual_matriz_chota
        jne .falso

        add rdx, LONG_SIZE
        lea actual_matriz,       [actual_matriz + largo_n * LONG_SIZE + LONG_SIZE]
        lea actual_matriz_chota, [actual_matriz + largo_n * LONG_SIZE]
        sub actual_matriz_chota, LONG_SIZE

        inc rcx
        jmp .ciclo

    .falso:
        mov rax, 0
    .fin_ciclo:

    ; Stack Frame (Limpieza)
    pop rbp

    ret