ASM = $(wildcard *.asm)
ASM_O = $(ASM:.asm=.o)

main: ${ASM}
	make ${ASM_O}

%.o: %.asm
	nasm -f elf64 -F DWARF $< -g

clean:
	-rm -f *.o ejec