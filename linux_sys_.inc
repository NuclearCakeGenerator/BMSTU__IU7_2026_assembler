SYS_WRITE EQU 1
SYS_EXIT  EQU 60
SYS_READ  EQU 0

STDIN     EQU 0
STDOUT    EQU 1

%macro exit 1
    mov rax, SYS_EXIT
    mov rdi, %1
    syscall
%endmacro

%macro print_string 2
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro

%macro read_string 2
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro

%macro print_char 1
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, %1
    mov rdx, 1
    syscall
%endmacro

%macro read_char 1
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, %1
    mov rdx, 1
    syscall
%endmacro
