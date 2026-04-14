# Variables
AS = nasm
ASFLAGS = -f elf64 -g -F dwarf # -g and -F dwarf are for debugging
LD = ld
GCC = gcc
LDFLAGS = -no-pie

# Get all .asm files and define their resulting binary names
SRCS = $(wildcard *.asm)
OBJS = $(SRCS:.asm=.o)
APP = app.exe

# Default target: build all
all: $(APP)

# Rule to link the object file into an executable
$(APP): $(OBJS)
	$(GCC) $(LDFLAGS) -o $@ $^

# Rule to assemble .asm into .o
%.o: %.asm
	$(AS) $(ASFLAGS) $< -o $@

# Clean up
clean:
	rm -f *.o $(OBJS) $(APP)

.PHONY: all clean
