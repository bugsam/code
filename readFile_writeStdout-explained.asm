; Author: @bugsam
; 04/03/2020

section .data
	fd db "/etc/shadow",0	; set file descriptor, example '/etc/shadow'
	handle db "",0		; buffer to save handle

section .bss			; specify additional information to ELF bss section
	buffer resq 0x100	; create a buffer in memory of 2048bytes / note that each quad equals 8 bytes

section .text
	global _start

	OpenFile:
		push ebp
		mov ebp, esp
		
		mov ecx, 0x0		; set access mode to read-only (O_RDONLY)
		mov ebx, fd		; specify handle 
		mov eax, 0x05		; open syscall
		int 0x80
		
		mov dword[handle], eax	; save file descriptor

		mov esp, ebp
		pop ebp
		ret

	ReadFile:
		push ebp
		mov ebp, esp
		
		mov edx, 0x800		; buffer size 2000 bytes
		mov ecx, buffer		; memory reserved area, file contents
		mov ebx, dword[handle]	; file descriptor
		mov eax, 0x03		; read syscall
		int 0x80

		leave
		ret

	WriteStd:
		push ebp
		mov ebp, esp
		
		mov edx, 0x800		; buffer size 2000 bytes	
		mov ecx, buffer		; memory reserved area, file contents
		mov ebx, 0x01		; file descriptor stdout
		mov eax, 0x04		; write syscall
		int 0x80

		leave
		ret

	CloseFile:
		push ebp
		mov ebp, esp

		mov ebx, dword[handle]	; file descriptor
		mov eax, 0x06		; close syscall
		int 0x80

		leave
		ret

	_start:
		pushfd
		pushad

		call OpenFile
		call ReadFile
		call WriteStd
		call CloseFile
		
		pushad
		pushfd

		mov ebx, 0x0		; exit code
		mov eax, 0x1		; exit syscall
		int 0x80
