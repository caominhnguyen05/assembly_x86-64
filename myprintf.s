.data
message:        .asciz "My name is %s. I think I'll get a %u for my exam. What does %r do? And%%? Numbers from -2 to 2: %d %d %d %d %d "
myname:         .asciz "Hoang Minh"
template:       .asciz "0123456789"
sign_character: .asciz "-"

.text
.global main
 
main:
    push    %rbp                    # prologue
    mov     %rsp,%rbp

    mov     $message,%rdi
    mov     $myname,%rsi
    mov     $4000,%rdx
    mov     $-2,%rcx
    mov     $-1,%r8
    mov     $0,%r9
    push    $2
    push    $1

    call    myprintf

    mov     %rbp,%rsp               # epilogue
    pop     %rbp

    call    exit

myprintf:                           # calculate the length of the string stored in %rdi
    push    %rbp                    # prologue
    mov     %rsp,%rbp

    push    %r9                     # push the memory address of the string to the stack
    push    %r8                     # push all the arguments passed to myprintf onto the stack
    push    %rcx
    push    %rdx
    push    %rsi
    push    %rdi

    mov     %rsp,%rdx               # rdx holds the address of the args passed to my printf on the stack
                                    # since there maybe more than 6 args passed to myprintf

    mov     $0,%rax                 # rax always holds how many characters need to be printed 
    mov     %rdi,%rsi               # rsi holds the address of the message to be printed every loop

    myprintf_loop:                  
        cmpb    $37,(%rdi)          # detect % 
        je      print_special
        myprintf_continue:   
        cmpb    $0,(%rdi)           # stop when encounter the ending code (null)
        je      myprintf_end
        
        inc     %rax
        inc     %rdi                # increments rdi to fetch the next char
        jmp     myprintf_loop

    myprintf_end:
    mov     $1,%rdi
    mov     %rax,%rdx
    mov     $1,%rax
    syscall
        
    pop     %rdi
    pop     %rsi
    pop     %rdx
    pop     %rcx
    pop     %r8
    pop     %r9

    mov     %rbp,%rsp               # epilogue
    pop     %rbp
    ret


print_special:
    # print all of the characters before the "%"
    push    %rdi
    push    %rdx

    mov     $1,%rdi                 # write to stdout 
    mov     %rax,%rdx               # numbers of characters to be printed   
    mov     $1,%rax                 # syswrite
    syscall 

    pop     %rdx
    pop     %rdi    
    
    cmpb    $100,1(%rdi)            # check if the next character is r, u, s or d
    je      print_d
    cmpb    $115,1(%rdi)
    je      print_s
    cmpb    $117,1(%rdi)
    je      print_u
    cmpb    $37,1(%rdi)
    je      print_div
    print_special_continue:
    mov     $0,%rax                 # rax always holds how many characters need to be printed next
    mov     %rdi,%rsi               # rsi always points to the beginning address of next chunk of characters to be printed
    jmp     myprintf_continue


print_s:                            
    add     $8,%rdx                 # rdx holds the number of which arg should be used 
    cmp     %rdx,%rbp               # check if the number of args has passed 6
    jne     print_s_normal_arg
    add     $16,%rdx                # skip the old rbp and the return value 

    print_s_normal_arg:
    push    %rdi
    push    %rdx

    mov     $0,%rax
    mov     (%rdx),%rdi
    print_s_loop:                   # this is only for finding the length of the string
        cmpb    $0,(%rdi)
        je      print_s_loop_continue
        inc     %rax
        inc     %rdi
        jmp     print_s_loop

    print_s_loop_continue:          # print out the null terminated string which is given to myprintf as an argument
        mov     $1,%rdi             # THIS IS THE PROBLEM !!!!!!!!!!!!!!
        mov     (%rdx),%rsi         # buffer
        mov     %rax,%rdx           # number of chars to be printed
        mov     $1,%rax             # syswrite
        syscall

    pop     %rdx
    pop     %rdi

    add     $2,%rdi                 # skip the format "%s" 
    jmp     print_special_continue


print_div:
    add     $1,%rdi                 # skip the first % character
    jmp     print_special_continue


print_u:
    add     $8,%rdx
    cmp     %rdx,%rbp               # check if the number of args has passed 6
    jne     print_u_normal_arg
    add     $16,%rdx
    
    print_u_normal_arg:             # skip the old rbp and the return value 
    push    %rdi
    push    %rdx


    push    (%rdx)                  # push the number to be printed onto the stack (this is relevant to print_d)

    print_unsign:
    mov     (%rsp),%rax             # rax holds the number to be printed
    push    $0                      # a mark used later to check whether all digits have been printed 
    print_u_loop:                   # push the ascii code of the digits onto the stack
        mov     $0,%rdx
        mov     $10,%rsi            
        div     %rsi                # result in rax, remain in rdx

        mov     $template,%rsi
        add     %rdx,%rsi
        push    %rsi


        cmp     $0,%rax             # compare result of the last division with 0
        jne     print_u_loop        
    
    print_u_loop2:                  # print the digits
        mov     $1,%rdi
        pop     %rsi
        mov     $1,%rdx
        mov     $1,%rax
        syscall

        cmp     $0,(%rsp)           # check if all the digits are printed
        jne     print_u_loop2

    
    add     $16,%rsp

    pop     %rdx
    pop     %rdi

    add     $2,%rdi                 # skip the format "%s" 
    jmp     print_special_continue

print_d:

    add     $8,%rdx
    cmp     %rdx,%rbp               # check if the number of args has passed 6
    jne     print_d_normal_arg
    add     $16,%rdx                # skip the old rbp and the return value 

    print_d_normal_arg:
    push    %rdi
    push    %rdx

    push    (%rdx)                  # store the number to be printed onto the stack (this is relevant to print_unsign)
    cmp     $0,(%rsp)               # check if the number to be printed is positive 
    jge     print_unsign            


    mov     $1,%rdi                 # print the sign character
    mov     $sign_character,%rsi
    mov     $1,%rdx
    mov     $1,%rax
    syscall

    pop     %rdi
    dec     %rdi                    # calculate the positive respresentation of the number: subtract 1, flip all bits
    not     %rdi
    push    %rdi                    

    jmp     print_unsign            # print the number as a positive number since we have already printed th sign character










