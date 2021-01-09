CFLAGS=-Wall -Wextra -pedantic -std=c99 -Wconversion -Og -ggdb -no-pie
CC=gcc
AS=nasm
ASFLAGS=-f elf64 -g -FDWARF
EJ1OBJS=ej1_asm.o lib_c.o ej1_c.o
EJ2OBJS=ej2_asm.o lib_c.o ej2_c.o
EJ3OBJS=ej3_asm.o lib_c.o ej3_c.o
EJ4OBJS=ej4_asm.o lib_c.o ej4_c.o

all: ej1 ej2 ej3 ej4

format:
	clang-format -style=Chromium -i *.c *.h

%_asm.o: %.s
	$(AS) $(ASFLAGS) $^ -o $@

%_c.o: %.c
	$(CC) $(CFLAGS) $^ -c -o $@

ej1: $(EJ1OBJS)
	$(CC) $(CFLAGS) $^ -o $@

ej2: $(EJ2OBJS)
	$(CC) $(CFLAGS) $^ -o $@

ej3: $(EJ3OBJS)
	$(CC) $(CFLAGS) $^ -o $@

ej4: $(EJ4OBJS)
	$(CC) $(CFLAGS) $^ -o $@

clean:
	rm -f *.o ej1 ej2 ej3 ej4
