.text
valid_message: .asciz "valid"
invalid_message: .asciz "invalid"

.include "basic.s"

.global main

# *******************************************************************************************
# Subroutine: check_validity                                                                *
# Description: checks the validity of a string of parentheses as defined in Assignment 6.   *
# Parameters:                                                                               *
#   first: the string that should be check_validity                                         *
#   return: the result of the check, either "valid" or "invalid"                            *
# *******************************************************************************************
check_validity:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq $0, %rax			# clear register
	movq $0, %rdx			# stack counter
loop:
	movb (%rdi), %al		# Move the character into %rax
	cmpb $0, %al			# Check if character is null
	je   valid

	# Check if it's open or closed parenthesis
	cmpq $'(', %rax			
	je   push_open
	cmpq $'<', %rax
	je   push_open
	cmpq $'{', %rax
	je   push_open
	cmpq $'[', %rax
	je   push_open

	cmpq $')', %rax
	je   pop_parenthesis
	cmpq $'>', %rax
	je   pop_arrow
	cmpq $'}', %rax
	je   pop_curly_brace
	cmpq $']', %rax
	je   pop_square_bracket

push_open:
	pushq %rax				# push open parenthesis on the stack
	incq %rdx				# increment stack counter
	incq %rdi				# %rdi stores address of the next character
	jmp  loop				# check next character

pop_parenthesis:
	decq %rdx				# decrement stack counter
	incq %rdi				# %rdi stores address of the next character
	popq %rcx				# pop last parenthesis from the stack
	cmpq $'(', %rcx			# check if it is the matching parenthesis
	je   loop				# if yes, check next character
	jne  fail				

pop_arrow:
	decq %rdx				# decrement stack counter
	incq %rdi				# %rdi stores address of the next character
	popq %rcx				# pop last parenthesis from the stack
	cmpq $'<', %rcx			# check if it is the matching parenthesis
	je   loop				# if yes, check next character
	jne  fail

pop_curly_brace:
	decq %rdx				# decrement stack counter
	incq %rdi				# %rdi stores address of the next character
	popq %rcx				# pop last parenthesis from the stack
	cmpq $'{', %rcx			# check if it is the matching parenthesis
	je   loop				# if yes, check next character
	jne  fail

pop_square_bracket:
	decq %rdx				# decrement stack counter
	incq %rdi				# %rdi stores address of the next character
	popq %rcx				# pop last parenthesis from the stack
	cmpq $'[', %rcx			# check if it is the matching parenthesis
	je   loop				# if yes, check next character
	jne  fail

valid:
	cmpq $0, %rdx						# check if number of characters is even
	jne  fail							# if not, it is invalid
	movq $valid_message, %rax			# return "valid"
	jmp  end

fail:
	movq $invalid_message, %rax			# return "invalid"
	jmp  end

end:	
	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi		# first parameter: address of the message
	call	check_validity		# call check_validity

	popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program
