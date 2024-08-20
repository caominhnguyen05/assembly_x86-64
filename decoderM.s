.text
output: .asciz "%c"
.include "final.s"

.global main

# ************************************************************
# Subroutine: decode                                         *
# Description: decodes message as defined in Assignment 3    *
#   - 2 byte unknown                                         *
#   - 4 byte index                                           *
#   - 1 byte amount                                          *
#   - 1 byte character                                       *
# Parameters:                                                *
#   first: the address of the message to read                *
#   return: no return value                                  *
# ************************************************************
decode:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	# your code goes here
	push %rbx
	push %r12
	push %r13
	push %r14
	movq %rdi, %rbx
separate:
	movq (%rdi), %rax

	movzx %al, %r12
	shrq $8, %rax

	movzx %al, %r13
	shrq $8, %rax

	movl %eax, %edx
	movq %rdx, %r14

print_char:
	cmpq $1, %r13
	jl done

	movq $output, %rdi
	movq %r12, %rsi
	movq $0, %rax
	call printf

	decq %r13
	jmp print_char

done:
	cmpq $0, %r14
	je end
	leaq (%rbx,%r14,8), %rdi

	jmp separate

end:
	pop %r14
	pop %r13
	pop %r12
	pop %rbx
	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi	# first parameter: address of the message
	call	decode			# call decode

	popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program

