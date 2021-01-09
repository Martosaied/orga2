global treeTrim

%define param_tree 		        (r13)
%define param_list 		        (r14)
%define first_node 		        (rbx)

%define off_first 0 
%define off_size 8 
%define off_type_key 12 
%define off_duplicate 16 
%define off_type_data 20

%define off_key 0
%define off_values 8
%define off_left 16
%define off_right 24

%define size_tree 24
%define size_node 32

extern getCompareFunction
extern listAdd
extern treeDelete
extern treeDeleteAux
extern getCloneFunction
extern malloc
extern free
extern listNew

;*** Tree ***
;typedef struct s_tree {
;   struct s_treeNode* first;   0 - 8bytes
;   uint32_t size;              8 - 4bytes 
;   type_t typeKey;             12 - 4bytes
;   int duplicate;              16 - 4bytes
;   type_t typeData;            20 - 4bytes
;} tree_t;                      total: 24 bytes

;typedef struct s_treeNode {
;   void* key;                  0 - 8bytes
;   list_t* values;             8 - 8bytes
;   struct s_treeNode* left;    16 - 8bytes
;   struct s_treeNode* right;   24 - 8bytes
;} treeNode_t;                  total: 32 bytes

; typedef struct s_list {
;   type_t type;                  0 - 4bytes
;   uint32_t size;                4 - 4bytes
;   struct s_listElem* first;     8 - 8bytes
;   struct s_listElem* last;      16 - 8bytes
; } list_t;

;   int treeTrim(tree_t* tree, list_t** key)
;   RDI -> tree_t* tree
;   RSI -> list_t** key

section .data
    result: dd 0        ; variable global para guardar el resultado de la funcion


section .text
treeTrim:
    ; armo stackframe
    push    rbp
    mov     rbp, rsp
    push    r12
    push    r13

    mov     r12, rdi    ; guardo en r13 el puntero al arbol
    mov     r13, rsi    ; guardo en r12 el doble puntero a la lista 

    mov     edi, [r12 + off_type_key]   ; muevo a edi el tipo de la key
    call    listNew                     ; creo una lista del tipo de la key del arbol
    mov     [r13], rax                  ; apunto el doble puntero al puntero a la nueva lista

    mov     rdx, r12                    ; pongo en rdx el puntero al arbol
    mov     rdi, [r12 + off_first]      ; pongo en rdi el puntero al primer nodo del arbol
    mov     rsi, [r13]                  ; pongo en rsi el puntero a la lista
    call    treeTrimAux

    mov     rax, [result]               ; seteo rax con el resultado

    ; desarmo stackframe
    pop     r13
    pop     r12
    pop     rbp
    ret



treeTrimAux:
    ; armo stack frame
    push    rbp
    mov     rbp, rsp
    push    first_node
    push    r12
    push    param_tree
    push    param_list
    push    r15
    sub     rsp, 8

    test    rdi, rdi    ; si el puntero es nulo, salteamos 
    jz      .fin


    mov     param_tree, rdx
    mov     param_list, rsi
    mov     first_node, rdi

    ; busco maximo en la izquierda
    mov     rdi, [param_tree + off_type_key]    ; tipo de dato de la key
    call    getCompareFunction
    mov     r15, rax                            ; muevo a r15 el puntero a funcion de comparacion
    
    mov     rdi, [first_node + off_right]       
    test    rdi, rdi                            ; chequeo si el nodo a la derecha es nulo
    jz      .salteoEliminar2                    ; si es nulo salteo el chequeo y la eliminacion del mismo 
    mov     rsi, r15                            ; muevo a rsi la funcion de comparacion
    call    min                                 ; en rdi ya se encuentra mi nodo asi que busco el minimo de ese lado
    mov     r12, rax                            ; guardo el minimo en r12

    ; hago lo mismo que arriba pero para la izquierda, buscando el maximo 
    mov     rdi, [first_node + off_left]
    test    rdi, rdi
    jz      .salteoEliminar
    mov     rsi, r15
    call    max
    ; minimo en r12 y el maximo en rax
    

    ; chequeo si el minimo de las key del lado izquierdo es mayor a la key del nodo actual
    mov     rdi, rax
    mov     rsi, [first_node + off_key]
    call    r15
    test    rax, 2              ; si es mayor entonces seguimos de largo y borramos el subarbol
    jz      .salteoEliminar     ; sino salteamos esta parte
    mov     rdi, [first_node + off_left]    ; movemos puntero al nodo a eliminar a rdi
    mov     rsi, param_tree                 ; movemos puntero al arbol a rsi
    mov     rdx, param_list                 ; movemos a rdx el puntero a la lista
    call    eliminarSubarbol                ; borramos el subarbol
    mov     QWORD [first_node + off_left], 0    ; seteamos left del nodo actual a nulo
    mov     DWORD [result], 1                   ; seteamos variable result en 1 (borramos algun subarbol)
    .salteoEliminar:


    ; hacemos exactamente lo mismo para el lado derecho
    mov     rdi, r12
    mov     rsi, [first_node + off_key]
    call    r15
    test    rax, 2
    jnz     .salteoEliminar2
    mov     rdi, [first_node + off_right]
    mov     rsi, param_tree
    mov     rdx, param_list
    call    eliminarSubarbol
    mov     QWORD [first_node + off_right], 0
    mov     DWORD [result], 1
    .salteoEliminar2:
    
    cmp     QWORD [first_node + off_left], 0    ; chequeamos si el puntero es nulo
    jz      .salteoRecursivoIzquierda           ; si lo es salteamos el llamado recursivo
    mov     rdi, [first_node + off_left]
    mov     rsi, param_list
    mov     rdx, param_tree
    call    treeTrimAux
    .salteoRecursivoIzquierda:

    cmp     QWORD [first_node + off_right], 0   ; chequeamos si el puntero es nulo
    jz      .salteoRecursivoDerecha             ; si lo es salteamos el llamado recursivo
    mov     rdi, [first_node + off_right]
    mov     rsi, param_list
    mov     rdx, param_tree
    call    treeTrimAux
    .salteoRecursivoDerecha:

