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
        float_result[i] = float_a[i] + float_b[i];
    }
    auto end = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count();
    std::cout << "Float ADD:    " << std::setw(12) << duration << " ns" << std::endl;
}

void test_float_mul() {
    auto start = std::chrono::high_resolution_clock::now();
    for (int i = 0; i < COUNT; ++i) {
        float_result[i] = float_a[i] * float_b[i];
    }
    auto end = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count();
    std::cout << "Float MUL:    " << std::setw(12) << duration << " ns" << std::endl;
}

void test_double_add() {
    auto start = std::chrono::high_resolution_clock::now();
    for (int i = 0; i < COUNT; ++i) {
        double_result[i] = double_a[i] + double_b[i];
    }
    auto end = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count();
    std::cout << "Double ADD:   " << std::setw(12) << duration << " ns" << std::endl;
}

void test_double_mul() {
    auto start = std::chrono::high_resolution_clock::now();
    for (int i = 0; i < COUNT; ++i) {
        double_result[i] = double_a[i] * double_b[i];
    }
    auto end = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count();
    std::cout << "Double MUL:   " << std::setw(12) << duration << " ns" << std::endl;
}

int main() {
    init_random_data();
    
    std::cout << "Native C++ Floating Point Operations (" << COUNT << " iterations)" << std::endl;
    std::cout << "========================================" << std::endl;
    
    test_float_add();
    test_float_mul();
    test_double_add();
    test_double_mul();
    
    return 0;
}
