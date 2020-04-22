global _start

section .data
	welcome db "This program will calculate the sum of two values: ",0x0a
	welcomeL equ $-welcome

	ask_one	db "Please enter the first value: ",0x0
	ask_oneL equ $-ask_one

	ask_two db "Please enter the seconde value: ",0x0	
	ask_twoL equ $-ask_two

section .bss
	value1 resq 4				; allocate 32 bytes in memory
	value2 resq 4

section .text
	WriteStdOut:
		push ebp
		mov ebp, esp
	
		mov edx, [ebp+12]		; buffer size
		mov ecx, [ebp+8]		; buffer
		mov ebx, 0x01			; file descriptor (stdout)	
		mov eax, 0x04
		int 0x80

		mov esp, ebp
		pop ebp
		ret

	ReadStdIn:
		push ebp
		mov ebp, esp
		
		mov edx, [ebp+12]		; buffer size
		mov ecx, [ebp+8]		; buffer
		mov ebx, 0x01 			; file descriptor (stdin)
		mov eax, 0x03			; read syscall (return number of bytes written to the buffer)	
		int 0x80	
	
		mov esp, ebp
		pop ebp
		ret

	AsciiNumToHex:
		; this function removes 30 from the ASCII character, then
		; convert DECIMAL to HEXADECIMAL through formula, for place
		; values equals or greater then tens, where y is the DECIMAL value: 
		; (y*6) + (y*3) 

		push ebp
		mov ebp, esp
		sub esp, 0x20
		
		mov ecx, eax			; offset to last byte of memory string
		mov esi, [ebp+8]		; first byte of memory string
	
		mov dword[ebp-8], 0xa		; set multiplier
		mov edi, 0x00
		mov byte[ebp-4], 0x01		; control place value loop
	..@back1:
		lea eax, [esi+ecx-1]		; interact with bytes from right to left
		push ecx

		xor ecx, ecx

		; convert ASCII character in number
		mov ecx, [eax]
		xor eax, eax
		mov al, cl
		sub al, 0x30	
		xor ecx, ecx
		mov cl, al
	
		; for the first place value isn't necessary
		; to use the formular (y*6) + (y*4)
		
		cmp byte[ebp-4], 0x01
		je ..@ones
	
		; for the others place value jump to formula	
		jmp ..@tens

		; hundreds
		..@hundreds:
				; multiply to adquire correct place value
				mov ebx, dword[ebp-8]		; restore multiplier
				mul ebx				
				add edi, eax			; saves accumulator
				
				; increments multiplier
				mov eax, 0xa
				mul ebx
				mov dword[ebp-8], eax		; saves multiplier
				jmp ..@ends

		; hundreds and tens
		..@tens:
			; short explanation: (y+6) * (y+4)	
			push ebx			; saves multiplier
			mov ebx, 0x06
			mul ebx				; operation (y*6), result will be in AX
			push eax			; saves result (y*6)
			
			; changed bl to ebx
			mov ebx, 0x04
			mov eax, ecx
			mul ebx				; operation (y*4), result will be in AX 
			
			pop ebx				; get result of (y*6)
			add eax, ebx 			

			pop ebx				; restore multiplier

			cmp byte[ebp-4], 0x03
			jge ..@hundreds

		; hundreds, tens and ones
		..@ones:
			add edi, eax			; saves acumulator
		
		..@ends:
			inc byte[ebp-4]
			pop ecx
			loop ..@back1	
		
		add esp, 0x12
		leave
		ret

	_start:
		pushfd
		pushad

		push welcomeL
		push welcome
		call WriteStdOut
			
		push ask_oneL 
		push ask_one
		call WriteStdOut
		
		push 0x100				; buffer size limit
		push value1 				; buffer
		call ReadStdIn				; return size of written data to buffer
		dec eax	
		mov byte[ds:value1+eax], 0x00		; clear LF character
		
		call AsciiNumToHex			; transfor to hexadecimal
		mov dword[value1], edi			; save hexadecimal value
		
		push ask_twoL
		push ask_two
		call WriteStdOut
		
		push 0x100				; buffer size limit
		push value2				; buffer
		call ReadStdIn				; return size of written data to buffer
		dec eax
		mov byte [ds:value2+eax], 0x00		; clear LF character
	
		call AsciiNumToHex
		mov dword[value2], edi			; save hexadecimal value
		
		; sum operation
		mov eax, dword[value1]
		add eax, dword[value2]
		
		; TODO reverse HEX to ASCII
		
		push 0x04				; buffer size
		push eax				; buffer (sum result)
		call WriteStdOut
		
		pushad
		pushfd
		
		mov ebx, 0x00
		mov eax, 0x01
		int 0x80
