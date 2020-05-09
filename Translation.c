#include "Translation.h"

Quad* quads = (Quad *) 0;
unsigned total = 0;
unsigned int currQuad = 0;

#define EXPAND_SIZE 1024
#define CURR_SIZE (total*sizeof(Quad))
#define NEW_SIZE (EXPAND_SIZE*sizeof(Quad) + CURR_SIZE)

void expand(void) {
    assert(total == currQuad);
    Quad* p = (Quad*) malloc(NEW_SIZE);
    if(quads) {
        memcpy(p, quads, CURR_SIZE);
        free(quads);
    }
    quads = p;
    total += EXPAND_SIZE;

    return;
}

void emit(enum iopcode op, Expr* arg1, Expr* arg2, Expr* result, 
    unsigned label, unsigned line) {
        if(currQuad == total) {
            expand();
        }

        Quad * p = quads + currQuad++;
        p -> op = op;
        p -> arg1 = arg1;
        p -> arg2 = arg2;
        p -> result = result;
        p -> label = label;
        p -> line = line;
    
        return;
    }


int tempCounter = 0;

char* newTempName(void) {
    char* result = (char *) malloc(sizeof(char *));
    char buff[20];

    result = sprintf("_t_%d", itoa(tempCounter,buff,2));

    tempCounter++;

    return result;
}

SymbolTableEntry newTemp(int scope, int line) {
    char* name = newTempName();
    Variable *var;
    SymbolTableEntry* sym = lookupScope(name, scope);
    
    if(sym != NULL) {
        return *sym;
    }

    sym = (SymbolTableEntry*) malloc(sizeof(SymbolTableEntry));
    var = (Variable *) malloc(sizeof(Variable));

    var -> name = name;
    var -> scope = scope;
    var -> line = line;

    sym -> isActive = 1;
    sym -> funcVal = NULL;
    sym -> varVal = var;
    if(scope == 0)
        sym -> type = GLOBAL;
    else
        sym -> type = LOCAL;

    insertEntry(sym);

    return *sym;
}