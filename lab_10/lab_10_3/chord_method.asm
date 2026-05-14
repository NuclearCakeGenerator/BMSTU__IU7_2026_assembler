; NASM program: chord_method.asm
; Chord method root finder for f(x) = sin(x^2 + 5x)

section .data
    fmt_usage db "Usage: %s <a> <b> <iterations>", 10, 0
    fmt_result db "Approximate root after %d iterations: %.12g", 10, 0
    fmt_fx db "f(root) = %.12g", 10, 0
    fmt_error db "Function has same signs at endpoints (f(a)=%g, f(b)=%g)", 10, 0
    
    five dq 5.0
    two dq 2.0
    zero dq 0.0

section .text
    global main
    extern printf
    extern strtod
    extern sin

; Helper: compute f(x) = sin(x^2 + 5x)
; Input: xmm0 = x
; Output: xmm0 = f(x)
compute_f:
    push rbp
    mov rbp, rsp
    sub rsp, 8
    
    movsd qword [rsp], xmm0     ; save x
    
    ; Compute x^2
    movsd xmm1, xmm0
    mulsd xmm0, xmm0            ; x^2
    
    ; Compute 5*x
    movsd xmm2, qword [rsp]     ; load x back
    mulsd xmm2, qword [rel five] ; 5*x
    
    ; Compute x^2 + 5x
    addsd xmm0, xmm2
    
    ; Call sin()
    call sin
    
    add rsp, 8
    pop rbp
    ret

main:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    sub rsp, 64
    
    ; Local stack layout:
    ; [rsp]     = a
    ; [rsp+8]   = b
    ; [rsp+16]  = fa
    ; [rsp+24]  = fb
    ; [rsp+32]  = n_iter
    ; [rsp+40]  = result (root)
    ; [rsp+48]  = f(result)
    ; [rsp+56]  = temp
    
    ; Save argc and argv
    mov r12, rdi            ; argc
    mov r13, rsi            ; argv
    
    ; Check argument count
    cmp r12, 4
    je .parse_args
    
    ; Print usage
    mov rdi, qword [r13]
    lea rsi, [rel fmt_usage]
    xor eax, eax
    call printf
    mov eax, 2
    jmp .exit
    
.parse_args:
    ; Parse a (argv[1])
    mov rdi, qword [r13 + 8]
    lea rsi, [rsp + 56]
    xor edx, edx
    call strtod
    movsd qword [rsp], xmm0
    
    ; Parse b (argv[2])
    mov rdi, qword [r13 + 16]
    lea rsi, [rsp + 56]
    xor edx, edx
    call strtod
    movsd qword [rsp + 8], xmm0
    
    ; Parse n_iter (argv[3])
    mov rdi, qword [r13 + 24]
    lea rsi, [rsp + 56]
    xor edx, edx
    call strtod
    cvttsd2si r14d, xmm0
    mov dword [rsp + 32], r14d
    
    ; Compute fa = f(a)
    movsd xmm0, qword [rsp]
    call compute_f
    movsd qword [rsp + 16], xmm0
    
    ; Compute fb = f(b)
    movsd xmm0, qword [rsp + 8]
    call compute_f
    movsd qword [rsp + 24], xmm0
    
    ; Check sign: fa * fb > 0?
    movsd xmm0, qword [rsp + 16]
    movsd xmm1, qword [rsp + 24]
    mulsd xmm0, xmm1
    comisd xmm0, qword [rel zero]
    ja .sign_error
    
    ; Chord method loop
    xor ebx, ebx
    
.chord_loop:
    cmp ebx, r14d
    jge .chord_done
    
    ; Load current a, b, fa, fb
    movsd xmm2, qword [rsp]         ; a
    movsd xmm3, qword [rsp + 8]     ; b
    movsd xmm4, qword [rsp + 16]    ; fa
    movsd xmm5, qword [rsp + 24]    ; fb
    
    ; Check if fb - fa == 0
    movsd xmm0, xmm5
    subsd xmm0, xmm4
    comisd xmm0, qword [rel zero]
    je .chord_done
    
    ; Compute x = (a*fb - b*fa) / (fb - fa)
    movsd xmm0, xmm2
    mulsd xmm0, xmm5                ; a*fb
    
    movsd xmm1, xmm3
    mulsd xmm1, xmm4                ; b*fa
    
    subsd xmm0, xmm1                ; a*fb - b*fa
    
    movsd xmm1, xmm5
    subsd xmm1, xmm4                ; fb - fa
    
    divsd xmm0, xmm1                ; x
    
    movsd qword [rsp + 56], xmm0    ; save x temporarily
    
    ; Compute fx = f(x)
    call compute_f
    movsd qword [rsp + 48], xmm0    ; save fx
    
    ; Check if fx == 0
    comisd xmm0, qword [rel zero]
    je .chord_done
    
    ; Load saved values
    movsd xmm4, qword [rsp + 16]    ; fa
    movsd xmm5, qword [rsp + 24]    ; fb
    movsd xmm6, qword [rsp + 48]    ; fx
    movsd xmm0, qword [rsp + 56]    ; x
    
    ; Check sign: fa * fx < 0?
    movsd xmm7, xmm4
    mulsd xmm7, xmm6
    comisd xmm7, qword [rel zero]
    jnb .else_branch
    
    ; fa * fx < 0: b = x, fb = fx
    movsd qword [rsp + 8], xmm0     ; b = x
    movsd qword [rsp + 24], xmm6    ; fb = fx
    jmp .loop_continue
    
.else_branch:
    ; a = x, fa = fx
    movsd qword [rsp], xmm0         ; a = x
    movsd qword [rsp + 16], xmm6    ; fa = fx
    
.loop_continue:
    inc ebx
    jmp .chord_loop
    
.chord_done:
    ; Compute result = (a + b) / 2
    movsd xmm0, qword [rsp]
    addsd xmm0, qword [rsp + 8]
    divsd xmm0, qword [rel two]
    movsd qword [rsp + 40], xmm0
    
    ; Compute f(result)
    call compute_f
    movsd qword [rsp + 48], xmm0
    
    ; Print result: printf("Approximate root after %d iterations: %.12g\n", n_iter, result)
    lea rdi, [rel fmt_result]       ; format string in rdi
    mov esi, r14d                   ; n_iter in esi (second positional arg goes in RSI for printf)
    movsd xmm0, qword [rsp + 40]    ; result in xmm0
    mov al, 1                        ; 1 XMM register used
    call printf
    
    ; Print f(result): printf("f(root) = %.12g\n", f_result)
    lea rdi, [rel fmt_fx]
    movsd xmm0, qword [rsp + 48]
    mov al, 1
    call printf
    
    xor eax, eax
    jmp .exit
    
.sign_error:
    movsd xmm0, qword [rsp + 16]
    movsd xmm1, qword [rsp + 24]
    lea rdi, [rel fmt_error]
    mov eax, 2
    call printf
    mov eax, 3
    
.exit:
    add rsp, 64
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
