;************************************************************************** 
;Víctor de Juan Sanz y Guillermo Julián Moreno
;************************************************************************** 

; DEFINICION DEL SEGMENTO DE DATOS 
DATOS SEGMENT 
;-- rellenar con los datos solicitados 
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


	MOV AX, 4C00H 
    INT 21H 

START ENDP 


PUBLIC _enteroACadenaHexa
_enteroACadenaHexaPROC FAR
	
	PUSH BP
	MOV BP,SP

	POP BP
	RET

ENDP _enteroACadenaHexa

PUBLIC _calculaChecksum
_calculaChecksumPROC FAR
	
	PUSH BP
	MOV BP,SP

	POP BP
	RET

ENDP _calculaChecksum

PUBLIC _calculaLetraDNI
_calculaLetraDNIPROC FAR
	
	PUSH BP
	MOV BP,SP

	POP BP
	RET

ENDP _calculaLetraDNI

PRINT_BYTES PROC NEAR
;; Parámetros: 
;	IN: 	BX:		El offset de donde está el valor.
;			SI: 	El offset de la última posición en la que se empieza a escribir.
;			DI: 	El número de caracteres a imprimir.
;
;	OUT:	Almacena en [SI] los bytes ASCII de los caracteres del número.
;			CH guarda el número de caracteres escrito.
;	
;	USES: AX,BX,CL,CH,DL,DI,SI

	MOV BX,0H
	MOV CX,0H



	AND [SI],BX
	MOV BX,m


	RET
PRINT_BYTES ENDP


CODE ENDS
END START
