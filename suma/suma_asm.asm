; short suma(short* vector, short n);

global suma

section .text
suma:
    ; Armo stackframe
    push rbp
    mov rbp, rsp


    xor ax, ax
    xor rcx, rcx

.ciclo: add ax, [rdi + rcx * 2]
        inc rcx
        cmp rcx, rsi 
        jl  .ciclo
    
    pop rbp
    ret
