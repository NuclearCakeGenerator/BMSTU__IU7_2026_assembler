# Variables
AS = nasm
ASFLAGS = -f elf64 -g -F dwarf  # -g and -F dwarf are for debugging
LD = ld
LDFLAGS = 

# Get all .asm files and define their resulting binary names
SRCS = $(wildcard *.asm)
BINS = $(SRCS:.asm=)

# Default target: build all
all: $(BINS)

# Rule to link the object file into an executable
%: %.o
	$(LD) $(LDFLAGS) -o $@ $<

# Rule to assemble .asm into .o
%.o: %.asm
	$(AS) $(ASFLAGS) $< -o $@

# Clean up
clean:
	rm -f *.o $(BINS)

.PHONY: all clean