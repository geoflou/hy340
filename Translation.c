#include "Translation.h"
 
unsigned programVarOffset = 0;
unsigned functionLocalOffset = 0;
unsigned formalArgOffset = 0;
unsigned scopeSpaceCounter = 1;

Quad* quads = (Quad *) 0;
unsigned total = 0;
unsigned int currQuad = 0;

#define EXPAND_SIZE 1024
#define CURR_SIZE (total*sizeof(Quad))
#define NEW_SIZE (EXPAND_SIZE*sizeof(Quad) + CURR_SIZE)

int tempVarCounter = 0;

void expand(void){
    assert(total == currQuad);
    Quad* p = (Quad *) malloc(NEW_SIZE);
    if(quads){
        memcpy(p, quads, CURR_SIZE);
        free(quads);
    }

    quads = p;
    total +=EXPAND_SIZE;
    return;
}


void emit(enum iopcode op, Expr* arg1, Expr* arg2, Expr* result,
                                        unsigned label, int line) {

    if(currQuad == total)
        expand();

    Quad* p = quads + currQuad++;
    p -> op = op;
    p -> arg1 = arg1;
    p -> arg2 = arg2;
    p -> result = result;
    p -> label = label;
    p -> line = line;
    
    return;
}



char* newTempName(int counter){
    char* tempName =(char*) malloc(sizeof(char*)); 
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

void resetfunclocalsoffset(void){
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

Expr* newExpr(enum expr_t t){
    Expr* e = (Expr*) malloc(sizeof(Expr));
    memset(e, 0, sizeof(Expr));
    e -> type = t;
    return e;
}

Expr* newExpr_conststring(char* s){
    Expr* e = newExpr(conststring_e);
    e-> strConst = strdup(s);
    return e;
}

Expr* newExpr_constbool(unsigned char b){
    Expr* e = newExpr(constbool_e);
    e->boolConst = b;
    return e;
}

Expr* newExpr_constnum(double n){
    Expr* e = newExpr(constnum_e);
    e -> numConst = n;
    return e;
}



Expr* emit_iftableitem(Expr* e, int scope, int line, int label){
    if(e->type != tableitem_e){
        return e;
    }
    SymbolTableEntry symbol;
    Expr* result = newExpr(var_e);
    SymbolTableEntry *symptr = (SymbolTableEntry*) malloc (sizeof(SymbolTableEntry));
    symptr = &symbol;
    symbol=newTemp(scope,line);
    result -> sym = symptr;
    emit(tablegetelem, e, e -> index, result, label, line);

    return result;
}

void printQuads(){
    printf("quad# \t \t opcode \t \t \t result \t \t \t arg1 \t \t \t arg2 \t \t \t label\n");
    printf("-------------------------------------------------------------------------------------------------------------------------------------------\n");
    //To be implemented
    printf("-------------------------------------------------------------------------------------------------------------------------------------------\n");
}
