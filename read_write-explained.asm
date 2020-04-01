; Author: @bugsam
; 03/29/2020

global _start ; set EntryPoint

ReadScreen:
	; epilogue
	push ebp 
	mov ebp, esp

	; check /usr/include/x86_64-linux-gnu/asm/unistd_32.h to find more syscall numbers
	; syscall read
	mov eax, 0x03 
	mov ebx, 0x01
	mov ecx, Buffer 
	mov edx, 0x80 
	int 0x80

	leave
	ret 

WriteScreen:
	push ebp
	mov ebp, esp

	; syscall write
	mov eax, 0x04
	mov ebx, 0x01
	mov ecx, Buffer
	mov edx, 0x80
	int 0x80

	leave
	ret
_start:
	pushad
	pushfd
	
	call ReadScreen
	or eax,eax
	jnz escape

	popfd
	popad
write:	
	pushad
	pushfd	

	call WriteScreen
	
	popfd
	popad
escape:
	; syscall exit 
	mov eax,0x1
	mov ebx,0x0
	int 0x80

Buffer: db "",0
