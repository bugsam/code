; Author: @bugsam [GitHub]
; 04/02/2020

section .data				; specify additional information to ELF data section
	buffer db "bugsam",0x0a
	bufferL equ $-buffer
	bufferD db "",0

section .bss
section .text
	global _start

	counter:
		mov ecx, 0x3			; set counter
		jmp print
	_start:
		jmp counter
	print:
		push ecx 			; save ecx, as it is the counter
			
		mov edx, bufferL
		mov ecx, buffer
		mov ebx, 0x01
		mov eax, 0x04			; syscall (write)
		int 0x80

		pop ecx				; restore ecx
		dec ecx				; decrement ecx
						; when ECX becomes 0, Zero Flag is set to 0 and jump is not taken
		jnz print			; take jump only if Zero Flag is not set
			
		mov eax, 0x01
		mov ebx, 0x00
		int 0x80
