section .rodata
vectorBrillo: db 1, 2, 1, 0, 1, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0

vector09: dd 0.9, 0.9, 0.9, 1.0

mascaraShuffle: db 0, 0, 0, 10000000b, 0, 0, 0, 10000000b, 1, 1, 1, 10000000b, 1, 1, 1, 10000000b

global ImagenFantasma_asm

section .text
; rdi <- uint8_t *src,
; rsi <- uint8_t *dst,
; edx <- int width,
; ecx <- int height,
; r8d <- int src_row_size,
; r9d <- int dst_row_size,
; rbp+16 <- int offsetx,
; rbp+24 <- int offsety
ImagenFantasma_asm:
    push    rbp
    mov     rbp, rsp

    mov r15d, [rbp+16]                ; r15d = offsetx
    mov r14d, [rbp+24]                ; r14d = offsety

    mov ebx, edx                      ; necesito liberar edx para hacer multiplicaciones tranquilo y siempre dst_row_size = src_row_size entonces uno de los dos es redundante

    movdqu xmm8, [vectorBrillo]
    movups xmm9, [vector09]
    movdqu xmm10, [mascaraShuffle]

    .cicloHeight:
    dec ecx
    jl .fin
    ; int jj = j/2 + offsety;
    mov r11d, ecx
    shr r11d, 1
    add r11d, r14d                    ; r11d = jj
    mov r9d, ebx
        .cicloWidth:
        sub r9d, 4
        jl .cicloHeight
        ; int ii = i/2 + offsetx;
        mov r10d, r9d
        shr r10d, 1
        add r10d, r15d                ; r10d = ii

                                      ; src[jj][ii] = [rdi +  jj * src_row_size + 4 * ii]
        mov eax, r11d                 ; eax = jj
        mul r8d                       ; rax = jj * src_row_size
        lea rax, [rax + r10 * 4]      ; rax = jj * src_row_size + 4 * ii

        movq xmm7, [rdi + rax]        ; xmm7 = [ -- | -- | -- | -- | -- | -- | -- | -- | a2 | r2 | g2 | b2 | a1 | r1 | g1 | b1 ] a partir de ii, jj
                                      ; xmm8 = [ 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 1  | 2  | 1  | 0  | 1  | 2  | 1  ]

        pmaddubsw xmm7, xmm8          ; xmm7 = [ 0 | 0 | 0 | 0 | 1*r2 + 0*a2 | 1*b2 + 2*g2 | 1*r1 + 0*a1 | 1*b1 + 2*g1 ]
        phaddw xmm7, xmm7             ; xmm7 = [ 0 | 0 | b2 | b1 | 0 | 0 | b2 | b1 ] b de brillo, no de blue
        psraw xmm7, 3                 ; divido todos los words por 8, ya tengo el brillo (en words)

        packuswb xmm7, xmm7           ; xmm7 = [ 0 | 0 | b2 | b1 | 0 | 0 | b2 | b1 | 0 | 0 | b2 | b1 | 0 | 0 | b2 | b1 ]

        pshufb xmm7, xmm10            ; xmm7 = [ 0 | b2 | b2 | b2 | 0 | b2 | b2 | b2 | 0 | b1 | b1 | b1 | 0 | b1 | b1 | b1 ]

                                      ; src[j][i] = [rdi +  j * src_row_size + 4 * i]
        mov eax, ecx                  ; eax = j
        mul r8d                       ; eax = j * src_row_size
        lea rax, [eax + r9d * 4]      ; rax = j * src_row_size + 4 * ii
        movdqu xmm3, [rdi + rax]      ; xmm0 = primeros 4 pixeles a partir de i, j


        pmovzxbd xmm0, xmm3           ; xmm0 = 1er pixel
        psrldq xmm3, 4
        pmovzxbd xmm1, xmm3           ; xmm1 = 2do pixel
        psrldq xmm3, 4
        pmovzxbd xmm2, xmm3           ; xmm2 = 3er pixel
        psrldq xmm3, 4
        pmovzxbd xmm3, xmm3           ; xmm3 = 4to pixel

        cvtdq2ps xmm3, xmm3           ; los convierto a float
        cvtdq2ps xmm2, xmm2
        cvtdq2ps xmm1, xmm1
        cvtdq2ps xmm0, xmm0

        mulps xmm3, xmm9              ; multiplico por 0.9
        mulps xmm2, xmm9
        mulps xmm1, xmm9
        mulps xmm0, xmm9

        cvtps2dq xmm3, xmm3           ; los convierto a int
        cvtps2dq xmm2, xmm2
        cvtps2dq xmm1, xmm1
        cvtps2dq xmm0, xmm0

        packusdw xmm0, xmm1           ; xmm0 = [2do pixel | 1er pixel]
        packusdw xmm2, xmm3           ; xmm2 = [4to pixel | 3er pixel]

        packuswb xmm0, xmm2           ; xmm0 = [4to pixel | 3er pixel | 2do pixel | 1er pixel]

        paddusb xmm0, xmm7

        movdqu [rsi + rax], xmm0

        jmp .cicloWidth

.fin:
pop rbp
ret