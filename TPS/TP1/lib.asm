section .data
formato_fprintf_float:
    db '%f', 0
formato_fprintf_tree1:
    db '(', 0
formato_fprintf_tree2:
    db ')->', 0
formato_fprintf_str:
    db 'NULL', 0
section .text

global floatCmp
global floatClone
global floatDelete

global strClone
global strLen
global strCmp
global strDelete
global strPrint

global docClone
global docDelete

extern listNew
global listAdd
extern listPrint

global treeInsert
global treePrint

extern free
extern fprintf
extern malloc
extern fopen
extern fputc
extern fwrite
extern getCompareFunction
extern getCloneFunction
extern getPrintFunction

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
         inc rax
         jmp .fin
     .amayorb:
         dec rax
         jmp .fin

floatClone:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8

    mov rbx, rdi ;EN RDX ESTA EL PUNTERO AL FLOAT ORIGINAL
    mov rdi, 4
    call malloc  ;EN RAX ESTA EL PUNTERO NUEVO
    mov ecx, DWORD [rbx]
    mov DWORD [rax], ecx

    add rsp, 8
    pop rbx
    pop rbp
    ret
floatDelete:
    push rbp
    mov rbp, rsp
    call free
    pop rbp
    ret
floatPrint:

    push    rbp
    mov     rbp, rsp

    movss   xmm0, [rdi]
    mov     rdi, rsi
    mov     rsi, formato_fprintf_float
    mov     rax, 1
    call    fprintf

    pop     rbp
    ret

;*** String ***

strClone:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8

    xor rcx, rcx
    .length:
        mov dl, BYTE [rdi + rcx]
        inc rcx
        cmp dl, 0
        jne .length
    mov rbx, rdi ;rbx = puntero a char
    mov rdi, rcx ;rdi = longitud

    call malloc

    xor rcx, rcx ;hay una instruccion loop que automaticamente va decrementando rcx, considerar
    .copy:
        mov dl, BYTE [rbx + rcx]
        mov BYTE [rax + rcx], dl
        inc rcx
        cmp dl, 0
        jne .copy

    add rsp, 8
    pop rbx
    pop rbp
    ret

strLen:
    push rbp
    mov rbp, rsp
    xor rax, rax
    .loop:
        mov dl, BYTE [rdi + rax]
        inc rax
        cmp dl, 0
        jne .loop
    pop rbp
    ret
strCmp:
    push rbp
    mov rbp, rsp

    xor rcx, rcx
    .loop:
        mov al, [rdi + rcx]
        mov dl, [rsi + rcx]
        cmp al, dl
        jb  .amayorb
        ja  .bmayora
        add al, dl
        jz  .iguales
        inc rcx
        jmp .loop
    .fin:
        pop rbp
        ret
    .amayorb:
        mov rax, 1
        jmp .fin
    .bmayora:
        mov rax, -1
        jmp .fin
    .iguales:
        xor rax, rax
        jmp .fin

strDelete:
    push rbp
    mov rbp, rsp
    call free
    pop rbp
    ret
strPrint:
    push rbp
    mov rbp, rsp

    xor rcx, rcx
    mov dl, BYTE [rdi + rcx]
    cmp dl, 0
    je  .imprimirNULL

    .loop:
        mov dl, BYTE [rdi + rcx]
        inc rcx
        cmp dl, 0
        jne .loop
    
    dec rcx
    mov rdx, rcx
    mov rcx, rsi
    mov rsi, 1

    call fwrite

    .fin:
    pop rbp
    ret

.imprimirNULL:
    mov     rdi, rsi
    mov     rsi, formato_fprintf_str
    mov     rax, 0
    call    fprintf
    jmp     .fin

;*** Document ***
;typedef struct s_docElem {
;   type_t type;              0 - 4bytes
;   void* data;               8 - 8bytes
;} docElem_t;                 total: 16 bytes

;typedef struct s_document {
;   int count;                0 - 4bytes
;   struct s_docElem* values; 8 - 8bytes
;} document_t;                total: 16 bytes
docClone:
    ;armo stackframe
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r15
    push    r14
    push    r12

    mov rbx, rdi        ;rbx = puntero a doc original
    mov r14, [rdi + 8]  ;r14 = punto a arreglo original

    ;creamos doc nuevo
    mov rdi, 16
    call malloc
    mov ecx, [rbx + 0] 
    mov [rax + 0], ecx
    mov r12, rax        ;r12 = puntero a doc nuevo

    ;creamos el arreglo nuevo
    mov edi, [rbx + 0]  
    shl rdi, 4         ;rdi = count del doc * 16 (tamaño de cada elem)
    call malloc
    mov [r12 + 8], rax
    mov r15, rax        ;r15 = puntero a arreglo (ergo, al primero elemento)

    .guarda:                ;while(r15 < coso)
        mov eax, [r12 + 0]  ;cantidad de elementos
        sal rax, 4          ;multiplicado por 16 (tamaño de cada elemento)
        add rax, [r12 + 8]  ;sumado a la direccion del arreglo
        cmp r15, rax
        jz .fin

    .loop:
        ;guardo puntero a funcion de clonacion que usare
        mov edi, [r14 + 0]       ;edi = tipo
        mov [r15 + 0], edi
        call getCloneFunction 
        mov rdi, [r14 + 8]
        call rax                ;rax = puntero a copia de data

        mov [r15 + 8], rax

        add r15, 16
        add r14, 16
        jmp .guarda

    .fin:
    mov rax, r12

    ;desarmo stackframe
    pop r12
    pop r14
    pop r15
    pop rbx
    pop rbp
    ret
