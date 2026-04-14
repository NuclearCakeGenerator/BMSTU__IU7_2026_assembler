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
