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
	ASSUME CS: CODIGO, DS: DATOS, ES: EXTRA, SS: PILA 
	ORG 256

START PROC
	MOV AX, 4C00H 
    INT 21H 

START ENDP 

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

codigo ENDS
END inicio