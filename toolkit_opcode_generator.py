# Author: @bugsam
# 05/23/2020
# sys.argv[1] = string:: path to elf
# sys.argv[2] = string:: one byte key (e.g. '0xAA')
import sys
from elftools.elf.elffile import ELFFile
from capstone import *

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

def cipher(bytes,key):
	ops = bytes
	i = 0
	x = 0
	y = 2
	code  = ''
	while i != (len(ops)/2):
		code += '%02x'% (int(ops[x:y],16)^int(key,16))
		x = y
		y += 2
		i += 1
	return code

def no_nullbyte(code):
	if '00' in str(code):
		return False,str(code).find('00')	#return position of null byte
	else:
		return True

path = sys.argv[1]
f = open(path, 'rb')	#read binary
elf = ELFFile(f)	# map file as ELF
code = elf.get_section_by_name('.text')	# extract .text section
ops = code.data()	# get data from text
xcode, ncode = (shellcode(ops.hex())) #returns payload with \ and ,
lcode = int(len(str(xcode))/4)

key = sys.argv[2]
encoded = (cipher(ops.hex(),key))
xencoded, nencoded = shellcode(encoded)
old = (cipher(encoded,key))
print("Key works:",ops.hex() == old and no_nullbyte(encoded))
print("Shellcode length:",lcode,hex(lcode))
print()
print("NO Null bytes:",no_nullbyte(xcode))
print("Original:",ops.hex())
print("Payload:",xcode)
print("Payload:",ncode)
print()
print("NO Null bytes:",no_nullbyte(encoded))
print("Encoded:",encoded)
print("Payload:",xencoded)
print("Payload:",nencoded)
