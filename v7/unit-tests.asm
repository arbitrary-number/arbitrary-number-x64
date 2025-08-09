; Run: nasm -f elf64 test_arbitrary_number.asm && ld -o test_arbitrary_number test_arbitrary_number.o

section .data
    ; Unit test 1: 1/3 + 1/3 + 1/3 → Should be 1
    ; Stored as: c, a, b
test1_terms dq 1, 1, 3
             dq 1, 1, 3
             dq 1, 1, 3
test1_count dq 3

; Expected result: 3 * (1/3) = 3/3 = 1
; We'll sum all terms and compare to expected numerator = 1, denominator = 1
expected_n dq 1
expected_d dq 1

section .bss
    result_sum_n resq 1
    result_sum_d resq 1
    tmp_result   resq 32

section .text
    global _start

_start:
    ; Step 1: Simplify terms
    mov rsi, test1_terms
    mov rdi, [test1_count]
    call simplify_terms

    ; Step 2: Sum all terms into single rational result
    mov rsi, tmp_result
    mov rdi, [test1_count]
    call sum_terms

    ; Compare to expected: result_sum_n / result_sum_d == 1 / 1
    mov rax, [result_sum_n]
    cmp rax, [expected_n]
    jne test_fail

    mov rax, [result_sum_d]
    cmp rax, [expected_d]
    jne test_fail

    ; Success
    mov rax, 60     ; exit syscall
    xor rdi, rdi    ; return code 0 = success
    syscall

test_fail:
    mov rax, 60
    mov rdi, 1      ; return code 1 = fail
    syscall

; Sum all terms in array of form c*(a/b)
; Input:
;   rsi = pointer to terms
;   rdi = number of terms
; Output:
;   result_sum_n / result_sum_d (in memory)
sum_terms:
    push rbx
    push rcx
    push rdx
    xor rbx, rbx              ; total_numerator
    mov rcx, 1                ; total_denominator

    mov r8, 0                 ; loop counter
.sum_loop:
    cmp r8, rdi
    jge .done

    ; Load term: c, a, b
    mov rax, [rsi + r8*24]        ; c
    mov r9, [rsi + r8*24 + 8]     ; a
    mov r10, [rsi + r8*24 + 16]   ; b

    ; term_value_n = c * a
    imul rax, r9
    ; Scale numerator to common denominator: (rax * rcx)
    imul rax, rcx
    ; term_value_d = b * current total denominator
    mov rdx, r10
    imul rdx, rcx

    ; Scale running total_numerator
    imul rbx, r10
    add rbx, rax     ; total_n += scaled current term

    ; Update common denominator
    mov rcx, rdx

    inc r8
    jmp .sum_loop

.done:
    ; Write result
    mov [result_sum_n], rbx
    mov [result_sum_d], rcx
    pop rdx
    pop rcx
    pop rbx
    ret

; --- Simplify routine from earlier (reuse the one from before) ---
simplify_terms:
    ; Implement simplification (see earlier message)
    ; You can either inline or call GCD per (a,b) pair
    ret

gcd:
    ; Euclidean algorithm
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
