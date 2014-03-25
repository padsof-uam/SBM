#include <stdio.h>

unsigned int minimoComunMultiplo (unsigned int a, unsigned int b);

int calculaMediana(int a, int b, int c, int d);

int esFibonacci(unsigned int num);

int divisiblePor4(int num);

int main(int argc, char const *argv[])
{


	printf("FIB 122  %d\n", esFibonacci(122));

	printf("FIB 13  %d\n", esFibonacci(13));

	printf("FIB 0  %d\n", esFibonacci(0));

	printf("DIV4 16  %d\n", divisiblePor4(16));

	printf("DIV4 23 %d\n", divisiblePor4(23));


	return 0;
}