#include <stdio.h>
#include <stdlib.h>
#include <math.h>

// Function variant 1: f(x) = sin(x^2 + 5x)
double f(double x) {
    return sin(x*x + 5.0*x);
}

// Regula falsi (chord) method implementation
double chord_method(double a, double b, int n_iter) {
    double fa = f(a);
    double fb = f(b);

    for (int i = 0; i < n_iter; ++i) {
        if (fb - fa == 0.0) break;
        double x = (a*fb - b*fa) / (fb - fa); 
        double fx = f(x);
        if (fx == 0.0) return x;

        if (fa * fx < 0) {
            b = x; fb = fx;
        } else {
            a = x; fa = fx;
        }
    }
    return (a + b) / 2.0;
}

int main(int argc, char **argv) {
    if (argc != 4) {
        fprintf(stderr, "Usage: %s <a> <b> <iterations>\n", argv[0]);
        return 2;
    }

    double a = atof(argv[1]);
    double b = atof(argv[2]);
    int n = atoi(argv[3]);

    double fa = f(a);
    double fb = f(b);
    if (fa * fb > 0) {
        fprintf(stderr, "Function has same signs at endpoints (f(a)=%g, f(b)=%g)\n", fa, fb);
        return 3;
    }

    double root = chord_method(a, b, n);
    printf("Approximate root after %d iterations: %.12g\n", n, root);
    printf("f(root) = %.12g\n", f(root));
    return 0;
}
