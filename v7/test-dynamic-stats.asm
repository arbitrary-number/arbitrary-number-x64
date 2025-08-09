; test_dynamic_stats.asm — NASM x64 assembly test file

section .data
    ; Example dataset (modifiable size!)
    ; Format: int64_t values
data_values dq 10, 20, 30, 40, 50, 60
data_count  dq 6        ; Adjust this if you modify data_values

expected_mean_n dq 35   ; (10+20+...+60)/6 = 35
expected_mean_d dq 1
expected_var_n  dq 350  ; variance = [(...)/6] = 350 exactly
expected_var_d  dq 1

section .bss
    sums resq 2         ; sum numerator, sum denominator
    mean_n resq 1
    mean_d resq 1
    diff_terms resq 48  ; space for (c,a,b) diff terms (6 terms)
    var_sum resq 2

section .text
    extern malloc, free
    global _start

_start:
    ; 1. Sum values
    mov rsi, data_values
    mov rdi, [data_count]
    call sum_int_array_to_rational

    mov [sums], rax       ; sum numerator
    mov [sums+8], rdx     ; sum denominator (1)

    ; 2. Calculate mean: mean = sum / count
    mov rax, [sums]
    mov rcx, [data_count]
    cqo
    idiv rcx
    mov [mean_n], rax
    mov rax, [sums+8]
    mov [mean_d], rax

    ; 3. Compute difference squares: (xi - mean)^2 as rational terms
    mov r8, [data_count]
    mov r9, 0             ; loop counter
    mov r10, diff_terms

.diff_loop:
    cmp r9, r8
    jge .diff_done

    ; Load xi
    mov r11, [data_values + r9*8]

    ; Compute xi - mean_n/mean_d = (xi*mean_d - mean_n) / mean_d
    mov r12, r11
    imul r12, [mean_d]
    mov r13, [mean_n]
    sub r12, r13          ; numerator
    mov r14, [mean_d]     ; denominator

    ; Square it: numerator^2 / denominator^2
    imul r12, r12
    imul r14, r14

    ; Store as one term: (c=1, a=r12, b=r14)
    mov [r10], 1
    mov [r10+8], r12
    mov [r10+16], r14

    add r10, 24
    inc r9
    jmp .diff_loop
.diff_done:

    ; 4. Sum difference terms via sum_terms
    mov rsi, diff_terms
    mov rdi, [data_count]
    call sum_terms
    mov [var_sum], rax
    mov [var_sum+8], rdx

    ; 5. Divide by count to get variance
    mov rax, [var_sum]
    mov rcx, [data_count]
    cqo
    idiv rcx
    mov rax, rax
    mov [var_sum], rax
    mov [var_sum+8], rdx

    ; 6. Compare mean and variance to expected
    mov rax, [mean_n]
    cmp rax, [expected_mean_n]
    jne fail
    mov rax, [mean_d]
    cmp rax, [expected_mean_d]
    jne fail

    mov rax, [var_sum]
    cmp rax, [expected_var_n]
    jne fail
    mov rax, [var_sum+8]
    cmp rax, [expected_var_d]
    jne fail

    ; PASS
    mov rax, 60
    xor rdi, rdi
    syscall

fail:
    mov rax, 60
    mov rdi, 1
    syscall

; Helper to sum integer array as rational (num/1)
; Input: rsi=array ptr, rdi=len
; Output: rax=sum, rdx=1
sum_int_array_to_rational:
    xor rax, rax
    xor rsi, rsi            ; reuse registers
.sum_int_loop:
    cmp rsi, rdi
    jge .sum_done
    mov rbx, [data_values + rsi*8]
    add rax, rbx
    inc rsi
    jmp .sum_int_loop
.sum_done:
    mov rdx, 1
    ret
