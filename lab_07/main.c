#include <stdio.h>
#include <string.h>

extern void copyAsm(char *dst, const char *src, int len);

int strlenAsm(const char *str)
{
    long len;
    __asm__ volatile(
        ".intel_syntax noprefix\n"
        "mov rdi, %1\n"
        "mov rcx, -1\n"
        "xor al, al\n"
        "cld\n"
        "repne scasb\n"
        "not rcx\n"
        "dec rcx\n"
        "mov %0, rcx\n"
        ".att_syntax prefix\n"
        : "=r"(len)
        : "r"(str)
        : "rcx", "rdi", "al", "memory");
    return (int)len;
}



// 1. Обычное копирование без перекрытия
static void test_non_overlap(void)
{
    printf("\n=== %s ===\n", __func__);

    // Arrange
    char src[] = "Hello, world!";
    char dst[50] = "????????";
    int len = strlenAsm(src) + 1;

    // Act
    copyAsm(dst, src, len);

    // Assert
    printf("Результат:   \"%s\"\n", dst);
    printf("Ожидалось:   \"%s\"\n", src);
    if (strcmp(dst, src) == 0)
        printf("=> Тест пройден\n");
    else
        printf("=> Тест НЕ пройден\n");
}

// 2. Копирование пустого источника (src = "", копируем только '\0')
static void test_copy_empty_source(void)
{
    printf("\n=== %s ===\n", __func__);

    // Arrange
    char src[] = "";
    char dst[50] = "Initial text";
    int len = strlenAsm(src) + 1;

    // Act
    copyAsm(dst, src, len);

    // Assert
    printf("Результат:   \"%s\"\n", dst);
    printf("Ожидалось:   \"\" (пустая строка)\n");
    if (dst[0] == '\0')
        printf("=> Тест пройден\n");
    else
        printf("=> Тест НЕ пройден\n");
}

// 3. Копирование с len = 0 (ничего не должно измениться)
static void test_copy_zero_len(void)
{
    printf("\n=== %s ===\n", __func__);

    // Arrange
    char src[] = "Any data";
    char dst[50] = "Original";

    // Act
    copyAsm(dst, src, 0);

    // Assert
    printf("Результат:   \"%s\"\n", dst);
    printf("Ожидалось:   \"%s\" (без изменений)\n", "Original");
    if (strcmp(dst, "Original") == 0)
        printf("=> Тест пройден\n");
    else
        printf("=> Тест НЕ пройден\n");
}

// 4. Копирование в пустой буфер
static void test_copy_to_empty_dest(void)
{
    printf("\n=== %s ===\n", __func__);
    char src[] = "New content";
    char dst[50] = "XXXXXXXXXXXXXXXXX";
    int len = strlenAsm(src) + 1;

    // Act
    copyAsm(dst, src, len);

    // Assert
    printf("Результат:   \"%s\"\n", dst);
    printf("Ожидалось:   \"%s\"\n", src);
    if (strcmp(dst, src) == 0)
        printf("=> Тест пройден\n");
    else
        printf("=> Тест НЕ пройден\n");
}

// 5. Копирование назад (перекрытие, dst > src)
static void test_copy_backward_overlap(void)
{
    printf("\n=== %s ===\n", __func__);

    // Arrange
    char buf[50] = "123456789";
    char expected[] = "123123456";
    int len = 6;

    // Act
    copyAsm(buf + 3, buf, len);

    // Assert
    printf("Результат:   \"%s\"\n", buf);
    printf("Ожидалось:   \"%s\"\n", expected);
    if (strcmp(buf, expected) == 0)
        printf("=> Тест пройден\n");
    else
        printf("=> Тест НЕ пройден\n");
}

// 6. Копирование вперед (перекрытие, dst < src)
static void test_copy_forward_overlap(void)
{
    printf("\n=== %s ===\n", __func__);

    // Arrange
    char buf[50] = "123456789";
    char expected[] = "456789789";
    int len = 6;

    // Act
    copyAsm(buf, buf + 3, len);

    // Assert
    printf("Результат:   \"%s\"\n", buf);
    printf("Ожидалось:   \"%s\"\n", expected);
    if (strcmp(buf, expected) == 0)
        printf("=> Тест пройден\n");
    else
        printf("=> Тест НЕ пройден\n");
}

// 7. Полное перекрытие (dst == src)
static void test_full_overlap(void)
{
    printf("\n=== %s ===\n", __func__);

    // Arrange
    char buf[50] = "Unchanged";
    int len = strlenAsm(buf) + 1;

    // Act
    copyAsm(buf, buf, len);

    // Assert
    printf("Результат:   \"%s\"\n", buf);
    printf("Ожидалось:   \"%s\"\n", "Unchanged");
    if (strcmp(buf, "Unchanged") == 0)
        printf("=> Тест пройден\n");
    else
        printf("=> Тест НЕ пройден\n");
}

// 8. Копирование 1 байта
static void test_copy_one_byte(void)
{
    printf("\n=== %s ===\n", __func__);

    // Arrange
    char src[] = "Abcdef";
    char dst[20] = "XXXXXXXXXX";
    int len = 1;

    // Act
    copyAsm(dst, src, len);

    // Assert
    printf("Результат:   \"%s\"\n", dst);
    printf("Ожидалось:   \"AXXXXXXXXX\"\n");
    if (dst[0] == 'A' && dst[1] == 'X' && dst[2] == 'X' && dst[3] == 'X')
        printf("=> Тест пройден\n");
    else
        printf("=> Тест НЕ пройден\n");
}

// 9. Тест с нулл птр
static void test_nullptr_len_zero(void)
{
    printf("\n=== %s ===\n", __func__);
    
    // Arrange
    char *dst = NULL;
    const char *src = "Hello";
    int len = 0;
    // Act
    copyAsm(dst, src, len);
    // Assert
    printf("Результат: программа не упала\n");
    printf("=> Тест пройден\n");
}

int main()
{

    test_non_overlap();
    test_copy_empty_source();
    test_copy_zero_len();
    test_copy_to_empty_dest();
    test_copy_backward_overlap();
    test_copy_forward_overlap();
    test_full_overlap();
    test_copy_one_byte();
    test_nullptr_len_zero();

    return 0;
}