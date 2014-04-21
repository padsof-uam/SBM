;************************************************************************** 
;	Pareja 3
;	Víctor de Juan Sanz y Guillermo Julián Moreno
;************************************************************************** 

DATOS SEGMENT 
	BUFFER		DB 	80 DUP ('$')
	BUFFER_COPY DB	80 DUP ('$')
	DEC_STR 	DB	"dec",0
	TOPRINT		DB 	8 DUP ('$')
	END_BUFFER	DB	"$"
	QUIT_STR 	DB 	"quit",0
	INT_CALL_COUNT 	DW 	0
	INT_PARAMS	DW 0
	INDEX		DW 2
	FUNCIONO	DB "?$"
DATOS ENDS 

PILA SEGMENT STACK "STACK" 
	DB 40H DUP (0) ;ejemplo de inicialización, 64 bytes inicializados a 0 

PILA ENDS 

EXTRA SEGMENT 
EXTRA ENDS 


CODE SEGMENT 
	ASSUME CS: CODE, DS: DATOS, ES: EXTRA, SS: PILA 

EMPTY_ROUTINE PROC
	IRET
EMPTY_ROUTINE ENDP


START PROC
	MOV AX, DATOS
	MOV DS, AX
	MOV AX, PILA
	MOV SS, AX
	MOV AX, EXTRA
	MOV ES, AX
	MOV SP, 64 

READ_LOOP:
	MOV AX, 80
	MOV SI, OFFSET BUFFER
	CALL CLEAR_BUF

	MOV AH, 0AH			
	MOV DX, OFFSET BUFFER
	MOV BUFFER[0], 80	
	INT 21H			; Leemos la cadena

	MOV DI, OFFSET BUFFER + 1
	MOV DL,DS:[DI]
	XOR DH,DH
	MOV DI,DX
	MOV BUFFER[DI+2],0

	MOV SI, OFFSET BUFFER + 2
	MOV DI, OFFSET QUIT_STR
	CALL SCMP

	CMP AX, 1
	JE END_PROG

	MOV SI, OFFSET BUFFER + 2
	MOV DI, OFFSET DEC_STR
	CALL SCMP

	MOV INT_PARAMS, 12H
	MOV DI, OFFSET BUFFER ; Nos preparamos para convertir a hexa el buffer que nos pasan

	CMP AX, 1 ; Salvo que nos pidan hacerlo a decimal
	JNE PRINT

	MOV INT_PARAMS, 13H 	; Si nos piden que pasemos a decimal, cambiamos el parámetro
	MOV DI, OFFSET BUFFER_COPY	; 	y usamos el buffer anterior
	MOV DI,0
PRINT:
	CALL INSTALL_PERIODIC

	MOV SI, OFFSET BUFFER
	MOV DI, OFFSET BUFFER_COPY ; Nos guardamos una copia del buffer actual
	MOV AX, 80
	CALL COPYBUF


	JMP READ_LOOP
	
END_PROG:

	; Desinstalamos la interrupcion si salimos del programa.
	MOV AX, CODE
	MOV ES, AX
	MOV AX, OFFSET EMPTY_ROUTINE
	MOV BX, CS
	CLI
	MOV ES:[ 1CH*4 ], AX
	MOV ES:[ 1CH*4+2 ], BX
	STI

	mov dx, OFFSET START
	int 27h ; Acaba y deja residente el código de la rutina vacía,
	; descartando el codigo que no interesa (PSP, variables)

START ENDP 

INSTALL_PERIODIC PROC
	MOV AX, 0
	MOV ES, AX
	MOV AX, OFFSET PERIODIC
	MOV BX, CS
	CLI
	MOV ES:[ 1CH*4 ], AX
	MOV ES:[ 1CH*4+2 ], BX
	STI
	RET
INSTALL_PERIODIC ENDP

COPYBUF PROC
	; Recibe: 	SI, offset cadena origen.
	; 			DI, offset cadena destino.
	; 			AX, caracteres a copiar
	PUSH BP
	MOV BP,SP
	PUSH BX 

COPY_LOOP:
	MOV BX, DS:[SI]
	MOV DS:[DI], BX
	INC SI
	INC DI
	DEC AX
	JNZ COPY_LOOP


	POP BX
	POP BP
	RET
COPYBUF ENDP

CLEAR_BUF PROC
	; Recibe: 	SI: Offset de la cadena
	; 			AX: Caracteres a poner a '$'

	PUSH BX
	MOV BL, '$'
CLEAR_BUF_LOOP:
	MOV [SI], BL
	INC SI
	DEC AX
	JNZ CLEAR_BUF_LOOP

	POP BX
	RET
CLEAR_BUF ENDP

SCMP PROC
	; Recibe: 	SI, offset primera cadena.
	; 			DI, offset segunda cadena.
	; Devuelve: AX, 1 si son iguales, 0 si no.
	PUSH BP
	MOV BP,SP
	PUSH BX
	XOR AX,AX
	XOR BX,BX

SCMP_LOOP:
	MOV AL, [SI]
	MOV BL, [DI]

	CMP AX, BX
	JNZ SCMP_NOT_EQUAL

	INC SI
	INC DI

	CMP BX, 0h
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

;;; Recibe en DI el offset de la cadena a imprimir.
PERIODIC PROC
	; Sumamos 1 al temporizador y comprobamos si ha pasado 1 segundo aproximadamente.
	MOV BX, INT_CALL_COUNT
	INC BX
	MOV INT_CALL_COUNT, BX
	CMP BX, 18
	JNE PERIODIC_REAL_END

	MOV INT_CALL_COUNT,0h ; Reiniciamos el temporizador
	
	; Guardamos en toprint el valor a imprimir y llamamos a la interrupción.
;	MOV DI,INDEX
;	MOV BL, BYTE PTR BUFFER[DI]
;	CMP BL,'$'
;	JE PERIODIC_END

	;INC DI
	;XOR BH,BH
	;MOV AX,INT_PARAMS
	;MOV DX, OFFSET TOPRINT
	;MOV SI, OFFSET END_BUFFER
	;INT 60h
	; Imprimimos el resultado.
	;MOV DX,SI
	;MOV AH,9
	;INT 21H

	MOV DX, OFFSET FUNCIONO
	MOV AH,9
	INT 21H

	JMP PERIODIC_REAL_END

PERIODIC_REAL_END:
	
	RET
PERIODIC ENDP

CODE ENDS
END START
