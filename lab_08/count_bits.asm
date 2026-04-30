bits 64
global count_bits

; count_bits(rdi: uint64_t) -> rax: int (bit count)
; Count the number of set bits (1s) in a 64-bit number
count_bits:
    xor rax, rax        ; rax = result (bit count)
    xor rcx, rcx        ; rcx = loop counter
    
.loop:
    cmp rcx, 64         ; processed all 64 bits?
    jge .done
    
    mov r8, rdi         ; copy input to r8
    shr r8, cl          ; shift right by rcx positions
    and r8, 1           ; isolate LSB
    add rax, r8         ; add to result if bit is 1
    
    inc rcx              ; next bit
    jmp .loop
    
.done:
    ret
