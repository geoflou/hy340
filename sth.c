#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(){
    char *result = malloc(sizeof(char *));
    char *buffer;

    strcpy(result, "_func");
    strcat(result, itoa(1,buffer,2));


    printf("%s\n",result);
    return 0;
}