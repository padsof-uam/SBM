;************************************************************************** 
;Víctor de Juan Sanz y Guillermo Julián Moreno
;************************************************************************** 

; DEFINICION DEL SEGMENTO DE DATOS 
DATOS SEGMENT 
	DNI DB "T","R","W","A","G","M","Y","F","P","D","X","B","N","J","Z","S","Q","V","H","L","C","K","E"
DATOS ENDS 

;************************************************************************** 
; DEFINICION DEL SEGMENTO DE PILA 
PILA SEGMENT STACK "STACK" 
	DB 40H DUP (0) ;ejemplo de inicialización, 64 bytes inicializados a 0 
PILA ENDS 

;************************************************************************** 
; DEFINICION DEL SEGMENTO EXTRA 

EXTRA SEGMENT 
	RESULT DW 0,0 ;ejemplo de inicialización. 2 PALABRAS (4 BYTES) 
EXTRA ENDS 

;************************************************************************** 
; DEFINICION DEL SEGMENTO DE CODIGO 

CODE SEGMENT 
	ASSUME CS: CODE, DS: DATOS, ES: EXTRA, SS: PILA 
START PROC


	MOV AX, 4C00H 
    INT 21H 

START ENDP 


PUBLIC _enteroACadenaHexa
_enteroACadenaHexa PROC FAR
	
	PUSH BP
	MOV BP,SP
	PUSH DX DI
	
	; Offset del puntero en el que guardar el resultado.
	MOV DI,[BP+8]
	; Segment del puntero en el que guardar el resultado.
	MOV AX,[BP+10]
	; Inicializamos el segmento de datos al segment que nos dan. 	
	PUSH DS
	MOV DS,AX

	; El numero a convertir.
	MOV DX,[BP+6]
	
	; Una vez tenemos los argumentos empezamos:
	MOV CX,4H
	MOV BX, 000FH
	ADD DI,5h
	MOV [DI],BYTE PTR 0H
	DEC DI

main:
	AND BX,DX
	CMP BL,0Ah
	JS no_letter
	ADD BL,'A'-'0'-10
no_letter:
	ADD BL,'0'
	MOV [DI],BL
	DEC DI
	MOV BX, 000FH
	SHR DX,CL
	CMP DX,0h
	JNZ main
	;ponemos en el final el 0 (fin de cadena de C)

fill_zeros:
	MOV [DI],BYTE PTR '0'
	DEC DI
	JNZ fill_zeros

	POP DS
	POP DI DX
	POP BP
	RET

ENDP _enteroACadenaHexa

PUBLIC _calculaChecksum
_calculaChecksum PROC FAR
	
	PUSH BP
	MOV BP,SP

	POP BP
	RET

ENDP _calculaChecksum


;void calculaLetraDNI(char* inStr, char* letra)

PUBLIC _calculaLetraDNI
_calculaLetraDNI PROC FAR
	
	PUSH BP
	MOV BP,SP

	PUSH AX BX CX DI 
	
	; Offset del puntero en el que guardar el resultado.
	;MOV DI,[BP+10]
	
	; Segment del puntero en el que guardar el resultado.
	MOV AX,[BP+12]
	; Inicializamos el segmento de datos al segment que nos dan. 	
	PUSH ES
	MOV ES,AX
	
	; Offset del puntero donde está el número.
	MOV DI,[BP+6]
	MOV SI,DI
	ADD SI,8h
	
	; Segment del puntero donde está el número.
	MOV AX,[BP+8]
	
	; Inicializamos el segmento de datos al segment que nos dan. 	
	PUSH DS
	MOV DS,AX


	; En DS leemos y en ES escribimos el resultado.
	MOV BX,0h
	MOV DL,23
	MOV BL, DS:[DI]
	SUB BL,'0'
	INC DI

LeerDNI:
; [((0 * 10) + 5 )%23] * 10 + 3 ]
; mod(mod(mod(mod(mod(mod(53,23)*10+1,23)*10+2,23)*10+8,23)*10+3,23)*10+6,23)
; Esta forma de pensar sale bien.
	MOV AX,10
	MUL BL
	; Tenemos AX = 0*10
	ADD AL, DS:[DI]
	SUB AL,'0'
	; Tenemos AX = 0*10+5

	;modulo 23 en cada iteración
	DIV DL
	MOV AL,AH
	XOR AH,AH

	; Tenemos AX = (0*10+5)%23
	MOV BL,AL
	INC DI
	CMP DI,SI
	JNZ LeerDNI

	; Tenemos el número en CX
suvieja:
	MOV AX,BX
	DIV DL
	MOV AL,AH
	XOR AH,AH
	; Dejamos el resultado en AX
	
	MOV DI,AX

	MOV AX,DATOS
	MOV DS,AX

	MOV CL,DNI[DI]


	MOV DI,[BP+10]
	MOV ES:[DI],CL
	INC DI
	MOV ES:[DI],byte ptr 0H

	AND [SI],BX
	POP DS
	POP ES
	POP DI CX BX AX 
	POP BP
	RET

ENDP _calculaLetraDNI



PUBLIC _calculaChecksum
_calculaChecksum PROC FAR
	PUSH BP
	MOV BP,SP
	PUSH BX CX DI

	MOV CX, [BP + 8]
	MOV DI, [BP + 6]
	MOV AX,0
	MOV DS, CX
CHECKSUM_LOOP:
	MOV BX, [DI]
	ADD AX, BX
	CMP BX, 0H
	INC DI
	JNZ CHECKSUM_LOOP

	MOV BX, 0100H
	SUB BX, AX
	MOV BX, AX
	XOR AH, AH	
	MOV CX, [BP + 8]
	MOV DI, [BP + 6]


	POP BP
	RET
ENDP _calculaChecksum
	

CODE ENDS
END START
