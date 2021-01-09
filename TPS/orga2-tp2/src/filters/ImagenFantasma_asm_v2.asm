section .rodata
vectorBrillo: db 1, 2, 1, 0, 1, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0

vector09: dd 0.9, 0.9, 0.9, 1.0

mascaraShuffle: db 0, 0, 0, 10000000b, 0, 0, 0, 10000000b, 1, 1, 1, 10000000b, 1, 1, 1, 10000000b

global ImagenFantasma_asm_v2

section .text
; rdi <- uint8_t *src,
; rsi <- uint8_t *dst,
; edx <- int width,
; ecx <- int height,
; r8d <- int src_row_size,
; r9d <- int dst_row_size,
; rbp+16 <- int offsetx,
; rbp+24 <- int offsety
ImagenFantasma_asm_v2:
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

        movq xmm7, [rdi + rax]        ; xmm7 = [ -- | -- | -- | -- | -- | -- | -- | -- | a2 | b2 | g2 | r2 | a1 | b1 | g1 | r1 ] a partir de ii, jj
                                      ; xmm8 = [ 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 1  | 2  | 1  | 0  | 1  | 2  | 1  ]

        pmaddubsw xmm7, xmm8          ; xmm7 = [ 0 | 0 | 0 | 0 | 1*b2 + 0*a2 | 1*r2 + 2*g2 | 1*b1 + 0*a1 | 1*r1 + 2*g1 ]
        phaddw xmm7, xmm7             ; xmm7 = [ 0 | 0 | b2 | b1 | 0 | 0 | b2 | b1 ] b de brillo, no de blue
        psraw xmm7, 3                 ; divido todos los words por 8, ya tengo el brillo (en words)

        packuswb xmm7, xmm7           ; xmm7 = [ 0 | 0 | b2 | b1 | 0 | 0 | b2 | b1 | 0 | 0 | b2 | b1 | 0 | 0 | b2 | b1 ]

        pshufb xmm7, xmm10            ; xmm7 = [ 0 | b2 | b2 | b2 | 0 | b2 | b2 | b2 | 0 | b1 | b1 | b1 | 0 | b1 | b1 | b1 ]

                                      ; src[j][i] = [rdi +  j * src_row_size + 4 * i]
        mov eax, ecx                  ; eax = j
        mul r8d                       ; eax = j * src_row_size
        lea rax, [eax + r9d * 4]      ; rax = j * src_row_size + 4 * ii
        movdqu xmm0, [rdi + rax]      ; xmm0 = primeros 4 pixeles a partir de i, j

        paddusb xmm0, xmm7

        movdqu [rsi + rax], xmm0

        jmp .cicloWidth

.fin:
pop rbp
ret