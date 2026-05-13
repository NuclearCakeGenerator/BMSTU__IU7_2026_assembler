; NASM program: sine_nasm.asm
; Compares sin(pi) and sin(pi/2) using approximations and x87 FLDPI

section .data
    title      db "Sine Precision Comparison", 10, 0
    sep        db "==========================================", 10, 0
    fmt_label  db "%s", 0
    fmt_value  db "  %s %12.12f", 10, 0

    lbl_pi     db "sin(PI):", 0
    lbl_pi2    db "sin(PI/2):", 0

    label_314   db "Approx 3.14:", 0
    label_31496 db "Approx 3.141596:", 0
    label_x87   db "x87 FLDPI:", 0

    label_314_half   db "Approx 3.14/2:", 0
    label_31496_half db "Approx 3.141596/2:", 0
    label_x87_half   db "x87 FLDPI/2:", 0

    pi_3_14      dq 3.14
    pi_3_141596  dq 3.141596
    two           dq 2.0

    tmp_val      dq 0.0

section .text
    global main
    extern printf

main:
    push rbp
    mov rbp, rsp

    ; print title and separator
    lea rdi, [rel title]
    xor eax, eax
    call printf
    lea rdi, [rel sep]
    xor eax, eax
    call printf

    ; sin(PI):
    lea rdi, [rel lbl_pi]
    xor eax, eax
    call printf

    ; 3.14
    fld qword [rel pi_3_14]
    fsin
    fstp qword [rel tmp_val]
    lea rdi, [rel fmt_value]
    lea rsi, [rel label_314]
    movsd xmm0, qword [rel tmp_val]
    mov eax, 1
    call printf

    ; 3.141596
    fld qword [rel pi_3_141596]
    fsin
    fstp qword [rel tmp_val]
    lea rdi, [rel fmt_value]
    lea rsi, [rel label_31496]
    movsd xmm0, qword [rel tmp_val]
    mov eax, 1
    call printf

    ; x87 FLDPI
    fldpi
    fsin
    fstp qword [rel tmp_val]
    lea rdi, [rel fmt_value]
    lea rsi, [rel label_x87]
    movsd xmm0, qword [rel tmp_val]
    mov eax, 1
    call printf

    ; newline
    lea rdi, [rel sep]
    xor eax, eax
    call printf

    ; sin(PI/2):
    lea rdi, [rel lbl_pi2]
    xor eax, eax
    call printf

    ; 3.14/2
    fld qword [rel pi_3_14]
    fld qword [rel two]
    fdivp st1, st0    ; st0 = pi/2
    fsin
    fstp qword [rel tmp_val]
    lea rdi, [rel fmt_value]
    lea rsi, [rel label_314_half]
    movsd xmm0, qword [rel tmp_val]
    mov eax, 1
    call printf

    ; 3.141596/2
    fld qword [rel pi_3_141596]
    fld qword [rel two]
    fdivp st1, st0
    fsin
    fstp qword [rel tmp_val]
    lea rdi, [rel fmt_value]
    lea rsi, [rel label_31496_half]
    movsd xmm0, qword [rel tmp_val]
    mov eax, 1
    call printf

    ; x87 FLDPI/2
    fldpi
    fld qword [rel two]
    fdivp st1, st0
    fsin
    fstp qword [rel tmp_val]
    lea rdi, [rel fmt_value]
    lea rsi, [rel label_x87_half]
    movsd xmm0, qword [rel tmp_val]
    mov eax, 1
    call printf

    ; final newline
    lea rdi, [rel sep]
    xor eax, eax
    call printf

    ; print actual M_PI using C constant (call from libc):
    ; use format "  Actual PI value:   %.12f\n"
    lea rdi, [rel fmt_value]
    lea rsi, [rel label_x87]    ; reuse label
    ; load M_PI via x87 FLDPI then store
    fldpi
    fstp qword [rel tmp_val]
    movsd xmm0, qword [rel tmp_val]
    mov eax, 1
    call printf

    mov eax, 0
    leave
    ret
