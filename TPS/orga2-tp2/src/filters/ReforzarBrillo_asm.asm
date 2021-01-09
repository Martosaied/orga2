extern ReforzarBrillo_c
global ReforzarBrillo_asm


section .rodata
    brillo: db 1, 2, 1, 0, 1, 2, 1, 0, 1, 2, 1, 0, 1, 2, 1, 0
    mascaraTransparencia: times 4 db 0, 0, 0, 255
    signado: times 4 dd 128


section .text
; ---------------------------------
; void ReforzarBrillo_asn
;     uint8_t *src  --> RDI
;     uint8_t *dst  --> RSI
;     int width     --> EDX
;     int height    --> ECX
;     int src_row_size --> r8d
;     int dst_row_size --> r9d
;     int umbralSup     --> rbp+16
;     int umbralInf     --> rbp+24
;     int brilloSup     --> rbp+32
;     int brilloInf     --> rbp+40
; ---------------------------------
ReforzarBrillo_asm:
    ; armo stackframe
    push rbp
    mov rbp, rsp
    
    ; signeamos los umbrales, esto es debido a que no tenemos instruccion para crear mascara comparado numeros unsigned
    ; restamos 128 y los interpretamos como numeros signados
    sub    DWORD [rbp+16], 128
    sub    DWORD [rbp+24], 128
    
    ; xmm6 --> | umbralSup | umbralSup | umbralSup | umbralSup |
    movd    xmm6, [rbp + 16]
    pshufd   xmm6, xmm6, 0

    ; xmm7 --> | umbralInf | umbralInf | umbralInf | umbralInf |
    movd    xmm7, [rbp + 24]
    pshufd   xmm7, xmm7, 0

    ; xmm8 --> | brSup | brSup | brSup | brSup | brSup | brSup | brSup | brSup |
    movd    xmm8, [rbp + 32]
    packssdw xmm0, xmm8
    packsswb xmm0, xmm8
    pxor xmm0, xmm0
    pshufb   xmm8, xmm0

    ; xmm9 --> | brInf | brInf | brInf | brInf | brInf | brInf | brInf | brInf |
    movd    xmm9, [rbp + 40]
    packssdw xmm0, xmm9
    packsswb xmm0, xmm9
    pxor xmm0, xmm0
    pshufb   xmm9, xmm0

    ; recorreremos de a 4 pixeles, por lo que caluclo la cantidad total de pixeles y divido por 4 
    imul    rcx, rdx
    sar     rcx, 2

    movdqu      xmm1, [brillo]                      ; muevo mascara de brillo
    movdqu      xmm13, [mascaraTransparencia]       ; muevo mascara de transparencia
    movdqu      xmm12, [signado]                    ; muevo valor para signar 

.ciclo: 
    movdqu      xmm0, [rdi] ; aca vamos a poner el brillo de todos los pixeles
    movdqu      xmm2, xmm0  ; aca vamos a dejar la data de los pixeles

    ; para los 4 pixeles calculo su brillo
    pmaddubsw   xmm0, xmm1       ; xmm0 = [ 1*r1 + 2*g1 | 1*b1 + 0*a1 | 1*r2 + 2*g2 | 1*b2 + 0*a2 | 1*r3 + 2*g3 | 1*b3 + 0*a3 | 1*r4 + 2*g4 | 1*b4 + 0*a4 ]
    phaddw      xmm0, xmm0       ; xmm0 = [ b4 | b3 | b2 | b1 | b4 | b3 | b2 | b1 ]
    psraw       xmm0, 2          ; divido todos los words por 8, ya tengo el brillo (en words)
    pmovzxwd    xmm0, xmm0       ; hago que el brillo de cada pixel ocupe 32bits
    psubd       xmm0, xmm12      ; resto 128 a cada int del xmm0

    ; paso a explicar en que registro vamos a mantener nuestra data cruda y en cuales los vamos a procesar
    ; xmm0 -> brillo, este registro no lo vamos a modificar
    ; xmm2 -> pixeles, pero solo el resultado final luego de haber comparado y procesado con uno de los umbrales
    ; xmm3 -> mascara, este registro guardara la mascara que se usara para sumar/restar los pixeles que lo requieran
    ; xmm4 -> copia de los datos enmascarados, vamos a guardar el resultado de las cuentas pero solo los datos que hayan sido enmascarados
    ; xmm10 -> copiar del valor a sumar/restar, a este le vamos a aplicar la mascara generada para luego sumarle el resultado a xmm4
    ; ------------------------- Umbral Superior -----------------------
    movdqa      xmm3, xmm0  ; copio brillos a xmm3
    movdqa      xmm4, xmm2  ; copio datos a xmm4
    pcmpgtd     xmm3, xmm6  ; creo una mascara con los brillos y los umbrales
    movdqa      xmm10, xmm8 ; muevo brilloSup a xmm10
    pand        xmm10, xmm3 ; aplico mascara, solo sumara en aquellas posiciones que superen el umbral
    paddusb     xmm4, xmm10 ; sumo brilloSup de manera saturada
    ;------------------------------------------------------------------

    pcmpeqb     xmm10, xmm10    ; lleno xmm5 de 1s
    pxor        xmm10, xmm3     ; invierto la mascara, esta me indica que pixeles siguen siendo elegibles para aplicar el filtro con el umbral inferior
    movdqa      xmm2, xmm4      ; muevo el resultado final a xmm2 
    
    ; mismo uso de registros, añadimos xmm11 para tampoco mutar el umbral, ya que al usar al reves pcmpgtd, la mascara se guardarua en xmm7
    ; perdiendo asi el umbral inferior
    ;------------------------------ Umbral Inferior -------------------
    movdqa      xmm11, xmm7     ; copio umbral a xmm11
    pcmpgtd     xmm11, xmm0     ; creo una mascara con los brillos y los umbrales
    pand        xmm11, xmm10    ; filtro mascara de los pixeles a los que ya superaban el superior
    movdqa      xmm10, xmm9     ; muevo brilloInf a xmm10
    pand        xmm10, xmm11    ; aplico mascara, solo restara en aquellas posiciones que no superen el umbral
    psubusb     xmm2, xmm10     ; resto brilloInf de manera saturada
    ;------------------------------------------------------------------


    por         xmm2, xmm13                     ; recompongo las transparencias a 255

    movdqa      [rsi], xmm2                     ; guardo los 128 bits procesados en [rsi]

    add         rsi, 16                         ; avanzo 4 pixeles
    add         rdi, 16                         ; avanzo 4 pixeles
    dec         rcx
    jz          .fin
    jmp         .ciclo

.fin:
    pop         rbp
    ret
