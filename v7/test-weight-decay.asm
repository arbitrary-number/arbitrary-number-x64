section .data
    ; 10 iterations of: 1/10000 - 1/50000
    ; Each iteration has two terms:
    ;   c = 1, a = 1, b = 10000 (gradient)
    ;   c = -1, a = 1, b = 50000 (decay)
test_terms:
%assign i 0
%rep 10
    dq 1, 1, 10000
    dq -1, 1, 50000
%assign i i+1
%endrep

term_count dq 20         ; 10 pairs

expected_n dq 1
expected_d dq 5000

section .bss
result_sum_n resq 1
result_sum_d resq 1

section .text
    global _start

_start:
    ; (1) Sum all symbolic terms
    mov rsi, test_terms
    mov rdi, [term_count]
    call sum_terms

    ; (2) Compare to expected 1 / 5000
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
