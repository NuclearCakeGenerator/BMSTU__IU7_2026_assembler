section .data
    msg db "Hello, Linux x64!", 10
    len equ $ - msg

section .text
    global _start

_start:
    ; syscall: write(1, msg, len)
    mov rax, 1          ; syscall number for sys_write
    mov rdi, 1          ; file descriptor 1 (stdout)
    mov rsi, msg        ; pointer to message
    mov rdx, len        ; message length
    syscall

    ; syscall: exit(0)
    mov rax, 60         ; syscall number for sys_exit
    xor rdi, rdi        ; exit code 0
    syscall