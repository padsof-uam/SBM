#include <stdio.h>
#include <stdlib.h>

unsigned int minimoComunMultiplo (unsigned int a, unsigned int b);

int calculaMediana(int a, int b, int c, int d);

int esFibonacci(unsigned int num);

int divisiblePor4(int num);

void enteroACadenaHexa (int num, char *outStr);

void calculaChecksum(char *inStr, char *Check);

void calculaLetraDNI(char *inStr, char *letra);

void pruebasChecksum()
{
    char bytes[] = {0x0B, 0xA0, 0x80, 0xFA, 0x92, 0x6F, 0x36, 0xC3, 0xA0, 0x76, 0x00};
    char check;
    char str[100];

    calculaChecksum(bytes, &check);
    printf("Checksum de %s: 0x%x\n", bytes, check & 0xff); /* Solo queremos los bytes m.s. */

    printf("Introduzca una cadena para calcular su checksum: ");
    scanf("%s", str);
    
    calculaChecksum(str, &check);
    printf("Checksum de %s: 0x%x\n", str, check & 0xff); /* Solo queremos los bytes m.s. */
}

void pruebasMcm()
{
    int a, b;
    printf("Introduzca 2 valores para calcular el minimo comun multiplo: \n");
    scanf("%d", &a);
    scanf("%d", &b);

    printf("El minimo comun multiplo es: %d\n\n", minimoComunMultiplo(a, b));
}

void pruebasMediana()
{
	int med[4];

	printf("Introduzca 4 valores para calcular la mediana: \n");
    scanf("%d", &med[0]);
    scanf("%d", &med[1]);
    scanf("%d", &med[2]);
    scanf("%d", &med[3]);
    printf("La mediana es: %d\n\n", calculaMediana(med[0], med[1], med[2], med[3]));
}

void pruebasFibonacci()
{
	int num;
	  printf("Introduzca el numero para comprobar si pertenece a la secuencia de Fibonacci:\n");
    scanf("%d", &num);

    if (esFibonacci(num) == 1)
        printf("El %d si pertenece a la secuencia de fibonacci\n", num);
    else
        printf("El %d no pertenece a la secuencia de fibonacci\n", num);

}

void pruebasDivisible4()
{
	int num;

	printf("Introduzca el numero para comprobar es divisible por 4:\n");
    scanf("%d", &num);
    if (divisiblePor4(num) == 1)
        printf("El %d si es divisible por 4\n", num);
    else
        printf("El %d no es divisible por 4\n", num);

    printf("\n");
}

void pruebasCadenaHexa()
{
	int num;
    char *str = calloc(sizeof(char), 5);

    printf("Introduzca el entero para ser convertido a hexadecimal:\n");
    scanf("%d", &num);
    enteroACadenaHexa(num, str);
    printf("El numero en hexadecimal es: %s\n", str);
}

void pruebasDNI()
{
    char *str = calloc(sizeof(char), 5);
    char *dni = calloc(sizeof(char), 10);

	printf("Introduzca el DNI del que calcular la letra:\n");
    scanf("%s",dni);
    calculaLetraDNI(dni, str);
    printf("El dni completo es %s%s\n", dni,str);
}

int main(int argc, char const *argv[])
{ 
	pruebasChecksum();
	pruebasDNI();
	pruebasDivisible4();
	pruebasFibonacci();
	pruebasMcm();
	pruebasMediana();
	pruebasCadenaHexa();
    // DNI alvaro: 02735676 -> X
    // DNI dj: 05312836 -> C
    return 0;
}
