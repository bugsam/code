; Author: @bugsam
; 04/26/2020

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
        xor edx, edx                    ; clear EDX
        mov dl, 0xc                     ; EDX (12d) _count_ (

        pop ecx                         ; ECX (*msg) _*buf_ (memory address adquired in runtime to the first 
                                        ; byte of memory that contains the respective string).
                                        ; In other words, this is the return-instruction pointer, saved by call
                                        ; instruction (E8) in the procedure stack 

        xor ebx, ebx                    ; clear EBX
        inc bl                          ; EBX (1)  _fd_ (file descriptor STDOUT)
        xor eax, eax                    ; clear EAX
        times 0x04 inc al               ; EAX (4) syscall WRITE
        int 0x80 

        xor ebx, ebx                    ; clear EBX
        xor eax, eax                    ; clear EAX
        inc eax                         ; EAX (1) syscall EXIT 
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

        msg: db "Hello World",0xA       ; string of 12 bytes
                                        ; return-instruction pointer, points to this string in this program