.fin:
    add     rsp, 8
    pop     r15
    pop     param_list
    pop     param_tree
    pop     r12
    pop     first_node
    pop     rbp
    ret


max:
    ; armo stackframe
    push    rbp
    mov     rbp, rsp
    push    r12
    push    r13
    push    r14
    push    r15

    ; si el puntero es nulo salto al fin donde devuelvo null
    test    rdi, rdi
    jz      .finNull

    mov     r12, rdi    ; --> nodo
    mov     r13, rsi    ; --> compare function 

    mov     rdi, [r12 + off_left]   ; busco el mayor en la izquierda
    mov     rsi, r13                
    call    max                     ; llamado recursivo
    mov     r14, rax                ; me quedo en r14 el mayor de la izquierda

    mov     rdi, [r12 + off_right]  ; busco el mayor en la derecha
    mov     rsi, r13                
    call    max                     ; llamado recursivo
    mov     r15, rax                ; me quedo en r14 el mayor de la izquierda

    ; comparo max key del nodo de la izquierda con key del nodo actual 
    cmp     r14, 0                  ; si r14 es 0, la key del nodo actual es mas mas grande (o igual que en esta implementacion funcionarian igual) 
    jz      .keyNodoMasGrande
    mov     rdi, [r12 + off_key]
    mov     rsi, r14
    call    r13
    test    rax, 2
    jnz     .keyNodoMasGrande       ; si es mas grande el nodo actual salto a esa etiqueta
    jz      .keyIzqMasGrande        ; si es mas grande el nodo de la izquierda salto a esta etiqueta

    ; Comparo key del nodo actual con el nodo de la derecha
    .keyNodoMasGrande:
        cmp     r15, 0
        jz      .keyNodoMasGrandeFin    ; si la key es 0, otra salteo al final 
        mov     rdi, [r12 + off_key]
        mov     rsi, r15
        call    r13
        test    rax, 2
        jnz     .keyNodoMasGrandeFin    ; si la key del nodo es mas grande que la de la derecha salteo al final
        mov     rax, r15
        jmp     .fin

    ; Comparo key del nodo izquierdo con el nodo de la derecha
    .keyIzqMasGrande:
        cmp     r15, 0
        jz      .keyIzqMasGrandeFin
        mov     rdi, r14
        mov     rsi, r15
        call    r13
        test    rax, 2
        jnz     .keyIzqMasGrandeFin
        ; seteo en rax la key del nodo derecho
        mov     rax, r15
        jmp     .fin

    ; seteo en rax la key del nodo actual
    .keyNodoMasGrandeFin:
        mov     rax, [r12 + off_key]
        jmp     .fin
    ; seteo en rax la key del nodo izquierdo
    .keyIzqMasGrandeFin:
        mov     rax, r14
        jmp     .fin

    .fin:
        pop     r15
        pop     r14
        pop     r13
        pop     r12
        pop     rbp
        ret
    .finNull:
        mov     rax, 0
        pop     r15
        pop     r14
        pop     r13
        pop     r12
        pop     rbp
        ret

