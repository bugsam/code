#include <stdio.h>

int main(void){
    char letter;
    int i = 5, j = 9, x, y;
    scanf("%c",&letter);
    for(y = 0; y < 5; y++){
        for(x = 0 ; x < (j-i); x++)
            printf("+");
        for(x = 0; x < 9-((j-i)*2); x++)
            printf("%c",letter);
        for(x = 0 ; x < (j-i); x++)
            printf("+");
        printf("\n");
        j--;
    }
    return 0;
}
