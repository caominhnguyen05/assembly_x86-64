.data
cells: .skip 30000

.text
character: .asciz "%c"

.global brainfuck

format_str: .asciz "We should be executing the following code:\n%s"

# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
brainfuck:
	# prologue
	pushq %rbp
	movq %rsp, %rbp

	pushq %rbx
	pushq %rbx					# save registers values on the stack
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15					
	movq %rdi, %rbx					# base address of the command string

	movq $cells, %r14				# Pointer to the current memory cell - in %r14
	movq $0, %r12					# character index

	movq $0, %r13					# clear register
	movq $0, %r15					# loop level

loop:
	movb (%rbx, %r12), %r13b		# gets a character
	cmpq $0, %r13					# if null character, jump to end
	je   end

	cmpq $'+', %r13
	je   case_plus
	cmpq $'-', %r13
	je   case_minus
	cmpq $'>', %r13
	je   case_greater_arrow
	cmpq $'<', %r13
	je   case_smaller_arrow
	cmpq $'[', %r13
	je   case_left_bracket
	cmpq $']', %r13
	je   case_right_bracket
	cmpq $'.', %r13
	je   case_dot
	cmpq $',', %r13
	je   case_comma

	jmp next_char					# ignore every other character

case_plus:
	incq (%r14)				# increment the memory cell at the pointer
	jmp  next_char

case_minus:
	decq (%r14)				# decrement the memory cell at the pointer
	jmp  next_char

# Move the pointer to the right
case_smaller_arrow:
	cmpq $cells, %r14
	je   move_to_last_cell
	decq %r14				# Point to the previous memory cell		
	jmp  next_char

move_to_last_cell:
	movq $29999, %rdx
	movq cells(%rdx), %r14
	jmp  end

# Move the pointer to the left
case_greater_arrow:
	incq %r14				# Point to the next memory cell
	jmp  next_char
	
# Output the character signified by the cell at the pointer
case_dot:
	movq $character, %rdi
	movq $0, %rsi				# clear register
	movb (%r14), %sil			# move current character into %rsi
	movq $0, %rax
	call printf					# print character at current cell	

	jmp  next_char

# Input a character and store it in the cell at the pointer
case_comma:
	movq $0, %rsi
	movq $0, %rax
	movq $character, %rdi
	leaq (%r14), %rsi			# input character will be stored in current cell
	call scanf					
	
	cmpb $'0', (%r14)				# if the user enters a null character, end the program
	jne   next_char
	movq $0, (%r14)

	jmp next_char

# Jump past the matching ] if the cell at the pointer is 0
case_left_bracket:
	cmpb $0, (%r14)					# if cell at the pointer is not 0, 
	jne  next_char					# jump to the main loop to process the next character

	movq $1, %rcx					# initialise bracket counter			

skip_character:
	incq %r12						# gets address of the next character
	movb (%rbx, %r12), %r13b
	cmpb $'[', %r13b				# if character is '[', increment bracket counter
	je   inc_bracket_counter 

	cmpb $']', %r13b				# if character is ']', check if it's the matching closing bracket
	je   check_matching_bracket

	jmp skip_character

inc_bracket_counter:
	incq %rcx					# increment bracket counter
	jmp  skip_character			# checks the next character

check_matching_bracket:
	decq %rcx					# decrement bracket counter
	cmpq $0, %rcx				# check if it is the matching closing bracket
	jne  skip_character			# if not, check the next character
	je   next_char				# if yes, continue executing commands

# Jump back to the matching [ if the cell at the pointer is nonzero
case_right_bracket:
	cmpb $0, (%r14)
	je   next_char

	movq $1, %rdx

skip_character_backwards:
	decq %r12						# gets address of the previous character

	movb (%rbx, %r12), %r13b
	cmpb $']', %r13b				# check if it's closing bracket
	je   inc_bracket_counter_backward

	cmpb $'[', %r13b
	je   check_matching_bracket_backwards
	jne  skip_character_backwards

inc_bracket_counter_backward:
	incq %rdx						# increment bracket counter
	jmp  skip_character_backwards

check_matching_bracket_backwards:
	decq %rdx						# decrement bracket counter
	cmpq $0, %rdx
	je   next_char
	jne  skip_character_backwards

next_char:
	incq %r12
	jmp  loop
	
end:
	popq %r15
	popq %r14						# restore initial registers values
	popq %r13
	popq %r12
	popq %rbx
	popq %rbx
	# epilogue
	movq %rbp, %rsp
	popq %rbp
	ret
