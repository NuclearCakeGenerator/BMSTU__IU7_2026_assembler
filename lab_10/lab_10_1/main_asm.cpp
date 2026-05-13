#include <iostream>
#include <chrono>
#include <cstdint>
#include <cstdlib>
#include <ctime>
#include <iomanip>

// COUNT of operations
const int COUNT = 1000000;

// Global arrays for testing
float float_a[COUNT], float_b[COUNT];
double double_a[COUNT], double_b[COUNT];
float float_result[COUNT];
double double_result[COUNT];

void init_random_data() {
    srand(time(nullptr));
    for (int i = 0; i < COUNT; ++i) {
        float_a[i] = static_cast<float>(rand()) / RAND_MAX;
        float_b[i] = static_cast<float>(rand()) / RAND_MAX;
        double_a[i] = static_cast<double>(rand()) / RAND_MAX;
        double_b[i] = static_cast<double>(rand()) / RAND_MAX;
    }
}

void test_float_add() {
    auto start = std::chrono::high_resolution_clock::now();
    for (int i = 0; i < COUNT; ++i) {
        float result;
        float a = float_a[i];
        float b = float_b[i];
        asm volatile(
            "flds %2\n\t"
            "fadds %1\n"
            : "=t" (result)
            : "m" (a), "m" (b)
            :
        );
        float_result[i] = result;
    }
    auto end = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count();
    std::cout << "Float ADD:    " << std::setw(12) << duration << " ns" << std::endl;
}

void test_float_mul() {
    auto start = std::chrono::high_resolution_clock::now();
    for (int i = 0; i < COUNT; ++i) {
        float result;
        float a = float_a[i];
        float b = float_b[i];
        asm volatile(
            "flds %2\n\t"
            "fmuls %1\n"
            : "=t" (result)
            : "m" (a), "m" (b)
            :
        );
        float_result[i] = result;
    }
    auto end = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count();
    std::cout << "Float MUL:    " << std::setw(12) << duration << " ns" << std::endl;
}

void test_double_add() {
    auto start = std::chrono::high_resolution_clock::now();
    for (int i = 0; i < COUNT; ++i) {
        double result;
        double a = double_a[i];
        double b = double_b[i];
        asm volatile(
            "fldl %2\n\t"
            "faddl %1\n"
            : "=t" (result)
            : "m" (a), "m" (b)
            :
        );
        double_result[i] = result;
    }
    auto end = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count();
    std::cout << "Double ADD:   " << std::setw(12) << duration << " ns" << std::endl;
}

void test_double_mul() {
    auto start = std::chrono::high_resolution_clock::now();
    for (int i = 0; i < COUNT; ++i) {
        double result;
        double a = double_a[i];
        double b = double_b[i];
        asm volatile(
            "fldl %2\n\t"
            "fmull %1\n"
            : "=t" (result)
            : "m" (a), "m" (b)
            :
        );
        double_result[i] = result;
    }
    auto end = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count();
    std::cout << "Double MUL:   " << std::setw(12) << duration << " ns" << std::endl;
}

int main() {
    init_random_data();
    
    std::cout << "Inline Assembly Floating Point Operations (" << COUNT << " iterations)" << std::endl;
    std::cout << "========================================" << std::endl;
    
    test_float_add();
    test_float_mul();
    test_double_add();
    test_double_mul();
    
    return 0;
}
