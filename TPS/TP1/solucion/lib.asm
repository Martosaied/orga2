section .data

section .text

global floatCmp
global floatClone
global floatDelete
global floatPrint

global strClone
global strLen
global strCmp
global strDelete
global strPrint

global docClone
global docDelete

global listAdd

global treeInsert
global treePrint

extern free
extern malloc

;*** Float ***

floatCmp:
     push rbp
     mov rbp, rsp
     xor rax, rax 
     movss xmm1, [rdi]
     comiss xmm1, [rsi]
     jb .bmayora
     ja .amayorb
     .fin:
        pop rbp
        ret
     .bmayora:
         dec rax
         jmp .fin
     .amayorb:
         inc rax
         jmp .fin

floatClone:
    push rbp
    mov rbp, rsp
    mov rdx, rdi ;EN RDX ESTA EL PUNTERO AL FLOAT ORIGINAL
    mov rdi, 4
    call malloc  ;EN RAX ESTA EL PUNTERO NUEVO
    mov ecx, DWORD [rdx]
    mov DWORD [rax], ecx
    pop rbp
    ret
floatDelete:
    push rbp
    mov rbp, rsp
    call free
    pop rbp
    ret
floatPrint:
ret

;*** String ***

strClone:
ret
strLen:
    xor rax, rax
    .loop:
        mov dl, BYTE [rdi + rax]
        inc rax
        cmp dl, 0
        jne .loop
    ret
strCmp:
ret
strDelete:
    ;call free
    ret
strPrint:
ret

;*** Document ***

docClone:
ret
docDelete:
ret

;*** List ***

listAdd:
ret

;*** Tree ***

treeInsert:
ret
treePrint:
ret

