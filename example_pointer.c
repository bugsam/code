//@bugsam 16/04/2021
#include <stdio.h>

int main(){
    int a = 0x42424242;
    int * addressOfA = &a;
    //print a value
    printf("At the address %p there is the value %x\n",addressOfA,* addressOfA);
    int b = 0x41414141;
    * addressOfA = 0x0;
    addressOfA = addressOfA - 2;
    //print b value
    printf("At the address %p there is the value %x\n",addressOfA,* addressOfA);
    return 0;
}
