.PHONY: run_1 run_2 run_3 all clean

# Default target
all: run_3

# Subtask 1: Performance comparison (add/mul with x87 disabled/enabled, asm)
run_1:
	$(MAKE) -C lab_10_1 all

# Subtask 2: Sine precision comparison (NASM)
run_2:
	$(MAKE) -C lab_10_2 all

# Subtask 3: Root finding via chord method
run_3:
	$(MAKE) -C lab_10_3 all

clean:
	$(MAKE) -C lab_10_1 clean
	$(MAKE) -C lab_10_2 clean
	$(MAKE) -C lab_10_3 clean
