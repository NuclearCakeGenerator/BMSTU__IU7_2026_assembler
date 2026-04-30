all:
	mkdir -p out
	nasm -f elf64 -o out/main.o main.asm
	gcc out/main.o -L/usr/lib/x86_64-linux-gnu $(shell pkg-config --libs gtk+-3.0) -o app.exe -no-pie
