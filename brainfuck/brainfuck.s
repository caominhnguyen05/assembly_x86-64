.global brainfuck
format_c:       .asciz "%c"
format_str:     .asciz "We should execute the following code: \n%s\n"



# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
brainfuck:
	pushq 	%rbp
	movq 	%rsp, %rbp

	pushq 	%r13
	pushq 	%r14
	pushq 	%r15    


    movq 	%rsp,%r13	            # r13 serves as pointer to cells

    movq     $0,%r14                 # clear r14
    decq     %rdi


	brainfuck_main_loop:
	incq	    %rdi
    movb     (%rdi),%r14b                     
	cmpb 	$0,%r14b               
	je 	    end
	cmpb 	$43,%r14b			
	je 	    case_plus
	cmpb  	$45,%r14b
	je 	    case_minus
	cmpb  	$62,%r14b
	je 	    case_g
	cmpb 	$60,%r14b
	je 	    case_l
	cmpb 	$91,%r14b
	je 	    case_bracket_left
	cmpb 	$93,%r14b
	je 	    case_bracket_right
    cmpb     $46,%r14b
    je      case_dot
    cmpb     $44,%r14b
    je      case_comma
    jmp     brainfuck_main_loop

	case_plus:                      # increment the value of current cell 
        addb 	$1,(%r13)
        jmp	brainfuck_main_loop

	case_minus:
        subb     $1,(%r13)               # dcrement the value of current cell
        jmp	brainfuck_main_loop

	case_g:                         # move the pointer, create more space on the stack if needed
        subb     $8,%r13b
        cmpq      %r13,%rsp
        jge     increase_stack_size
        jmp     brainfuck_main_loop

	case_l:                         # move the pointer
        add     $8,%r13
        jmp     brainfuck_main_loop

	case_dot:                
        pushq    %rdi       
        movq     $format_c,%rdi
        movq     $0,%rsi                 # clear rsi
        movb    (%r13),%sil             # print value of current cell
        movq     $0,%rax
        call    printf
        popq     %rdi
        jmp     brainfuck_main_loop

	case_comma:                     
        pushq    %rdi
        mov     $0,%rax
        mov     $format_c,%rdi
        leaq     (%r13),%rsi            # store value from scanf into current cell 
        call    scanf
        popq     %rdi
        cmpb     $0,(%r13)              # if the user send the null character, stops
        je      end

        jmp     brainfuck_main_loop    

	case_bracket_left:
        cmpb     $0,(%r13)               # check if the value of the current cell is greater than 0            
        jg      brainfuck_main_loop      # do the commands inside the loop if value of the current cell is greater than 0
        movq     $1,%r12
        skip_command_loop:
        incq     %rdi
        mov     (%rdi),%r14b
        cmpb     $91,%r14b              # if encounter [, increments bracket counter
        je      inc_open_bracket_counter     
        cmpb     $93,%r14b              # if encounter ], decrements bracket counter, if counter = 0, it means that 
        je      check_right_bracket     # we have found the appropriate closing bracket of this loop 
        jmp     skip_command_loop

    inc_open_bracket_counter:                
        incq     %r12
        jmp     skip_command_loop       # increase bracket counter
    check_right_bracket:
        decq     %r12
        cmpq     $0,%r12
        jne     skip_command_loop       # counter == 0 means that we have found the appropriate closing bracket of this loop
        jmp     brainfuck_main_loop     # so jump back to the main loop    


	case_bracket_right:
        cmpb     $0,(%r13)               # if the value of cell is grater than 0, do the loop again
        je      brainfuck_main_loop                          
        movq     $1,%r12
        skip_command_loop_backward:
        decq     %rdi
        movb     (%rdi),%r14b
        cmpb     $93,%r14b
        je      inc_close_bracket_counter
        cmpb     $91,%r14b
        je      check_left_bracket
        jmp     skip_command_loop_backward
        
        inc_close_bracket_counter:
        incq     %r12
        jmp     skip_command_loop_backward

        check_left_bracket:
        decq     %r12
        cmpq     $0,%r12
        jne     skip_command_loop_backward    # counter == 0 means that we have found the appropriate opening bracket of this loop 
        jmp     brainfuck_main_loop         # so jump back to the main loop

       increase_stack_size:
        pushq     $0
        pushq     $0
        jmp     brainfuck_main_loop    

	end:
	movq 	%rbp,%rsp                  
	subq	    $24,%rsp

	popq 	%r15
	popq	    %r14
	popq	    %r13

	movq 	%rbp, %rsp
	popq 	%rbp
	ret
