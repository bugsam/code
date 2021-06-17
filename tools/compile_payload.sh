#!/usr/bin/env bash
# Author: @bugsam
# Contains others people code
FILE=$1
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
gcc -fno-stack-protector -zexecstack -o ${FILE} ${FILE}.c
