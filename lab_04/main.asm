global MAX_HEIGHT
global MAX_WIDTH
global ZERO_CODE
global _start
global matrix
global height
global width

extern print_matrix
extern process_matrix
extern SYS_WRITE
extern SYS_EXIT
extern SYS_READ
extern STDIN
extern STDOUT

MAX_HEIGHT EQU 9
MAX_WIDTH  EQU 9
ZERO_CODE EQU '0'

section .data

    matrix db MAX_HEIGHT * MAX_WIDTH dup(0)
    height db 0
    width db 0
    msg1 db "Enter height and width on each line (max 9 each):", 10
    MSG_1_LEN EQU $ - msg1
    read_buffer db MAX_WIDTH + 2 dup(0)
    msg2 db "Enter matrix line by line (each line should have <width> number of digits with no spaces):", 10
    MSG_2_LEN EQU $ - msg2
    msg3 db "Inital matrix:", NEW_LINE
    MSG_3_LEN EQU $ - msg3
    msg4 db "Matrix after deleting column:", NEW_LINE
    MSG_4_LEN EQU $ - msg4

section .text
_start:
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, msg1
    mov rdx, MSG_1_LEN
    syscall

    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, read_buffer
    mov rdx, 2                                  ; Read height and '/n'.
    syscall
    mov al, [read_buffer]
    sub al, ZERO_CODE
    mov [height], al

    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, read_buffer
    mov rdx, 2                                  ; Read width and '/n'.
    syscall
    mov al, [read_buffer]
    sub al, ZERO_CODE
    mov [width], al

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, msg2
    mov rdx, MSG_2_LEN
    syscall

    mov r12, 0                                  ; row index = 0.
row_loop:
    movzx r8, byte [height]
    cmp r12, r8
    jge exit_row_loop

    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, read_buffer
    movzx rdx, byte [width]
    inc rdx                                   ; Read width + '/n'.
    syscall

    ; Destination pointer for current row:
    ; rdi = &matrix[row * MAX_WIDTH]
    mov rax, r12                              ; rax = row.
    imul rax, MAX_WIDTH                       ; rax = row * 9.
    lea rdi, [matrix + rax]                   ; Row base address.
    mov r13, 0                                ; col index = 0.
col_loop:
    movzx r8, byte [width]
    cmp r13, r8
    jge exit_col_loop

    mov al, [read_buffer + r13]               ; Read digit from input row.
    sub al, ZERO_CODE                         ; Convert code to numeric value.
    mov [rdi + r13], al                       ; Store into matrix[row][col].

    inc r13                                   ; col++.
    jmp col_loop                              ; Continue processing row.

exit_col_loop:
    inc r12                                   ; row++.
    jmp row_loop                              ; Continue processing matrix.

exit_row_loop:

                                                            ; printf(msg3)
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, msg3
    mov rdx, MSG_3_LEN
    syscall
                                                            ; print_matrix()
    call print_matrix
                                                            ; process_matrix()
    call process_matrix
                                                            ; printf(msg4)
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, msg4
    mov rdx, MSG_4_LEN
    syscall
                                                            ; print_matrix()
    call print_matrix


    mov rax, SYS_EXIT
    mov rdi, 0                              ; Exit status = 0.
    syscall

