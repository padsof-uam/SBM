;************************************************************************** 
;	Pareja 3
;	Víctor de Juan Sanz y Guillermo Julián Moreno
;************************************************************************** 

DATOS SEGMENT 
DATOS ENDS 

PILA SEGMENT STACK "STACK" 
	DB 40H DUP (0) ;ejemplo de inicialización, 64 bytes inicializados a 0 
PILA ENDS 

EXTRA SEGMENT 
EXTRA ENDS 


CODE SEGMENT 
	ASSUME CS: CODE, DS: DATOS, ES: EXTRA, SS: PILA 
START PROC


	MOV AX, 4C00H 
    INT 21H 

START ENDP 

CODE ENDS
END START