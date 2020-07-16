#!/usr/bin/env python3
# Author: @bugsam
# Date? 07/16/2020
#
# 
# sys.argv[1] = string:: path to elf
import sys
import secrets
from elftools.elf.elffile import ELFFile
from capstone import *

def random():
    return secrets.token_hex(1)

def shellcode(bytes):
    ops = bytes
    i = 0
    x = 0
    y = 2
    code  = ''
    ncode = ''

    while i != (len(ops)/2):
        code += "\\x" + ops[x:y]
        ncode += '0x%02x,'% (int(ops[x:y],16))
        x = y
        y += 2
        i += 1
    return code, ncode

def isPrime(n) :
    p = 0
    if (n <= 1):
        return False
    for num in range(1, n):
        if (n % num == 0):
            p += 1
            if p > 1:
                break
    if (p > 1):
        return False
    else:
        return True
        
def insertion(bytes):
    i = 0
    x = 0
    y = 2
    p = 0
    code  = ''
    
    while i != (len(bytes)):
        code += bytes.hex()[x:y]
        if(isPrime(i)):
            #code += random()
            code += "FF"
        x = y
        y += 2
        i += 1
    return code

path = sys.argv[1]
f = open(path, 'rb')    # read binary
elf = ELFFile(f)        # map file as ELF
code = elf.get_section_by_name('.text') # extract .text section
ops = code.data()       # get data from text

payload = insertion(ops)    # insert random values if prime number
original_xcode, original_ncode = (shellcode(ops.hex())) # returns payload with \ and ,
prime_xcode, prime_ncode = (shellcode(payload))# returns payload with \ and ,

original_lcode = int(len(str(original_xcode))/4) # returns length shellcode
prime_lcode = int(len(str(prime_xcode))/4) # returns length shellcode

print("Original shellcode length:",original_lcode,hex(original_lcode))
print("Original opcodes:",original_xcode,"\n",original_ncode)
print()
print("Prime shellcode length:",prime_lcode,hex(prime_lcode))
print("Prime opcodes:",prime_xcode,"\n",prime_ncode)
print()
