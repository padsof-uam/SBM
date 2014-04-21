;************************************************************************** 
;	Pareja 3
;	Víctor de Juan Sanz y Guillermo Julián Moreno
;************************************************************************** 

DATOS SEGMENT 
	BUF DB 80 DUP('$')
	DECHEX DB "Escribe cadena decimal para convertir (a hexa): $"
	HEXDEC DB "Escribe cadena hexa para convertir (a decimal): $"
	OUT_BUF DB 15 DUP('$')
	END_BUF DB '$'
	ERROR DB "La interrupcion no esta instalada. $"
DATOS ENDS 

PILA SEGMENT STACK "STACK" 
	DB 40H DUP (0) ;ejemplo de inicialización, 64 bytes inicializados a 0 
PILA ENDS 


CODE SEGMENT 
	ASSUME CS: CODE, DS: DATOS, SS: PILA 
START PROC
	MOV AX, DATOS
	MOV DS, AX
	MOV AX, PILA
	MOV SS, AX
	MOV SP, 64 ; CARGA EL PUNTERO DE PILA CON EL VALOR MAS ALTO

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

	MOV AX, DATOS
	MOV DS, AX
	MOV AH, 9h
	MOV DX, OFFSET DECHEX
	INT 21H

	MOV AH, 0AH			
	MOV DX, OFFSET BUF
	MOV BUF[0], 80		
	INT 21H

	; Escribimos un salto de línea.
	MOV DL, 0AH
	MOV AH, 02H
	INT 21H

	; Ignoramos el primer y el último de lo leido que es info adicional innecesaria.
	MOV DI, OFFSET BUF + 1
	MOV DL,DS:[DI]
	XOR DH,DH
	MOV DI,DX
	MOV BUF[DI+2],'$'
	MOV DX, OFFSET BUF + 2
	MOV AH, 12H
	MOV SI,0FFFFh
	INT 60H

	MOV AH, 9
	MOV DX, OFFSET HEXDEC
	INT 21H

	MOV AH,0AH			
	MOV DX, OFFSET BUF
	MOV BUF[0], 80		
	INT 21H

	MOV DL, 0AH
	MOV AH, 02H
	INT 21H

	MOV DI, OFFSET BUF + 1
	MOV DL,DS:[DI]
	XOR DH,DH
	MOV DI,DX
	MOV BUF[DI+2],'$'
	MOV DX, OFFSET BUF + 2
	MOV AH, 13H
	MOV SI,0FFFFh
	INT 60H
	JMP FIN

UNINSTALLED:

	MOV AH,9h
	MOV DX, OFFSET ERROR
	INT 21H

FIN:
	MOV AX, 4C00H 
    INT 21H 

START ENDP 

CODE ENDS
END START
