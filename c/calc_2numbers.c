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
struct num *icreateNumber(int);
struct num *generateNumber(void);
void potentialize(struct num *);
struct num *sum(struct num *, struct num *);
struct num *getElement(struct num *ptr, int);
struct num *reverseStruct(struct num *);
struct num* calc(struct num *, struct num *, struct num *, struct num *, struct num *, int , int);
void printDigit(struct num *);

int main(void){
    struct num *a, *b, *result;
    
    a = generateNumber();
    b = generateNumber();
    result = sum(a,b);
	printDigit(result);
    
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
    int count = 0;
    count = countBytes(n);
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

struct num *icreateNumber(int c){
    struct num *bit;
    bit = (struct num *) malloc(sizeof(struct num));
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

struct num *getElement(struct num *ptr, int c){
	int n=0;
	while(n < c){
	    ptr = ptr->next;
		n++;
	}
	return(ptr);
}

struct num* calc(struct num *start, struct num *major, struct num *lower, struct num *nbit, struct num *bit, int sizeMajor, int sizeLower){
	while(sizeMajor != sizeLower){
		if(start == NULL){
			bit = icreateNumber(major->digit);
			start = nbit = bit;
		} else {
			bit = icreateNumber(major->digit);
			nbit = join(nbit, bit);
		}
			major = major->next;
			sizeMajor--;
        }
        for(int i=0; i<sizeMajor; i++){
			bit = icreateNumber(major->digit + lower->digit);
			nbit = join(nbit, bit);
			major = major->next;
			lower = lower->next;
        }
	return start;
}

struct num *sum(struct num *a, struct num *b){
    int sizeOfA = 0, sizeOfB = 0, sizeMajor=0, sizeLower=0;
	struct num *start=NULL, *bit=NULL, *nbit=NULL, *major=NULL, *lower=NULL;
		
    sizeOfA = countBytes(a);
    sizeOfB = countBytes(b);
	
    if(sizeOfA > sizeOfB){
		major = a;
		lower = b;
		sizeMajor = sizeOfA;
		sizeLower = sizeOfB;
        start = calc(start, major, lower, nbit, bit, sizeMajor, sizeLower);
	} else if (sizeOfA < sizeOfB){
		major = b;
		lower = a;
		sizeMajor = sizeOfB;
		sizeLower = sizeOfA;
        start = calc(start, major, lower, nbit, bit, sizeMajor, sizeLower);
    } else {
		for(int i=0; i<sizeOfA; i++){
			if(start == NULL){
				bit = icreateNumber(a->digit + b->digit);
				start = nbit = bit;
				a = a->next;
				b = b->next;
			} else {
				bit = icreateNumber(a->digit + b->digit);
				nbit = join(nbit, bit);
				a = a->next;
				b = b->next;
			}
		}
	}
	return(start);
}

void printDigit(struct num *ptr){
	int num = 0;
	
	while(ptr != NULL){
		num += ptr->digit;
		ptr = ptr->next;
	}
	printf("%d\n",num);
}
