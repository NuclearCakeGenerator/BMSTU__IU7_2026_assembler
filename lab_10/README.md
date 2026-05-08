# Lab 10 — Mathematical coprocessor: chord-method root finder

This program implements the "method of chords" (regula falsi) to find a root
of the function f(x) = sin(x^2 + 5x) (function variant 1) on a given interval.

Build:

```sh
make -C lab_10
```

Run:

```sh
./lab_10/main <a> <b> <iterations>
# Example:
./lab_10/main -2 1 30
```

The program prints the approximate root and the value f(root).
