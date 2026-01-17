IDEAL
MODEL small
STACK 100h
DATASEG

massageToUser1 	db 'Welcome To my piano! $'
massageToUser2	db 'if you want to play on the piano, you have to know that: z is C     s is c#     x is D     d is d#     c is E     v is F     g is f#     b is G     h is g#     n is A     j is a#     m is B     and: , is c -> escape(esc) is exit the piano$'
massageToUser3  db 'press any key to continue: $'


SizeOfLineY		dw 200
tempLineY		dw 0
SizeOfLineX		dw 15
tempLineX		dw 0
x 				dw 0
tempX 			dw 0
y				dw 0
tempY 			dw 0
color			db 15
address 		dw 0
address2		dw 0
address3		dw 0
address4		dw 0

Clock			equ es:6Ch

noteC			dw 008E9h
noteCDiez		dw 00869h
noteD			dw 007F0h
noteDDiez		dw 0077Eh
noteE			dw 00712h
noteF			dw 006ADh
noteFDiez		dw 0064Ch
noteG			dw 005F1h
noteGDiez		dw 0059Dh
noteA			dw 0054Bh
noteADiez		dw 00500h
noteB			dw 004B8h
noteC2			dw 00474h

CODESEG

;this function get x, y and size and print a line
proc line
	
	;save the return addres
	pop [address3]
	
	;size of line
	pop di
	;ip of color
	pop si
	;y
	pop dx
	;x
	pop cx
	
	mov al, [si]
	xor bh, bh
	
;this is a loop that print some pixels in the same line 
PrintPixel:
	mov ah,0ch
	int 10h
	
	inc dx
	dec di
	cmp di, 0
	jne PrintPixel
	
	;finish the function
	push [address3]
	ret

endp line

;this function color all the screen on one color
proc WhiteScreen
	
	;save the return address
	pop [address2]
	mov cx, 320
	
	;this is a function that run 320 time on all the
	;screen and call the function that color a line
PrintScreen:
	push cx
	
	;put all the information in the stack and then call to the function
	push [x]
	mov [y], 0
	push [y]
	push offset color
	push [SizeOfLineY]
	call line 
	
	pop cx
	
	;every time color other line
	inc [x]
	loop PrintScreen
	
	;back to the address that she called
	push [address2]
	ret

endp WhiteScreen

;this function color all the touch pointes in a piano 
proc TouchPoint
	
	pop [address2]
	push cx
	
	;the color is grey and we have to do it 7 times and start from pixel 39
	mov cx, 7
	mov [color], 8
	mov [x], 39
	
printLine:

	push cx
	
	;put all the information in the stack and call to the function that color a line
	push [x]
	mov [y], 0
	push [y]
	push offset color
	push [SizeOfLineY]
	call line
	
	;every time we have to increas the x by 40
	add [x], 40
		
	pop cx
	
	loop printLine

	pop cx
	
	;return to the address that called that function
	push [address2]
	ret 
	
endp TouchPoint

;this function color on the screen a rectangle
proc Rect
	
	pop [address2]
	
	pop [x]
	pop [y]
	pop [SizeOfLineX]
	pop [SizeOfLineY]
	mov [color], 0
	
	mov cx, [SizeOfLineX]
	
;this loop call to the function that colored a line on the screen several times
printRect:
	
	push cx
	
	;push all the information to the stack and call to the function that colored a line
	push [x]
	push [y]
	push offset color
	push [SizeOfLineY]
	call line
	
	pop cx
	
	inc [x]
	
	loop printRect
	
	;return to the address that called
	push [address2]
	ret
	
endp Rect

;this function color on the screen the black rectangles in an octava in piano
proc printRects
	
	pop [address]
	
	;all this lines are just called several times to the function that colored 
	;rectangles every time with the same size but the strat of the color is different 
	mov [SizeOfLineX], 19
	mov [SizeOfLineY], 85
	mov [x], 31
	mov [y], 0
	
	push [SizeOfLineY]
	push [SizeOfLineX]
	push [y]
	push [x]
	call Rect
	
	mov [SizeOfLineX], 19
	mov [tempLineX], 19
	mov [SizeOfLineY], 85
	mov [tempLineY], 85
	mov [x], 71
	mov [tempX], 152
	mov [y], 0
	mov [tempY], 0
	
	push [SizeOfLineY]
	push [SizeOfLineX]
	push [y]
	push [x]
	call Rect
	
	mov cx, 3

;this is a loop that print the three rectangles in octava
drawRects:
	
	push cx
	
	push [tempLineY]
	push [tempLineX]
	push [y]
	push [tempX]
	call Rect
	
	pop cx
	
	add [tempX], 40
	mov [y], 0
		
	loop drawRects
	
	;return to the address that called this function
	push [address]
	ret
	
endp printRects

;this function make a sound
proc makeSound
		
	pop [address2]
	pop bx
	
	push ax 
	push dx
	
	; open speaker
	in al, 61h
	or al, 00000011b
	out 61h, al
	
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	
	; play frequency 131Hz
	mov ax, bx
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	
	mov ax, 40h
	mov es, ax
	mov ax, [Clock]

