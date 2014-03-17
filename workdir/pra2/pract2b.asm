;************************************************************************** 

; ESTRUCTURA BÁSICA DE UN PROGRAMA EN ENSAMBLADOR 

;************************************************************************** 

; DEFINICION DEL SEGMENTO DE DATOS 

DIR equ 50H * 4

DATOS SEGMENT 
	MATRIZ DB -3,-2,-3,0,-6,-2,10,12,-1,"$"
	TEXTO_INI DB "La matriz 3x3 es:",0AH,"$"
	NUMSEP DB ", $"
	BUFFEREND DB "$"
	DET_RESULT DB 6 DUP (0),"$"
	TEXTO_FIN DB 0AH,"El determinante es:",0AH,"$"
	ASCII_BUFFER DB 10 DUP (0),"$"
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

	MOV AX, 0
	MOV ES, AX
	CLI
	MOV BX, OFFSET PRINT_WORDS 
	MOV ES:[DIR], BX
	MOV BX, CODE
	MOV ES:[DIR + 2], BX
	STI

	MOV AH,9H
	MOV DX,OFFSET TEXTO_INI
	INT 21H

	MOV DI, 0H
MATRIZ_PR_LOOP:	
	MOV BL, MATRIZ[DI]
	CALL SEXT
	INT 50H
	MOV DX, AX
	MOV AH,9H
	INT 21H ; Imprimimos la cadena que nos haya devuelto la interrupción

	INC DI
	CMP DI, 9H
	JZ MATRIZ_PR_END
	
	; Imprimimos un separador si todavía no hemos acabado.
	MOV DX, OFFSET NUMSEP
	INT 21H
	JMP MATRIZ_PR_LOOP

MATRIZ_PR_END:

	MOV AH,9H
	MOV CL,CH
	XOR CH,CH
	MOV DX,OFFSET BUFFEREND
	SUB DX,CX
	INT 21H

	;; EMPIEZA EL CÁLCULO DE LA MATRIZ.
	MOV DI, 0H
	MOV SI, 0H

	MOV CX,4H
	XOR AX, AX
	XOR BX, BX
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

	;;	YA HEMOS CALCULADO EL DETERMINANTE.  
	;;	Tenemos el resultado en BX. Ahora vamos a imprimirlo.

	;;IMPRIMIMOS EL TEXTO.
	MOV AH,9H
	MOV DX, OFFSET TEXTO_FIN
	INT 21H


	;; Convertimos el valor de BX a ASCII e imprimimos.
	INT 50H
	MOV DX, AX
	MOV AH, 9H
	INT 21H

	MOV AX, 4C00H 
    INT 21H 

START ENDP 











;;;;;;;;;;;;;; CALCULO PRODUCTO DIAGONAL ;;;;;;;;;;;;;;;;;;;;;;;;;;
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;PRINT PROCEDURE;;;;;;;;;;;;;;;;;;;;;;
PRINT_BYTES PROC NEAR
;; Parámetros: 
;	IN: 	BX:		El offset de donde está el valor.
;			SI: 	El offset de la última posición en la que se empieza a escribir.
;			DI: 	El número de caracteres a imprimir.
;
;	OUT:	Almacena en [SI] los bytes ASCII de los caracteres del número.
;	
;	USES: AX,BX,CL,CH,DL,DI,SI 
	MOV DL,1H
	XOR CH,CH
	MOV CL,0AH
MAIN_BYTE:
	MOV AL,[BX+DI-1]
	MOV AH,AL
	AND AH,80H
	JZ  NEG_CORRECTED_BYTE
	NEG AL
	MOV DL,0H
NEG_CORRECTED_BYTE:
CONVERT_BYTE:
    XOR AH,AH
	DIV CL
	ADD AH,'0'
	DEC SI
	MOV [SI],AH
	INC CH
	AND AL, AL
	JNZ CONVERT_BYTE
	CMP DL,0H
	JNZ NO_MINUS_BYTE
	MOV DL,1H
	INC DL
	INC CH
	DEC SI
	MOV [SI],BYTE PTR '-'
NO_MINUS_BYTE:	
	DEC DI
	JZ LAST_BYTE

	DEC SI
	INC CH
	MOV [SI],BYTE PTR ','
LAST_BYTE:
	CMP DI,0H
	JNZ MAIN_BYTE
	RET
PRINT_BYTES ENDP



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;PRINT PROCEDURE;;;;;;;;;;;;;;;;;;;;;;
PRINT_WORDS PROC NEAR
;; Parámetros: 
;	IN: 	BX:		Número a convertir
;
;	OUT:	BX: 	Número de caracteres ASCII obtenidos.
;			DX:AX 	Segmento:offset de la cadena
;	
;	USES: AX,BX,CL,CH,DL,DI,SI 
	MOV DL,1H
	MOV CL,0AH
	MOV SI,0AH
	MOV AX, BX
	XOR BX, BX
	ADD AX, 0H
	JS NEG_CORRECTED
	JMP CONVERT
NEG_CORRECTED:
	MOV DL,0H
	NEG AX
CONVERT:
    XOR AH,AH
	DIV CL
	ADD AH,'0'
	DEC SI
	MOV ASCII_BUFFER[SI],AH
	INC BX
	AND AL, AL
	JNZ CONVERT
	AND SI, SI
	JZ LAST
	CMP DL,0H
	JNZ NO_MINUS
	MOV DL,1H
	INC DL
	INC BX
	DEC SI
	MOV ASCII_BUFFER[SI],BYTE PTR '-'
NO_MINUS:	
LAST:
	MOV DX, SEG ASCII_BUFFER
	MOV AX, OFFSET ASCII_BUFFER
	ADD AX, SI
	RET
PRINT_WORDS ENDP

SEXT PROC NEAR
; IN -> BL. Out -> BL extendido en signo en BL.
	AND BL, BL
	JS SEXT_IS_NEGATIVE
	MOV BH, 00H
	RET
SEXT_IS_NEGATIVE:
	MOV BH, 0FFH
	RET
SEXT ENDP


CODE ENDS
END START
