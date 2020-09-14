%define i (rcx)
%define j (rdx)
%define n (rdi)

global diagonalDominante

section .text
diagonalDominante:
;armo stack frame
        push    rbp
        mov     rbp, rsp
        
        mov     j, 0
        jmp     .L2
.L5:
        mov     i, 0
        jmp     .L3
.L4:
        add     j, 1
.L3:
        mov     eax, i
        cdqe
        cmp     n, rax
        ja      .L4
        add     j, 1
.L2:
        mov     eax, j
        cdqe
        cmp     n, rax
        ja      .L5
        nop
        pop     rbp
        ret


; PEGAR ESTO EN GODBOLT (corregido porque sino no compila)
; int dominante(long *M, unsigned short n) 
; { 
;     int res = 1;
;     for(int i = 0; i<n; i++ ){
;         int acu = 0;
;         for(int j = 0; j<n; j++){
;             if(i!=j){
;                 acu += abs(M[i][j]);
;             }
            
;         }
        
;         if(abs(M[i][i])<acu){
;             return 0;
;         }
; }


; }
