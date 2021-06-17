; Author: @bugsam
; 04/05/2020

global _start

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
section .data
	fd_src db "/etc/shadow",0			; file descriptor (source)
	fd_dst db "./shadow",0				; file descriptor (destination)

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
section .bss
	source_file resq 0x100				; memory allocation to 2048 bytes, note that one quad is equal to 8 bytes
	handle_src resq 0x1				; handle file (8 bytes)
	handle_dst resq 0x1				; (destination handle)

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
section .text
	OpenFile:
		push ebp				; save old base pointer
		mov ebp, esp				; save old intruction pointer
		
							; %%%%%%%%% S T A C K %%%%%%%%%%%%%%%%%
							; [ebp+16]	: third argument
							; [ebp+12]	: second argument
							; [ebp+8]	: first argument
							; [ebp+4] 	: return address
							; [ebp] 	: old ebp value
							; [ebp-4]	: first local variable

		mov edx, [ebp+16]			; mode [ignored if O_CREAT or O_TMPFILE is not specified]
		mov ecx, [ebp+12]			; flags
		mov ebx, [ebp+8]			; file descriptor
		mov eax, 0x05				; open syscall
		int 0x80
		
		mov esp, ebp
		pop ebp
		ret

	ReadFile:
		push ebp
		mov ebp, esp
	
		mov edx, [ebp+16]			; size of buffer 
		mov ecx, [ebp+12] 			; buffer to keep file in memory
		mov ebx, [ebp+8]			; file descriptor
		mov eax, 0x03				; read syscall
		int 0x80
	
		mov esp, ebp
		pop ebp
		ret

	WriteFile:
		push ebp
		mov ebp, esp

		mov edx, [ebp+16]			; buffer size
		mov ecx, [ebp+12]			; handle source
		mov ebx, [ebp+8]			; handle destination
		mov eax, 0x04				; write syscall
		int 0x80
		
		mov esp, ebp
		pop ebp
		ret

	CloseFile:
		push ebp
		mov ebp, esp
		
		mov ebx, [ebp+8]			; file descriptor
		mov eax, 0x06				; close syscall
		int 0x80
		
		mov esp, ebp
		pop ebp
		ret

	_start:
		pushad
		pushfd
		
		; source file
		push 0x00				; argument flag [O_RDONLY] [ebp+12]
		push fd_src				; argument file descriptor [ebp+8]
		call OpenFile
		mov dword[handle_src], eax		; save file descriptor
		
		push 0x800				; argument buffer size [ebp+16]
		push source_file			; argument memory allocation buffer [ebp+12]
		push dword[handle_src] 			; argument file descriptor [ebp+8]
		call ReadFile
		;%%%%%%%%%%%%%%%%%

	
		; destination file
		push 0x1a4				; argument mode [S_IRUSR+S_IWUSR+,S_IRGRP+S_IROTH] (linux: u=rw,g=r,o=r) [0644]
		push 0x42				; argument flag [O_RDWR+O_CREAT] [ebp+12]
		push fd_dst				; argument file descriptor [ebp+8]
		call OpenFile
		mov dword[handle_dst], eax		; save file descriptor


		push 0x800				; argument buffer size [ebp+16]
		push source_file 			; argument source buffer [ebp+12]
		push dword[handle_dst]			; argument destination buffer [ebp+16]
		call WriteFile
		;%%%%%%%%%%%%%%%%

		push dword[handle_src]			; file descriptor
		call CloseFile

		push dword[handle_dst]			; file descriptor
		call CloseFile

		pushfd
		pushad
		
		mov ebx, 0x00				; exit code
		mov eax, 0x01				; exit syscall
		int 0x80
