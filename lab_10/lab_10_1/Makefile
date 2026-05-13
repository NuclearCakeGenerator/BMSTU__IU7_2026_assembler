CXX = g++
CXXFLAGS = -std=c++11 -O2 -Wall

OUT_DIR = out

# Default target
all: run_tests

# Build with 80387 FPU enabled
$(OUT_DIR)/app_80387: main.cpp
	$(CXX) $(CXXFLAGS) -m80387 -o $(OUT_DIR)/app_80387 main.cpp

# Build with 80387 FPU disabled (SSE)
$(OUT_DIR)/app_no80387: main.cpp
	$(CXX) $(CXXFLAGS) -mno-80387 -o $(OUT_DIR)/app_no80387 main.cpp

# Build with inline assembly version
$(OUT_DIR)/app_asm: main_asm.cpp
	$(CXX) $(CXXFLAGS) -m80387 -o $(OUT_DIR)/app_asm main_asm.cpp

# Generate disassembly
disassemble: $(OUT_DIR)/app_80387 $(OUT_DIR)/app_no80387 $(OUT_DIR)/app_asm
	objdump -d $(OUT_DIR)/app_80387 > $(OUT_DIR)/app_80387.asm
	objdump -d $(OUT_DIR)/app_no80387 > $(OUT_DIR)/app_no80387.asm
	objdump -d $(OUT_DIR)/app_asm > $(OUT_DIR)/app_asm.asm

# Run all tests
run_tests: $(OUT_DIR)/app_80387 $(OUT_DIR)/app_no80387 $(OUT_DIR)/app_asm disassemble
	@echo ""
	@echo "=========================================="
	@echo "Testing with x87 (80387) ENABLED"
	@echo "=========================================="
	@$(OUT_DIR)/app_80387
	@echo ""
	@echo "=========================================="
	@echo "Testing with x87 (80387) DISABLED (SSE)"
	@echo "=========================================="
	@$(OUT_DIR)/app_no80387
	@echo ""
	@echo "=========================================="
	@echo "Testing with Inline Assembly"
	@echo "=========================================="
	@$(OUT_DIR)/app_asm
	@echo ""
	@echo "Disassembly files generated in $(OUT_DIR)/"

clean:
	rm -rf $(OUT_DIR)/*
