extern printf
global imprimir_params

section .data
formato_printf: db 'a: %d, f: %f, s: %s', 10, 0


section .text
imprimir_params:
    push rbp
    mov rbp, rsp

    mov rdx, rsi
    mov rsi, rdi
    mov rdi, formato_printf

    mov rax, 1
    call printf

    pop rbp
    ret
