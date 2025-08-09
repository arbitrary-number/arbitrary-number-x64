section .data
    ; Store terms: all c=1 for 1/x
test_terms dq 1, 1, 3
            dq 1, 1, 7
            dq 1, 1, 9
            dq 1, 1, 11
            dq 1, 1, 13
test_count dq 5

    scalar dq 1287

expected_n dq 1500        ; This is the exact result
expected_d dq 1

section .bss
    simplified_terms resq 120
    result_sum_n resq 1
    result_sum_d resq 1

section .text
    global _start

_start:
    ; Simplify terms (no-op for these, but necessary step)
    mov rsi, test_terms
    mov rdi, [test_count]
    call simplify_terms

    ; Multiply expression by scalar
    mov rsi, test_terms
    mov rdi, [test_count]
    mov rdx, [scalar]
    call multiply_by_scalar

    ; Sum the result
    mov rsi, test_terms
    mov rdi, [test_count]
    call sum_terms

    ; Reduce the result (optional)
    ; You could call simplify_result if needed

    ; Check result against expected
    mov rax, [result_sum_n]
    cmp rax, [expected_n]
    jne test_fail

    mov rax, [result_sum_d]
    cmp rax, [expected_d]
    jne test_fail

    ; SUCCESS
    mov rax, 60
    xor rdi, rdi
    syscall

test_fail:
    mov rax, 60
    mov rdi, 1
    syscall
