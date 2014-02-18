;************************************************************************** 

; ESTRUCTURA BÁSICA DE UN PROGRAMA EN ENSAMBLADOR 

;************************************************************************** 

; DEFINICION DEL SEGMENTO DE DATOS 

DATOS SEGMENT 
CONTADOR DB 0
BEBA DW 0CAFEH
TABLA100 DB 100 DUP (0)
ERROR1 DB " Errores en el programa. Resultados incorrectos. "
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
	MOV AX,DATOS
	MOV DS,AX
	MOV BL,ERROR1[6]
	MOV TABLA100[63H],BL

	MOV BX, BEBA
	MOV WORD PTR TABLA100[23H],BX

	MOV CONTADOR, BL
	;MOV CX, OFFSET TABLA100+63H
	;MOV BX, DS:DX
CODE ENDS 

END START 
