all:
	nasm -f elf64 -o main.o main.asm
	gcc main.o -L/usr/lib/x86_64-linux-gnu $(shell pkg-config --libs gtk+-3.0) -o app.exe -no-pie