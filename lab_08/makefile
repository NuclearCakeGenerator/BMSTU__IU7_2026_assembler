SRCS = main.asm count_bits.asm
OBJS = $(patsubst %.asm,out/%.o,$(SRCS))

all: $(OBJS)
	mkdir -p out
	gcc $(OBJS) -L/usr/lib/x86_64-linux-gnu $(shell pkg-config --libs gtk+-3.0) -o app.exe -no-pie

out/%.o: %.asm
	mkdir -p out
	nasm -f elf64 -o $@ $<

clean:
	rm -rf out app.exe

.PHONY: all clean
