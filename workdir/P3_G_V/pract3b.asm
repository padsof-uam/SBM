;************************************************************************** 
;Víctor de Juan Sanz y Guillermo Julián Moreno
;************************************************************************** 

; DEFINICION DEL SEGMENTO DE DATOS 
DATOS SEGMENT 
	;; TABLA DE LETRAS PARA EL DNI
	DNI DB "T","R","W","A","G","M","Y","F","P","D","X","B","N","J","Z","S","Q","V","H","L","C","K","E"
DATOS ENDS 

CODE SEGMENT BYTE PUBLIC 'CODE'
	ASSUME CS: CODE, DS: DATOS

START PROC
START ENDP

;;; DEVUELVE UN CHAR* CON LA CADENA DONDE ESTA EL ENTERO ESCRITO EN HEXADECIMAL (EN ASCII)
PUBLIC _enteroACadenaHexa
_enteroACadenaHexa PROC FAR
	
	PUSH BP
	MOV BP,SP
	PUSH DX DI
	
	;; Offset del puntero en el que guardar el resultado.
	MOV DI,[BP+8]
	;; Segment del puntero en el que guardar el resultado.
	MOV AX,[BP+10]
	;; Inicializamos el segmento de datos al segmento que nos dan. 	
	PUSH DS
	MOV DS,AX

	; El numero a convertir.
	MOV DX,[BP+6]
	
	; Una vez tenemos los argumentos empezamos:
	MOV CX,4H
	MOV BX, 000FH
	ADD DI,5h
	
	;ponemos en el final el 0 (fin de cadena de C)
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

	;; RELLENAMOS LA CADENA CON 0'S EN LA IZQUIERDA (PARA NO IMPRIMIR LO QUE HUBIERA EN LA MEMORIA)
fill_zeros:
	MOV [DI],BYTE PTR '0'
	DEC DI
	JNZ fill_zeros

	POP DS
	POP DI DX
	POP BP
	RET

ENDP _enteroACadenaHexa


;;; CALCULA LA LETRA DE UN DNI PASADO COMO CHAR *.
PUBLIC _calculaLetraDNI
_calculaLetraDNI PROC FAR
	
	PUSH BP
	MOV BP,SP

	PUSH AX BX CX DI 
	
	;; Segment del puntero en el que guardar el resultado.
	MOV AX,[BP+12]
	;; Inicializamos el segmento de extra al segment que nos dan. 	
	PUSH ES
	MOV ES,AX
	
	;; Offset del puntero donde está el número.
	MOV DI,[BP+6]
	;; Inicializamos los contadores.
	MOV SI,DI
	ADD SI,8h
	
	;; Segment del puntero donde está el número.
	MOV AX,[BP+8]
	
	;; Inicializamos el segmento de datos al segmento que nos dan. 	
	PUSH DS
	MOV DS,AX


	;; En DS leemos y en ES escribimos el resultado.

	MOV BX,0h ;; Marcamos con 0 el final de la cadena (centinela de C).
	MOV DL,23
	MOV BL, DS:[DI]
	SUB BL,'0'
	INC DI

LeerDNI:
	;; Si el DNI empieza por 053... Realizamos este calculo:
	; [((0 * 10) + 5 )%23] * 10 + 3 ]%23
	MOV AX,10
	MUL BL
	;; Tenemos AX = 0*10
	ADD AL, DS:[DI]
	SUB AL,'0'
	;; Tenemos AX = 0*10+5

	;;modulo 23 en cada iteración
	DIV DL
	MOV AL,AH
	XOR AH,AH

	;; Tenemos AX = (0*10+5)%23
	MOV BL,AL
	INC DI
	CMP DI,SI
	JNZ LeerDNI

	;; Tenemos el número en CX
	MOV AX,BX
	DIV DL
	MOV AL,AH
	XOR AH,AH
	
	;; Dejamos el resultado final en AX y lo almacenamos en DI para poder 
	; utilizarlo como indice de la tabla de letras.
	MOV DI,AX

	;; Inicializamos el segmento de datos para poder leer la tabla de letras.
	MOV AX,DATOS
	MOV DS,AX
	MOV CL,DNI[DI]


	MOV DI,[BP+10]
	MOV ES:[DI],CL 
	INC DI
	MOV ES:[DI],byte ptr 0H ; Marcamos el fin de cadena de C.

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

	; Guardamos el array de bytes.
	MOV BX, [BP + 8]
	MOV DI, [BP + 6]
	MOV AX,0
	MOV CX,0

	PUSH DS
	MOV DS, BX
CHECKSUM_LOOP:
	MOV CL, [DI] ; Cargamos el byte del array
	ADD AX, CX   ; 	y sumamos al acumulador.
	INC DI    
	CMP CX, 0H   ; Si es cero, paramos.
	JNZ CHECKSUM_LOOP

	MOV CX, 0100H 
	XOR AH, AH   ; Nos quitamos los bytes más significativos.
	SUB CX, AX   ;  Restamos 100 - acumulador para obtener el checksum.
	MOV BX, [BP + 12]
	MOV DI, [BP + 10]

	MOV DS, BX 
	MOV [DI], CL 
	POP DS
	POP DI CX BX
	POP BP
	RET
ENDP _calculaChecksum

CODE ENDS
END START
