global hide

section .rodata
    mascara_grises: times 4 db 0, 7, 3, 7

; void hide(uint32_t* imagen, uint8_t* T, int m, int n)
; RDI --> uint32_t* imagen
; RSI --> uint8_t* T
; EDX --> int m
; ECX --> int n
section .text
hide:
    ; armo stackframe
    push rbp
    mov rbp, rsp

    imul    edx, ecx
    sar     ecx, 2

    movdqu xmm8, [mascara_grises]

.ciclo:
    movd        xmm2, [rsi]
    pmovzxbd    xmm2, xmm2

    movdqu      xmm1, [rdi]

    movdqa      xmm3, xmm2
    movdqa      xmm4, xmm2
    movdqa      xmm5, xmm2

    pslldq      xmm3, 2
    pslld       xmm4, 5
    psrld       xmm5, 5

    pand        xmm5, xmm4 
    pand        xmm5, xmm3 
    pand        xmm5, xmm8 
    
    pcmpeqb     xmm9, xmm9    ; lleno xmm5 de 1s
    pxor        xmm9, xmm8     ; invierto la mascara, esta me indica que pixeles siguen siendo elegibles para aplicar el filtro con el umbral inferior

    pand        xmm1, xmm9
    paddb       xmm1, xmm5
    
    movdqa      [rdi], xmm1

    add rdi, 16
    add rsi, 4
    loop .ciclo


.fin:
    pop    rbp
    ret
