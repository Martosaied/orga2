; Ejercicio 3
; void gris_ASM(uint8_t* imgRGB, short n, uint16_t* imgGray);

; Dada una matriz de nˆn pixeles RGB (1 byte por componente), hacer una funcion que convierta los
; pixeles a escala de grises usando la formula (R + 2 * G + B) / 4

; RDI -> uint8_t* imgRGB
; RSI -> short n
; RDX -> uint16_t* imgGray

%define argDirImgRGB    (rdi)
%define argN            (rsi)
%define argDirImgGray   (rdx)

%define colorR          (al)
%define colorG          (bl)
%define colorB          (cl)
%define nColor          (r15)
%define nPixel          (rcx)
%define dirImgGray      (r10)
%define dirImgRGB       (r11)
%define imgSize 		(r12)

global gris_ASM

section .text
gris_ASM: 
    ; Armo Stackframe
    push rbp
    mov rbp, rsp

    mov dirImgGray, argDirImgGray
    mov dirImgRGB, argDirImgRGB
    mov nPixel, 0
    mov nColor, 0

    mov rax, argN
    mul rax
	mov imgSize, 0
	mov imgSize, rax


.ciclo:
	mov ax, 0
	mov al, [dirImgRGB + nColor + 1]
	sal ax, 1
	mov bx, 0
	mov bl, [dirImgRGB + nColor + 0]
	add ax, bx
	mov bl, [dirImgRGB + nColor + 2]
	add ax, bx
; divido
	sar ax, 2
; grabo en la imagen de salida
	mov [dirImgGray + nPixel], al
; condición del cico
	add nColor, 3
	inc nPixel
	cmp nPixel, imgSize
	jl .ciclo
; fin del ciclo

    pop rbp
    ret




