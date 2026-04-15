%include "constants.inc"
%include "../chars.inc"
%include "../linux_sys.inc"

global enter_number

NUMBER_BUFFER_SIZE equ 6

section .data
    prompt db "Enter a 16 bit SIGNED HEXADECIMAL number: ", CHAR_CARRIAGE_RETURN, CHAR_LINE_FEED
    PROMPT_LEN equ $ - prompt
    error_msg db "Invalid input. Please enter a valid 16 bit signed hexadecimal number.", CHAR_CARRIAGE_RETURN, CHAR_LINE_FEED
    ERROR_MSG_LEN equ $ - error_msg

section .bss
    number resb 5 ; 4 for the number and 1 for the null terminator and sign

section .text
enter_number:
    print_string prompt, PROMPT_LEN
    read_string number, NUMBER_BUFFER_SIZE

hex_to_bin:
; string is at [number]
mov al, '-'
cmp al, [number]
jne check_as_positive
mov rsi, 1
jmp convert_abs
check_as_positive:
mov rsi, 0

convert_abs:
mov rcx, 4
xor rax, rax
fetch_digit:
xor rdx, rdx
mov dl, [number + rcx - 1]
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
; rax now contains the absolute value of the number
; rsi indicates if the number is negative (1) or positive (0)
; We can now convert it to two's complement if it's negative
cmp rsi, 0
je end_conversion
    neg rax
end_conversion:
    ret

invalid_digit:
    print_string error_msg, ERROR_MSG_LEN
    jmp enter_number
