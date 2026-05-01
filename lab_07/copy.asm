section .text
    global copyAsm

copyAsm:
    ; RDI = dst
    ; RSI = src
    ; RDX = len

    mov rcx, rdx

    cmp rdi, rsi
    jl forward

    ; копирование назад
    add rsi, rcx
    add rdi, rcx
    dec rsi
    dec rdi
    std
    rep movsb
    cld
    ret

forward:
    cld
    rep movsb
    ret
