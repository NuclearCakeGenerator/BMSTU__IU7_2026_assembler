CC = gcc
CFLAGS = -std=c99 -O2 -Wall -m80387 -D_GNU_SOURCE
LDLIBS = -lm

OUT_DIR = out

all: run_sine

$(OUT_DIR)/sine: main.c
	$(CC) $(CFLAGS) -o $(OUT_DIR)/sine main.c $(LDLIBS)

disassemble: $(OUT_DIR)/sine
	objdump -d $(OUT_DIR)/sine > $(OUT_DIR)/sine.asm

run_sine: $(OUT_DIR)/sine disassemble
	@echo ""
	@echo "=========================================="
	@echo "Sine Precision Test (x87 FLDPI)"
	@echo "=========================================="
	@$(OUT_DIR)/sine
	@echo ""
	@echo "Disassembly saved to $(OUT_DIR)/sine.asm"

clean:
	rm -rf $(OUT_DIR)/*
