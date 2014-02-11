;************************************************************************** 

; ESTRUCTURA BÁSICA DE UN PROGRAMA EN ENSAMBLADOR 

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