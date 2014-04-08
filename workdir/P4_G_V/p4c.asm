;************************************************************************** 
;	Pareja 3
;	Víctor de Juan Sanz y Guillermo Julián Moreno
;************************************************************************** 

DATOS SEGMENT 
	S1 DB "Cadena1",0
	S2 DB "AAadena1",0
DATOS ENDS 

PILA SEGMENT STACK "STACK" 
	DB 40H DUP (0) ;ejemplo de inicialización, 64 bytes inicializados a 0 

PILA ENDS 

EXTRA SEGMENT 
EXTRA ENDS 


CODE SEGMENT 
	ASSUME CS: CODE, DS: DATOS, ES: EXTRA, SS: PILA 

START PROC
	MOV AX, DATOS
	MOV DS, AX
	MOV AX, PILA
	MOV SS, AX
	MOV AX, EXTRA
	MOV ES, AX
	MOV SP, 64 

	MOV SI, OFFSET S1
	MOV DI, OFFSET S2
	CALL SCMP

	MOV SI, OFFSET S2
	MOV DI, OFFSET S2
	CALL SCMP
START ENDP 

SCMP PROC
	; Recibe: 	SI, offset primera cadena.
	; 			DI, offset segunda cadena.
	; Devuelve: AX, 1 si son iguales, 0 si no.
	PUSH BP
	MOV BP,SP
	PUSH BX

SCMP_LOOP:
	MOV AL, [SI]
	MOV BL, [DI]

	CMP AX, BX
	JNZ SCMP_NOT_EQUAL

	INC SI
	INC DI

	CMP BX, 0H
	JNZ SCMP_LOOP ; No hemos llegado al final de la cadena, volvemos al bucle.
	MOV AX, 1H
	JMP SCMP_END

SCMP_NOT_EQUAL:
	MOV AX, 0	
SCMP_END:
	POP BX 
	POP BP
	RET
SCMP ENDP

CODE ENDS
END START
