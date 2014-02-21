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

EXTRA ENDS 

;************************************************************************** 

; DEFINICION DEL SEGMENTO DE CODIGO 

CODE SEGMENT 
;	ASSUME CS: CODE, DS: DATOS, ES: EXTRA, SS: PILA 
 
START PROC 

    ;INICIALIZA LOS REGISTROS DE SEGMENTO CON SUS VALORES 

    MOV AX, 6500h
    MOV DS, AX
    MOV AX, PILA
    MOV SS, AX
    MOV AX, EXTRA
    MOV ES, AX
    MOV SP, 64 ; CARGA EL PUNTERO DE PILA CON EL VALOR MAS ALTO

    ; FIN DE LAS INICIALIZACIONES

    ; COMIENZO DEL PROGRAMA

    MOV AX,0013H
    MOV BX,00BAH
    MOV CX,3412H
    MOV DX,CX

    ; Cargar en AL el contenido de la posición de memoria 65646H y en
    ;   AH en contenido de la posición 65647H 
    MOV AL,DS:0646H
    MOV AH,DS:0647H

    MOV DS:5007h,CH
    MOV AX,[DI]

    MOV AX,[BP]-10

    ; FIN DEL PROGRAMA
    
    ; Devolvemos el control al sistema operativo para liberar 
    ;   toda la memoria utilizada.
    MOV AX, 4C00H
    INT 21H

; FIN DEL SEGMENTO DE CODIGO 
CODE ENDS 
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION 
END START 

