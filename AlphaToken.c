#include "AlphaToken.h"

void alphaListInsert(int line, char* value, char* type){
    struct AlphaToken* newToken, *tmp;

    assert(value != NULL);
    assert(type != NULL);

    newToken = (struct AlphaToken *) malloc(sizeof(struct AlphaToken));
    newToken -> line = line;
    newToken -> value = value;
    newToken -> type = type;
    newToken -> next = NULL;
    
    tmp = tokenListHead;

    if(tmp == NULL){
        tokenListHead = newToken;
        return;
    }

    while(tmp -> next != NULL){
        tmp = tmp -> next;
    }

    tmp -> next = newToken;
    return;

}

void printAlphaList(){
    struct AlphaToken * tmp = tokenListHead;
    int tokenCount = 1;

    if(tmp == NULL){
        printf("No tokens recognized\n");
        return;
    }

    while(tmp != NULL){
        printf("%d:  #%d \t \"%s\" \t %s\n", tokenCount, tmp->line, tmp -> value, tmp-> type);
        tokenCount++;
        tmp = tmp -> next;
    }

    return;
}
