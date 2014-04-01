;************************************************************************** 
;	Pareja 3
;	Víctor de Juan Sanz y Guillermo Julián Moreno
;************************************************************************** 

DATOS SEGMENT 
	AUTORES DB "Víctor de Juan Sanz y Guillermo Julián Moreno"
	USO DB "Ejecuta el programa con /I para instalar",0AH,"Ejecuta el programa con /D para instalar",0Ah
	ESTADO DB "El estado del driver es: "
	INSTALADO DB "instalado"
	DESINSTALADO DB "desinstalado"
DATOS ENDS 

PILA SEGMENT STACK "STACK" 
	DB 40H DUP (0) ;ejemplo de inicialización, 64 bytes inicializados a 0 
PILA ENDS 

EXTRA SEGMENT 
EXTRA ENDS 

CODIGO SEGMENT 
	ASSUME CS: CODIGO, DS: DATOS, SS: PILA 
	ORG 256 

inicio: jmp installer

;; Definicion de variables globales
	tabla DB 'abcdf'
	flag DW 0


;; Rutina de servicio a la interrupción
routine PROC FAR
	;; Salva registros modificados
	push BX

	;; Instrucciones de la rutina

	;; Recupera registros modificados
	pop BX
	iret
routine ENDP


instalador PROC
	mov ax, 0
	mov es, ax
	mov ax, OFFSET routine
	mov bx, cs
	cli
	mov es:[ 60h*4 ], ax
	mov es:[ 60h*4+2 ], bx
	sti
	mov dx, OFFSET instalador
	int 27h ; Acaba y deja residente descartando el codigo que no interesa.
	;; PSP, variables y rutina routine.
instalador ENDP

desinstalador PROC 
	;; Desinstala routine de INT 60h
	push ax bx cx ds es
	mov cx, 0
	mov ds, cx ; Segmento de vectores interrupción
	mov es, ds:[ 60h*4+2 ] ; Lee segmento de routine
	mov	bx, es:[ 2Ch ] ; Lee segmento de entorno del PSP de routine
	mov	ah, 49h 
	int	21h ; Libera segmento de routine (es)
	mov	es, bx
	int	21h ; Libera segmento de variables de entorno de routine
	;; Pone a cero vector de interrupción 60h
	cli
	mov	ds:[ 60h*4 ], cx ; cx = 0
	mov	ds:[ 60h*4+2 ], cx
	sti
	pop es ds cx bx ax
	ret
desinstalador ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;PRINT PROCEDURE;;;;;;;;;;;;;;;;;;;;;;
HEX_TO_DEC PROC NEAR
;; Parámetros: 
;	IN: 	BX:		El offset de donde está el valor.
;			SI: 	El offset de la última posición en la que se empieza a escribir.
;			DI: 	El número de caracteres a imprimir.
;
;	OUT:	Almacena en DS:[SI] los bytes ASCII de los caracteres del número.
;	
;	USES: AX,BX,CL,CH,DL,DI,SI 
	MOV DL,1H
	MOV CL,0AH
MAIN:
	MOV AX,[BX+DI-1]
	JS  NEG_CORRECTED
	NEG AX
	MOV DL,0H
NEG_CORRECTED:
CONVERT:
    XOR AH,AH
	DIV CL
	ADD AH,'0'
	DEC SI
	MOV [SI],AH
	INC CH
	AND AL, AL
	JNZ CONVERT_BYTE
	DEC DI
	JZ LAST_BYTE
	CMP DL,0H
	JNZ NO_MINUS
	MOV DL,1H
	INC DL
	INC CH
	DEC SI
	MOV [SI],BYTE PTR '-'
NO_MINUS:	
	DEC SI
	INC CH
	MOV [SI],BYTE PTR ','
LAST:
	CMP DI,0H
	JNZ MAIN
	RET
HEX_TO_DEC ENDP


; Recibe en DX el carácter a buscar.
; Devuelve en AX 1 si ha encontrado el parámetro, 0 si no.
HAS_ARG PROC
	PUSH BP
	MOV BP,SP
	PUSH BX CX

	MOV SI, 81H
	MOV BL, ES:[80H] ; Guardamos la longitud de los parámetros.
	ADD BL, 80H 	; En BX está la primera posición que no es la cadena de parámetros.
	MOV AX, 0 		; Inicializamos AX a 0.
	XOR BH, BH
AI_LOOP:
	CMP SI, BX
	JZ IST_END
	MOV CL, ES:[SI]
	INC SI
	CMP CL, '/'
	JNZ AI_LOOP 
	MOV CL, ES:[SI-2]
	CMP CL, ' '
	JNZ AI_LOOP ; Si el anterior carácter a la barra no es un espacio, nos vamos.
	; Tenemos algo como " /". Comprobamos el siguiente carácter
	MOV CL, ES:[SI]
	CMP CL, DL
	JNZ AI_LOOP 
	MOV AX, 1
	; Es igual al carácter que buscábamos. Comprobemos si tenemos algún carácter por detrás...
	MOV CL, ES:[SI+1]
	CMP CL, ' '
	JZ IST_END ; Un espacio nos vale
	CMP CL, 0DH
	JZ IST_END ; Un retorno de carro también
	MOV AX, 0
	JMP AI_LOOP ; Otras cosas no nos valen. Seguimos con el bucle.

IST_END:
	POP CX BX
	POP BP
	RET
HAS_ARG ENDP

CODIGO ENDS
END inicio
