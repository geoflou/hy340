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
    char* tempName; 
    sprintf(tempName, "_temp_%d", counter);
    return tempName;
}


char* newTempFuncName(int counter){
    char* name;
    sprintf(name, "_temp_func_%d", counter);
    return name;
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



enum scopespace_t currscopespace(void){
    if(scopeSpaceCounter == 1){
        return programvar;
    }
    else if(scopeSpaceCounter % 2 == 0){
        return formalarg;
    }
    else
        return functionlocal;
        
}



unsigned currscopeoffset(void){
    switch (currscopespace()){
        case programvar : return programVarOffset;
        case functionlocal : return functionLocalOffset;
        case formalarg : return formalArgOffset;
        default : assert(0);
    }
    return;
}

void inccurrscopeoffset (void) {
    switch(currscopespace()){
        case programvar : ++programVarOffset; break;
        case functionlocal : ++functionLocalOffset; break;
        case formalarg : ++formalArgOffset; break;
        default : assert(0);
    }
    return;
}


void enterscopespace(void){
    ++scopeSpaceCounter;
    return;
}

void exitscopespace(void){
    assert(scopeSpaceCounter > 1);
    --scopeSpaceCounter;
    return;
}

void resetformalargsoffset(void){
    formalArgOffset = 0;
    return;
}

void resetformalargsoffset(void){
    functionLocalOffset = 0;
    return;
}

void restorecurrscopespace(unsigned n){
    switch(currscopespace()){
        case programvar : programVarOffset = n; break;
        case functionlocal : functionLocalOffset = n; break;
        case formalarg : formalArgOffset = n; break;
        default: assert(0);
    }
    return;
}

unsigned nextquadlabel (void){
    return currQuad;
}

void patchlabel(unsigned quadNo, unsigned label){
    assert(quadNo < currQuad);
    quads[quadNo].label = label;
    return;
}

void printQuads(){
    printf("quad# \t \t opcode \t \t \t result \t \t \t arg1 \t \t \t arg2 \t \t \t label\n");
    printf("-------------------------------------------------------------------------------------------------------------------------------------------\n");
    //To be implemented
    printf("-------------------------------------------------------------------------------------------------------------------------------------------\n");
}
