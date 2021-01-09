extern free
; struct supernode {
;   supernode* abajo,       8 bytes -> 0
;   supernode* derecha,     8 bytes -> 8 
;   supernode* izquierda,   8 bytes -> 16
;   int dato                4 bytes -> 20
; }                         total: 24 bytes
global borrar_columna
section .text
borrar_columna: ;rdi <- doble puntero al nodo
    ;armo stackframe
    push rbp
    mov rbp, rsp
    push r13
    push r14
    push r15

    mov r14, rdi    ;r14 = puntero a puntero a nodo a borrar
    mov r15, [rdi]  ;r15 = puntero a nodo a borrar
    mov rcx, [r15 + 8]
    mov [rdi], rcx ; dejo apuntando a mi doble puntero al nodo de la derecha del primer nodo eliminado

    .guarda:
        test    r15, r15
        jz      .fin

    .body:          ;free y enganchar derecho con izquierdo
        ;engancho el derecho con el izquierdo 
        mov rdx, [r15 + 8]  ;rdx = puntero a derecha
        mov rcx, [r15 + 16] ;rdx = puntero a izquierda
        mov [rdx + 16], rcx
        mov [rcx + 8], rdx

        mov rdi, r15
        mov r15, [r15 + 0]  ;current = current->abajo
        
        call free

    .fin:
    ;a guardar a guardar cada cosa en su lugar. pide pan, no le dan, piden queso le dan hueso y le cortan el pescueso
    pop r15
    pop r14
    pop r14
    pop rbp
    ret
    ret