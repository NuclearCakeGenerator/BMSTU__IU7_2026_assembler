MAX_HEIGHT EQU 9
MAX_WIDTH  EQU 9

section .data
    matrix db MAX_HEIGHT * MAX_WIDTH dup(0)
    height db 0
    width db 0
    msg1 db "Enter height and width on each line (max 9 each):", 10
    MSG_1_LEN EQU $ - msg1
    read_buffer db MAX_WIDTH + 2 dup(0)
    msg2 db "Enter matrix line by line (each line should have <width> number of digits with no spaces):", 10
    MSG_2_LEN EQU $ - msg2

section .text
    global _start

_start:
    ; print first message
    mov rax, 1
    mov rdi, 1
    mov rsi, msg1
    mov rdx, MSG_1_LEN
    syscall

    ; read height line (digit + newline)
    mov rax, 0
    mov rdi, 0
    mov rsi, read_buffer
    mov rdx, 2
    syscall
    mov al, [read_buffer]
    sub al, '0'
    mov [height], al

    ; read width line (digit + newline)
    mov rax, 0
    mov rdi, 0
    mov rsi, read_buffer
    mov rdx, 2
    syscall
    mov al, [read_buffer]
    sub al, '0'
    mov [width], al

    ; print second message
    mov rax, 1
    mov rdi, 1
    mov rsi, msg2
    mov rdx, MSG_2_LEN
    syscall

    mov rcx, 0                    ; row = 0

row_loop:
    movzx r8, byte [height]
    cmp rcx, r8
    jge done

    ; read one matrix row: width digits + newline
    movzx rdx, byte [width]
    inc rdx
    mov rax, 0
    mov rdi, 0
    mov rsi, read_buffer
    syscall

    ; destination = matrix + row * MAX_WIDTH
    mov rax, rcx
    imul rax, MAX_WIDTH
    lea rdi, [matrix + rax]

    xor rbx, rbx                    ; col = 0

col_loop:
    movzx r8, byte [width]
    cmp rbx, r8
    jge next_row

    mov al, [read_buffer + rbx]
    sub al, '0'
    mov [rdi + rbx], al

    inc rbx
    jmp col_loop

next_row:
    inc rcx
    jmp row_loop

done:
    mov rax, 60
    xor rdi, rdi
    syscall
