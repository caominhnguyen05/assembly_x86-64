.text
output: .asciz "Result is %ld.\n"
input: .asciz "%ld"
prompt: .asciz "Enter a number: "

.global main

main:
    # Prologue
    pushq %rbp
    movq %rsp, %rbp

    # Ask user to input base value
    movq $prompt, %rdi
    movq $0, %rax
    call printf 

    # Take base input value from user
    mov $input, %rdi 
	sub $16, %rsp 
	lea -16(%rbp), %rsi 
	call scanf

    movq %rsi, %rdi
    call factorial

    movq %rax, %rsi
    movq $0, %rax
    movq $output, %rdi
    call printf

    #Epilogue
    movq %rbp, %rsp
    popq %rbp

end:
    movq $0, %rdi
    call exit

# Input: %rdi - n (the number for which factorial is calculated)
# Output: %rax - the factorial of n
factorial:
    # Base case: if n is 0 or 1, return 1
    cmpq $1, %rdi
    jle base_case

    # Recursive case: n! = n * (n-1)!
    pushq %rdi
    subq $1, %rdi         # n-1
    call factorial        # Recursive call to factorial
    popq %rdi             
    mulq %rdi             # Multiply n by the result of factorial(n-1)

    ret
    
base_case:
    movq $1, %rax          # Return 1 if n <= 1
    ret
