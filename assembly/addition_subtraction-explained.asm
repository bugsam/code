; Author: @bugsam
; 03/31/2020

global _start

_start:
        ; simple add operation
        mov al, 0x45
        add al, 0x25            ; sum 0x6a (as expected), FLAGS:[ PF ZF IF ]
        xor eax, eax            ; clear EAX
        

        ; simple subtraction w/ (greater minuend)
        mov eax, 0xBEAD
        sub eax, 0x4321         ; difference 0x7b8c (as expected), FLAGS:[IF]
        xor eax, eax


        ; simple subtraction w/ (greater subtrahand)
        ; short explanation: 
        ; (((ffff+2d)−3d)−ffff)=-10

        ; CF=1, indicates the borrow action
        ; SF=1, indicates negative result
        ; we'll also use the integer subtraction with borrow (sbb) instruction, this instructions looks for CF flag to borrow

        clc                     ; to avoid mistakes, clear CF
        mov ax, 0x2d
        stc                     ; as we know the subtrahand is greater, we have to set the borrow flag, stc sets CF=1
        sbb ax, 0x3d            ; as CF is set to 1, SBB adds 0xffff (all bits from register size) to AX, then subtract 0x3D and gets a results 0xffef (as expected), FLAGS:[ CF AF SF IF ]
        mov bx, 0xffff          ; as borrowed 0xffff, we have to remove it to get the real difference
        sub bx, ax              ; sub calcs the difference and stores it in BX register, difference is -0x10 (as expected) [IF]
        xor ax, ax              
        xor bx, bx

        ; when subtracting greater sutrahand one possible solution is:
        ;
        ;  [1]2D        you borrow 1 from an imaginary digit (you have borrowed one hundred here)
        ;    -3D        
        ;  ----- 
        ;     F0
        ;  -(100-F0)=-10 
        ;
        ; (as you have borrowed 1 hundred, to get the difference, you to remove it)
        ; (all numbers are in hex system)

        ; set exit
        mov eax, 0x1
        mov ebx, 0x0
        int 0x80
