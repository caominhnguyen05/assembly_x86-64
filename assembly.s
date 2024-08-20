.text
input: .asciz "%d"
output: .asciz "Hello!\n"
output2: .asciz "Hi! %d\n"

.global main 

main:
	# Prologue
	push %rbp
	mov %rsp, %rbp

	mov $output, %rdi 
	mov $0, %rax
	call printf

	mov $input, %rdi 
	sub $16, %rsp 
	lea -16(%rbp), %rsi 
	call scanf

	mov $output2, %rdi 
	#pop %rsi 
	mov $0, %rax 
	call printf

	# Epilogue
	mov %rbp, %rsp 
	pop %rbp

end: 
	mov $0, %rdi 
	call exit
	