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

; Helper: compute f(x) = sin(x^2 + 5x) using x87 FPU
; Input: xmm0 = x
; Output: xmm0 = f(x)
compute_f:
    push rbp
    mov rbp, rsp
    sub rsp, 24
    
    ; Save x to stack
    movsd qword [rsp], xmm0     ; [rsp] = x
    
    ; Use x87 FPU to compute sin(x^2 + 5x)
    ; Compute x^2
    fld qword [rsp]             ; st0 = x
    fld qword [rsp]             ; st0 = x, st1 = x
    fmul                        ; st0 = st0*st1 (result in st1), pop
    fstp qword [rsp + 8]        ; store x^2, pop
    
    ; Compute 5*x
    fld qword [rel five]        ; st0 = 5
    fld qword [rsp]             ; st0 = x, st1 = 5
    fmul                        ; st0 = st0*st1, pop
    fstp qword [rsp + 16]       ; store 5*x, pop
    
    ; Compute x^2 + 5x
    fld qword [rsp + 8]         ; st0 = x^2
    fld qword [rsp + 16]        ; st0 = 5*x, st1 = x^2
    faddp                       ; st0 = st0+st1 (add and pop)
    
    ; Compute sine
    fsin                        ; st0 = sin(st0)
    
    ; Store result to xmm0
    fstp qword [rsp + 8]        ; store result, pop
    movsd xmm0, qword [rsp + 8] ; load result into xmm0
    
    add rsp, 24
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
    
    ; Check if fb - fa == 0
    fld qword [rsp + 24]            ; st0 = fb
    fld qword [rsp + 16]            ; st0 = fa, st1 = fb
    fcompp                          ; compare st0 and st1, pop both
    fstsw ax
    sahf
    je .chord_done
    
    ; Compute x = (a*fb - b*fa) / (fb - fa)
    fld qword [rsp + 24]            ; st0 = fb
    fld qword [rsp + 16]            ; st0 = fa, st1 = fb
    fsubp st1                       ; st0 = fb - fa
    fld qword [rsp + 8]             ; st0 = b, st1 = (fb - fa)
    fld qword [rsp + 16]            ; st0 = fa, st1 = b, st2 = (fb - fa)
    fmulp                           ; st0 = b*fa, st1 = (fb - fa)
    fld qword [rsp]                 ; st0 = a, st1 = b*fa, st2 = (fb - fa)
    fld qword [rsp + 24]            ; st0 = fb, st1 = a, st2 = b*fa, st3 = (fb - fa)
    fmulp                           ; st0 = a*fb, st1 = b*fa, st2 = (fb - fa)
    fsubrp st1                      ; st0 = a*fb - b*fa, st1 = (fb - fa)
    fdivrp st1                      ; st0 = (a*fb - b*fa) / (fb - fa)
    fstp qword [rsp + 56]           ; store x, pop
    
    ; Compute fx = f(x)
    movsd xmm0, qword [rsp + 56]    ; load x into xmm0
    call compute_f
    movsd qword [rsp + 48], xmm0    ; save fx
    
    ; Check if fx == 0 using x87 FPU stack (like line 144)
    fld qword [rsp + 48]            ; load fx onto x87 stack
    fld qword [rel zero]            ; load 0 onto x87 stack
    fcompp                          ; compare st0 and st1, pop both
    fstsw ax
    sahf
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
