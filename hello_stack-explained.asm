; Author: @bugsam
; 05/09/2020

global _start

section .text

_start:
        xor edx, edx            ; clear EDX
        mov dl, 0x22            ; EDX (34) (size without padding)

        push 0x90900a3f         ; *buf (buffer with padding)
        push 0x7961646f
        push 0x7420756f
        push 0x79206572
        push 0x6120776f
        push 0x68202c6d
        push 0x61736775
        push 0x6240206f
        push 0x6c6c6548          

        mov ecx, esp            ; ECX (Stack Pointer)

        xor ebx, ebx            ; clear EBX
        mov bl, 0x01            ; EBX (1) stdout

        xor eax, eax
        mov al, 0x04            ; EAX (4) syscall WRITE
        int 0x80

        ; fun way to set syscall
        mov eax, 0x0eaf08201           ; random number
        and eax, 0xff                  ; EAX (1) syscall EXIT
        int 0x80
