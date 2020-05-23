# Author: @bugsam
# 05/23/2020

import sys
from elftools.elf.elffile import ELFFile
from capstone import *

def shellcode(bytes):
	ops = bytes.hex()
	i = 0
	x = 0
	y = 2
	code  = ''
	while i != (len(ops)/2):
		code += "\\x" + ops[x:y]
		x = y
		y += 2
		i += 1
	return code	

path = sys.argv[1]
#f = open('./exec-shellcode', 'rb')	#read binary
f = open(path, 'rb')	#read binary
elf = ELFFile(f)	# map file as ELF
code = elf.get_section_by_name('.text')	# extract .text section
ops = code.data()	# get data from text

print(shellcode(ops))
