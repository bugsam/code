; Author: @bugsam
; 05/04/2020

global _start                           ; define the entry point

section .text

_start:
        jmp short jumper                ; jump short (EB), will jump to a memory address, 
                                        ; in jump short, the relative  address is 8-bit value. 
                                        ; For a forward jump, when the relative address is positve, 
                                        ; it will result a memory address greather than the current EIP:
                                        ; EIP + 1-byte (opcode EB) + 1-byte (relative address) + rel8 = next_instruction
                                        ; ex: 8049000: eb 1c 
                                        ; 0849000 + 1 + 1 + 1c = 0804901E (next intruction)

                                        ; For a reverse jump, when the relative address is negative,
                                        ; it will result a memory address less than the current EIP,
                                        ; the relative number is a signed number and might be stored in
                                        ; little endian:
                                        ; EIP + 1-byte (opcode EB) + 1-byte (relative address) - (rel8_two's_complement) = next_instruction
                                        ; ex: 8049011: eb ed
                                        ; NOT(1110 1101) = 0001 0010 + 1 = 13h
                                        ; NOT(ed) + 1 = 13h (rel8_two's_complement)
                                        ; 08049011 + 2 + 13h = 08049000 (next intruction)

; as this is supposed to be a shellcode, it can't contain NULL bytes.
; otherwise, many of these instructions could be written in a simplified way
shellcode:
        pop esi                         ; ECX (*cmd) (memory address adquired in runtime to the first 
                                        ; byte of memory that contains the respective string).
                                        ; In other words, this is the return-instruction pointer, saved by call
                                        ; instruction (E8) in the procedure stack 

        xor ebx, ebx                    ; clear EBX

        ; set array values
        lea ecx, [esi + 21]             ; ECX (argv[0]) memory address
        mov dword[esi], ecx             ; set pointer to first argument

        lea ecx, [esi + 24]             ; ECX (argv[1]) memory address
        mov dword[esi + 4], ecx         ; set pointer to second argument
        mov dword[esi + 8], ebx         ; set argv[2] NULL-dword

        ; set NULL
        mov byte[esi + 23], bl          ; set NULL-terminated character in string argv[0]
        mov byte[esi + 26], bl          ; set NULL-terminated character in string argv[1]
        mov dword[esi + 8], ebx         ; set NULLL argv[2] to finish the array

        ; calling syscall
        lea edx, [esi + 8]              ; EDX (*envp), as we hardcoded the full pathname it is not necessary
                                        ; to use environ, so envp[0] will be a NULL dword (in Linux it is allowed
                                        ; to set envp[] as NULL, in other systems it might result in an EFAULT
        lea ecx, [esi]                  ; ECX (*argv), pointer to *argv[0], which is the first memory address
                                        ; for the given array.
        lea ebx, [esi + 12]             ; EBX (*pathname), full path to process image that will be created.

        xor eax, eax
        mov al, 0xb                     ; EAX (11) syscall EXECVE
        int 0x80                         

jumper:
        call shellcode                  ; near call (E8), will saves the return-instruction pointer on the 
                                        ; stack and changes the EIP to the value pointing to the relative address.
                                        ; The return-instruction pointer, points to the next operation that should 
                                        ; be execute when a return occurs from the called procedure.
                                        ; Perhaps the relative address is in little-endian, also it might be negative 
                                        ; if the called procedure is before the current EIP value. In a 32 bit operation
                                        ; the return-instruction pointer can be obtained:
                                        ; EIP + 1-byte (opcode E8) + 4-byte (relative address) = return_instruction_pointer
                                        ; The called procedure in forward mode can be obtained through:
                                        ; return_instruction_pointer + rel32 = next_instruction
                                        ; ex: 8049002: e8 1d 00 00 00
                                        ; 08049002 + 1 + 4 = 8049007 (return_instruction_pointer)
                                        ; 08049007 + 0000001d = 08049024 (next_instruction) 

                                        ; The called procedure in a reverse mode can be obtained through:
                                        ; return_instruction_pointer - rel32_two's_complement = next_instruction
                                        ; ex:  804906d: e8 ab ff ff ff 
                                        ; 0804906d + 1 + 4 = 08049072 (return_instruction_pointer)
                                        ; NOT(1111 1111 1111 1111 1111 1111 1010 1011) = 0101 0100 + 1 = 55h
                                        ; NOT(ffffffab) + 1 = 55h (rel32_two's_complement)
                                        ; 08049072 - 55h = 0804901d (next_instruction)

        cmd: db "ZZZZNNNNZZZZ/usr/bin/ncN-hZ" 
                                        ; pointer to: *argv[0]: "/usr/bin/nc",0
                                        ; pointer to: *argv[1]: "-h",0
                                        ; argv[2]: NULL
                                        ; *pathname: /usr/bin/nc
                                        ; return-instruction pointer, points to this string in this program
