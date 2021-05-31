/*
@bugsam
05/29/2021
*/

#include <stdio.h>
#include <stdlib.h>

struct num{
    int digit;
    struct num *next;
};

struct num *join (struct num *, struct num *);
struct num *createNumber(char);
struct num *generateNumber(void);
void potentialize(struct num *);
int sum(struct num *, struct num *);

int main(void){
    struct num *a, *b;
    int result = 0;
    
    a = generateNumber();
    b = generateNumber();
    result = sum(a,b);
    
    return 0;
}

int countBytes(struct num *n){
    int count = 0;
    while(n != NULL){
        n = n->next;
        count++;
    }
    return(count);
}

void potentialize(struct num *n){
    struct num *ptr = n;
    int count = 0;
    count = countBytes(n);
    n = ptr;
    while(n != NULL){
        for(int i=1; i<count; i++){
            n->digit *= 10;
        }
        n = n->next;
        count--;
    }
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
    potentialize(start);
    return(start);
}

int sum(struct num *a, struct num *b){
    //generate struct result
    int sizeOfA = 0, sizeOfB;
    sizeOfA = countBytes(a);
    sizeOfB = countBytes(b);
    if(sizeOfA > sizeOfB){
        while(sizeOfA == sizeOfB){
            a = a->next;
            sizeOfA--;
        }
        for(int i=1; i<sizeOfA; i++){
            
        }
    } else if (sizeOfA < sizeOfB){
        for(int i=1; i<sizeOfB; i++){
            
        }
    } else {
        //equals
        for(int i=1; i<sizeOfA; i++){
            
        }
    }
}
