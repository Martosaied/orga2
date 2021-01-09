global treeTrim

extern getCompareFunction

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

;int treeTrim(tree_t* tree, list_t** key)
; RDI -> tree_t* tree
; RSI -> list_t** key

section .text
treeTrim:
    push rbp
    mov rbp, rsp
    
    mov rdi, [rdi + 0]
    mov rdx, rdi
    call treeTrimAux

    pop rbp
    ret



treeTrimAux:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r13, rdi
    mov r14, rsi

    ; busco maximo en la izquierda
    mov rdi, [r13 + 12] ; tipo de dato de la key
    call getCompareFunction
    mov rbx, [r13]      ; primer nodo
    mov r15, rax        ; puntero a funcion de comparacion
    
    ; Calcular minimo 
    ; Calcular maximo
    ; dejamos minimo en r12 y el maximo en rax
    
    ; mov rdi, rax
    ; mov rsi, [rbx + 0]
    ; call r15
    ; cmp rax, 0 
    ; jge  .eliminarSubarbolIzq

    ; mov rdi, r12
    ; mov rsi, [rbx + 0]
    ; call r15
    ; cmp rax, 0
    ; jle .eliminarSubarbolDer




    ; busco minimo en la derecha

    ; si a >= x, borro arbol izquierdo
    ; si x >= b, borro arbol derecho

    ; ejecuto recursivamente la funcion en los lados
    ; que hayan quedado luego de las validaciones


    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret


max:
    push rbp
    mov rbp, rsp
    
    ; TODO: calcular maximo
    ; RDI --> nodo
    ; RSI --> compare function
    mov rax, 0  

    pop rbp
    ret

min:
    push rbp
    mov rbp, rsp

    
    ; TODO: calcular minimo
    ; RDI --> nodo
    ; RSI --> compare function
    mov rax, 0  

    pop rbp
    ret

