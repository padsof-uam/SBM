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
	USO DB "Autores: Victor de Juan Sanz y Guillermo Julian Moreno",0AH,0AH,"Ejecuta el programa con /I para instalar",0AH,"Ejecuta el programa con /D para instalar",0Ah,"$"
	ESTADO_INS DB 0Ah,"El estado del driver es: instalado",0AH,"$"
	ESTADO_UNINS DB 0Ah,"El estado del driver es: desinstalado",0AH,"$"
	INSTALADO DB "Instalado",0AH,"$"
	DESINSTALADO DB "Desinstalado",0AH,"$"
	PRUEBAS DB	"Pruebas de la rutina (sin llamada a interrupcion): ", 0AH, "$"
	DECIMAL DB "13","$"
	HEXADECIMAL DB "F","$"
	BUFFER DB 15 dup ("$")
	END_BUFFER DB 0Ah,"$"

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

	;; Vamos a comprobar que esté instalado antes de nada.
	PUSH ES
	MOV AX,0
	MOV ES,AX
	MOV AX,	ES:[ 60h*4 ]
	MOV BX,	ES:[ 60h*4 + 2 ]
	POP ES
	AND AX,BX
	CMP AX,0
	JE UNINSTALLED

	PUSH DS
	MOV AX, CS
	MOV DS, AX
	MOV AH, 9h
	MOV DX,OFFSET ESTADO_INS
	INT 21h
	POP DS
	JMP END_INIC

UNINSTALLED:
	PUSH DS
	MOV AX, CS
	MOV DS, AX
	MOV AH, 9h
	MOV DX,OFFSET ESTADO_UNINS
	INT 21h
	POP DS
	JMP END_INIC

END_INIC:
	jmp fin_main

install:
	call instalador
	jmp fin_main

uninstall:
	call desinstalador
	jmp fin_main

fin_main:
;; PRUEBAS
;	PUSH DS
;	MOV AX,CS
;	MOV DS,AX
;	MOV AH,9h
;	MOV DX,OFFSET PRUEBAS
;	INT 21h
;	MOV DX, OFFSET HEXADECIMAL
;	MOV AH,13h
;	CALL routine
;	MOV DX,OFFSET DECIMAL
;	MOV AH,12h
;	CALL routine
;	POP DS
	
	MOV AX, 4C00H 
	INT 21H 


STAT PROC
	PUSH AX DX CX
	MOV CX, DS
	MOV AX,CS
	MOV DS,AX

	MOV DS, CX
	POP CX DX AX
	RET
STAT ENDP

;; Rutina de servicio a la interrupción
routine PROC 
	;; Salva registros modificados
	push SI BX CX

	MOV BX, DX ;; En DX está el offset de la cadena a convertir.

	cmp AH, 12H
	jz dectohex

	cmp AH, 13H
	jz hextodec

	jmp fin

dectohex:

	MOV CX,10
	CALL STRTOINT

	;; tenemos en BX el valor a convertir en ASCII imprimible.

	MOV SI, OFFSET END_BUFFER
	MOV CX, 10h
	CALL CONVERT2BASE

	MOV DL, 'h'
	MOV AH, 02H
	INT 21H

	jmp fin

hextodec:
	MOV CX,10h
	CALL STRTOINT

	MOV SI, OFFSET END_BUFFER
	MOV CX, 0AH
	call CONVERT2BASE

	MOV DL, 'O'
	MOV AH, 02H
	INT 21H

fin:
	; Escribimos un salto de linea.
	MOV DL, 0AH
	MOV AH, 02H
	INT 21H
	POP CX BX SI
	IRET
routine ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;PROCEDURES;;;;;;;;;;;;;;;;;;;;;;
CONVERT2BASE PROC NEAR
;; Parámetros: 
;	IN: 	AX:		El valor.
;			SI: 	El offset de la última posición en la que se empieza a escribir.
;			CX: 	La base a la que convertir.
;
;	OUT:	Imprime los bytes ASCII de los caracteres del número.
;	
;	USES: AX,BX,CL,CH,DL,SI 
	MOV BX,AX
	JMP SUBMAIN_CNV2B
MAIN_CNV2B:
	POP AX
	MOV BX,AX
SUBMAIN_CNV2B:
	XOR DX,DX
	DIV CX
	;; El resto de la division que es lo que nos interesa está en AX.
	;	Nos quedamos con 1 byte para pasarlo a ASCII.
    XOR DH,DH
	ADD DL,'0'
	;; Procedemos a corregir si es una letra:
    CMP DL,'9'
    JBE STORE
    ADD DL,'A'-'0'-10
STORE:
	CMP AX, 0h
	JNZ SUBMAIN_CNV2B

	; Imprimimos el carácter guardado en DL
	MOV AH, 02H
	INT 21H 		

	MOV AX,BX
	XOR DX,DX
	DIV CX
	PUSH DX
	CMP AX, 0h
	JNZ MAIN_CNV2B

	POP AX

	RET
CONVERT2BASE ENDP

STRTOINT PROC NEAR
;; Parámetros: 
;	IN: 	BX:		El offset de donde está la cadena a convertir.
;			CX: 	La base en la que está el número.
;
;	OUT:	AX: 	Número convertido.
;	
	PUSH DI DX
	MOV DI,0h
	MOV AX,0h
MAIN_STRTOINT:
	MUL CX
	MOV DL,[BX+DI]
	; Corregimos si se trata de una letra.
    CMP DL,'9'
    JBE NOTLETTER_STOI
    SUB DL,'A'-'0'-10
NOTLETTER_STOI:	
	ADD AL,DL
	SUB AL,'0'
	INC DI
	MOV DL,[BX + DI]
	CMP DL,"$"
	JNZ MAIN_STRTOINT
	; Tenemos el número en AX.	
	POP DX DI
	RET
STRTOINT ENDP

instalador PROC
	mov ax, 0
	mov es, ax
	mov ax, OFFSET routine
	mov bx, cs
	cli
	mov es:[ 60h*4 ], ax
	mov es:[ 60h*4+2 ], bx
	sti

	PUSH DS
	MOV AX, CS
	MOV DS, AX
	MOV AH, 9h
	MOV DX,OFFSET INSTALADO
	INT 21h
	POP DS

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

	; Imprimimos el mensaje en pantalla
	PUSH DS
	MOV AX,CS
	MOV DS,AX
	MOV AH,9h
	MOV DX,OFFSET DESINSTALADO
	INT 21h
	POP DS
	
	pop es ds cx bx ax

	ret
desinstalador ENDP


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
