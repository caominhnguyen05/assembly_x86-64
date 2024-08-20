.text
welcome: .asciz "\nWelcome to our program!\n"
prompt: .asciz "\nPlease enter a positive number:\n"

input: .asciz "%ld"
output: .asciz "The result is: %ld.\n\n"

.global main
main: 
    #prologue
    pushq %rbp
    movq %rsp, %rbp

    movq $0, %rax
    movq $welcome, %rdi
    call printf
    call inout

    #epilogue
    movq %rbp, %rsp
    popq %rbp

end:
    movq $0, %rdi
    call exit

inout: 
    #prologue
    pushq %rbp
    movq %rsp, %rbp

    movq $0, %rax
    movq $prompt, %rdi
    call printf

    subq $16, %rsp
    movq $0, %rax
    movq $input, %rdi
    leaq -16(%rbp), %rsi
    call scanf

    movq -16(%rbp), %rsi

    movq %rsi, %rax
    movq $2, %rcx
    movq $0, %rdx
    divq %rcx

    cmpq $0, %rdx
    jne odd

even: 
    incq %rsi
odd: 
    movq $0, %rax
    movq $output, %rdi

    call printf

    #epilogue
    movq %rbp, %rsp
    popq %rbp

    ret