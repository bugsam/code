/*@bugsam
05/29/2021
*/

#include <stdio.h>
#include <stdlib.h>

struct num{
    char digit;
    struct num *next;
};

int main(void){
    //! showMemory(msb)
    struct num *bit=NULL, *nbit; //
    char a;
    int sum = 0;
    
    scanf("%c",&a);
    bit = (struct num *) malloc(sizeof(struct num));
    nbit = bit;
    
    while(a != 0x0a){
        a -= 0x30;
        bit->digit = a;
        scanf("%c",&a);
        
        if(a != 0x0a){
            bit = (struct num *) malloc(sizeof(struct num));
            
            nbit->next = bit;
            nbit = bit;
        }
    }
    
    printf("sum: %d",sum);
}
