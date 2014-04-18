;************************************************************************** 
;	Pareja 3
;	Víctor de Juan Sanz y Guillermo Julián Moreno
;************************************************************************** 

DATOS SEGMENT 
	BUF DB 80 DUP('$')
	HEXDEC DB 1BH, "Escribe cadena para convertir $"
DATOS ENDS 

PILA SEGMENT STACK "STACK" 
	DB 40H DUP (0) ;ejemplo de inicialización, 64 bytes inicializados a 0 
PILA ENDS 


CODE SEGMENT 
	ASSUME CS: CODE, DS: DATOS, SS: PILA 
START PROC
	MOV AH, 9
	MOV DX, OFFSET HEXDEC
	INT 21H

	MOV AH,0AH			
	MOV DX, OFFSET BUF
	MOV BUF[0], 80		
	INT 21H

	MOV DX, OFFSET BUF
	MOV AH, 12H
	INT 60H

	MOV AH, 9
	MOV DX, OFFSET HEXDEC
	INT 21H

	MOV AH,0AH			
	MOV DX, OFFSET BUF
	MOV BUF[0], 80		
	INT 21H

	MOV DX, OFFSET BUF
	MOV AH, 13H
	INT 60H
START ENDP 

CODE ENDS
END START
