%include "constants.inc"
%include "../chars.inc"
%include "../linux_sys.inc"

extern system

global get_option

BUFFER_SIZE equ 1

section .data
    menu_msg db "[MENU]",  CHAR_CARRIAGE_RETURN, CHAR_LINE_FEED
    db "[1]", CHAR_TAB, "Enter a new 16 bit SIGNED NEXADECIMAL number.", CHAR_CARRIAGE_RETURN, CHAR_LINE_FEED
    db "[2]", CHAR_TAB, "Print a number in UNSIGNED BINARY form.",  CHAR_CARRIAGE_RETURN, CHAR_LINE_FEED
    db "[3]", CHAR_TAB, "Print a 8bit clipped number in SIGNED OCTAL form.",  CHAR_CARRIAGE_RETURN, CHAR_LINE_FEED
    db "[4]", CHAR_TAB, "Print a LEAST two's degree EXCEEDING this UNSIGNED number.",  CHAR_CARRIAGE_RETURN, CHAR_LINE_FEED
    db "[5]", CHAR_TAB, "Exit.",  CHAR_CARRIAGE_RETURN, CHAR_LINE_FEED
    db  CHAR_CARRIAGE_RETURN, CHAR_LINE_FEED, "Press a number key with a proper menu option",  CHAR_CARRIAGE_RETURN, CHAR_LINE_FEED
    MENU_MSG_LEN equ $ - menu_msg
    raw_cmd db "stty raw -echo",0
    sane_cmd db "stty sane",0

section .bss
    buf resb BUFFER_SIZE

section .text
                                                    ; char get_option(void)
get_option:
                                                    ; {
                                                    ;     system(raw_cmd) via rdi
    mov rdi, raw_cmd
    call system
                                                    ;     fprintf(menu_msg)
    print_string menu_msg, MENU_MSG_LEN
                                                    ;     while(true)
get_option_loop:
                                                    ;     {
                                                    ;         ch = fgetc()
    read_string buf, BUFFER_SIZE
                                                    ;         if ('1' > ch)
                                                    ;          continue
    mov cl, '1'
    cmp cl, [buf]
    jg get_option_loop
                                                    ;         if ('5' < ch)
                                                    ;             continue
    mov cl, '5'
    cmp cl, [buf]
    jl get_option_loop
                                                    ;         break
                                                    ;     }
end_get_option_loop:
                                                    ;     system(sane_cmd) via rdi
    mov rdi, sane_cmd
    call system    
                                                    ;     return ch // via rax
    movzx rax, byte [buf]
    sub rax, '0'
    ret
                                                    ; }
end_get_option:
