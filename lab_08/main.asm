bits 64
global main
extern count_bits
extern gtk_init
extern gtk_main
extern gtk_main_quit
extern gtk_window_new
extern gtk_window_set_title
extern gtk_window_set_default_size
extern gtk_window_set_position
extern gtk_widget_show
extern gtk_widget_show_all
extern gtk_container_add
extern gtk_box_new
extern gtk_entry_new
extern gtk_button_new_with_label
extern gtk_label_new
extern gtk_box_pack_start
extern gtk_entry_get_text
extern gtk_label_set_text
extern g_signal_connect_data
extern exit

%define GTK_WIN_POS_CENTER 1
%define GTK_ORIENTATION_VERTICAL 1
%define GTK_WIN_WIDTH 400
%define GTK_WIN_HEIGHT 200

section .bss
window:         resq 1
entry:          resq 1
button:         resq 1
result_label:   resq 1
result_str:     resb 64

section .rodata
window_title:   db "Bit Counter", 0
button_label:   db "Count Bits", 0
initial_label:  db "Result: 0", 0
signal_destroy: db "destroy", 0
signal_clicked: db "clicked", 0
result_prefix:  db "Result: ", 0

section .text

; Helper: simple string to integer conversion
; Input: rdi = string pointer
; Output: rax = parsed integer (or 0 if invalid)
string_to_int:
    xor rax, rax        ; result = 0
    xor rcx, rcx        ; sign = 0
    
    ; Check for minus sign
    mov r8b, byte [rdi]
    cmp r8b, '-'
    jne .parse_loop
    mov rcx, 1          ; sign flag
    inc rdi
    
.parse_loop:
    mov r8b, byte [rdi]
    cmp r8b, 0          ; null terminator?
    je .parse_done
    
    ; Check if digit (0-9)
    cmp r8b, '0'
    jl .parse_done
    cmp r8b, '9'
    jg .parse_done
    
    ; Convert digit to number
    sub r8b, '0'
    imul rax, rax, 10
    movzx r8, r8b
    add rax, r8
    
    inc rdi
    jmp .parse_loop
    
.parse_done:
    ; Apply sign if negative
    cmp rcx, 1
    jne .done_parse
    neg rax
    
.done_parse:
    ret

; Helper: integer to string conversion (simple version)
; Input: rdi = integer, result stored in global result_str
; Uses a buffer and builds string backwards
int_to_string_simple:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    
    mov r12, rdi        ; r12 = input number
    lea rsi, [rel result_str]  ; output buffer in rsi
    
    ; If zero, special case
    test r12, r12
    jnz .not_zero
    mov byte [rsi], '0'
    mov byte [rsi+1], 0
    jmp .str_done
    
.not_zero:
    mov r13, rsi        ; r13 = start of output buffer
    xor r8, r8          ; r8 = negative flag
    
    ; Handle negative numbers
    cmp r12, 0
    jns .start_convert
    mov byte [rsi], '-'
    inc rsi
    mov r8, 1           ; set negative flag
    neg r12             ; negate the number
    
.start_convert:
    ; Build string backwards in a temp location, then copy forward
    lea r9, [rel result_str]
    add r9, 60          ; r9 = temp buffer start (end of result_str)
    mov byte [r9+1], 0  ; null term
    mov r10, r9         ; r10 = write position
    
    mov rax, r12        ; rax = number to convert
    mov rbx, 10         ; rbx = divisor
    
.convert_loop:
    test rax, rax
    jz .copy_result
    
    xor rdx, rdx
    div rbx             ; rdx:rax / 10 -> rax=quotient, rdx=remainder
    add dl, '0'         ; convert digit to ASCII
    mov byte [r10], dl
    dec r10
    
    jmp .convert_loop
    
.copy_result:
    ; Copy from r10+1 to rsi
    inc r10
.copy_loop:
    mov al, byte [r10]
    mov byte [rsi], al
    test al, al
    jz .str_done
    inc r10
    inc rsi
    jmp .copy_loop
    
.str_done:
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

_destroy_window:
    call gtk_main_quit
    ret

; Button click handler
; Input: rdi = button widget, rsi = user_data
on_button_clicked:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    
    ; Get text from entry
    mov rdi, [rel entry]
    call gtk_entry_get_text  ; rax = const char*
    
    ; Convert to integer
    mov rdi, rax
    call string_to_int       ; rax = number
    
    mov r12, rax             ; save number
    
    ; Call count_bits
    mov rdi, r12
    call count_bits          ; rax = bit count
    
    ; Convert result to string
    mov rdi, rax             ; rdi = bit count
    call int_to_string_simple
    
    ; Update label with result
    mov rdi, [rel result_label]
    lea rsi, [rel result_str]
    call gtk_label_set_text
    
    pop r12
    pop rbx
    pop rbp
    ret

main:
    push rbp
    mov rbp, rsp
    push r12
    sub rsp, 8
    
    ; Initialize GTK
    xor rdi, rdi
    xor rsi, rsi
    call gtk_init
    
    ; Create main window
    xor rdi, rdi
    call gtk_window_new
    mov qword [rel window], rax
    
    mov rdi, [rel window]
    lea rsi, [rel window_title]
    call gtk_window_set_title
    
    mov rdi, [rel window]
    mov rsi, GTK_WIN_WIDTH
    mov rdx, GTK_WIN_HEIGHT
    call gtk_window_set_default_size
    
    mov rdi, [rel window]
    mov rsi, GTK_WIN_POS_CENTER
    call gtk_window_set_position
    
    ; Create vertical box container
    mov rdi, GTK_ORIENTATION_VERTICAL
    xor rsi, rsi
    call gtk_box_new
    mov r12, rax        ; r12 = vbox
    
    ; Create and add label
    lea rdi, [rel initial_label]
    call gtk_label_new
    mov [rel result_label], rax
    
    mov rdi, r12
    mov rsi, [rel result_label]
    xor rdx, rdx        ; expand = FALSE
    xor rcx, rcx        ; fill = FALSE
    xor r8, r8          ; padding = 0
    call gtk_box_pack_start
    
    ; Create and add entry
    call gtk_entry_new
    mov [rel entry], rax
    
    mov rdi, r12
    mov rsi, [rel entry]
    mov rdx, 1          ; expand = TRUE
    mov rcx, 1          ; fill = TRUE
    mov r8, 5           ; padding = 5
    call gtk_box_pack_start
    
    ; Create and add button
    lea rdi, [rel button_label]
    call gtk_button_new_with_label
    mov [rel button], rax
    
    mov rdi, r12
    mov rsi, [rel button]
    xor rdx, rdx        ; expand = FALSE
    xor rcx, rcx        ; fill = FALSE
    mov r8, 5           ; padding = 5
    call gtk_box_pack_start
    
    ; Add vbox to window
    mov rdi, [rel window]
    mov rsi, r12
    call gtk_container_add
    
    ; Connect destroy signal
    mov rdi, [rel window]
    lea rsi, [rel signal_destroy]
    lea rdx, [rel _destroy_window]
    xor rcx, rcx
    xor r8, r8
    xor r9, r9
    call g_signal_connect_data
    
    ; Connect button clicked signal
    mov rdi, [rel button]
    lea rsi, [rel signal_clicked]
    lea rdx, [rel on_button_clicked]
    xor rcx, rcx
    xor r8, r8
    xor r9, r9
    call g_signal_connect_data
    
    ; Show all widgets
    mov rdi, [rel window]
    call gtk_widget_show_all
    
    ; Run main loop
    call gtk_main
    
    add rsp, 8
    pop r12
    leave
    ret
