;************************************************************************** 

; ESTRUCTURA BÁSICA DE UN PROGRAMA EN ENSAMBLADOR 

;************************************************************************** 

; DEFINICION DEL SEGMENTO DE DATOS 

DATOS SEGMENT 

MATRIZ DB 3,2,3,0,6,2,0,2,1,"$"

TEXTO_INI DB "La matriz es:",0AH,"$"
TEXTO_FIN DB "El determinante es:",0AH,"$"


DEC_RESULT DB 8 DUP(0)

BUFFEREND DB "$"

DATOS ENDS 

;************************************************************************** 

; DEFINICION DEL SEGMENTO DE PILA 

PILA SEGMENT STACK "STACK" 

DB 40H DUP (0) ;ejemplo de inicialización, 64 bytes inicializados a 0 

PILA ENDS 

;************************************************************************** 

; DEFINICION DEL SEGMENTO EXTRA 

EXTRA SEGMENT 

EXTRA ENDS 

;************************************************************************** 

; DEFINICION DEL SEGMENTO DE CODIGO 

CODE SEGMENT 
	ASSUME CS: CODE, DS: DATOS, ES: EXTRA, SS: PILA 

START PROC
	; INICIALIZA LOS REGISTROS DE SEGMENTO CON SU VALOR

	MOV AX, DATOS
	MOV DS, AX
	MOV AX, PILA
	MOV SS, AX
	MOV AX, EXTRA
	MOV ES, AX
	MOV SP, 64 ; CARGA EL PUNTERO DE PILA CON EL VALOR MAS ALTO

	MOV AH,9H
	MOV DX,OFFSET TEXTO_INI
	INT 21H

	MOV DX, OFFSET MATRIZ
	INT 21H


	;; Empieza el cálculo de la matriz.
	MOV DI, 0H
	MOV CX,4H


MAIN_LOOP_1:;; Bucle principal.
	;; Iteramos 3 veces (con SI como contador) para calcular el producto de las 3 diagonales "principales".
	PUSH BX
	PUSH SI
	CALL DT_DIAG
	;; Tenemos en AX el resultado del producto de la diagonal
	POP SI
	POP BX
	ADD BX,AX
	INC SI
	CMP SI,3H
	JNE MAIN_LOOP_1
	MOV SI,0H
	MOV CX,7H
MAIN_LOOP_2:
	;; Iteramos 3 veces con las diagonales "secundarias".
	PUSH BX
	PUSH SI
	CALL DT_DIAG
	;; Tenemos en AX el resultado del producto de la diagonal
	POP SI
	POP BX
	SUB BX,AX
	INC SI
	CMP SI,3H
	JNE MAIN_LOOP_2

	;; Tenemos el resultado en BX.

	MOV SI,OFFSET BUFFEREND
	MOV AX,BX

	CALL PRINT

	MOV AH,9H
	MOV DX, OFFSET TEXTO_FIN
	INT 21H
	MOV DX,OFFSET BUFFEREND
	SUB DX,DI
	INT 21H


	MOV AX, 4C00H 
    INT 21H 

START ENDP 

PRINT PROC NEAR
;; Parámetros: 
;	IN: 	AX:		El resultado hexadecimal a imprimir en decimal.
;			SI: 	El offset de la última posición en la que se empieza a escribir.
;
;	OUT:	Almacena en [SI] los bytes ASCII de los caracteres del número.
;			DI:		El número de bytes escritos
;	
;	No utiliza: DI,BX.
	
	MOV DI,0
CONVERT:
	MOV CX,0AH
    XOR DX,DX
	DIV CX
	ADD DL,'0'

	DEC SI
	MOV [SI],DL
	INC DI
	AND AX, AX
	JNZ CONVERT
	RET
PRINT ENDP


DT_DIAG PROC NEAR
	MOV AX, 1H
	MOV SI, 0H

DT_DIAG_LOOP:
	MOV BL, MATRIZ[DI]

	IMUL BL
	ADD DI, CX

;; Módulo 9	
	PUSH AX
	MOV AX, DI
	MOV DX, 9H
	DIV DL
	MOV DL,AH
	MOV DI,DX
	POP AX
;; Módulo 9 fin

	INC SI
	CMP SI, 3H

	JNE DT_DIAG_LOOP

	RET
DT_DIAG ENDP

CODE ENDS
END START