FirstTick:

	cmp ax, [Clock]
	je FirstTick
	
	; count 0.5 sec
	mov cx, 2 ; 2x0.055sec = ~0.1sec

DelayLoop:

	mov ax, [Clock]

;this loop make a sound while a 0.1 second did not passed	
Tick:
	
	cmp ax, [Clock]
	je Tick
	loop DelayLoop
	
	; close the speaker
	in al, 61h
	and al, 11111100b
	out 61h, al
	
	pop dx
	pop ax
	
	;return to the address that called this function
	push [address2]
	ret
	
endp makeSound

;this function used to color the note that pressed on the piano
proc drawColoredRect
	
	pop [address4]
	
;this loop call to the function that print a line several times
printColoredRect:
	
	push cx
	
	;put all the information in the stack and call to the function that print a line
	push [x]
	push [y]
	push offset color
	push [SizeOfLineY]
	call line
	
	pop cx
	
	inc [x]
	
	loop printColoredRect
	
	;return to the address that called this function
	push [address4]
	ret
	
endp drawColoredRect

;this function actually make the connection between the user and the piano, 
;it is gets chars and make a sound according the input and color the note
proc play
	
	pop [address]
	
	mov ax, 0

playWhile:
	
	;get input from the user (a char)
	mov ah, 1
	int 16h
	
	mov ah, 0
	int 16h

;check if the char is 'z' if not check to the next note if yes:
checkC:
	cmp al, 122
	jne checkCDiez
playC:
	;color the note in green
	push [noteC]
	mov [x], 0
	mov [y], 180
	mov [color], 10
	mov [SizeOfLineY], 20
	mov cx, 39
	call drawColoredRect
	
	;make the sound according the note that pushed
	call makeSound
	
	;color the note by the color it should colored (white or black)
	mov [x], 0
	mov [y], 180
	mov [color], 15
	mov [SizeOfLineY], 20
	mov cx, 39
	call drawColoredRect
	
	jmp continue
	
;check if the input is 's' if not jump to the next note if yes:
checkCDiez:
	cmp al, 115
	jne checkD
playCDiez:
	push [noteCDiez]
	mov [x], 31
	mov [y], 70
	mov [color], 10
	mov [SizeOfLineY], 15
	mov cx, 19
	;color the note in the green color and the make sound
	call drawColoredRect
	call makeSound
	mov [x], 31
	mov [y], 70
	mov [color], 0
	mov [SizeOfLineY], 15
	mov cx, 19
	;color the note in black
	call drawColoredRect
	jmp continue
	
	;this next 19 lines do the same effect like the last 19 lines
checkD:
	cmp al, 120
	jne checkDDiez
playD:
	push [noteD]
	mov [x], 40
	mov [y], 180
	mov [color], 10
	mov [SizeOfLineY], 20
	mov cx, 39
	call drawColoredRect
	call makeSound
	mov [x], 40
	mov [y], 180
	mov [color], 15
	mov [SizeOfLineY], 20
	mov cx, 39
	call drawColoredRect
	jmp continue
	
	;this next 19 lines do the same effect like the last 19 lines
checkDDiez:
	cmp al, 100
	jne checkE
playDDiez:
	push [noteDDiez]
	mov [x], 71
	mov [y], 70
	mov [color], 10
	mov [SizeOfLineY], 15
	mov cx, 19
	call drawColoredRect
	call makeSound
	mov [x], 71
	mov [y], 70
	mov [color], 0
	mov [SizeOfLineY], 15
	mov cx, 19
	call drawColoredRect
	jmp continue
	
	;this next 19 lines do the same effect like the last 19 lines
checkE:
	cmp al, 99
	jne checkF
playE:
	push [noteE]
	mov [x], 80
	mov [y], 180
	mov [color], 10
	mov [SizeOfLineY], 20
	mov cx, 39
	call drawColoredRect
	call makeSound
	mov [x], 80
	mov [y], 180
	mov [color], 15
	mov [SizeOfLineY], 20
	mov cx, 39
	call drawColoredRect
	jmp continue
	
	;because the computer can not jump to far way, I did that he jump for several short ways 
jumpToStart3:
	jmp playWhile
	
	;this next 19 lines do the same effect like the last 19 lines
checkF:
	cmp al, 118
	jne checkFDiez
playF:
	push [noteF]
	mov [x], 120
	mov [y], 180
	mov [color], 10
	mov [SizeOfLineY], 20
	mov cx, 39
	call drawColoredRect
	call makeSound
	mov [x], 120
	mov [y], 180
	mov [color], 15
	mov [SizeOfLineY], 20
	mov cx, 39
	call drawColoredRect
	jmp continue

	;this next 19 lines do the same effect like the last 19 lines
checkFDiez:
	cmp al, 103
	jne checkG
