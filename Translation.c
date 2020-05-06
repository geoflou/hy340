#include "Translation.h"

void expand(void){
    assert(total == currQuad);
    Quad* p = (Quad *) malloc(NEW_SIZE);
    if(quads){
        memcpy(p, quads, CURR_SIZE);
        free(quads);
    }

    quads = p;
    total +=EXPAND_SIZE;
}


void emit(enum iopcode op, Expr* arg1, Expr* arg2, Expr* result,
                                        unsigned label, unsigned line) {

    if(currQuad == total)
        expand();

    Quad* p = quads + currQuad++;
    p -> op = op;
    p -> arg1 = arg1;
    p -> arg2 = arg2;
    p -> result = result;
    p -> label = label;
    p -> line = line;

}

char* newTempName(int counter){
    return sprintf("_temp_%d", counter);
}

SymbolTableEntry newTemp(int scope, int line){
    SymbolTableEntry *sym;
    Variable* var =(Variable *) malloc(sizeof(Variable));
    char* name = newTempName(tempVarCounter);

    tempVarCounter++;
    sym = lookupScope(name, scope);
    if(sym != NULL)
        return *sym;

    sym = (SymbolTableEntry*) malloc(sizeof(SymbolTableEntry));

    var -> name = name;
    var -> line = line;
    var -> scope = scope;

    sym -> isActive = 1;
    sym -> varVal = var;
    sym -> funcVal = NULL;
    if(scope > 0){
        sym -> type = LOCAL;
    } else {
        sym -> type = GLOBAL;
    }

    insertEntry(sym);

    return *sym;
}