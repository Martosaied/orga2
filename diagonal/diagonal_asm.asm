; ; void diagonal(short* matriz, short n, short* vector);
; global diagonal

; section .text
; diagonal: 
;     push rbp
;     mov rbp, rsp

;     ;rdi -> puntero matriz
;     ;rsi -> n
;     ;rdx -> puntero vector

;     ;rcx -> contador

;     mov rcx, 0

; .ciclo:
;     mov rbx, rcx ;reinicio rbx para tener el indice actual
;     mov r9, rsi
;     imul r9, 2
;     imul rbx, r9
;     lea r8, [rbx+2*rcx] ; puntero a la posicion deseada de la matriz(fila)
;     mov rax, [r8+rdi]
;     mov [rdx+2*rcx], rax

;     inc rcx
;     cmp rcx, rsi
;     jl .ciclo

;     pop rbp
;     ret

global diagonal

%define SHORT_SIZE 2

section .text

diagonal:

    ; void diagonal(short* matriz, short n, short* vector)
    ; short* matriz -> RDI
    ; short n       -> SI
    ; short* vector -> RDX

    ; Stack Frame (Armado)
    push rbp
    mov rbp, rsp

    ; Preparación
    and rsi, 0xFFFF ; extensión sin signo a 64 bits ('n' no va a ser negativo)

    ; Ciclo
    mov rcx, 0 ; índice de ciclo
    
    .ciclo:
        cmp rcx, rsi
        je .fin_ciclo

        mov r9w, [rdi]
        mov [rdx], r9w

        add rdx, SHORT_SIZE
        lea rdi, [rdi + rsi * SHORT_SIZE + SHORT_SIZE]

        inc rcx
        jmp .ciclo

    .fin_ciclo:

    ; Stack Frame (Limpieza)
    pop rbp

    ret