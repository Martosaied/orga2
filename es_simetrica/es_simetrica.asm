; Ejercicio 13 - Guia 1
; long esSimetrica(long *M, unsigned short n);

; Una funcion que indique si la matriz M es simetrica.


; RDI -> long* M
; RSI -> unsigned short n

%define argMatriz    (rdi)
%define argN         (rsi)

%define index (rcx)
%define dirActual (r11)
%define dirFin (r12)
%define dirOpuesta (r13)

global es_simetrica

section .text
es_simetrica: 
    ; Armo Stackframe
    push rbp
    mov rbp, rsp

    xor index, index
    lea dirFin, [argN * 8]
    sub dirFin, 8
    mov rax, 1

.ciclo:
    lea dirActual, [index * 8]

    mov dirOpuesta, dirFin
    sub dirOpuesta, dirActual

    mov rax, [argMatriz + dirActual]
	cmp rax, [argMatriz + dirOpuesta]
    jne .falso

    inc index
    cmp index, argN
    je  .fin
    jmp .ciclo
.falso:    
    xor rax, rax
    mov rax, 0

.fin:
    pop rbp
    ret


; Primero obtengo el offset de la fila
; < ́ındiceFila> * <tama ̃noDato*tama ̃noFila>
; ejemplo
; ÝÝÝÝÑ mul rax, rdx ; ojo! modifica rdx tambi ́en
; Segundo el offset dentro de la fila
; [< ́ındiceFila*tama ̃noDato*tama ̃noFila> + < ́ındiceColumna> * <tama ̃noDato>]
; ejemplo
; ÝÝÝÝÑ lea rsi, [rax+rcx*2]; rsi <= rax+rcx*2
; Tercero, accedo al dato
; [<base> + < ́ındiceFila*tama ̃noDato*tama ̃noFila+ ́ındiceColumna*tama ̃noDato>]
; ejemplo
; ÝÝÝÝÑ mov rdx, [rbx+rsi]

