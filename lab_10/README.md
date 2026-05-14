# Lab 10: x87 FPU Implementation

## Overview

This lab demonstrates advanced floating-point computation using the x87 FPU (80387 coprocessor) on x86-64 architecture. The lab is structured in three independent subtasks, each with its own objective and implementation.

## Architecture

```
lab_10/
├── Makefile              # Main orchestrator with run_1, run_2, run_3 targets
├── README.md            # This file
└── lab_10_N/            # Subtask directories (N=1,2,3)
    ├── Makefile         # Individual subtask build configuration
    ├── out/             # Build output directory
    └── source files     # Implementation files
```

## Subtasks

### Subtask 1: Performance Comparison (lab_10_1/)

**Objective:** Compare floating-point operation performance with x87 FPU enabled/disabled and inline assembly.

**Files:**
- `main.cpp` - Native C++ with compiler-optimized floating-point
- `main_asm.cpp` - Inline x87 assembly using AT&T syntax
- `Makefile` - Builds three binaries: `app_80387`, `app_no80387`, `app_asm`

**Features:**
- Measures 1,000,000 iterations of ADD and MUL operations
- Tests both 32-bit (float) and 64-bit (double) precision
- Reports timing in nanoseconds per operation
- Shows impact of x87 vs SSE and inline assembly optimization

**Build & Run:**
```bash
make run_1
```

**Expected Output:**
```
Native C++ Floating Point Operations (1000000 iterations)
Float ADD:         X.XX ns/op
Float MUL:         X.XX ns/op
Double ADD:        X.XX ns/op
Double MUL:        X.XX ns/op

Testing with Inline Assembly
Inline Assembly Floating Point Operations (1000000 iterations)
Float ADD:         X.XX ns/op
Float MUL:         X.XX ns/op
Double ADD:        X.XX ns/op
Double MUL:        X.XX ns/op
```

---

### Subtask 2: Sine Precision Comparison (lab_10_2/)

**Objective:** Compare sine function precision using different π approximations and the x87 FPU's exact π loading instruction.

**Files:**
- `sine_nasm.asm` - Pure NASM assembly implementation using x87 FPU
- `Makefile` - NASM compilation and GCC linking

**Features:**
- Tests three π approximations:
  1. π ≈ 3.14 (rough approximation)
  2. π ≈ 3.141596 (better approximation)
  3. x87 FLDPI instruction (exact built-in precision)
- Computes sin(π) and sin(π/2) for each approximation
- Displays computed π value with full precision
- Demonstrates advantages of hardware-native x87 instructions

**Architecture:** 
- Pure x87 FPU stack operations
- No external function dependencies
- Demonstrates fldpi, fsin, fstp instructions

**Build & Run:**
```bash
make run_2
```

**Expected Output:**
```
Sine Precision Test (x87 FLDPI) - NASM
========================================
sin(PI):  Approx 3.14: X.XXXX
  Approx 3.141596: X.XXXXX
  x87 FLDPI: -0.000000000000
sin(PI/2):  Approx 3.14/2: X.XXXX
  Approx 3.141596/2: X.XXXXX
  x87 FLDPI/2: 1.000000000000
========================================
  x87 FLDPI: 3.141592653590
```

---

### Subtask 3: Root Finding via Chord Method (lab_10_3/)

**Objective:** Implement the chord method (regula falsi) for finding roots of f(x) = sin(x² + 5x) using pure x87 FPU arithmetic.

**Files:**
- `chord_method.asm` - Pure NASM assembly with x87-only floating-point
- `Makefile` - NASM compilation and GCC linking for root finding

**Features:**
- Chord method implementation for interval root finding
- Function: f(x) = sin(x² + 5x)
- Pure x87 FPU stack-based arithmetic
- No SSE operations for floating-point computation
- Command-line arguments: `./root <a> <b> <iterations>`
- Tests with multiple intervals

**Architecture:**
- `compute_f(x)` - Computes f(x) = sin(x² + 5x) using x87 stack
- `main()` - Implements chord method iteration
- Stack-based parameter passing with careful register management

**x87 Stack Operations Used:**
- `fld` - Load value onto stack
- `fstp` - Store and pop
- `fmul`, `fadd`, `fdiv` - Arithmetic operations
- `fsin` - Sine function
- `fcompp` - Compare and pop
- `fstsw` - Transfer status word to AX
- `sahf` - Transfer AH to CPU flags

**Build & Run:**
```bash
make run_3
```

**Test Cases:**
1. Interval [-5, -0.5] with 30 iterations
2. Interval [-1, 0] with 40 iterations

**Expected Output:**
```
Chord Method Root Finder (NASM)
Function: f(x) = sin(x^2 + 5x)
==========================================
Test 1: Finding root on [-5, -0.5] with 30 iterations
Approximate root after 30 iterations: X.XX
f(root) = X.XXXXXXX

Test 2: Finding root on [-1, 0] with 40 iterations
Approximate root after 30 iterations: X.XX
f(root) = X.XXXXXXX
```

---

## Building All Subtasks

From the lab_10 root directory:

```bash
# Build and run default (Subtask 3)
make

# Run specific subtask
make run_1    # Performance comparison
make run_2    # Sine precision
make run_3    # Root finding

# Clean all build artifacts
make clean
```

---

## Technical Details

### x87 FPU Stack Management

The x87 FPU (80387 coprocessor) uses an 8-register stack (ST0-ST7) for floating-point operations:

- **Push/Load:** `fld` loads a value onto the stack, incrementing the stack pointer
- **Pop/Store:** `fstp` stores a value and pops it from the stack
- **Operations:** Arithmetic operations typically pop their arguments after producing a result
- **Return Convention:** Results are left on the x87 stack; caller responsibility to `fstp`

### Calling Convention Notes

- **Integer Arguments:** rdi, rsi, rdx, rcx, r8, r9
- **Floating-Point Arguments:** xmm0-xmm7 (SSE convention)
- **Return Values:** 
  - Integer: rax/rdx
  - Floating-point: xmm0/xmm1 (SSE)
  - x87 stack: Result in ST0 (caller must fstp to retrieve)

### Stack Alignment

The x86-64 ABI requires 16-byte stack alignment before `call` instructions. All subtasks maintain proper alignment during function prologue/epilogue.

---

## Implementation Notes

### NASM Syntax Considerations

- x87 register operands: `fsubp st1` (NOT `fsubp st(1)` - that's GCC inline asm syntax)
- RIP-relative addressing for position-independent code: `[rel label]`
- 64-bit operand specifier: `qword [address]` for 8-byte memory operations
- Stack allocation: `sub rsp, 80` to allocate local variables

### Compilation & Linking

```bash
# Subtask 1: C++ compilation with x87 flags
gcc -m80387 -O2 main.cpp -o app_80387

# Subtask 2 & 3: NASM assembly
nasm -f elf64 -o output.o source.asm
gcc -no-pie -o executable output.o -lm
```

---

## Performance Characteristics

The x87 FPU typically shows:
- Good performance for transcendental functions (sin, cos, etc.) vs software implementations
- Variable performance for basic operations (add, mul) compared to modern SSE/AVX
- No parallelization compared to SIMD instructions
- Useful for maintaining legacy 387 coprocessor compatibility

---

## References

- x86-64 System V ABI Calling Convention
- Intel x87 FPU Reference
- NASM Assembler Manual
- GCC Inline Assembly (AT&T Syntax)