playFDiez:
	push [noteFDiez]
	mov [x], 152
	mov [y], 70
	mov [color], 10
	mov [SizeOfLineY], 15
	mov cx, 19
	call drawColoredRect
	call makeSound
	mov [x], 152
	mov [y], 70
	mov [color], 0
	mov [SizeOfLineY], 15
	mov cx, 19
	call drawColoredRect
	jmp continue
	
	;this next 19 lines do the same effect like the last 19 lines
checkG:
	cmp al, 98
	jne checkGDiez
playG:
	push [noteG]
	mov [x], 160
	mov [y], 180
	mov [color], 10
	mov [SizeOfLineY], 20
	mov cx, 39
	call drawColoredRect
	call makeSound
	mov [x], 160
	mov [y], 180
	mov [color], 15
	mov [SizeOfLineY], 20
	mov cx, 39
	call drawColoredRect
	jmp continue
	
	;this next 19 lines do the same effect like the last 19 lines
checkGDiez:
	cmp al, 104
	jne checkA
playGDiez:
	push [noteGDiez]
	mov [x], 192
	mov [y], 70
	mov [color], 10
	mov [SizeOfLineY], 15
	mov cx, 19
	call drawColoredRect
	call makeSound
	mov [x], 192
	mov [y], 70
	mov [color], 0
	mov [SizeOfLineY], 15
	mov cx, 19
	call drawColoredRect
	jmp continue
	
	;because the computer can not jump to far way, I did that he jump for several short ways
jumpToStart2:
	jmp jumpToStart3
	
	;this next 19 lines do the same effect like the last 19 lines
checkA:
	cmp al, 110
	jne checkADiez
playA:
	push [noteA]
	mov [x], 200
	mov [y], 180
	mov [color], 10
	mov [SizeOfLineY], 20
	mov cx, 39
	call drawColoredRect
	call makeSound
	mov [x], 200
	mov [y], 180
	mov [color], 15
	mov [SizeOfLineY], 20
	mov cx, 39
	call drawColoredRect
	jmp continue
	
	;this next 19 lines do the same effect like the last 19 lines
checkADiez:
	cmp al, 106
	jne checkB
playADiez:
	push [noteADiez]
	mov [x], 232
	mov [y], 70
	mov [color], 10
	mov [SizeOfLineY], 15
	mov cx, 19
	call drawColoredRect
	call makeSound
	mov [x], 232
	mov [y], 70
	mov [color], 0
	mov [SizeOfLineY], 15
	mov cx, 19
	call drawColoredRect
	jmp continue
	
	;because the computer can not jump to far way, I did that he jump for several short ways
jumpToStart1:
	jmp jumpToStart2
	
	;this next 19 lines do the same effect like the last 19 lines
checkB:
	cmp al, 109
	jne checkC2
playB:
	push [noteB]
	mov [x], 240
	mov [y], 180
	mov [color], 10
	mov [SizeOfLineY], 20
	mov cx, 39
	call drawColoredRect
	call makeSound
	mov [x], 240
	mov [y], 180
	mov [color], 15
	mov [SizeOfLineY], 20
	mov cx, 39
	call drawColoredRect
	jmp continue
jumpToStart:
	jmp jumpToStart1
	
	;this next 19 lines do the same effect like the last 19 lines
checkC2:
	cmp al, 44
	jne continue
playC2:
	push [noteC2]
	mov [x], 280
	mov [y], 180
	mov [color], 10
	mov [SizeOfLineY], 20
	mov cx, 40
	call drawColoredRect
	call makeSound
	mov [x], 280
	mov [y], 180
	mov [color], 15
	mov [SizeOfLineY], 20
	mov cx, 40
	call drawColoredRect
	jmp continue
	
	;check if the char is not escape, if yes exit the program if not exit the loop and function 
continue:
	cmp al, 27
	jne jumpToStart
	
	;return to the function that called this function
	push [address]
	ret
	
endp play

	
start:

	mov ax, @data
	mov ds, ax
	
	;new line
	mov dl, 10
	mov ah, 2
	int 21h
	
	;print the first massage to the user
	mov dx, offset massageToUser1
	mov ah, 9
	int 21h
	
	;carriage return
	mov dl, 10
	mov ah, 2
	int 21h
	;new line
	mov dl, 13
	mov ah, 2
	int 21h
	
	;print the second massage to the user
	mov dx, offset massageToUser2
	mov ah, 9
	int 21h
	
	;carriage return
	mov dl, 10
	mov ah, 2
	int 21h
	;new line
	mov dl, 13
	mov ah, 2
	int 21h
	
	;print the third massage to the user
	mov dx, offset massageToUser3
	mov ah, 9
	int 21h
	
	;the user enter a char
	mov ah, 1
	int 21h
	
	
	; Graphic mode
	mov ax, 13h
	int 10h

	;call all the grafic functions 
	call WhiteScreen
	call TouchPoint
	call printRects
	
	;call to the main function that make sounds
	call play
	
	
	; Return to text mode
	mov ah, 0
	mov al, 2
	int 10h

exit:
	mov ax, 4c00h
	int 21h
END start