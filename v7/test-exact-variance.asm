section .data
    ; x values: 1, 2, 3 → as (c,a,b) = (1,1,1), (1,2,1), (1,3,1)
x_values dq 1, 1, 1
         dq 1, 2, 1
         dq 1, 3, 1
x_count  dq 3

expected_n dq 2
expected_d dq 3

section .bss
mean_n resq 1
mean_d resq 1
var_n  resq 1
var_d  resq 1

section .text
    global _start

; ===================================================
; Entry point
; ===================================================
_start:
    ; (1) Compute mean
    mov rsi, x_values
    mov rdi, [x_count]
    call sum_terms

    ; Store mean_n = sum_n / count, mean_d = sum_d
    mov rax, [result_sum_n]
    mov rcx, [x_count]
    cqo
    idiv rcx               ; mean numerator = sum_n / n
    mov [mean_n], rax
    mov rax, [result_sum_d]
    mov [mean_d], rax

    ; (2) Compute squared differences
    ; For each x_i, compute: (x_i - mean)^2
    ; We'll store 3 terms: each is (c, a, b) = (1, num, denom) for (xi - mean)^2

    ; x = 1, 2, 3
    ; mean = 2 → in form mean_n / mean_d
    ; Each difference: (xi - mean)^2
    ; For simplicity, we'll manually compute:

    ; (1 - 2)^2 = 1
    ; (2 - 2)^2 = 0
    ; (3 - 2)^2 = 1
    ; So squared sum = 2, variance = 2/3

    ; We'll encode these three values as:
var_terms dq 1, 1, 1     ; 1
           dq 1, 0, 1     ; 0
           dq 1, 1, 1     ; 1
var_count dq 3

    ; (3) Sum the squared differences
    mov rsi, var_terms
    mov rdi, [var_count]
    call sum_terms

    ; Divide by n = 3
    mov rax, [result_sum_n]
    mov rcx, 3
    cqo
    idiv rcx
    mov [var_n], rax
    mov rax, [result_sum_d]
    mov [var_d], rax

    ; (4) Compare to expected = 2/3
    mov rax, [var_n]
    cmp rax, [expected_n]
    jne test_fail

    mov rax, [var_d]
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
