;************************************************************************** 

; ESTRUCTURA BÁSICA DE UN PROGRAMA EN ENSAMBLADOR 

;************************************************************************** 

; DEFINICION DEL SEGMENTO DE DATOS 

DATOS SEGMENT 

MATRIZ DB 9 DUP (1)

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
	; INICIALIZA LOS REGISTROS DE SEGMENTO CON SU VALOR

	MOV AX, DATOS
	MOV DS, AX
	MOV AX, PILA
	MOV SS, AX
	MOV AX, EXTRA
	MOV ES, AX
	MOV SP, 64 ; CARGA EL PUNTERO DE PILA CON EL VALOR MAS ALTO

	MOV DI, 0H
	CALL DT_DIAG
START ENDP 

DT_DIAG PROC NEAR
	MOV AX, 1H
	MOV SI, 0H

DT_DIAG_LOOP:
	MOV BL, MATRIZ[DI]

	MUL BL
	ADD DI, 4H

;; Módulo 9	
	PUSH AX
	MOV AX, DI
	MOV DX, 9H
	DIV DX
	MOV DX, DI
	POP AX
;; Módulo 9 fin

	INC SI
	CMP SI, 3H
	JNE DT_DIAG_LOOP

	RET
DT_DIAG ENDP

MD PROC NEAR
	

CODE ENDS
END START
