#include <stdio.h>
#include <math.h>

double sin_approx_3_14() {
    double result;
    asm volatile(
        "fldl $3.14\n\t"
        "fsin\n"
        : "=t" (result)
        :
        :
    );
    return result;
}

double sin_approx_3_141596() {
    double result;
    asm volatile(
        "fldl $3.141596\n\t"
        "fsin\n"
        : "=t" (result)
        :
        :
    );
    return result;
}

double sin_fldpi() {
    double result;
    asm volatile(
        "fldpi\n\t"
        "fsin\n"
        : "=t" (result)
        :
        :
    );
    return result;
}

double sin_pi_half_3_14() {
    double result;
    asm volatile(
        "fldl $3.14\n\t"
        "fldl $2.0\n\t"
        "fdiv\n\t"
        "fsin\n"
        : "=t" (result)
        :
        :
    );
    return result;
}

double sin_pi_half_3_141596() {
    double result;
    asm volatile(
        "fldl $3.141596\n\t"
        "fldl $2.0\n\t"
        "fdiv\n\t"
        "fsin\n"
        : "=t" (result)
        :
        :
    );
    return result;
}

double sin_pi_half_fldpi() {
    double result;
    asm volatile(
        "fldpi\n\t"
        "fldl $2.0\n\t"
        "fdiv\n\t"
        "fsin\n"
        : "=t" (result)
        :
        :
    );
    return result;
}

int main() {
    printf("Sine Precision Comparison\n");
    printf("==========================================\n");
    printf("sin(PI):\n");
    printf("  Approx 3.14:       %.12f\n", sin_approx_3_14());
    printf("  Approx 3.141596:   %.12f\n", sin_approx_3_141596());
    printf("  x87 FLDPI:         %.12f\n", sin_fldpi());
    
    printf("\nsin(PI/2):\n");
    printf("  Approx 3.14/2:     %.12f\n", sin_pi_half_3_14());
    printf("  Approx 3.141596/2: %.12f\n", sin_pi_half_3_141596());
    printf("  x87 FLDPI/2:       %.12f\n", sin_pi_half_fldpi());
    
    return 0;
}
