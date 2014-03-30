;************************************************************************** 
;Víctor de Juan Sanz y Guillermo Julián Moreno
;************************************************************************** 

; DEFINICION DEL SEGMENTO DE DATOS 
DATOS SEGMENT 
;-- rellenar con los datos solicitados 
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

	POP BP
	RET

ENDP _enteroACadenaHexa

PUBLIC _calculaLetraDNI
_calculaLetraDNI PROC FAR
	
	PUSH BP
	MOV BP,SP

	POP BP
	RET

ENDP _calculaLetraDNI

PRINT_BYTES PROC NEAR
;; Parámetros: 
;	IN: 	BX:		El offset de donde está el valor.
;			SI: 	El offset de la última posición en la que se empieza a escribir.
;			DI: 	El número de caracteres a imprimir.
;
;	OUT:	Almacena en [SI] los bytes ASCII de los caracteres del número.
;			CH guarda el número de caracteres escrito.
;	
;	USES: AX,BX,CL,CH,DL,DI,SI

	MOV BX,0H
	MOV CX,0H



	AND [SI],BX


	RET
PRINT_BYTES ENDP


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
