; Author: @bugsam
; 03/28/2020

global _start ; set initial EntryPoint

PrintText:
        ; epilogue
        push ebp ; save EBP onto the stack to use it to save ESP content
        ; ESP is the memory address of the top of the stack
        ; we have to save it to allow the correct flow of the program
        ; when EIP (instructor pointer) moves to other command
        ; it has to be right, or you gonna pop things different
        ; than what was expected to
        mov ebp, esp

        mov eax, 0x4
        mov ebx, 0x1
        mov ecx, string
        mov edx, stringL
        int 0x80

        ; prologue
        ; leave works similar to mov esp, ebp / than pop ebp
        leave 

        ret ; avoid loop as setting IP to continue from its caller
_start:
        ; there's at least two ways to save state
        ; you can push each register into the stack
        ; or you can use pushad to do that for you
        pushad ; save all registers
        ; the same here, use pushfd to push all CPU flags onto the stack
        pushfd ; save all CPU flags
        
        call PrintText
        
        popfd ; pop all flags from the stack
        popad ; pop all registers from the stack

        mov eax, 1 ; prepare exit function
        mov ebx, 0x0 ; set return as success
        int 0x80 ; call syscall

        string: db "Working with stack",0xa
        stringL: equ $-string
