
global suma

section .text

suma:

	; short suma(short* vector, short n);

	; short* vector -> RDI
	; short n -> RSI

	; Stack Frame (Armado)

	push rbp
	mov rbp, rsp

	; Lógica

	mov ax, 0  ; Acumulador
	mov rcx, 0 ; Contador

.ciclo:
	add ax, [rdi + 2*rcx]

	inc rcx
	cmp rcx, rsi
	jl .ciclo

	; Stack Frame (Limpieza)

	pop rbp

	ret
