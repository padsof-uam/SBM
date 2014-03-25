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



PUBLIC _minimoComunMultiplo
;;;	Recibe 2 unsigned int por la pila.
_minimoComunMultiplo PROC FAR

	;; Acceso a los parámetros/argumentos.
	PUSH BP
	MOV BP,SP
	MOV AX,[BP+6]
	MOV BX,[BP+8]

	; Empezamos

EUCLIDES:
	CMP BX,0H
	JZ EUCLIDES_FIN
	MOV DX,0H
	DIV BX
	MOV AX,BX
	MOV BX,DX
	JMP EUCLIDES

EUCLIDES_FIN:
	;; Tenemos en AX el máximo común divisor.

	MOV CX,AX
	MOV DX,0H
	;; RECUPERAMOS LOS ARGUMENTOS.
	MOV AX,[BP+6]
	MOV BX,[BP+8]

	MUL BX
	DIV CX

	;; TENEMOS EL RESULTADO EN DX:AX. COMO LA FUNCIÓN ES UNSIGNED INT, SOLO 
	;	TENDREMOS EN CUENTA AX

	POP BP
	RET

_minimoComunMultiplo ENDP


PUBLIC _calculaMediana

_calculaMediana PROC FAR
	PUSH BP
	MOV BP,SP
	PUSH BX DI SI

	MOV DI,8H ;; ITERADOR DE "ARRIBA"
	MOV SI,6H ;; ITERADOR DE "ABAJO"

INSERT_SORT:
	MOV SI,DI

	MOV AX,[BP+DI]

INSERT_SORT_L2:
	SUB SI,2
	MOV BX,[BP+SI]
	CMP AX,BX
	JNS INSERT_PASS_END	
	MOV [BP+SI],AX
	MOV [BP+SI+2],BX
	CMP SI,6H
	JNZ INSERT_SORT_L2

INSERT_PASS_END:
	ADD DI,2H
	CMP DI,14
	JNZ INSERT_SORT

	MOV AX, [BP+8]
	ADD AX,[BP+10]

	SAR AX,1

	POP SI DI BX
	POP BP
	RET
_calculaMediana ENDP

CODE ENDS
END START
