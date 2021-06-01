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
struct num *sum(struct num *a, struct num *b);

int main(void){
    struct num *a, *b;
    struct num *result;
    
    a = generateNumber();
    b = generateNumber();
    result = sum(a,b);
    printf("%d",result->digit);
    
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

struct num *sum(struct num *a, struct num *b){
    //! showMemory(res)
    int sizeOfA = 0, sizeOfB;
	struct num *res;
	
	res = (struct num *) malloc(sizeof(struct num));
	
    sizeOfA = countBytes(a);
    sizeOfB = countBytes(b);
	
    if(sizeOfA > sizeOfB){
        while(sizeOfA != sizeOfB){
            res->digit += a->digit;
			a = a->next;
            sizeOfA--;
        }
        for(int i=0; i<sizeOfA; i++){
			res->digit += (a->digit + b->digit);
			a = a->next;
			b = b->next;
        }
    } else if (sizeOfA < sizeOfB){
		while(sizeOfA != sizeOfB){
			res->digit += b->digit;
			b = b-> next;
			sizeOfB--;
		}
        for(int i=0; i<sizeOfB; i++){				
			res->digit += (a->digit + b->digit);
			a = a->next;
			b = b->next;
        }
    } else {
        for(int i=0; i<sizeOfA; i++){
            res->digit += (a->digit + b->digit);
			a = a->next;
			b = b->next;
        }
    }
	return(res);
}
