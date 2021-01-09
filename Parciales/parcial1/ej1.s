global docSimilar

section .text



;*** Document ***
;typedef struct s_docElem {
;   type_t type;              0 - 4bytes
;   void* data;               8 - 8bytes
;} docElem_t;                 total: 16 bytes

;typedef struct s_document {
;   int count;                0 - 4bytes
;   struct s_docElem* values; 8 - 8bytes
;} document_t;                total: 16 bytes
%define off_type 0 
%define off_data 8

%define off_count 0
%define off_docElem 8

extern getCompareFunction

; int docSimilar(document_t* a, document_t* b, void* bitmap)
; RDI --> document_t* a
; RSI --> document_t* b
; RDX --> void* bitmap
docSimilar:
    ; Armo stackframe 
    push    rbp
    mov     rbp, rsp
    push rbx
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    ; muevo parametros a registros no volatiles
    mov r13, rdi ; r13 --> document a
    mov r14, rsi ; r14 --> document b
    mov r15b, BYTE [rdx] ; r15 --> bitmap

    ; comparo tamaño total del document
    mov rcx, [r13 + off_count]
    mov rdx, [r14 + off_count]
    cmp rcx, rdx
    ja .amayorb
    jb .bmayora

    mov r10, [r13 + off_docElem]
    mov r11, [r14 + off_docElem]

    ; comparo tipos de datos
    mov bl, 1
    .loop:
        test r15b, bl
        jz   .skiploop 

        mov rax, [r10 + off_type]
        mov rdx, [r11 + off_type]

        cmp rax, rdx
        ja .bmayora ; no se cual seria el criterio en caso de que no sean iguales en tipos de datos
        jb .amayorb ; no se cual seria el criterio en caso de que no sean iguales en tipos de datos

    .skiploop:
        sal bl, 1
        add r10, 16
        add r11, 16
    loop .loop
    
    ; comparo datos de cada documento
    mov r11, [r13 + off_count]
    mov rbx, [r13 + off_docElem]
    mov r12, [r14 + off_docElem]
    mov r10b, 1
    .dataLoop:
        test r15b, r10b
        jz   .skipDataLoop 

        mov rdi, [rbx + off_type]
        call getCompareFunction

        mov rdi, [rbx + off_data]
        mov rsi, [r12 + off_data]
        call rax

        test rax, 2
        jnz .amayorb
        test rax, 1
        jnz .bmayora


    .skipDataLoop:
        sal r10b, 1
        add rbx, 16
        add r12, 16
        dec r11
        cmp r11, 0
        jnz .dataLoop


 .iguales:
    mov rax, 0
    jmp .fin
 .amayorb:
    mov rax, -1
    jmp .fin
 .bmayora:
    mov rax, 1
    jmp .fin

.fin:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop rbx
    pop rbp
    ret
