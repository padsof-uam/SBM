;************************************************************************** 

; ESTRUCTURA BÁSICA DE UN PROGRAMA EN ENSAMBLADOR 

;************************************************************************** 

; DEFINICION DEL SEGMENTO DE DATOS 

DATOS SEGMENT 


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
	MOV AX, 0531H
	MOV DS, AX

    ;INICIALIZA LOS REGISTROS DE SEGMENTO CON SUS VALORES 
    MOV BX,0211H
    MOV DI,1010H

    MOV AL,DS:[1234H] ; Accede a 1765
    MOV AX,[BX] ; Accede a 0742 
    MOV [DI],AL ; Guarda en 1541
CODE ENDS

END START
