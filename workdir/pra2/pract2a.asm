;************************************************************************** 

; ESTRUCTURA BÁSICA DE UN PROGRAMA EN ENSAMBLADOR 

;************************************************************************** 

; DEFINICION DEL SEGMENTO DE DATOS 

DATOS SEGMENT 

MATRIZ DB 9 DUP (0)

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
START ENDP 

DT_R  PROC NEAR
	; Entradas:
	; 	Ninguna.
	; Salidas:
	; 	Determinante: 	BX
	MOV DI, 2H
	XOR BX, BX
	MOV CH, 1

DT_R_L1:
	MOV DX, DI
	MOV CL, DL
	CALL DT_SR
	ADD BX, AX

	DEC DI
	JNE DT_R_L1

	CMP CH, -1H
	JE DT_END

	MOV DI, 2H
	MOV CH, -1H
	JMP DT_R_L1

DT_END:
	RET
DT_R ENDP

DT_SR PROC NEAR 
	; Entradas:
	; 	Contador columna: 		BX
	; 	Tipo de producto: 		CX
	; Salidas:
	; 	Producto "diagonal": 	AX
	MOV AX, 1H ; Inicializamos producto = 1 en AX
	MOV SI, 0H ; Primera fila

IR: 
	MOV AX, SI
	MOV DX, 3
	MUL DX
	ADD DX, BX
	MOV SI, DX

	POP AX
	XOR DH, DH
	MOV DL,MATRIZ[SI]
	MUL DX
	PUSH AX    ; Guardamos AX para no sobreescribir.

	; Adición módulo tres al contador de columna.
	ADD BX, CX ; Sumamos type en el contador de columna.
	ADD AX, BX ; Guardamos en AX el valor de contador de columna.
	ADD AX, 3  ; Sumamos tres a AX para evitar el caso en el que sea negativo.
	MOV DX, 3 	
	DIV DX	   ; Dividimos el contador de columna (al que hemos sumado tres) por tres.
	MOV CL, AL ; En AL está el resto de la división, es decir, CL módulo 3.
	XOR CH, CH ; El valor de CL módulo 3 será siempre positivo, los bytes más significativos son 0.
	; Fin adición módulo tres.

	INC SI     ; Incrementados el contador de fila.
	CMP SI, 3H ; Miramos si es igual a 3.
	JNE IR     ; Si no hemos llegado al final del bucle, reiteramos.
	; Fin bucle.

	IMUL CH ; Multiplicamos el resultado por +1 ó -1 según sea el orden de multiplicación.

	RET
DT_SR ENDP 

CODE ENDS
END START
