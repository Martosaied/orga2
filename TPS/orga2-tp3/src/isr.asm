; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================

; Definicion de rutinas de atencion de interrupciones

%include "print.mac"

%define MEESEEKS_VIRT_START 0x8000000
%define MEESEEKS_VIRT_END 0x08014000
%define SCANCODE_Y 0x15
%define KEYBOARD_PORT 0x60

extern imprimir_excepcion
extern restaurar_pantalla
extern printScanCode
extern desalojar_tarea
extern screen_incTasksClocks

; SYSCALLS
extern create_mrmeeseeks
extern move
extern use_portal_gun
extern look
BITS 32

modo_debug: db 1
error_enable: db 0
sched_task_offset:     dd 0xFFFFFFFF
sched_task_selector:   dw 0xFFFF


; ; PIC
extern pic_finish1

; ; Sched
extern sched_next_task

extern game_checkEndOfGame

global back_trace

; ;
; ; Definición de MACROS
; ; -------------------------------------------------------------------------- ;;




%macro ISR_CON_ERROR_CODE 1
; Cada rutina de excepcion debe indicar en pantalla que problema se produjo
; e interrumpir la ejecucion. Posteriormente se modificaran estas rutinas para que se continue la
; ejecucion, resolviendo el problema y desalojando a la tarea que lo produjo.
global _isr%1

_isr%1:
        push dword [esp]
        pushad

        mov al, BYTE [modo_debug]
        cmp al, 1
        jne .moveOn

        mov BYTE [error_enable], 1

        ; registros de segmento y control
        push ss
        push gs
        push fs
        push es
        push ds
        push cs
        mov eax, cr4
        push eax
        mov eax, cr3
        push eax
        mov eax, cr2
        push eax
        mov eax, cr0
        push eax

        ; mensaje de error y codigo de error
        push DWORD isr_msg%1
        mov eax, DWORD %1
        push eax
        call imprimir_excepcion
        add esp, 36

        .moveOn:
        call desalojar_tarea

        jmp ((GDT_INDEX_TSS_IDLE << 3) | 0x0):0

    .fin:
        popad
        add esp, 4
        iret

%endmacro
; --------------------------------------------------------------------------------------------------
%macro ISR 1
; Cada rutina de excepcion debe indicar en pantalla que problema se produjo
; e interrumpir la ejecucion. Posteriormente se modificaran estas rutinas para que se continue la
; ejecucion, resolviendo el problema y desalojando a la tarea que lo produjo.
global _isr%1

_isr%1:
        push dword 0
        pushad

        mov al, BYTE [modo_debug]
        cmp al, 1
        jne .moveOn

        mov BYTE [error_enable], 1

        ; registros de segmento y control
        push ss
        push gs
        push fs
        push es
        push ds
        push cs
        mov eax, cr4
        push eax
        mov eax, cr3
        push eax
        mov eax, cr2
        push eax
        mov eax, cr0
        push eax

        ; mensaje de error y codigo de error
        push DWORD isr_msg%1
        mov eax, DWORD %1
        push eax
        call imprimir_excepcion

        add esp, 36

        .moveOn:
        call desalojar_tarea

        jmp ((GDT_INDEX_TSS_IDLE << 3) | 0x0):0

        .fin:
        popad
        add esp, 4
        iret

%endmacro
%define GDT_INDEX_TSS_IDLE 16

; ; Rutina de atención de las EXCEPCIONES
; ; -------------------------------------------------------------------------- ;;
ISR 0
ISR 1
ISR 2
ISR 3
ISR 4
ISR 5
ISR 6
ISR 7
ISR_CON_ERROR_CODE 8
ISR_CON_ERROR_CODE 9
ISR_CON_ERROR_CODE 10
ISR_CON_ERROR_CODE 11
ISR_CON_ERROR_CODE 12
ISR_CON_ERROR_CODE 13
ISR_CON_ERROR_CODE 14
ISR 15
ISR 16
ISR_CON_ERROR_CODE 17
ISR 18
ISR 19

isr_msg0: db 1, 32, 'Divide error', 32, 1, 0
isr_msg1: db 1, 32, 'Reserved', 32, 1,0
isr_msg2: db 1, 32, 'NMI interrupt', 32, 1,0
isr_msg3: db 1, 32, 'Breakpoint', 32, 1,0
isr_msg4: db 1, 32, 'Overflow', 32, 1,0
isr_msg5: db 1, 32, 'BOUND range exceeded', 32, 1,0
isr_msg6: db 1, 32, 'Invalid opcode (undefined opcode)', 32, 1,0
isr_msg7: db 1, 32, 'Device not available (no math coprocessor)', 32, 1,0
isr_msg8: db 1, 32, 'Double Fault', 32, 1,0
isr_msg9: db 1, 32, 'Coprocessor segment overrun (reserved)', 32, 1,0
isr_msg10: db 1, 32, 'Invalid TSS', 32, 1,0
isr_msg11: db 1, 32, 'Segment not present', 32, 1,0
isr_msg12: db 1, 32, 'Stack-Segment fault', 32, 1,0
isr_msg13: db 1, 32, 'General Protection', 32, 1,0
isr_msg14: db 1, 32, 'Page Fault', 32, 1,0
isr_msg15: db 1, 32, 'Reserved', 32, 1,0
isr_msg16: db 1, 32, 'x87 FPU Floating-Point error (math fault)', 32, 1,0
isr_msg17: db 1, 32, 'Alignment check', 32, 1,0
isr_msg18: db 1, 32, 'Machine check', 32, 1,0
isr_msg19: db 1, 32, 'SIMD Floating-Point exception', 32, 1,0

