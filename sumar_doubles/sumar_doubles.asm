global sumar_doubles
section .text
sumar_doubles:
    push rbp
    mov rbp, rsp

    addpd xmm0, xmm1

    pop rbp
    ret 