docDelete:
    ;armo stackframe
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r15

    mov rbx, rdi        ;rbx = puntero a documento
    mov r15, [rdi + 8]  ;r15 = puntero al arreglo

    .guarda:                ;while(r15 < coso)
        mov eax, [rbx + 0]  ;cantidad de elementos
        sal rax, 4          ;multiplicado por 16 (tamaño de cada elemento)
        add rax, [rbx + 8]  ;sumado a la direccion del arreglo
        cmp r15, rax
        jz .deleteDoc

    .loop:
        mov rdi, [r15 + 8]  ;rdi = puntero a la data que quiero borrar
        call free
        add r15, 16
        jmp .guarda

    .deleteDoc:
        mov rdi, [rbx + 8]
        call free

        mov rdi, rbx
        call free

    ;desarmo stackframe
    pop r15
    pop rbx
    pop rbp
    ret

;*** List ***
; typedef struct s_listElem {
;   void* data;                 0 - 8bytes
;   struct s_listElem* next;    8 - 8bytes
;   struct s_listElem* prev;    16 - 8bytes
; } listElem_t;


; typedef struct s_list {
;   type_t type;                  0 - 4bytes
;   uint32_t size;                4 - 4bytes
;   struct s_listElem* first;     8 - 8bytes
;   struct s_listElem* last;      16 - 8bytes
; } list_t;
listAdd:
    ;armo stackframe
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r15
    push    r14
    push    r13
    push    r12
    sub rsp, 8

    mov r14, rdi      ; r14 = puntero a lista
    mov r13, rsi      ; r13 = puntero a data

    ;guardo puntero a funcion de comparacion que usare
    mov edi, [r14 + 0]       ; edi = tipo
    call getCompareFunction 
    mov r12, rax            ; r12 = puntero a funcion

    ;incremento el tamanio de la lista
    inc DWORD [r14 + 4]

    lea r15, [r14 + 8]      ; r15 = direccion puntero al primer nodo (el famoso doble puntero)
    mov rbx, [r15]          ; rbx = puntero a nodo

    .guarda:                ; while(rbx != nullptr && rax != -1)
        test rbx, rbx
        jz .insertar

    .loop:
        mov rdi, r13         ; rdi = puntero a mi data
        mov rsi, [rbx + 0]  ; rsi = puntero a data del nodo actual
        call r12            ; rax = 1 si mi data es mas chica, 0 si son iguales, -1 si mi data es mas grande
        cmp rax, 1
        je .insertar
        lea r15, [rbx + 8]
        mov rbx, [r15]
        jmp .guarda


    .insertar:
        ;pido memoria para el nuevo nodo
        mov rdi, 24
        call malloc         ; rax = puntero a nuevo nodo
        mov [rax + 0], r13   ; le asigno su data
        mov [rax + 8], rbx  ; le asigno su sucesor

        test rbx, rbx       ; quiero ver si es null
        jne .sucNoEsNull
        mov [r14 + 16], rax ; si el sucesor es null, soy el ultimo, seteo el campo last
    .setPred:
        sub r15, 8          ; notar que r15 - 8 va a ser igual al puntero de la lista o al puntero del predecesor, si o si
        cmp r15, r14         ; si r15 es igual al puntero de la lista, soy el primero
        je .soyPrimero
        mov [rax + 16], r15  ; caso contrario, pred es r15
        mov [r15 + 8], rax   ; y su sucesor es el nuevo nodo
        jmp .fin

    .sucNoEsNull:
        mov [rbx + 16], rax ;si no es null, le seteo su nuevo predecesor
        jmp .setPred

    .soyPrimero:
        mov [r14 + 8], rax
        mov QWORD [rax + 16], 0 ; en ese caso, pred es null

    .fin:
    ;desarmo stackframe
    add rsp, 8
    pop r12
    pop r13
    pop r14
    pop r15
    pop rbx
    pop rbp
    ret

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
treeInsert:     ;rdi = *tree, rsi = *key, rdx = *data
    ;armo stackframe
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r15
    push    r14
    push    r13
    push    r12
    sub rsp, 8

    mov r14, rdi      ; r14 = puntero a arbol
    mov r13, rsi      ; r13 = puntero a clave
    mov r12, rdx      ; r12 = puntero a data

    ;guardo puntero a funcion de comparacion que usare
    mov edi, [r14 + 12]     ; edi = tipo
    call getCompareFunction 
    mov r11, rax            ; r11 = puntero a funcion

    lea r15, [r14 + 0]      ; r15 = direccion puntero al primer nodo (el famoso doble puntero)
    mov rbx, [r15]          ; rbx = puntero a nodo

    .guarda:                ; while(r15 != nullptr)
        test rbx, rbx
        jz .insertarNuevo

    .loop:
        mov rdi, r13        ; rdi = puntero a mi clave
        mov rsi, [rbx + 0]  ; rsi = puntero a clave del nodo actual
        call r11            ; rax = 1 si mi clave es mas chica, 0 si son iguales, -1 si mi clave es mas grande
        cmp rax, 1
        je .izquierda
        cmp rax, 0
        je  .insertarExistente

    .derecha:
        lea r15, [rbx + 24]
        mov rbx, [r15]
        jmp .guarda
    .izquierda:
        lea r15, [rbx + 16]
        mov rbx, [r15]
        jmp .guarda

    .insertarExistente:
        mov eax, [r14 + 16] ;si acepta duplicados
        test eax, eax
        jz .fin

        mov edi, [r14 + 20]     ; edi = tipo de data
        call getCloneFunction
        mov rdi, r12
        call rax
        mov r12, rax            ;ahora r12 es el puntero a mi nueva data (clonada)

        inc DWORD [r14 + 8] ;incremento size del arbol
        mov rdi, [rbx + 8]  ;puntero a lista de valores
        mov rsi, r12        ;puntero a mi data
        call listAdd
        mov rax, 1          ;resultado del procedimiento
        jmp .fin

    .insertarNuevo:
        inc DWORD [r14 + 8] ;incremento size

        mov edi, [r14 + 12]     ; edi = tipo de clave      
        call getCloneFunction
        mov rdi, r13
        call rax
        mov r13, rax            ; ahora r13 es el puntero a mi nueva clave (clonada)

        mov edi, [r14 + 20]     ; edi = tipo de data
        call getCloneFunction
        mov rdi, r12
        call rax
        mov r12, rax            ;ahora r12 es el puntero a mi nueva data (clonada)

        ;pido memoria para el nuevo nodo
        mov rdi, 32
        call malloc         ; rax = puntero a nuevo nodo
        mov [rax + 0], r13  ; le asigno su clave
        mov QWORD [rax + 16], 0   ; le asigno su nodo izquierdo
        mov QWORD [rax + 24], 0   ; le asigno su nodo derecho
        mov [rax + 8], rbx  ; le asigno su sucesor
        mov [r15], rax      ; conecto el nuevo nodo al arbol

        mov r13, rax        ; muevo el puntero a r13 porque lo quiero preservar y ya no necesito la clave

        ;creo la nueva lista de valores
        mov edi, [r14 + 20] ; tipo de la data
        call listNew
        mov [r13 + 8], rax  ; le asigno al nuevo nodo su lista de valores
        mov rdi, rax
        mov rsi, r12
        call listAdd       ;agrego la data
        mov rax, 1
    .fin:
    ;desarmo stackframe
    add rsp, 8
    pop r12
    pop r13
    pop r14
    pop r15
    pop rbx
    pop rbp
    ret
