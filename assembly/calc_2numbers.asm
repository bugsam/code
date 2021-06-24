section .data
        welcome db "Let's GoHacking!",0x0a,"Calculate the sum of two values: ",0xa
        welcomeL equ $-welcome

        askone db "Please enter the first number: ",0x0
        askoneL equ $-askone

        asktwo db "Please enter the seconde number: ",0x0
        asktwoL equ $-asktwo


section .bss
        num1 resq 4     ; allocate 32 bytes in memory
        num2 resq 4

section .text
        global _start


read_stdin:
        push ebp
        mov ebp, esp

        mov edx, [ebp+0xc]      ; count: buffer_size
        mov ecx, [ebp+8]        ; *buf: pointer to buffer
        mov ebx, 0x0    ; fd: stdin
        mov eax, 0x3    ; sys_read
        int 0x80

        mov esp, ebp
        pop ebp
        ret

write_stdout:
        push ebp
        mov ebp, esp


        mov edx, [ebp+0xc]      ; count: buffer_size
        mov ecx, [ebp+0x8]      ; *buf: pointer to buffer
        mov ebx, 0x1    ; fd: stdout
        mov eax, 0x4    ; sys_write
        int 0x80

        leave
        ret

;; ascii to int (ascii base 10)
atoi:
        push ebp
        mov ebp, esp
        sub esp, 0x14

        xchg ecx, eax                   ; ecx: sizeof(num)
        xchg ebx, eax                   ; ebx: *num

        mov byte [ebx+ecx-1], 0x00      ; clear LF character
        dec ecx                         ; remove LF from size
        push ecx                        ; save sizeof(num) onto stack

        ..@latoi1:
                sub byte [ebx], 0x30    ; byte operation: char to int
                inc ebx                 ; increase pointer to next byte
                loop ..@latoi1

        pop ecx                         ; retrieves sizeof(num) from stack
        dec ebx                         ; change pointer to last byte

        push eax
        mov eax, 0x1
        push ecx
        xor edx, edx

        ..@latoi2:
                push eax

                xor ecx, ecx
                add cl, byte[ebx]       ; works in next byte
                mul ecx                 ; eax: results

                add edx, eax            ; edx: temporary accumulator

                pop eax                 ; restore base multiplier

                mul 0xa                 ; increase base multiplier
                pop ecx                 ; restore loop counter
        loop ..@latoi2

                pop eax



        leave
        ret

;; int to ascii (ascii base 10) 
itoa:
        push ebp
        mov ebp, esp

        ;TODO add LF

        leave
        ret

;; calc int
calc_int:
        push ebp
        mov ebp, esp

        leave
        ret

_start:
        pushfd
        pushad

        xor eax, eax
        xor ebx, ebx

        push welcomeL
        push welcome
        call write_stdout

        push askoneL
        push askone
        call write_stdout
        push 0x0a
        push num1
        call read_stdin         ; read first number

        ;ECX -> buffer
        ;EAX -> size
        call atoi       ; first number


        push asktwoL
        push asktwo
        call write_stdout
        push 0x0a
        push num2
        call read_stdin ; read second number

        push num2
        call atoi       ; second number

        call calc_int
        call itoa       ; result number

        ;;TODO size of buffer
        push 0x0a
        push edx
        call write_stdout

        popad
        popfd

        mov ebx, 0x0
        mov eax, 0x1    ; sys_exit
        int 0x80
