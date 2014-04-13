;************************************************************************** 
;	Pareja 3
;	Víctor de Juan Sanz y Guillermo Julián Moreno
;************************************************************************** 

CODIGO SEGMENT 
	ASSUME CS: CODIGO
	ORG 256
inicio:
	jmp real_inicio
;; Definicion de variables globales
	tabla DB 'abcdf'
	flag DW 0
	AUTORES DB "Víctor de Juan Sanz y Guillermo Julián Moreno","$"
	USO DB "Ejecuta el programa con /I para instalar",0AH,"Ejecuta el programa con /D para instalar",0Ah,"$"
	ESTADO DB "El estado del driver es: ","$"
	INSTALADO DB "instalado","$"
	DESINSTALADO DB "desinstalado","$"
	BUFFER DB 15 dup ("$")
	END_BUFFER DB 0Ah,"$"
	DECIMAL DW 167
	HEXADECIMAL DW 0FEDCh

real_inicio:
	MOV AX,0
	;; Buscamos la I
	MOV DL,'I'
	call HAS_ARG
	cmp AX,1
	jz install

	MOV DL,'D'
	call HAS_ARG
	cmp AX,1
	jz uninstall

help:
	PUSH DS
	MOV AX,CS
	MOV DS,AX
	MOV AH,9h
	MOV DX,OFFSET USO
	INT 21h
	POP DS
	jmp fin_main

install:
	;call instalador
	PUSH DS
	MOV AX,CS
	MOV DS,AX
	MOV AH,9h
	MOV DX,OFFSET INSTALADO
	INT 21h
	POP DS
	jmp fin_main

uninstall:
	PUSH DS
	MOV AX,CS
	MOV DS,AX
	MOV AH,9h
	MOV DX,OFFSET DESINSTALADO
	INT 21h
	POP DS
	;call desinstalador
	jmp fin_main

fin_main:

	PUSH DS
	MOV AX,CS
	MOV DS,AX
	MOV DX,OFFSET DECIMAL
	MOV AH,12
	call routine
	
	MOV DX, OFFSET HEXADECIMAL
	MOV AH,13
	call routine

	POP DS
	MOV AX, 4C00H 
    INT 21H 


;; Rutina de servicio a la interrupción
routine PROC 
	
	;; Salva registros modificados
	push BX

	cmp AH,12
	jz dectohex

	cmp AH,13
	jz hextodec

	jmp fin
	;; Recupera registros modificados
dectohex:

	MOV CX,10H
	MOV BX,DX
	MOV SI,OFFSET END_BUFFER
	MOV DI, 1h

	call CONVERT2BASE

	jmp fin
hextodec:

	MOV BX,DX
	MOV SI,OFFSET END_BUFFER
	MOV DI, 1h
	MOV CX,0AH


	call CONVERT2BASE

	;jmp fin
fin:
	MOV AH,9
	MOV DX,SI
	INT 21H

	pop BX
	ret
routine ENDP


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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;PRINT PROCEDURE;;;;;;;;;;;;;;;;;;;;;;
CONVERT2BASE PROC NEAR
;; Parámetros: 
;	IN: 	BX:		El offset de donde está el valor.
;			SI: 	El offset de la última posición en la que se empieza a escribir.
;			DI: 	El número de caracteres a imprimir.
;			CX: 	La base a la que convertir.
;
;	OUT:	Almacena en DS:[SI] los bytes ASCII de los caracteres del número.
;	
;	USES: AX,BX,CL,CH,DL,DI,SI 
MAIN:
	MOV AX,[BX+DI-1]
CONVERT:
	XOR DX,DX
	DIV CX
	;; El resto que es lo que nos interesa está en AX.
	;	Nos quedamos con 1 byte para pasarlo a ASCII.
    XOR DH,DH
	ADD DL,'0'
	;; Procedemos a corregir si es una letra:
    CMP DL,'9'
    JBE STORE
    ADD DL,'A'-'0'-10
STORE:	;; Lo escribimos en memoria.
	DEC SI
	MOV [SI],DL
	CMP AX, 0h
	JNZ CONVERT
	DEC DI
LAST:
	CMP DI,0H
	JNZ MAIN
	RET
CONVERT2BASE ENDP


; Recibe en DX el carácter a buscar.
; Devuelve en AX 1 si ha encontrado el parámetro, 0 si no.
HAS_ARG PROC
	PUSH BP
	MOV BP,SP
	PUSH BX CX

	MOV SI, 80H
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
