
main: *.asm *.c
	nasm -f elf64 -g -F dwarf *.asm
	gcc *.c *.o -o main

clean:
	rm -f *.o main

