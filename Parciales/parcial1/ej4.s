%define source 		        (r13)
%define width 		        (rbx)
%define destination 		(r12)
%define row_size 		    (r10)

%define float_size 4
%define double_size 8

global calculation

;double* addings(float* matriz,int n)
; RDI -> float* matriz
; ESI -> int n


extern malloc

section .rodata
    mascara_puntas: db 255, 0, 0, 255
    mascara_medio: db 0, 255, 255, 0



section .text
calculation:
    ; armo stackframe
    push rbp
    mov rbp, rsp
    push rbx
    push r13

    mov source, rdi
    mov width, rsi

    mov     rdi, width
    imul    rdi, rdi
    shr     rdi, 1
    call    malloc
    mov     destination, rax
    
    mov     rcx, width 
    imul    rcx, rcx
    shr     rcx, float_size
    
    lea     row_size, [width * float_size]


    movdqu  xmm10, [mascara_puntas]
    movdqu  xmm11, [mascara_medio]

    xor     rax, rax
    xor     rdi, rdi
.loop:
    mov     rdx, rax
    
    movaps  xmm0, [source + rdx]
    
    add     rdx, row_size
    movaps  xmm1, [source + rdx]
    
    add     rdx, row_size
    movaps  xmm2, [source + rdx]

    add     rdx, row_size
    movaps  xmm3, [source + rdx]
    


    movsd       [destination + rdi], xmm5

    add rdi, double_size
    add rax, 16
    cmp rax, row_size
    je  .advance
.ret_advance:
    dec rcx
    cmp rcx, 0
    jnz .loop

    mov rax, destination

    pop     r13 
    pop     rbx
    pop     rbp
    ret

.advance: 
    xor     rax, rax
    times 4 add    rax, row_size
    add    source, rax
    xor    rax, rax
    jmp    .ret_advance