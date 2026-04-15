%include "constants.inc"
%include "../chars.inc"
%include "../linux_sys.inc"

extern get_option
extern enter_number
extern print_ub_number
extern print_so_number
extern print_exceeding_degree

global main

section .data
    handlers dq 0 enter_number, print_ub_number, print_so_number, print_exceeding_degree, end_main
    buf db 0, CHAR_CARRIAGE_RETURN, CHAR_LINE_FEED

section .bss
    number resw 1

section .text
main:
    call enter_number

event_loop:
    call get_option
    cmp rax, 5
    je end_main

    call qword [handlers + rax*8]
    jmp event_loop
end_main:
    exit 0
