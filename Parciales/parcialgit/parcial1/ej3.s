global hide

section .rodata
    mascara_grises: times 4 db 7, 3, 7, 0

; void hide(uint32_t* imagen, uint8_t* T, int m, int n)
; RDI --> uint32_t* imagen
; RSI --> uint8_t* T
; EDX --> int m
; ECX --> int n
section .text
hide:
    ; armo stackframe
    push        rbp
    mov         rbp, rsp
    ; ---------------

    ; voy a recorrer la imagen de a 4 pixeles
    imul        edx, ecx                ; calculo la cantidad total de pixeles
    sar         ecx, 2                  ; divido por 4

    movdqu      xmm8, [mascara_grises]  ; cargo mascara de grises que voy a utilizar para limpiar el xmm con los grieses

.ciclo:
    pmovzxbd    xmm2, [rsi]             ; cargo 4 bytes de grises y los extiendo a 4 bytes CADA uno

    movdqu      xmm1, [rdi]             ; cargo 4 pixeles --> 128 bits

    movdqa      xmm3, xmm2              ; copio los grises a xmm3
    movdqa      xmm4, xmm2              ; copio los grises a xmm4
    movdqa      xmm5, xmm2              ; copio los grises a xmm5

    pslldq      xmm3, 2                 ; shifteo xmm3 dos bytes a la izquierda
    pand        xmm3, xmm8              ; borro los bits que quedaron fuera de lugar
    pslld       xmm4, 5                 ; shifteo xmm4 5 bits a la izquierda
    pand        xmm4, xmm8              ; borro los bits que quedaron fuera de lugar
    psrld       xmm5, 5                 ; shifteo xmm5 5 bits a la derecha

    por         xmm5, xmm4              ; combino los grises de xmm4 y xmm5
    por         xmm5, xmm3              ; combino todos los grises
    
    pcmpeqb     xmm9, xmm9              ; lleno xmm5 de 1s
    pxor        xmm9, xmm8              ; invierto el registro para tener todos los pixeles que no van a ser afectados por los grises

    pand        xmm1, xmm9              ; seteo en 0 los bits que van a ser afectados por los grises
    paddb       xmm1, xmm5              ; sumo xmm5 poniendo los bits de los grises en sus correspondientes valores
    
    movdqa      [rdi], xmm1             ; actualizo la imagen

    add         rdi, 16                 ; me muevo 16 bytes(4 pixeles)
    add         rsi, 4                  ; me muevo 4 bytes(4 pixeles en byn)
    loop        .ciclo                  ; loop


.fin:
    pop         rbp
    ret
