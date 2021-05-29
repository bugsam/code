/*
@bugsam
05/29/2021
*/

#include <stdio.h>
#include <stdlib.h>

struct num{
    char digit;
    struct num *next;
};

struct num *join (struct num *, struct num *);
struct num *createNumber(char);
struct num *generateNumber(void);
int sum(struct num *, struc num *);

int main(void){
    //! showMemory(msb)
    struct num *a, *b;
    int result = 0;
    
    a = generateNumber();
    b = generateNumber();
    result = sum(a,b);
    
    
    return 0;
}

struct num *join(struct num *nbit, struct num *bit){
    nbit->next = bit;
    nbit = bit;

    return(nbit);
}

struct num *createNumber(char c){
    struct num *bit;
    bit = (struct num *) malloc(sizeof(struct num));
    c -= 0x30;
    bit->digit = c;

    return(bit);
}

struct num *generateNumber(void){
    struct num *start=NULL, *bit, *nbit;
    char a;
    int sum = 0;
    
    scanf("%c",&a);
    while(a != 0x0a){
        if(start == NULL){
            bit = createNumber(a);
            start = nbit = bit;
        } else {
            bit = createNumber(a);
            nbit = join(nbit, bit);
        }
        scanf("%c",&a);
    }
    return(start);
}

int sum(struct num *a, struc num *b){
    int result = 0;
    
    
    
}