; min es exactamene igual a max pero con las comparaciones invertidas
min:
    push    rbp
    mov     rbp, rsp
    push    r12
    push    r13
    push    r14
    push    r15

    test    rdi, rdi
    jz      .finNull

    mov     r12, rdi ; --> nodo
    mov     r13, rsi ; --> compare function 

    mov     rdi, [r12 + off_left]
    mov     rsi, r13
    call    min
    mov     r14, rax

    mov     rdi, [r12 + off_right]
    mov     rsi, r13
    call    min
    mov     r15, rax

    cmp     r14, 0
    jz      .keyNodoMasChica
    mov     rdi, [r12 + off_key]
    mov     rsi, r14
    call    r13
    test    rax, 2
    jz      .keyNodoMasChica
    jnz     .keyIzqMasChica

    .keyNodoMasChica:
        cmp     r15, 0
        jz      .keyNodoMasChicaFin
        mov     rdi, [r12 + off_key]
        mov     rsi, r15
        call    r13
        test    rax, 2
        jz      .keyNodoMasChicaFin
        mov     rax, r15
        jmp     .fin

    .keyIzqMasChica:
        cmp     r15, 0
        jz      .keyNodoMasChicaFin
        mov     rdi, r14
        mov     rsi, r15
        call    r13
        test    rax, 2
        jz      .keyIzqMasChicaFin
        mov     rax, r15
        jmp     .fin

    .keyNodoMasChicaFin:
        mov     rax, [r12 + off_key]
        jmp     .fin
    .keyIzqMasChicaFin:
        mov     rax, r14
        jmp     .fin

    .fin:
        pop     r15
        pop     r14
        pop     r13
        pop     r12
        pop     rbp
        ret
    .finNull:
        mov     rax, 0
        pop     r15
        pop     r14
        pop     r13
        pop     r12
        pop     rbp
        ret 


; RDI --> puntero a primer nodo
; RSI --> puntero al tree
; RDX --> doble puntero a la lista
eliminarSubarbol:
    push    rbp
    mov     rbp, rsp
    push    r12
    push    r13
    push    r14
    push    r15

    test    rdi, rdi    ; si el nodo el puntero al nodo es nulo, salteo a fin
    jz  .fin

    mov     r12, rdi    ; r12 = puntero a nodo
    mov     r13, rsi    ; r13 = puntero a tree
    mov     r14, rdx    ; r14 = doble puntero a lista 

    ; añado a la lista, las keys del subarbol que vamos a eliminar
    mov     rdi, r12    
    mov     rsi, r14
    mov     rdx, r13
    call    anadirElementosLista

    ; pido una posicion de memoria de 1 byte para crear un doble puntero al primer nodo del subarbol
    mov     rdi, 1
    call    malloc
    mov     [rax], r12
    mov     r15, rax

    mov     rdi, r13
    mov     rsi, r15
    call    treeDeleteAux   ; uso treeDeleteAux con un puntero al arbol y un doble puntero al primer nodo del subarbol

    mov     rdi, r15        ; libero la memoria del doble puntero que pedo antes
    call    free

    .fin:
        pop     r15
        pop     r14
        pop     r13
        pop     r12
        pop     rbp
        ret


; RDI --> puntero a nodo
; RSI --> doble puntero a lista
; RDX --> puntero a tree
anadirElementosLista:
    push    rbp
    mov     rbp, rsp
    push    r12
    push    r13
    push    r14
    sub     rsp, 8

    test    rdi, rdi
    jz      .fin

    mov     r12, rdi
    mov     r13, rsi
    mov     r14, rdx

    ; clono la key que voy a agregar
    mov     rdi, [rdx + off_type_key]
    call    getCloneFunction
    mov     rdi, [r12 + off_key]
    call    rax

    ; agrego a la lista la key en cuestion 
    mov     rdi, r13
    mov     rsi, rax
    call    listAdd
    sub     DWORD [r14 + off_size], 1

    ; llamado recursivo para la izquierda
    mov     rdi, [r12 + off_left]
    mov     rsi, r13
    mov     rdx, r14
    call    anadirElementosLista

    ; llamado recursivo para la derecha
    mov     rdi, [r12 + off_right]
    mov     rsi, r13
    mov     rdx, r14
    call    anadirElementosLista

    .fin:
        add     rsp, 8
        pop     r14
        pop     r13
        pop     r12
        pop     rbp
        ret
