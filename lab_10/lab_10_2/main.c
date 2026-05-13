#define _USE_MATH_DEFINES
#include <stdio.h>
#include <math.h>

int main() {
    // Test values
    double pi_approx_1 = 3.14;
    double pi_approx_2 = 3.141596;
    double pi_exact;
    
    // Load exact pi using x87 FLDPI instruction via inline assembly
    __asm__ volatile(
        "fldpi\n"
        : "=t" (pi_exact)
    );
    
    printf("Sine Precision Comparison\n");
    printf("==========================================\n");
    printf("sin(PI):\n");
    printf("  Approx 3.14:       %.12f\n", sin(pi_approx_1));
    printf("  Approx 3.141596:   %.12f\n", sin(pi_approx_2));
    printf("  x87 FLDPI:         %.12f\n", sin(pi_exact));
    
    printf("\nsin(PI/2):\n");
    printf("  Approx 3.14/2:     %.12f\n", sin(pi_approx_1 / 2.0));
    printf("  Approx 3.141596/2: %.12f\n", sin(pi_approx_2 / 2.0));
    printf("  x87 FLDPI/2:       %.12f\n", sin(pi_exact / 2.0));
    
    printf("\nActual precision comparison:\n");
    printf("  Actual PI value:   %.12f\n", M_PI);
    printf("  x87 FLDPI value:   %.12f\n", pi_exact);
    printf("  Difference:        %.15f\n", pi_exact - M_PI);
    
    return 0;
}
