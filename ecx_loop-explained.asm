; Author: @bugsam
; 04/02/2020

section .data				; specify additional information to ELF data section
	buffer db "bugsam",0x0a
	bufferL equ $-buffer

section .bss
section .text
global _start

_start:
	mov ecx, 0x3			; set counter
print:
	push ecx 			; save ecx, as it is the counter
	
	mov eax, 0x04			; syscall (write)
	mov ebx, 0x01
	mov ecx, buffer
	mov edx, bufferL
	int 0x80

	pop ecx				; restore ecx

	loop print			; return to label and decrement ECX by one
					; the last loop ocurrs when ECX gets to 1
		
	mov eax, 0x01
	mov ebx, 0x00
	int 0x80
