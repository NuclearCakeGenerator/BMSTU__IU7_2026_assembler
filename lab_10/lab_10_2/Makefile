NASM = nasm
CC = gcc
LDLIBS = -lm

OUT_DIR = out

all: run_sine

$(OUT_DIR)/sine: sine_nasm.asm | $(OUT_DIR)
	$(NASM) -f elf64 -o $(OUT_DIR)/sine_nasm.o sine_nasm.asm
	$(CC) -no-pie -o $(OUT_DIR)/sine $(OUT_DIR)/sine_nasm.o $(LDLIBS)

run_sine: $(OUT_DIR)/sine
	@echo ""
	@echo "=========================================="
	@echo "Sine Precision Test (x87 FLDPI) - NASM" 
	@echo "=========================================="
	@$(OUT_DIR)/sine

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

clean:
	rm -rf $(OUT_DIR)/*
