; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================

%include "print.mac"

global start
extern GDT_DESC
extern screen_init
extern mmu_init
extern mmu_init_kernel_dir
extern idt_init
extern IDT_DESC
extern pic_reset
extern pic_enable
extern lesPibardes
extern switchMap
extern tss_initial
extern tss_init
extern sched_init
extern game_init

%define EBP_INIT 0x25000
%define ESP_INIT 0x25000
%define CS_RING_0 0x0050
%define DS_RING_0 0x0060
%define GDT_SEL_VIDEO 0x0070
%define GDT_INDEX_TSS_INIT 15
%define GDT_INDEX_TSS_IDLE 16

BITS 16
; ; Saltear seccion de datos
jmp start

; ;
; ; Seccion de datos.
; ; -------------------------------------------------------------------------- ;;
start_rm_msg db     'Iniciando kernel en Modo Real'
start_rm_len equ    $ - start_rm_msg

start_pm_msg db     'Iniciando kernel en Modo Protegido'
start_pm_len equ    $ - start_pm_msg

; ;
; ; Seccion de código.
; ; -------------------------------------------------------------------------- ;;

; ; Punto de entrada del kernel.
BITS 16
start:
    ; Deshabilitar interrupciones
    cli

    ; Cambiar modo de video a 80 X 50
    mov ax, 0003h
    int 10h  ; set mode 03h
    mov ax, 1112h
    int 10h  ; load 8x8 font

             ; Imprimir mensaje de bienvenida
    print_text_rm start_rm_msg, start_rm_len, 0x07, 0, 0


    ; Habilitar A20
    call A20_disable
    call A20_check
    call A20_enable
    call A20_check


    ; Cargar la GDT
    lgdt [GDT_DESC]


    ; Setear el bit PE del registro CR0
    mov eax, cr0
    or  eax, 0x1
    mov cr0, eax

    ; Saltar a modo protegido
    jmp CS_RING_0:modo_protegido

BITS 32
modo_protegido:

    ; Establecer selectores de segmentos

    mov ax, DS_RING_0
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Establecer la base de la pila
    mov ebp, EBP_INIT
    mov esp, ESP_INIT


    ; Imprimir mensaje de bienvenida
    print_text_pm start_pm_msg, start_pm_len, 0x07, 0, 0

    ; Inicializar pantalla
    mov ax, GDT_SEL_VIDEO
    mov fs, ax
    call limpiar_pantalla_fs

    ; 

    ; Inicializar el manejador de memoria

    call mmu_init

    ; Inicializar el directorio de paginas
    call mmu_init_kernel_dir

    ; Cargar directorio de paginas

    mov cr3, eax

    ; Habilitar paginacion

    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax


    ; Inicializar tss
    call tss_init
    
    ; Inicializar tss de la tarea Idle
    ; medio que lo hicimos en tss_init

    ; Inicializar el scheduler
    call sched_init
    ; Inicializar la IDT
    call idt_init
    ; Cargar IDT
    lidt [IDT_DESC]
    ; Configurar controlador de interrupciones
    call pic_reset
    call pic_enable
    ; Cargar tarea inicial
    mov ax, ((GDT_INDEX_TSS_INIT << 3) | 0x3)
    ltr ax

    call screen_init
    
    call game_init
    ; Habilitar interrupciones
    sti
    

    ; Saltar a la primera tarea: Idle
    jmp ((GDT_INDEX_TSS_IDLE << 3) | 0x0):0

    ; Ciclar infinitamente (por si algo sale mal...)
    mov eax, 0xFFFF
    mov ebx, 0xFFFF
    mov ecx, 0xFFFF
    mov edx, 0xFFFF
    jmp $

    ; ; -------------------------------------------------------------------------- ;;

limpiar_pantalla_fs:
    xor ecx, ecx
    mov ebx, (80 * 50 * 2)
    .loop:
        mov [fs:ecx], WORD 0x0000
        inc ecx
        inc ecx
        cmp ecx, ebx
        jl .loop
    ret

%include "a20.asm"