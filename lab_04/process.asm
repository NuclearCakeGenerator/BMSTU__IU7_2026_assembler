global process_matrix
global print_matrix

%include "constants.inc"

section .data
extern matrix
extern height
extern width

section .text
print_matrix:
    ; push rbp  ; save the base pointer for caller
    ; mov rbp, rsp    ; set the base pointer to the current stack pointer
    push r12
    push r13

    mov r12, 0 ; current row index = 0
print_matrix_row_loop:
    cmp r12b, byte [height]
    jge exit_print_matrix_row_loop

    mov r13, 0 ; current column index = 0
print_matrix_column_loop:
    cmp r13b, byte [width]
    jge exit_print_matrix_column_loop

    mov r8, r12
    imul r8, MAX_WIDTH
    mov al, [matrix + r8 + r13] ; load matrix[r12][r13] into rax
    add al, ZERO_CODE
    push rax  ; push the character to print onto the stack

    ; print matrix[r12][r13]
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, rsp
    mov rdx, 1
    syscall
    add rsp, 8  ; clean up the stack after printing

    mov al, SPACE_CHAR
    push rax  ; push space character to print onto the stack
    ; print space character
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, rsp
    mov rdx, 1
    syscall
    add rsp, 8

    inc r13
    jmp print_matrix_column_loop
exit_print_matrix_column_loop:

    ; print new line character
    mov al, NEW_LINE
    push rax  ; push new line character to print onto the stack
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, rsp
    mov rdx, 1
    syscall
    add rsp, 8

    inc r12
    jmp print_matrix_row_loop
exit_print_matrix_row_loop:

    ; pop rbp  ; restore the base pointer for caller
    pop r13
    pop r12
    ret
end_print_matrix:
; just for readability


                                                    ; process_matrix()
process_matrix:
                                                    ; {
                                                    ;     int least_column_index = find_least_column(); // in rax
    call find_least_column
                                                    ;     delete_column(least_column_index)
    mov rdi, rax
    call delete_column
                                                    ;     return()
    ret
                                                    ; }
end_process_matrix:


                                                    ; delete_column(least_column_index):
delete_column:
                                                    ; {
;   rdi = least_column_index (passed by caller in rdi)
                                                    ;     current_row_index = 0 // in rax
    mov rax, 0
                                                    ;     while (current_row_index < height)
delete_column_row_loop:
    cmp al, byte [height]
    jge exit_delete_column_row_loop
                                                    ;     {
                                                    ;         current_column_index = least_column_index // in rcx
    mov rcx, rdi
                                                    ;         while (current_column_index + 1 < width)
delete_column_column_loop:
    mov r9, rcx
    inc r9
    cmp r9b, byte [width]
    jge exit_delete_column_column_loop
                                                    ;         {
                                                    ;             t = matrix[current_row_index][current_column_index + 1] // in rdx
    mov r8, rax
    imul r8, MAX_WIDTH
    mov rdx, [matrix + r8 + rcx + 1]
                                                    ;             matrix[current_row_index][current_column_index] = t
    mov [matrix + r8 + rcx], rdx
                                                    ;             current_column_index++
    inc rcx
    jmp delete_column_column_loop
                                                    ;         }
exit_delete_column_column_loop:
                                                    ;         current_row_index++
    inc rax
    jmp delete_column_row_loop
                                                    ;     }
exit_delete_column_row_loop:
                                                    ;     return
    ret
                                                    ; }
end_delete_column:


; find_column_sum(column_index)
find_column_sum:
    ; push rbp
    ; mov rbp, rsp

;   rdi = column_index (passed by caller in rdi)
    mov rax, 0 ; sum = 0

    mov rcx, 0 ; row index = 0
find_column_sum_row_loop:
    cmp cl, byte [height]
    jge exit_find_column_sum_row_loop

    mov r8, rcx
    imul r8, MAX_WIDTH
    add rax, [matrix + r8 + rdi] ; sum += matrix[row][column_index]
    inc rcx
    jmp find_column_sum_row_loop
exit_find_column_sum_row_loop:
    ; pop rbp
    ret
end_find_column_sum:



                                                    ; find_least_column()
                                                    ; {
find_least_column:
    ; push rbp
    ; mov rbp, rsp
                                                    ;     int least_sum = find_column_sum(0); // in rcx
    mov rdi, 0 ; column_index = 0
    call find_column_sum
    mov rcx, rax
                                                    ;     int least_column_index = 0; // in rax
    mov rax, 0
                                                    ;     int column_index = 1; // in rdx
    mov rdx, 1
                                                    ;     while (column_index < width)
find_least_column_loop:
    cmp dl, byte [width]
    jge exit_find_least_column_loop
                                                    ;     {
                                                    ;         int rax = find_column_sum(column_index)
    push rax  ; save rax before call
    push rcx  ; save rcx before call
    push rdx  ; save rdx before call

    mov rdi, rdx
    call find_column_sum

    pop rdx  ; restore rdx after call
    pop rcx  ; restore rcx after call
    pop rax  ; restore rax after call
                                                    ;         if (rax < least_sum)
    cmp rax, rcx
    jge skip_update_least_column
                                                    ;         {
                                                    ;             least_sum = rax;
    mov rcx, rax
                                                    ;             least_column_index = column_index;
    mov rax, rdx
                                                    ;         }
skip_update_least_column:
                                                    ;         column_index++;
    inc rdx
    jmp find_least_column_loop
                                                    ;     }
exit_find_least_column_loop:
                                                    ;     return least_column_index; // via rax
    ; pop rbp
    ret
                                                    ; }
end_find_least_column:




