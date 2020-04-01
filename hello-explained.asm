; Author: @bugsam
; 03/27/2020

global _start

_start:
        mov eax, 0x4 ; set syscall value 4 (__NR_write) to be used
        mov ebx, 0x1 ; set handle file to exit as value 2 (sysout)
        mov ecx, string ; set address of the begin of the string
        mov edx, stringL ; set size of the address that contains that string
        int 0x80 ; interuption for execution of wherever syscall is referenced by EAX

        mov eax, 0x1 ; set syscall value 1 (__NR_exit) to be used
        mov ebx, 0x0 ; set exit code as success
        int 0x80 ; interuption for execution of wherever syscall is referenced by EAX

        string: db "Hello World", 0xa ; define bytes with a new line delimiter LineFeed(0xa)
        stringL: equ $-string ; define value as end of the string ($) sub offset of the begin of the string
