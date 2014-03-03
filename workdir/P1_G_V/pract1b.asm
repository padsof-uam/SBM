;; Autores: Guillermo Julian Moreno y Victor de Juan Sanz

;************************************************************************** 


;************************************************************************** 
; DEFINICION DEL SEGMENTO DE DATOS 

DATOS SEGMENT 
	CONTADOR DB 0 ; Reservar memoria para una variable CONTADOR de un byte de tamaño.
	BEBA DW 0CAFEH ; Reservar memoria para una variable, BEBA, de dos bytes de tamaño, inicializada con el valor CAFEH.
	TABLA100 DB 100 DUP (0); Reservar 100 bytes para una tabla llamada TABLA100 (la ? porque no estan inicializados)
	ERROR1 DB "Errores en el programa. Resultados incorrectos."
DATOS ENDS 

;************************************************************************** 

; DEFINICION DEL SEGMENTO DE PILA 

PILA SEGMENT STACK "STACK" 

	DB 40H DUP (0) ;ejemplo de inicializacion, 64 bytes inicializados a 0 

PILA ENDS 

;************************************************************************** 
; DEFINICION DEL SEGMENTO EXTRA 

EXTRA SEGMENT 

	RESULT DW 0,0 ;ejemplo de inicializacion. 2 PALABRAS (4 BYTES) 

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

	; FIN DE LAS INICIALIZACIONES

	; COMIENZO DEL PROGRAMA

	; La instruccion MOV TABLA100[63H],ERROR1[5] no esta permitida,
	;	por lo que utilizamos un registro auxiliar.
	MOV BL,ERROR1[5] ; El primer caracter es el que ocupa el lugar 0.
	MOV TABLA100[63H],BL

	; Aqui también necesitamos utilizar un registro auxiliar
	MOV BX, BEBA
	MOV WORD PTR TABLA100[23H],BX

	
	; Debido a la arquitectura Little Endian, el byte mas significativo
	;	se encuentra en BL y no en BH.
	MOV CONTADOR, BL
	
	; Devolvemos el control al sistema operativo para liberar toda la
	;	memoria.
	MOV AX, 4C00H
	INT 21H
CODE ENDS 

END START 
