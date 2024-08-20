.text      
output: .asciz "\nLe Kha Dan Nguyen - lkdnguyen\nCao Minh Nguyen - caominhnguyen\nAssignment 1: Powers\n"

prompt_base: .asciz "Enter the base: "
prompt_exponent: .asciz "Enter the exponent: "
result: .asciz "Result is %ld.\n"
input_base: .asciz "%ld"
input_exp: .asciz "%ld"
    
.global main
main:
    #Prologue
    push %rbp
    movq %rsp, %rbp

    # Print name, netID and name of the assignment
    movq $output, %rdi
    movq $0, %rax
    call printf

    # Ask user to input base value
    movq $prompt_base, %rdi
    movq $0, %rax
    call printf 

    # Take base input value from user
    mov $input_base, %rdi 
	sub $16, %rsp 
	lea -16(%rbp), %rsi 
	call scanf

    # Store base value temporarily in %RBX
    movq %rsi, %rbx

    # Ask user to input exponent value
    movq $prompt_exponent, %rdi
    movq $0, %rax
    call printf

    # Take exponent input value from user
    mov $input_exp, %rdi 
	sub $16, %rsp 
	lea -16(%rbp), %rsi 
	call scanf

    # Take base value in %RBX, store in %RDI as a parameter
    mov %rbx, %rdi
    call pow

    # Print result of subroutine pow
    movq %rax, %rsi
    movq $0, %rax
    movq $result, %rdi
    call printf

    #Epilogue
    movq %rbp, %rsp
    popq %rbp
end:
    movq $0, %rdi
    call exit

pow:
    #Prologue
    push %rbp
    movq %rsp, %rbp

    # Inputs:
    #   %rdi - Base
    #   %rsi - Exponent
    # Output:
    #   %rax - Result
    #push %rdi           # Save base on the stack
    #push %rsi           # Save exponent on the stack
    movq $1, %rax       # Initialize result to 1
    
    # Check if exponent is zero. If it is, return 1.
    cmp $0, %rsi
    je done

loop:
    imulq %rdi          # Multiply result by base
    decq %rsi           # Decrement exponent
    # Check if exponent = 0. If not, loop continues.
    cmpq $0, %rsi
    jne loop
   
done:
    # Epilogue
    movq %rbp, %rsp
    popq %rbp
    ret
    