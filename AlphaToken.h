#include <assert.h>
#include <stdlib.h>
#include <stdio.h>

struct AlphaToken{
    
    int line;
    char* type;
    char* value;    

    struct AlphaToken* next;

};

struct AlphaToken * tokenListHead = NULL;

void alphaListInsert(int line, char* value, char* type);

void printAlphaList();

void ReadFromFile(FILE *param);

