%include "constants.inc"
%include "../chars.inc"
%include "../linux_sys.inc"

global print_ub_number

BITS_TO_PRINT equ 64

section .data
    bit_char db 0, CHAR_CARRIAGE_RETURN, CHAR_LINE_FEED

section .text
print_ub_number:
; the number is in rdi
    mov rcx, BITS_TO_PRINT
    push rbx ; preserved reg (for modifiable number)
    mov rbx, rdi ; copy the number to rbx for modification
print_loop:
    mov rdx, rbx
    mov r8, 1 << 63
    and rdx, r8
    shl rbx, 1
    cmp rdx, 0
    je print_zero
    mov byte [bit_char], '1'
    jmp print_bit
print_zero:
    mov byte [bit_char], '0'
print_bit:
    push rcx
    print_string bit_char, 1
    pop rcx
    loop print_loop

    print_string bit_char + 1, 2 ; print new line

    pop rbx ; restore preserved reg
    ret
