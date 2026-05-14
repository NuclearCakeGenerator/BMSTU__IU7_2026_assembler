NASM = nasm
CC = gcc
LDLIBS = -lm

OUT_DIR = out

all: run_root

$(OUT_DIR)/root: chord_method.asm | $(OUT_DIR)
	$(NASM) -f elf64 -o $(OUT_DIR)/chord_method.o chord_method.asm
	$(CC) -no-pie -o $(OUT_DIR)/root $(OUT_DIR)/chord_method.o $(LDLIBS)

disassemble: $(OUT_DIR)/root
	objdump -d $(OUT_DIR)/root > $(OUT_DIR)/root.asm

run_root: $(OUT_DIR)/root disassemble
	@echo ""
	@echo "=========================================="
	@echo "Chord Method Root Finder (NASM)"
	@echo "Function: f(x) = sin(x^2 + 5x)"
	@echo "=========================================="
	@echo "Test 1: Finding root on [-5, -0.5] with 30 iterations"
	@$(OUT_DIR)/root -5 -0.5 30
	@echo ""
	@echo "Test 2: Finding root on [-1, 0] with 40 iterations"
	@$(OUT_DIR)/root -1 0 40
	@echo ""
	@echo "Disassembly saved to $(OUT_DIR)/root.asm"

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

clean:
	rm -rf $(OUT_DIR)/*
