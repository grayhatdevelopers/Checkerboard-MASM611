.MODEL SMALL
.STACK 100
.DATA

;	newline db 10,13,'$'
	number dw ?
	count db 0
	regdx dw 0
	blreg db 9

    STUDENTID DB "i180621C", '$'

    COLORARRAY DB 20 DUP (?)
    TEXTARRAY DB 20 DUP (0)
    GREEN DB 47
    BLUE DB 49
    RED DB 64
    WHITE DB 120
    BLACK DB 7

    PRESSEDKEY DB ?

    LP1CTR DB 5
    LP2CTR DB 4

    _CHAR DB 'C'
    COLUMN DB 5
    ROW DB 6

    X1 DB 1
    X2 DB 6
    Y1 DB 5
    Y2 DB 7


.CODE
main proc
     MOV AX, @DATA              
     MOV DS, AX




;initialize colorsarray AND textarray
    MOV SI, 0
    MOV BX, 0

    MOV BX, OFFSET COLORARRAY
    MOV SI, OFFSET TEXTARRAY
    MOV CX, 20


OnInit:

    MOV AX, 0
    MOV AL, GREEN
    MOV [BX], AL

    MOV AX, 0
    MOV AL, _CHAR
    MOV [SI], AL

    INC SI   
    INC BX

;checking to skip the 'l'
    CMP _CHAR, 'G'
    JNE NUMBERS

    MOV AL, '0'
    MOV _CHAR, '0'
    JMP NOINC
    
    NUMBERS:

        CMP _CHAR, '9'
        JNE LETTERS

    ;changes _char to the remaining letters
        MOV _CHAR, 'i'
        JMP NOINC
    LETTERS:  
        INC _CHAR
    NOINC:
        CMP _CHAR, 'l'
        JNE SKIP

        INC _CHAR

    SKIP:

    ;swapping
        MOV AH, GREEN
        MOV AL, BLUE
        MOV BLUE, AH
        MOV GREEN, AL
        LOOP OnInit
    JMP INITSTART


OnChanges:
    CLICKFUNC:
        MOV SI, 0
        MOV SI, OFFSET COLORARRAY
        MOV AX, 0
        MOV AL, BLACK
        MOV [SI], AL
        JMP MEMCLEAR
    PRESSFUNC:
        MOV CX, 0
        MOV SI, OFFSET TEXTARRAY
    PRESSLOOP:
        MOV AX,0
        MOV AL, PRESSEDKEY
        CMP AL, [SI]
        JE PRESSCLR
        INC SI
        INC CX
        CMP CX, 20
        JB PRESSLOOP
    
        JMP CheckClk
        PRESSCLR:
            MOV SI, OFFSET COLORARRAY
            ADD SI, CX
            MOV AX, 0
            MOV AL, RED
            MOV [SI], AL
            JMP MEMCLEAR
    


;clear registers and reinitialize values
MEMCLEAR:
    MOV AX, 0
    MOV BX, 0
    MOV CX, 0
    MOV DX, 0    
    
    MOV LP1CTR, 5
    MOV LP2CTR, 4

    MOV _CHAR, 'C'
    MOV COLUMN, 5
    MOV ROW, 6

    MOV X1, 2
    MOV X2, 7
    MOV Y1, 5
    MOV Y2, 7

INITSTART:

;clear screen
    MOV AL,03
    MOV AH,0
    INT 10H


    MOV DI, OFFSET COLORARRAY
    MOV SI, OFFSET TEXTARRAY

;prints the rows
OUTLOOP:

;resets values and the counter
    MOV X1, 2
    MOV X2, 7
    MOV LP1CTR, 5

;prints the columns
INLOOP:

;prints a box with color
     MOV AH,06H
     MOV AL,3          
     MOV BH,[DI]  
     MOV CH,y1          
     MOV CL,x1           
     MOV DH,y2         
     MOV DL,x2           
     INT 10H


     INC DI

;moves the cursor so we can print _char
    MOV AH,02h					
	MOV DH,ROW
	MOV DL,COLUMN
	MOV BH,0
	INT 10H
    
;prints the _char
	MOV AH,0AH
	MOV AL, [SI]
	MOV BH,0
	MOV CX,1
	int 10H

;moves the position forward for the next _char
	ADD COLUMN,6
	INC SI

;moving coordinates to next box
    ADD X1, 6H
    ADD X2, 6H

;inner loop ending condition
    DEC LP1CTR
    CMP LP1CTR, 0
    JNE INLOOP

;returning to outer loop... increasing row value so next boxes can be printed
    ADD Y1, 4
    ADD Y2, 4
    
;resets _char column value, increases row value
    MOV COLUMN,5
    ADD ROW,4

;outer loop ending condition + condition checking
    DEC LP2CTR

    





;checking terminating condition
_FINALEXIT:
    CMP LP2CTR, 0
    JNE OUTLOOP


CheckClk:


CheckClkReturn:
	mov ax,03
	int 33h
	mov regdx,dx
	mov blreg,bl
	mov number,cx
 
    
    
    MOV AH, 0H
    INT 16H
    JNZ CheckKey

	mov cx,0h
	mov dx,0ffffh
	mov ah,86h
	int 15h


	mov ax,01
	int 33h
	cmp blreg,1
    je OnChanges
	jne CheckClkReturn




CheckKey:
    CMP AL, 27
    JE Exxit
    MOV BX, 0
    MOV BX, '$'
    MOV PRESSEDKEY, AL
    MOV SI, OFFSET STUDENTID
    MOV CX, 9
CKLOOP:	
    CMP [SI], AL
    JE PRESSFUNC    
    CMP [SI], BX
    JE CheckClkReturn
    INC SI
    LOOP CKLOOP
JMP CheckClkReturn

Exxit:
	mov ax,4c00h
	int 21h	
main endp

;return control back to program
     MOV AH, 04CH
     INT 21H
     END

;end :)




