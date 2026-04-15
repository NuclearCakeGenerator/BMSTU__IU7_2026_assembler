%include "constants.inc"
%include "../chars.inc"
%include "../linux_sys.inc"

global enter_number

NUMBER_BUFFER_SIZE equ 7

section .data
    prompt db "Enter a 16 bit SIGNED HEXADECIMAL number: ", CHAR_CARRIAGE_RETURN, CHAR_LINE_FEED
    PROMPT_LEN equ $ - prompt
    error_msg db "Invalid input. Please enter a valid 16 bit signed hexadecimal number.", CHAR_CARRIAGE_RETURN, CHAR_LINE_FEED
    ERROR_MSG_LEN equ $ - error_msg

section .bss
    number resb NUMBER_BUFFER_SIZE ; 4 for the number and 2 for the null terminator and sign and 1 for overflow detection

section .text
enter_number:
    print_string prompt, PROMPT_LEN
    read_string number, NUMBER_BUFFER_SIZE
    mov rcx, rax ; rax contains the number of bytes read, including the newline character
    dec rcx  ; for correct loop iteration

hex_to_bin:
; string is at [number]
    mov al, '-'
    mov ah, [number]
    cmp al, ah
    jne check_as_positive
    mov rsi, 1   ; for sign flag
    dec rcx      ; skip the '-' character
    jmp check_length
check_as_positive:
    mov rsi, 0

check_length:
    cmp rcx, 4
    jg invalid_digit
    push r12
    mov r12, rcx ; save number length

convert_abs:
    xor rax, rax ; for the resulting number
fetch_digit:
    xor rdx, rdx  ; for fetched character
    mov rdi, rsi
    add rdi, r12
    sub rdi, rcx ; calculate the address of the current digit

    mov dl, [number + rdi]

    cmp dl, 0
    je end_fetch_digits
;convert_digit
    cmp dl, '0'
    jl invalid_digit
    cmp dl, '9'
    jg check_uppercase
    sub dl, '0'
    jmp append_digit

check_uppercase:
    cmp dl, 'A'
    jl invalid_digit
    cmp dl, 'F'
    jg check_lowercase
    sub dl, 'A' - 10
    jmp append_digit

check_lowercase:
    cmp dl, 'a'
    jl invalid_digit
    cmp dl, 'f'
    jg invalid_digit
    sub dl, 'a' - 10
    jmp append_digit

append_digit:
    shl rax, 4
    or rax, rdx

    loop fetch_digit
end_fetch_digits:
; rax now contains the absolute value of the number
; rsi indicates if the number is negative (1) or positive (0)
; We can now convert it to two's complement if it's negative
    cmp rsi, 0
    je end_conversion
    neg rax
end_conversion:
    mov rbx, rax
    pop r12
    ret

invalid_digit:
    print_string error_msg, ERROR_MSG_LEN
    jmp enter_number
