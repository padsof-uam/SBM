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
	PUSH DX DI
	
	; Segment y offset del puntero.
	MOV DI,[BP+6]
	MOV AX,[BP+8]
	; Inicializamos el segmento de datos al segment que nos dan.
	PUSH DS
	MOV DS,AX

	; El numero a convertir.
	MOV DX,[BP+10]
	
	; Una vez tenemos los argumentos empezamos:
	MOV CX,4H
	MOV BX, 000FH
	MOV AX,DI
main:
	AND BX,DX
	ADD BX,'0'
	MOV [DI],BX
	ADD DI,2H
	MOV BX, 000FH
	SHL BX,CL
	SHL CX,CL
	CMP BX,0F000H
	JNZ main
	;ponemos en el final el 0 (fin de cadena de C)
	MOV [DI],0H

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

PUBLIC _calculaLetraDNI
_calculaLetraDNI PROC FAR
	
	PUSH BP
	MOV BP,SP

	POP BP
	RET

ENDP _calculaLetraDNI



CODE ENDS
END START
