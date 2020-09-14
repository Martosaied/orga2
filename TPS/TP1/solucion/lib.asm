
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
    mov edi, DWORD [rdi]
    mov esi, DWORD [rsi]
    cmp edi, esi
    xor rax, rax 
    jl .bmayora
    jg .amayorb
    .fin:
        ret
    .bmayora:
        dec rax
        jmp .fin
    .amayorb:
        inc rax
        jmp .fin

floatClone:
    mov rdx, rdi ;EN RDX ESTA EL PUNTERO AL FLOAT ORIGINAL
    mov rdi, 4
    call malloc  ;EN RAX ESTA EL PUNTERO NUEVO
    mov ecx, DWORD [rdx]
    mov DWORD [rax], ecx
    ret
floatDelete:
    call free
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

