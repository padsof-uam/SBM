#include <stdio.h>
#include <stdlib.h>

unsigned int minimoComunMultiplo (unsigned int a, unsigned int b);

int calculaMediana(int a, int b, int c, int d);

int esFibonacci(unsigned int num);

int divisiblePor4(int num);

void enteroACadenaHexa (int num, char* outStr);

void calculaChecksum(char* inStr, char* Check);

void calculaLetraDNI(char* inStr, char* letra);

int main(int argc, char const *argv[])
{

	char * str = calloc(sizeof(char),5);

	printf("FIB 122  %d\n", esFibonacci(122));

	printf("FIB 13  %d\n", esFibonacci(13));

	printf("FIB 0  %d\n", esFibonacci(0));

	printf("DIV4 16  %d\n", divisiblePor4(16));

	printf("DIV4 23 %d\n", divisiblePor4(23));


	enteroACadenaHexa(1551, str);
	printf("%s\n", str);

	// DNI alvaro: 02735676
	calculaLetraDNI("05312836", str);
	printf("%s\n", str);

	return 0;
}