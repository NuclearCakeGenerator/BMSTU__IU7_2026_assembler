CC = gcc
CFLAGS = -std=c99 -O2 -Wall
LDLIBS = -lm

OUT_DIR = out

all: run_root

$(OUT_DIR)/root: main.c
	$(CC) $(CFLAGS) -o $(OUT_DIR)/root main.c $(LDLIBS)

disassemble: $(OUT_DIR)/root
	objdump -d $(OUT_DIR)/root > $(OUT_DIR)/root.asm

run_root: $(OUT_DIR)/root disassemble
	@echo ""
	@echo "=========================================="
	@echo "Chord Method Root Finder"
	@echo "Function: f(x) = sin(x^2 + 5x)"
	@echo "=========================================="
	@echo "Test 1: Finding root on [-2, 1] with 30 iterations"
	@$(OUT_DIR)/root -2 1 30
	@echo ""
	@echo "Test 2: Finding root on [-1, 0] with 40 iterations"
	@$(OUT_DIR)/root -1 0 40
	@echo ""
	@echo "Disassembly saved to $(OUT_DIR)/root.asm"

clean:
	rm -rf $(OUT_DIR)/*