treePrint:
    push    rbp
    mov     rbp, rsp
    push    r12
    push    r13
    push    r14
    push    r15

    mov r12, rdi
    mov r15, rsi
       
    mov edi, [r12 + 12]     ; edi = tipo de data
    call getPrintFunction
    mov r13, rax 

    mov edi, [r12 + 20] 
    call getPrintFunction
    mov r14, rax 
    
    mov rcx, r14
    mov rdx, r13
    mov rsi, r15
    mov rdi, [r12 + 0] ; Puntero al primer nodo del arbol 
    call treePrintRecursive
    

    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbp
    ret

treePrintRecursive:
    push    rbp
    mov     rbp, rsp
    push    r12
    push    r13
    push    r14
    push    r15
    
    test rdi, rdi
    jz .fin

    mov r12, rdi    ;r12 = puntero a nodo
    mov r13, rsi    ;r13 = puntero a archivo
    mov r14, rdx    ;r14 = puntero a funcion print key
    mov r15, rcx    ;r15 = puntero a funcion print value

    mov rdi, [r12 + 16]
    mov rsi, r13
    mov rdx, r14
    mov rcx, r15
    call treePrintRecursive

    mov     rdi, r13
    mov     rsi, formato_fprintf_tree1
    mov     rax, 1
    call    fprintf

    mov     rdi, [r12 + 0]
    mov     rsi, r13
    call    r14

    mov     rdi, r13
    mov     rsi, formato_fprintf_tree2
    mov     rax, 1
    call    fprintf

    mov     rdi, [r12 + 8]
    mov     rsi, r13
    call    listPrint

    mov rdi, [r12 + 24]
    mov rsi, r13
    mov rdx, r14
    mov rcx, r15
    call treePrintRecursive

    .fin:
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbp
        ret



