section .data
    ; Example arbitrary number: 1/3 + 1/2
    terms dq 1, 3     ; 1/3
          dq 1, 2     ; 1/2
    term_count dq 2

    scalar dq 3       ; Scalar to multiply by

section .bss
    result resq 64    ; space for up to 32 simplified terms

section .text
    global _start

_start:
    mov rsi, terms        ; input terms
    mov rdi, term_count   ; number of terms
    call simplify_terms

    ; Multiply by scalar
    mov rsi, result       ; simplified terms
    mov rdi, [term_count] ; number of terms
    mov rdx, [scalar]     ; scalar value
    call multiply_by_scalar

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall

; --- Multiply each term by a scalar ---
; rsi = ptr to terms
; rdi = number of terms
; rdx = scalar
multiply_by_scalar:
    push rcx
    xor rcx, rcx
.mul_loop:
    cmp rcx, rdi
    jge .done
    mov rax, [rsi + rcx*16]       ; numerator
    imul rax, rdx
    mov [rsi + rcx*16], rax
    inc rcx
    jmp .mul_loop
.done:
    pop rcx
    ret

; --- Simplify each term by GCD ---
; rsi = ptr to terms
; rdi = number of terms
simplify_terms:
    push rcx
    push rax
    push rbx
    xor rcx, rcx
.simplify_loop:
    cmp rcx, rdi
    jge .done
    mov rax, [rsi + rcx*16]   ; numerator
    mov rbx, [rsi + rcx*16 + 8] ; denominator
    call gcd
    ; Divide numerator and denominator by GCD
    mov rdx, rax
    mov rax, [rsi + rcx*16]
    xor r8, r8
    div rdx
    mov [result + rcx*16], rax
    mov rax, [rsi + rcx*16 + 8]
    xor r8, r8
    div rdx
    mov [result + rcx*16 + 8], rax
    inc rcx
    jmp .simplify_loop
.done:
    pop rbx
    pop rax
    pop rcx
    ret

; --- GCD algorithm ---
; Input: rax = a, rbx = b
; Output: rax = gcd(a, b)
gcd:
    cmp rbx, 0
    je .done
.gcd_loop:
    xor rdx, rdx
    div rbx
    mov rax, rbx
    mov rbx, rdx
    test rbx, rbx
    jne .gcd_loop
.done:
    ret
