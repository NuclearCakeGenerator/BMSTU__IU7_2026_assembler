%include "constants.inc"
%include "../chars.inc"
%include "../linux_sys.inc"

extern get_option
; extern enter_number
; extern print_ub_number
; extern print_so_number
; extern print_exceeding_degree

global main

section .data
    ; handlers dq enter_number, print_ub_number, print_so_number, print_exceeding_degree, end_main

section .bss
    buf resb 1
    number resw 1

section .text
                                                    ; int main(void)
main:
                                                    ; {
                                                    ;     option = get_option() // in rax
    call get_option
                                                    ;     fprintf(option)
    add al, '0'
    mov [buf], al
    print_string buf, 1
                                                    ;     return 0
    exit 0
                                                    ; }
end_main:
    exit 0
