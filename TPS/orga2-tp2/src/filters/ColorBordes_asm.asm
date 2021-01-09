section .rodata
blanco: TIMES 16 db 255
mascaraTransparencia: TIMES 2 dw 0, 0, 0, 0x00FF
global ColorBordes_asm

; void ColorBordes_c(
;    uint8_t *src, => rdi
;    uint8_t *dst, => rsi
;    int width, => edx
;    int height, => ecx
;    int src_row_size, => r8d
;    int dst_row_size) => r9d
section .text
ColorBordes_asm:
    ; stackframe
    push rbp
    mov rbp, rsp
    push r15
    push rbx
    push r12
    sub rsp, 8 ; pila alineada
    
    sub rcx, 2 ; en rcx tengo la altura de mi matriz, pero no quiero llegar a modificar los pixeles que estan en la fila superior o inferior de la matriz, por lo que tengo height-2
    mov r12, rdx ; r12 guarda el ancho original de la imagen (el ancho se mide en pixeles)
    mov rbx, rdx ; rbx va a ser el registro que voy a usar para resetear el contador de columnas (va a tener la cantidad de columnas que realmente quiero recorrer en el ciclo)
    shr rbx, 1 ; divido la cantidad de columnas que tengo por 2, ya que voy a operar sobre 2 pixeles a la vez, por lo que voy a avanzar de a 2 columnas
    sub rbx, 1 ; resto 1 ya que esa va a ser la cantidad de pares de pixeles que voy a poder recorrer, ie, recorro width/2 - 1 pixeles, porque los bordes no requieren calculo

    movdqu xmm15, [blanco] ; pongo en el registro xmm15 16 bytes seteados al valor 255 (color blanco)
    xor rax, rax ; seteo un contador en 0
    .setFirstRowWhite: ; uso este pequeño ciclo para setear la primer fila de la matriz destino en blanco
        movdqu [rsi + rax * 4], xmm15 ; uso xmm15 para setear 4 pixeles en blanco
        add rax, 4 ; avanzo de a 16 bytes (notar que si rax avanza de a 4, el direccionamiento avanza de a 16 bytes, o 4 pixeles)
        cmp rax, r12 ; avanzo hasta que el contador haya pasado por todos los pixeles de la primer fila
        jl .setFirstRowWhite

    ; funcionamiento del ciclo setFirstRowWhite
    ; dst_matrix: | ? | ? | ? | ? | ? | ? | ? | ? |...
    ;    |     |     |     |
    ;    V     V     V     V 
    ; | 255 | 255 | 255 | 255 | ? | ? | ? | ? |...
    ;                            |     |     |     |
    ;                            V     V     V     V 
    ; | 255 | 255 | 255 | 255 | 255 | 255 | 255 | 255 |...

    lea rdi, [rdi + r8 + 4] ; me paro en la posicion src_matrix[1][1] de la matriz de origen
    lea rsi, [rsi + r9 + 4] ; me paro en la posicion dst_matrix[1][1] de la matriz de destino
    ; notar que r8 y r9 tienen en su mitad menos significativa los enteros representando el src_row_size y dst_row_size, y el resto del registro extendido con ceros

    movdqu xmm14, [mascaraTransparencia] ; uso xmm14 para guardar el valor de la mascara que voy a usar para mantener el valor de la componente alpha de cada pixel

    .rowLoop: ; ciclo para iterar sobre las filas de las matrices
        mov rdx, rbx ; uso rdx para iterar sobre las columnas de la fila sobre la que me encuentro
        mov [rsi - 4], dword 0xFFFFFFFF ; seteo el pixel dst_matrix[i][0] en 255 (0xFFFFFFFF) para setearlo en blanco
        .columnLoop:                                                                                                                              
            movdqa xmm8, xmm14 ; uso xmm8 como acumulador de resultados, y al ponerle xmm14 me aseguro de mantener el valor inicial de la componente alpha
            .verticalDifference: ; parte del ciclo donde calculo la diferencia vertical de los pixeles que rodean a aquellos a los que le calculo el valor de colorBorde
                mov r15, r8 ; necesito tener un row_size en negativo para poder restarlo como direccion efectiva cuando accedo a memoria
                neg r15 ; row size en negativo
                pmovzxbw xmm0, [rdi + r15 - 4] ; otra vez el problema del r8 probablemente
                pmovzxbw xmm1, [rdi + r8 - 4] ; (idem arriba)
                ; uso el pmovzxbw para extender cada byte a word para no perder precision con los calculos, es decir, extiendo las componentes rgba de 2 pixeles, de 8 a 16 bytes 
                ; entonces ahora xmm0 y xmm1 tienen los 2 pixeles de la fila superior y de la inferior respectivamente
                ; | px00 | px01 | px02 | px03 |... => xmm0: | px00 | px01 |
                ; | px10 | px11 | px12 | px13 |... => suponiendo que estoy iterando sobre el px11 (que tambien calcula el valor de px12)
                ; | px20 | px21 | px22 | px23 |... => xmm1: | px20 | px21 |

                psubw xmm0, xmm1 ; hago la resta de cada elemento (rgba) entre pixeles
                pabsw xmm0, xmm0 ; pongo el valor absoluto de la resta en xmm0
                ; xmm0: | r01(16b) | g01(16b) | b01(16b) | a01(16b) | r02(16b) | g02(16b) | b02(16b) | a02(16b) |
                ;      -
                ; xmm1: | r11(16b) | g11(16b) | b11(16b) | a11(16b) | r12(16b) | g12(16b) | b12(16b) | a12(16b) |
                ;       _________________________________________________________________________________________
                ; xmm0: abs(| r1(16b) | g1(16b) | b1(16b) | a1(16b) | r2(16b) | g2(16b) | b2(16b) | a2(16b) |) => entiendase que se toma abs() de cada valor

                paddw xmm8, xmm0 ; sumo al acumulador el resultado de abs(pixel_i-1 - pixel_i+1)
                ; xmm8:     | r1_acum | g1_acum | b1_acum | a1_acum | r2_acum | g2_acum | b2_acum | a2_acum |
                ;      +
                ; xmm0: abs(| r(16b) | g(16b) | b(16b) | a(16b) | r2(16b) | g2(16b) | b2(16b) | a2(16b) |)
                ;       __________________________________________
                ; xmm8:     | r1_acum | g1_acum | b1_acum | a1_acum | r2_acum | g2_acum | b2_acum | a2_acum | => nuevo valor acumulado

                ; ahora ocurre lo mismo que antes, pero con los pixeles directamente arriba y abajo del que le estoy calculando el valor
                pmovzxbw xmm0, [rdi + r15]
                pmovzxbw xmm1, [rdi + r8]
                ; | px00 | px01 | px02 | px03 |... => xmm0: | px01 | px02 |
                ; | px10 | px11 | px12 | px13 |... => suponiendo que estoy iterando sobre el px11(que tambien calcula el valor de px12)
                ; | px20 | px21 | px22 | px23 |... => xmm1: | px21 | px22 |

                psubw xmm0, xmm1
                pabsw xmm0, xmm0

                paddw xmm8, xmm0

                ; finalmente, misma operatoria pero con los pixeles siguientes a los que tome anteriormente
                pmovzxbw xmm0, [rdi + r15 + 4]
                pmovzxbw xmm1, [rdi + r8 + 4 ]
                ; | px00 | px01 | px02 | px03 |... => xmm0: | px02 | px03 |
                ; | px10 | px11 | px12 | px13 |... => suponiendo que estoy iterando sobre el px11(que tambien calcula el valor de px12)
                ; | px20 | px21 | px22 | px23 |... => xmm1: | px22 | px23 |

                psubw xmm0, xmm1
                pabsw xmm0, xmm0

                paddw xmm8, xmm0

            .horizontalDifference: ; parte del ciclo donde calculo la diferencia horizontal de los pixeles que rodean a aquellos a los que le calculo el valor de colorBorde
                ; ahora en vez de tomar pixeles de una misma columna, tomo pixeles de una misma fila
                ; entonces voy a tomar valores de 3 filas diferentes, empiezo con la fila i
                pmovzxbw xmm0, [rdi + r15 - 4] ; aca me agarro el par 1 de pixeles de la fila i
                pmovzxbw xmm1, [rdi + r15 + 4] ; aca me agarro el par 2 de pixeles de la fila i
                ; uso el pmovzxbw para extender cada byte a word para no perder precision con los calculos, es decir, extiendo las componentes rgba de 2 pixeles, de 8 a 16 bytes 
                ; entonces ahora xmm0 y xmm1 tienen los 2 pixeles de la fila superior y de la inferior respectivamente
                ; | px00 | px01 | px02 | px03 |... => xmm0: | px00 | px01 | y => xmm1: | px02 | px03 |
                ; | px10 | px11 | px12 | px13 |... => suponiendo que estoy iterando sobre el px11 (que tambien calcula el valor de px12)
                ; | px20 | px21 | px22 | px23 |...

                psubw xmm0, xmm1 ; los resto
                pabsw xmm0, xmm0 ; tomo su valor absoluto
                ; notar que la operacion es la misma que en verticalDifference, pero con la diferencia que los valores que estoy operando
                ; pertenecen a la misma fila, y los resto de la siguiente manera:
                ; xmm0: | r00(16b) | g00(16b) | b00(16b) | a00(16b) | r01(16b) | g01(16b) | b01(16b) | a01(16b) |
                ;      -
                ; xmm1: | r02(16b) | g02(16b) | b02(16b) | a02(16b) | r03(16b) | g03(16b) | b03(16b) | a03(16b) |
                ;       _________________________________________________________________________________________
                ; xmm0: abs(| r1(16b) | g1(16b) | b1(16b) | a1(16b) | r2(16b) | g2(16b) | b2(16b) | a2(16b) |) => entiendase que se toma abs() de cada valor

                paddw xmm8, xmm0 ; lo sumo al acumulador, igual que en verticalDifference
                
                ; ahora fila i+1
                pmovzxbw xmm0, [rdi + (-1)*4] ; aca me agarro el par 1 de pixeles de la fila i+1
                pmovzxbw xmm1, [rdi + 4] ; aca me agarro el par 2 de pixeles de la fila i+1

                psubw xmm0, xmm1 ; los resto
                pabsw xmm0, xmm0 ; tomo su valor absoluto

                paddw xmm8, xmm0 ; lo sumo al acumulador

                ; ahora fila i+2
                pmovzxbw xmm0, [rdi + r8 + (-1)*4] ; aca me agarro el par 1 de pixeles de la fila i+2
                pmovzxbw xmm1, [rdi + r8 + 4] ; aca me agarro el par 2 de pixeles de la fila i+2
                ; | px00 | px01 | px02 | px03 |...
                ; | px10 | px11 | px12 | px13 |... => suponiendo que estoy iterando sobre el px11 (que tambien calcula el valor de px12)
                ; | px20 | px21 | px22 | px23 |... => xmm0: | px20 | px21 | y => xmm1: | px22 | px23 |

                psubw xmm0, xmm1 ; los resto
                pabsw xmm0, xmm0 ; tomo su valor absoluto

                paddw xmm8, xmm0 ; lo sumo al acumulador

                ; ahora hay que cerrar el ciclo
                packuswb xmm8, xmm8 ; paso los valores que use por separado a bytes, entonces tengo en la parte baja del xmm8 el resultado de los dos pixeles
                ; la instruccion pack ya satura los valores, por lo que no necesito aplicar nada mas para conseguir la saturacion

                ; este codigo cierra la iteracion sobre estos 2 pixeles
                movq [rsi], xmm8 ; muevo el valor de xmm8 a su respectiva posicion en la matriz de destino 
                add rdi, 8 ; avanzo 2 columnas desde donde estaba parado (porque agarre 2 pixeles)
                add rsi, 8 ; idem pero sobre el dst

            dec rdx ; veo cuantas columnas me quedan recorrer
            jnz .columnLoop ; la instruccion dec ya actualiza los flags, por lo que me es suficiente para hacer el salto condicional
            mov [rsi], dword 0xFFFFFFFF ; seteo el ultimo valor de la fila en 255 (0xFFFFFFFF) para setearlo en blanco
            add rsi, 8 ; hago lo mismo que rdi (origen) con rsi (destino)
            add rdi, 8 ; esta suma me deja parado en la columna 1 de la fila que sigue por recorrer (8 es porque me salto la columna 0, por lo que quedo apuntando al primer byte de la 1)

        dec rcx ; una fila menos para recorrer
        jnz .rowLoop ; si todavia me quedan filas por recorrer, vuelvo a ejecutar el loop desde la columna 1 de la fila que sigue
    
    xor rax, rax
    lea rsi, [rsi - 4] ; como despues de terminar con todos los ciclos, quede parado en la ultima fila, y columna 1, me muevo a la columna 0 de esa fila
    .setLastRowWhite: ; este ciclo cumple con la misma funcion que setFirstRowWhite
        movdqu [rsi + rax * 4], xmm15
        add rax, 4
        cmp rax, r12
        jl .setLastRowWhite
        
    ; cierro stackframe
    add rsp, 8
    pop r12
    pop rbx
    pop r15
    pop rbp
    ret
