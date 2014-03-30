#include <stdio.h>

unsigned int minimoComunMultiplo (unsigned int a, unsigned int b);

int calculaMediana(int a, int b, int c, int d);

int esFibonacci(unsigned int num);

int divisiblePor4(int num);

void enteroACadenaHexa (int num, char* outStr);

void calculaChecksum(char* inStr, char* Check);

void calculaLetraDNI(char* inStr, char* letra);

int main(int argc, char const *argv[])
{
	char bytes[] = {0x0B,0xA0,0x80,0xFA,0x92,0x6F,0x36,0xC3,0xA0,0x76,0x00};
	char check;

	printf("FIB 122  %d\n", esFibonacci(122));

	printf("FIB 13  %d\n", esFibonacci(13));

	printf("FIB 0  %d\n", esFibonacci(0));

	printf("DIV4 16  %d\n", divisiblePor4(16));

	printf("DIV4 23 %d\n", divisiblePor4(23));

	calculaChecksum(bytes, &check);
	printf("Checksum de %s: %d", bytes, check);

	return 0;
}
