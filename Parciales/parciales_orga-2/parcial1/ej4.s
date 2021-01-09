%define source 		        (r13)
%define width 		        (rbx)
%define destination 		(r14)
%define row_size 		    (r10)

%define float_size 4
%define double_size 8

global calculation

; double* calculation(float* matriz,int n)
; RDI -> float* matriz
; ESI -> int n

extern malloc

section .text
calculation:
    ; armo stackframe
    push        rbp
    mov         rbp, rsp
    push        width
    push        source
    push        destination
    sub         rsp, 8                  

    mov         source, rdi
    mov         width, rsi

    ; calculo la cantidad de floats totales y luego las divido por 2, ya que pasaremos de guardar  1/4 de cantidad de numeros pero del doble de tamaño
    mov         rdi, width
    imul        rdi, rdi
    shr         rdi, 1
    call        malloc
    mov         destination, rax

    ; calculo la cantidad de floats totales y luego las divido por 16, ya que vamos a recorrer de a 16 pixeles 
    mov         rcx, width 
    imul        rcx, rcx
    shr         rcx, 4
    cmp         rcx, 0  ; si la imagen es de ancho 0 vamos a fin directo
    jz          .fin

    ; calculamos el tamaño de una row
    lea         row_size, [width * float_size]

    ; seteamos en 0 rax y rdi, el primero es para el offset dentro de una misma linea
    ; el segundo para ir avanzando el destination donde guardaremos el result
    xor         rax, rax
    xor         rdi, rdi
.loop:
    mov         rdx, rax    ; muevo el offset dentro de la linea a rdx
    
    ; el offset es para ubicarme en la fila, indica que pixel es el primero de la submatriz, el [0][0]
    movaps      xmm0, [source + rdx]    ; me quedo con los 4 numeros que siguen al offset  
    
    add         rdx, row_size           ; bajo una linea, exactamente por debajo del anterior
    movaps      xmm1, [source + rdx]
    
    add         rdx, row_size           ; otra vez  
    movaps      xmm2, [source + rdx]

    add         rdx, row_size           ; otra vez
    movaps      xmm3, [source + rdx]

    movaps      xmm4, xmm0              ; muevo xmm0 a xmm4
    shufps      xmm4, xmm3, 00111100b   ; me quedo en xmm4 los de las puntas de xmm3
    haddps      xmm4, xmm4              ; suma horizontal
    haddps      xmm4, xmm4              ; suma horizontal de nuevo, ahora en xmm4 tengo la suma de las 4 puntas de la matriz

    ; aqui abajo hacemos lo mismo pero con los 4 del medio de la submatriz
    movaps      xmm5, xmm1              
    shufps      xmm5, xmm2, 10011001b
    haddps      xmm5, xmm5
    haddps      xmm5, xmm5

    ; multiplicamos entre si ambos numeros como dice la cuenta
    mulps       xmm5, xmm4

    ; obtenemos los dos del medio de xmm0 y las puntas de xmm1
    shufps      xmm0, xmm1, 11001001b
    haddps      xmm0, xmm0              
    haddps      xmm0, xmm0
    ; y dejamos en xmm0 la suma de los mismos

    ; obtenemos los dos del medio de xmm2 y las puntas de xmm3
    shufps      xmm3, xmm2, 11001001b
    haddps      xmm3, xmm3
    haddps      xmm3, xmm3
    ; y dejamos en xmm3 la suma de los mismos
    addps       xmm3, xmm0 ; sumamos ambos resultados para hacer la cuenta del numerador


    divps       xmm3, xmm5      ; dividimos xmm5 con xmm3
    cvtss2sd    xmm3, xmm3      ; hacemos la conversion a double

    movsd       [destination + rdi], xmm3 ; guardamos resultado en la posicion determinada de la matriz dst

    add         rdi, double_size    ; avanzo rdi una posicion de double
    add         rax, 16             ; avanzo el offset(rax) 16 bytes(4 floats)
    cmp         rax, row_size       ; comparo rax con el tamaño de la fila 
    je          .advance            ; si son iguales salto a advance
.ret_advance:                       ; etiqueta para volver de advance
    dec         rcx                 ; decremento rcx
    cmp         rcx, 0              ; chequeo que rcx no sea 0
    jnz          .loop              ; salto a loop

.fin:
    mov         rax, destination    ; seteo rax con el puntero a la nueva matriz
    add         rsp, 8
    pop         destination
    pop         source
    pop         width
    pop         rbp
    ret
    
; en este lugar reseteo rax y sumo a source 4 lineas para que ese puntero este apuntando al principio las siguiente 4 lineas
.advance:
    xor     rax, rax
    times 4 add    rax, row_size
    add    source, rax
    xor    rax, rax
    jmp    .ret_advance