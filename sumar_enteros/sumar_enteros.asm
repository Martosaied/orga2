global sumar_enteros
section .text
sumar_enteros:
    push rbp
    mov rbp, rsp

    add edi, esi

    mov eax, edi

    pop rbp
    ret