; ; Rutina de atención del RELOJ
global _isr32
_isr32:
        pushad
        ; Avisar al pic que se recibio la interrupcion
        call pic_finish1

        cmp BYTE [error_enable], 1
        je .fin

        ; Imprimir el reloj del sistema
        call next_clock

        ; imprimir relojes en pantalla
        call screen_incTasksClocks

        ; check end of game
        call game_checkEndOfGame
        call sched_next_task
        ; si el proximo es 0 no salto
        cmp ax, 0
        je .fin

        ; verificar que la proxima tarea no sea la actual
        str cx
        cmp ax, cx
        je .fin

        mov word [sched_task_selector], ax ; se carga el selector de segmento
        jmp far [sched_task_offset]

        .fin:
        popad
        iret
        ; ; -------------------------------------------------------------------------- ;;
        ; ; Rutina de atención del TECLADO
global _isr33
_isr33:
        pushad
        mov  ebp, esp

        in al, KEYBOARD_PORT

        cmp al, SCANCODE_Y
        jne .noModoDebug

        cmp BYTE [modo_debug], 0
        je .entrarADebug

        call restaurar_pantalla

        mov BYTE [error_enable], 0
        mov BYTE [modo_debug], 0


        .entrarADebug:
        mov BYTE [modo_debug], 1

        .noModoDebug:
        ; Avisar al pic que se recibio la interrupcion
        call pic_finish1
        popad
        iret
        ; ; -------------------------------------------------------------------------- ;;
        ; ; Rutinas de atención de las SYSCALLS
global _isr88
global _isr89
global _isr100
global _isr123

_isr88:
        push ebp
        mov ebp, esp
        sub esp, 4
        pushad

        push ecx
        push ebx
        push eax

        call create_mrmeeseeks
        mov [ebp - 4], eax

        add esp, 12
        jmp ((GDT_INDEX_TSS_IDLE << 3) | 0x0):0

        popad
        pop eax
        pop ebp
        iret

_isr89:
        pushad
        mov ebp, esp

        call use_portal_gun
        jmp ((GDT_INDEX_TSS_IDLE << 3) | 0x0):0

        popad
        iret

_isr100:
        push ebp
        mov ebp, esp
        sub esp, 8
        pushad

        mov eax, ebp
        sub eax, 8
        push eax
        add eax, 4
        push eax
        call look
        add esp, 8

        jmp ((GDT_INDEX_TSS_IDLE << 3) | 0x0):0


        popad
        pop ebx
        pop eax
        pop ebp
        iret

_isr123:
        push ebp
        mov ebp, esp
        sub esp, 4
        pushad

        push ebx
        push eax
        call move
        add esp, 8
        mov [ebp - 4], eax

        jmp ((GDT_INDEX_TSS_IDLE << 3) | 0x0):0

        popad
        pop eax
        pop ebp
        iret
        ; ; -------------------------------------------------------------------------- ;;
        ; ; Funciones Auxiliares
        ; ; -------------------------------------------------------------------------- ;;
isrNumber:           dd 0x00000000
isrClock:            db '|/-\'
next_clock:
        pushad
        inc DWORD [isrNumber]
        mov ebx, [isrNumber]
        cmp ebx, 0x4
        jl .ok
                mov DWORD [isrNumber], 0x0
                mov ebx, 0
        .ok:
                add ebx, isrClock
                print_text_pm ebx, 1, 0x0f, 49, 79
                popad
        ret

back_trace:
        push ebp
        mov  ebp, esp
        push edi
        push ebx                           ; armar stack frame

        mov  ebx, [ebp + 12]               ; ebx = segundo parametro (ebp que le llego a la excepcion)
        mov  edi, [ebp + 8]                ; edi = puntero a array
        mov  ecx, 5                        ; limite de backtrace
.caminante_no_hay_camino:
        test ebx, ebx                      ; que no sea 0
        jz   .fin
        test ebx, 11b                      ; que sea multiplo de 4
        jnz   .fin
        cmp ebx, MEESEEKS_VIRT_START       ; que este dentro de los limites del codigo valido
        jl .fin
        cmp ebx, MEESEEKS_VIRT_END         ; que este dentro de los limites del codigo valido
        jge .fin
        mov  edx, [ebx + 4]                ; edx = la return address previa
        mov  ebx, [ebx + 0]                ; ebx = el stackframe previo.
        mov  [edi], edx                    ; copiamos viejo eip al array de retorno.
        add  edi, 4
        loop .caminante_no_hay_camino
.fin:
        pop ebx
        pop edi
        pop ebp
        ret


