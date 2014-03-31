;************************************************************************** 
;Víctor de Juan Sanz y Guillermo Julián Moreno
;************************************************************************** 
;************************************************************************** 
; DEFINICION DEL SEGMENTO DE CODIGO 


CODE SEGMENT BYTE PUBLIC 'CODE'
	ASSUME CS: CODE

START PROC
START ENDP

;;;	RECIBE 2 UNSIGNED INT POR PILA Y CALCULA SU MINIMO COMUN MULTIPL
PUBLIC _minimoComunMultiplo
_minimoComunMultiplo PROC FAR
	;; Acceso a los parámetros/argumentos.
	PUSH BP
	MOV BP,SP
	PUSH BX CX
	MOV AX,[BP+6]
	MOV BX,[BP+8]

	;; Empezamos. Utilizamos el método de Euclides para calcular el mcd
	; que lo utilizamos de la siguiente manera:
	; mcm(a,b) = (a*b)/mcd(a,b)

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
	POP CX BX
	POP BP
	RET
_minimoComunMultiplo ENDP

;;; CALCULA LA MEDIANA DE 4 ARGUMENTOS RECIBIDOS COMO PARÁMETRO.
PUBLIC _calculaMediana
_calculaMediana PROC FAR
	PUSH BP
	MOV BP,SP
	PUSH BX DI SI

	MOV DI,8H ;; ITERADOR DE "ARRIBA"
	MOV SI,6H ;; ITERADOR DE "ABAJO"

	;; ORDENAMOS LOS ARGUMENTOS RECIBIDOS CON EL ALGORITMO DE INSERT SORT.
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

	;; UNA VEZ ORDENADOS LOS ARGUMENTOS, CALCULAMOS LA MEDIA DE LOS 
	; ARGUMENTOS INTERMEDIOS QUE SE ENCUENTRAN ORDENADOS EN LA PILA.

	MOV AX, [BP+8]
	ADD AX,[BP+10]

	SAR AX,1

	POP SI DI BX
	POP BP
	RET
_calculaMediana ENDP


;;; COMPRUEBA SI UN NÚMERO PERTENECE A LA SECUENCIA DE FIBONACCI.
PUBLIC _esFibonacci
_esFibonacci PROC FAR
	PUSH BP
	MOV BP,SP
	PUSH BX CX DX

	MOV CX,[BP+6]
	MOV AX,1
	MOV BX,1

	;; CALCULAMOS NUMEROS DE LA SECUENCIA DE FIBONACCI HASTA ENCONTRAR
	; O SUPERAR EL VALOR RECIBIDO.
Fibonacci_start:
	CMP AX,CX
	JGE Fibonacci_end

	; Actualizamos los valores (con un registro auxiliar)
	MOV DX,AX
	ADD AX,BX
	MOV BX,DX
	JMP Fibonacci_start

	;; UNA VEZ TENEMOS LA INFORMACIÓN DEVOLVEMOS EN AX UN 1 (SI PERTENECE) O UN 0 (SINO PERTENECE).
Fibonacci_end:
	SUB AX,CX
	JZ Fibonacci_end_2
	MOV AX,0H
	JMP Fib_real_end
Fibonacci_end_2:
	MOV AX,1H

Fib_real_end:
	POP DX CX BX
	POP BP
	RET
_esFibonacci ENDP


;;; RECIBE UN ARGUMENTO Y DEVUELVE 1 SI ES DIVISIBLE POR 4 O UN 0 SINO.
PUBLIC _divisiblePor4 
_divisiblePor4 PROC FAR
	PUSH BP
	MOV BP,SP
	PUSH CX BX 

	MOV BX,[BP+6]
	MOV CL,14
	SHL BX,CL

	CMP BX,0H
	JZ DIV_4
	MOV AX,0H
	JMP NODIV_4
DIV_4:
	MOV AX,1H
NODIV_4:
	POP BX CX 
	POP BP
	RET
_divisiblePor4 ENDP

CODE ENDS
END START
