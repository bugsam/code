; Author: @bugsam
; 03/29/2020

global _start ; set EntryPoint

ReadStdIn:
	; epilogue
	push ebp 
	mov ebp, esp

	; check /usr/include/x86_64-linux-gnu/asm/unistd_32.h to find more syscall numbers
	mov edx, 0x80 			; buffer size
	mov ecx, Buffer			; buffer in memory to store input 
	mov ebx, 0x01			; file descriptor (read from stdin)
	mov eax, 0x03 			; sycall read
	int 0x80

	leave
	ret 

_start:
	pushad
	pushfd
	
	call ReadStdIn

	popfd
	popad

	; syscall exit 
	mov eax,0x1
	mov ebx,0x0
	int 0x80

Buffer: db "",0
