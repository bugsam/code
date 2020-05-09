/!/usr/bin/env python2
# 05/09/2020
# code to assist 'push shellcode' technique

__author__ = "@bugsam"

code = 'TYPE YOUR STRING HERE'
code = code[::-1].encode('hex')
#code = 'TYPE YOUR SHELLCODE HERE'
mod = len(code)%8
if mod != 0:
    count = (8 - mod)/2
    #adding padding
    code = ("90" * count) + code
i = 0
x = 0
y = 8
while i != (len(code)/8):
    print("push 0x"+code[x:y])
    x = y
    y += 8
    i += 1
