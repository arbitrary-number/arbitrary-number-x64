section .data
    ; Arbitrary number = 1*(1/3) + 1*(1/2) + -2*(5/6)
    ; Format: c, a, b
    terms dq 1, 1, 3       ; 1*(1/3)
          dq 1, 1, 2       ; 1*(1/2)
          dq -2, 5, 6      ; -2*(5/6)
    term_count dq 3

    scalar dq 3           ; Multiply the whole expression by this scalar

section .bss
    result resq 96        ; Enough space for 3 terms of 3 int64s

section .text
    global _start

_start:
    ; Simplify terms
    mov rsi, terms
    mov rdi, [term_count]
    call simplify_terms

    ; Multiply entire expression by scalar
    mov rsi, result
    mov rdi, [term_count]
    mov rdx, [scalar]
    call multiply_by_scalar

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall

; --- Simplify terms ---
; Input: rsi = input terms
;        rdi = term count
; Output: result = simplified terms
simplify_terms:
    push rcx
    xor rcx, rcx
.simplify_loop:
    cmp rcx, rdi
    jge .done

    ; Load c, a, b
    mov rax, [rsi + rcx*24]       ; c
    mov rbx, [rsi + rcx*24 + 8]   ; a
    mov rcx, [rsi + rcx*24 + 16]  ; b

    ; Save c in r8
    mov r8, rax

    ; GCD of a, b
    mov rax, rbx
    mov rbx, rcx
    call gcd

    ; rax now holds gcd
    mov r9, rax

    ; Simplify a and b
    mov rax, [rsi + rcx*24 + 8]
    xor rdx, rdx
    div r9
    mov r10, rax         ; simplified a

    mov rax, [rsi + rcx*24 + 16]
    xor rdx, rdx
    div r9
    mov r11, rax         ; simplified b

    ; Store simplified term: c, a, b
    mov [result + rcx*24], r8
    mov [result + rcx*24 + 8], r10
    mov [result + rcx*24 + 16], r11

    inc rcx
    jmp .simplify_loop
.done:
    pop rcx
    ret

; --- Multiply whole number by a scalar ---
; rsi = pointer to simplified terms
; rdi = number of terms
; rdx = scalar
multiply_by_scalar:
    push rcx
    xor rcx, rcx
.mul_loop:
    cmp rcx, rdi
    jge .done_mul

    ; Multiply c by scalar
    mov rax, [rsi + rcx*24]
    imul rax, rdx
    mov [rsi + rcx*24], rax

    inc rcx
    jmp .mul_loop
.done_mul:
    pop rcx
    ret

; --- GCD of rax and rbx ---
gcd:
    cmp rbx, 0
    je .gcd_done
.gcd_loop:
    xor rdx, rdx
    div rbx
    mov rax, rbx
    mov rbx, rdx
    test rbx, rbx
    jne .gcd_loop
.gcd_done:
    ret
