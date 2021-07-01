; Author: @bugsam
; Date: 06/27/2021

section .data
        welcome db "Let's GoHacking!",0x0a,"Calculate the sum of two values: ",0xa
        welcomeL equ $-welcome

        askone db "Please enter the first number: ",0x0
        askoneL equ $-askone

        asktwo db "Please enter the seconde number: ",0x0
        asktwoL equ $-asktwo


section .bss
        num1 resb 0xa   ; allocate bytes in memory
        num2 resb 0xa
        result resb 0x4
        result_ascii resb 0xa 

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
        xchg esi, eax                   ; esi: *num

        mov byte [esi+ecx-1], 0x00      ; clear LF character
        dec ecx                         ; remove LF from size
        push ecx                        ; save sizeof(num) onto stack

        ..@latoi1:
                sub byte [esi], 0x30    ; byte operation: char to int
                inc esi                 ; increase pointer to next byte
                loop ..@latoi1

        pop ecx                         ; retrieves sizeof(num) from stack
        dec esi                         ; change pointer to last byte

        mov eax, 0x1                    ; set multiplier for the first place value
        xor ebx, ebx

        ..@latoi2:
                push ecx
                push eax

                xor ecx, ecx
                add cl, byte[esi]       ; works in next byte
                mul ecx                 ; eax: results
                dec esi                 ; next byte

                add ebx, eax            ; edx: temporary accumulator

                pop eax                 ; restore base multiplier
                mov ecx, 0xa
                mul ecx                 ; increase base multiplier

                pop ecx                 ; restore loop counter
        loop ..@latoi2
                xchg eax, ebx           ; eax: returns results

        leave
        ret

;; int to ascii (ascii base 10) 
itoa:
        push ebp
        mov ebp, esp
        sub esp, 0x14
        mov edi, [ebp+0x8]              ; edi: points to reserved memory for string
        mov ebx, 0xa                    ; base(16)
        xor ecx, ecx

        ..@litoa1:
                xor edx, edx
                div ebx                         ; edx: remainder (modulo operation)
                add edx, 0x30                   ; convert to char ASCII
                push edx                        ; save result onto stack
                inc ecx                         ; sizeof(result)
                cmp eax, 0x00                   ; end of operation
                jnz ..@litoa1

        mov eax, ecx
        ..@litoa2:
                pop edx
                mov byte [edi],dl               ; save into reserved memory for string
                inc edi                         ; next byte
                loop ..@litoa2
        mov byte [edi], 0x0a                    ; add LF character
        inc eax                                 ; add LF to the count

        leave
        ret

;; calc int
calc_int:
        push ebp
        mov ebp, esp
        sub esp, 0x14

        mov ebx, [ebp+0x8]                      ; ebx: points to reserved memory (result)
        mov ecx, [ebx]                          ; ecx: store (result)
        add eax, ecx                            ; eax: temporary accumulator
        mov [ebx], eax                          ; ebx: save result in reserved memory result

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
        push 0xa                ; read max 9 bytes + LF
        push num1
        call read_stdin         ; read first number
        call atoi
        push result
        call calc_int

        push asktwoL
        push asktwo
        call write_stdout
        push 0xa                ; read max 9 bytes + LF
        push num2
        call read_stdin         ; read second number
        call atoi               ; second number
        push result
        call calc_int

        push result_ascii
        call itoa               ; result number

        push eax                ; sizeof(result_ascii)
        push result_ascii
        call write_stdout

        popad
        popfd

        mov ebx, 0x0
        mov eax, 0x1    ; sys_exit
        int 0x80
