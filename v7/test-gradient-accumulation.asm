section .data
    ; Terms: 1/10, 1/100, ..., 1/100000
grad_terms dq 1, 1, 10
            dq 1, 1, 100
            dq 1, 1, 1000
            dq 1, 1, 10000
            dq 1, 1, 100000
grad_count dq 5

scalar dq 900000        ; Multiply accumulated gradient by this (simulating weight update)
expected_n dq 100000    ; We expect the exact update to be 100000
expected_d dq 1

section .bss
result_sum_n resq 1
result_sum_d resq 1

section .text
    global _start

_start:
    ; (1) Multiply terms by scalar
    mov rsi, grad_terms
    mov rdi, [grad_count]
    mov rdx, [scalar]
    call multiply_by_scalar

    ; (2) Sum all terms symbolically
    mov rsi, grad_terms
    mov rdi, [grad_count]
    call sum_terms

    ; (3) Check if result is exactly 100000 / 1
    mov rax, [result_sum_n]
    cmp rax, [expected_n]
    jne test_fail

    mov rax, [result_sum_d]
    cmp rax, [expected_d]
    jne test_fail

    ; PASS
    mov rax, 60
    xor rdi, rdi
    syscall

test_fail:
    mov rax, 60
    mov rdi, 1
    syscall
