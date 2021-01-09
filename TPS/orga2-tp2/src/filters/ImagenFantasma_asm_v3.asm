section .rodata
vectorBrillo: db 1, 2, 1, 0, 1, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0

vector7: dw 7, 7, 7, 8, 7, 7, 7, 8

mascaraShuffle: db 0, 0, 0, 10000000b, 0, 0, 0, 10000000b, 1, 1, 1, 10000000b, 1, 1, 1, 10000000b

global ImagenFantasma_asm_v3

section .text
; rdi <- uint8_t *src,
; rsi <- uint8_t *dst,
; edx <- int width,
; ecx <- int height,
; r8d <- int src_row_size,
; r9d <- int dst_row_size,
; rbp+16 <- int offsetx,
; rbp+24 <- int offsety
ImagenFantasma_asm_v3:
    push    rbp
    mov     rbp, rsp

    mov r15d, [rbp+16]                 ; r15d = offsetx
    mov r14d, [rbp+24]                 ; r14d = offsety

    mov ebx, edx                       ; necesito liberar edx para hacer multiplicaciones tranquilo y siempre dst_row_size = src_row_size entonces uno de los dos es redundante

    movdqu xmm8, [vectorBrillo]
    movdqu xmm9, [vector7]
    movdqu xmm10, [mascaraShuffle]

    .cicloHeight:
    dec ecx
    jl .fin
    ; int jj = j/2 + offsety;
    mov r11d, ecx
    shr r11d, 1
    add r11d, r14d                     ; r11d = jj
    mov r9d, ebx
        .cicloWidth:
        sub r9d, 4
        jl .cicloHeight
        ; int ii = i/2 + offsetx;
        mov r10d, r9d
        shr r10d, 1
        add r10d, r15d                 ; r10d = ii

                                       ; src[jj][ii] = [rdi +  jj * src_row_size + 4 * ii]
        mov eax, r11d                  ; eax = jj
        mul r8d                        ; rax = jj * src_row_size
        lea rax, [rax + r10 * 4]       ; rax = jj * src_row_size + 4 * ii

        movq xmm7, [rdi + rax]         ; xmm7 = [ -- | -- | -- | -- | -- | -- | -- | -- | a2 | b2 | g2 | r2 | a1 | b1 | g1 | r1 ] a partir de ii, jj
                                       ; xmm8 = [ 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 1  | 2  | 1  | 0  | 1  | 2  | 1  ]

        pmaddubsw xmm7, xmm8           ; xmm7 = [ 0 | 0 | 0 | 0 | 1*b2 + 0*a2 | 1*r2 + 2*g2 | 1*b1 + 0*a1 | 1*r1 + 2*g1 ]
        phaddw xmm7, xmm7              ; xmm7 = [ 0 | 0 | b2 | b1 | 0 | 0 | b2 | b1 ] b de brillo, no de blue
        psraw xmm7, 3                  ; divido todos los words por 8, ya tengo el brillo (en words)

        packuswb xmm7, xmm7            ; xmm7 = [ 0 | 0 | b2 | b1 | 0 | 0 | b2 | b1 | 0 | 0 | b2 | b1 | 0 | 0 | b2 | b1 ]

        pshufb xmm7, xmm10             ; xmm7 = [ 0 | b2 | b2 | b2 | 0 | b2 | b2 | b2 | 0 | b1 | b1 | b1 | 0 | b1 | b1 | b1 ]

                                       ; src[j][i] = [rdi +  j * src_row_size + 4 * i]
        mov eax, ecx                   ; eax = j
        mul r8d                        ; eax = j * src_row_size
        lea rax, [eax + r9d * 4]       ; rax = j * src_row_size + 4 * ii
        movdqu xmm1, [rdi + rax]       ; xmm0 = primeros 4 pixeles a partir de i, j


        pmovzxbw xmm0, xmm1            ; xmm0 = [2do pixel | 1er pixel]
        psrldq xmm1, 8
        pmovzxbw xmm1, xmm1            ; xmm1 = [4to pixel | 3er pixel]


        movdqu xmm5, xmm0              ; xmm5 = [ a2 | b2 | g2 | r2 | a1 | b1 | g1 | r1 ]
        pmulhw xmm5, xmm9              ; xmm5 = [ hi(8*a2) | hi(7*b2) | hi(7*g2) | hi(7*r2) | hi(8*a1) | hi(7*b1) | hi(7*g1) | hi(7*r1) ]
        pmullw xmm0, xmm9              ; xmm0 = [ low(8*a2) | low(7*b2) | low(7*g2) | low(7*r2) | low(8*a1) | low(7*b1) | low(7*g1) | low(7*r1) ]
        movdqa xmm6, xmm0              ; xmm6 = [ low(8*a2) | low(7*b2) | low(7*g2) | low(7*r2) | low(8*a1) | low(7*b1) | low(7*g1) | low(7*r1) ]
        punpcklwd xmm0, xmm5           ; xmm0 = [ 8*a1 | 7*b1 | 7*g1 | 7*r1 ]
        punpckhwd xmm6, xmm5           ; xmm6 = [ 8*a2 | 7*b2 | 7*g2 | 7*r2 ]
        psrlw xmm0, 3                  ; xmm0 = [ a1 | 7/8*b1 | 7/8*g1 | 7/8*r1 ]
        psrlw xmm6, 3                  ; xmm6 = [ a2 | 7/8*b2 | 7/8*g2 | 7/8*r2 ]
        packusdw xmm0, xmm6            ; xmm0 = [ 2do pixel | 1er pixel ]

        movdqu xmm5, xmm1              ; xmm5 = [ a4 | b4 | g4 | r4 | a3 | b3 | g3 | r3 ]
        pmulhw xmm5, xmm9              ; xmm5 = [ hi(8*a4) | hi(7*b4) | hi(7*g4) | hi(7*r4) | hi(8*a3) | hi(7*b3) | hi(7*g3) | hi(7*r3) ]
        pmullw xmm1, xmm9              ; xmm1 = [ low(8*a4) | low(7*b4) | low(7*g4) | low(7*r4) | low(8*a3) | low(7*b3) | low(7*g3) | low(7*r3) ]
        movdqa xmm6, xmm1              ; xmm6 = [ low(8*a4) | low(7*b4) | low(7*g4) | low(7*r4) | low(8*a3) | low(7*b3) | low(7*g3) | low(7*r3) ]
        punpcklwd xmm1, xmm5           ; xmm1 = [ 8*a3 | 7*b3 | 7*g3 | 7*r3 ]
        punpckhwd xmm6, xmm5           ; xmm6 = [ 8*a4 | 7*b4 | 7*g4 | 7*r4 ]
        psrlw xmm1, 3                  ; xmm1 = [ a3 | 7/8*b3 | 7/8*g3 | 7/8*r3 ]
        psrlw xmm6, 3                  ; xmm6 = [ a4 | 7/8*b4 | 7/8*g4 | 7/8*r4 ]
        packusdw xmm1, xmm6            ; xmm1 = [ 4to pixel | 3er pixel ]

        packuswb xmm0, xmm1            ; xmm0 = [ 4to pixel | 3er pixel | 2do pixel | 1er pixel ]

        paddusb xmm0, xmm7

        movdqu [rsi + rax], xmm0

        jmp .cicloWidth

.fin:
pop rbp
ret