%include "constants.inc"
%include "../chars.inc"
%include "../linux_sys.inc"

extern system

BUFFER_SIZE equ 1

section .data
    menu_msg db "[MENU]", CHAR_NEWLINE
    db "[1]", CHAR_TAB, "Enter a new 16 bit SIGNED NEXADECIMAL number.", CHAR_NEWLINE
    db "[2]", CHAR_TAB, "Print a number in UNSIGNED BINARY form.", CHAR_NEWLINE
    db "[3]", CHAR_TAB, "Print a 8bit clipped number in SIGNED OCTAL form.", CHAR_NEWLINE
    db "[4]", CHAR_TAB, "Print a LEAST two's degree EXCEEDING this UNSIGNED number.", CHAR_NEWLINE
    db CHAR_NEWLINE, "Press a number key with a proper menu option", CHAR_NEWLINE
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
                                                    ;     while(true)
get_option_loop:
                                                    ;     {
                                                    ;         fprintf(menu_msg)
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, menu_msg
    mov rdx, MENU_MSG_LEN
    syscall
                                                    ;         ch = fgetc() // finally store in rbx
    mov rax, SYS_READ
    mod rdi, STDIN
    mov rsi, buf
    mov rdx, BUFFER_SIZE
                                                    ;         if (ch == '1')
                                                    ;             break
    mov cl, '1'
    cmp cl, [buf]
    je end_get_option_loop
                                                    ;         else if (ch == '2')
                                                    ;             break
    mov cl, '2'
    cmp cl, [buf]
    je end_get_option_loop
                                                    ;         else if (ch == '3')
                                                    ;             break
    mov cl, '3'
    cmp cl, [buf]
    je end_get_option_loop
                                                    ;         else if (ch == '4')
                                                    ;             break
    mov cl, '4'
    cmp cl, [buf]
    je end_get_option_loop
                                                    ;     }
jmp get_opton_loop
end_get_option_loop:
                                                    ;     system(sane_cmd) via rdi
    mov rdi, raw_cmd
    call system    
                                                    ;     return ch // via rax
    movzx rax [buf]
    sub rax, '0'
                                                    ; }
end_get_option:


