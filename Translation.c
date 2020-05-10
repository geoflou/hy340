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
    char* tempName = (char*) malloc(sizeof(char*)); 
    sprintf(tempName, "_t_%d", counter);
    return tempName;
}

char* newTempFuncName(int counter){
    char* name = (char*) malloc(sizeof(char*));
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

    var -> name = strdup(name);
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

Expr* lvalue_expr(SymbolTableEntry* sym) {
    assert(sym != NULL);
    Expr* e = (Expr* ) malloc(sizeof(Expr));
    memset(e, 0 , sizeof(Expr));

    e -> next = NULL;
    e -> sym = sym;

    switch(sym -> type) {
        case GLOBAL : e -> type = var_e; break;
        case LOCAL : e -> type = var_e; break;
        case USERFUNC: e -> type = programfunc_e; break;
        case LIBFUNC: e -> type = libraryfunc_e; break;
        default: assert(0);
    }

    return e;
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

Expr* newExpr_constbool(int b){
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
    SymbolTableEntry symbol = newTemp(scope, line);
    SymbolTableEntry* symptr = (SymbolTableEntry*)malloc(sizeof(SymbolTableEntry));
    Expr* result = newExpr(tableitem_e);
    symptr = &symbol; 
    result->sym = symptr;
    emit(tablegetelem, e, e -> index, result,(unsigned) label, (unsigned)line);

    return result;
}

Expr* member_item(Expr* e, char* name, int scope, int line, int label){
    e = emit_iftableitem(e, scope, line, label);

    Expr* tableitem = newExpr(tableitem_e);
    tableitem -> sym = e -> sym;
    tableitem -> index = newExpr_conststring(name);

    return tableitem;
}

Expr* make_call(Expr* lvalue, Expr* result, int scope, int line,int label){
     Expr* func = emit_iftableitem(lvalue, scope, line, label);
     /*edw prepei na mpei mia loop pou na kanei traverse ena array/list to opoio na kanei emit tis parametrous*/
     emit(call,func,NULL,NULL,label,line);
     
     emit(getretval,NULL, NULL, result, label, line);
     return result;

 }

void printQuads(){
    int i;
    char* opcode, *result, *arg1, *arg2;
    printf("quad# \t  opcode \t  result \t  arg1 \t   arg2  \t   label\n");
    printf("------------------------------------------------------------------------------------------------------------------------\n");
    for(i = 0;i < currQuad; i++){
        opcode =  getQuadOpcode(quads[i]);
        result = getQuadResult(quads[i]);
        arg1 = getQuadArg1(quads[i]);
        arg2 = getQuadArg2(quads[i]);
        printf("#%d \t  %s  \t  %s   \t  %s  \t  %s \t  %d  \n", i, opcode, result, arg1, arg2, quads[i].label);
    }
    printf("------------------------------------------------------------------------------------------------------------------------\n");
    return;
}


char* getQuadOpcode(Quad q){
    switch(q.op){
        case assign : return "assign";
        case add : return "add";
        case sub : return "sub";
        case mul : return "mul";
        case divide : return "divide";
        case mod : return "mod";
        case uminus : return "uminus";
        case and : return "and";
        case or : return "or";
        case not : return "not";
        case if_eq : return "if_eq";
        case if_noteq : return "if_noteq";
        case if_lesseq : return "if_lesseq";
        case if_greatereq : return "if_greatereq";
        case if_less : return "if_less";
        case if_greater : return "if_greater";
        case call : return "call";
        case param : return "param";
        case ret : return "ret";
        case getretval : return "getretval";
        case funcstart : return "funcstart";
        case funcend : return "funcend";
        case tablecreate : return "tablecreate";
        case tablegetelem : return "tablegetelem";
        case tablesetelem : return "tablesetelem";
        case jump: return "jump";
        default: assert(0);
    }
}

char* getQuadResult(Quad q){
    if(q.result == NULL)
        return  "    ";
    
    if(q.result->type == boolexpr_e){
        if(q.result->boolConst == 0)
            return "false";
        return "true";
    }

    return getQuadName(q.result->sym);
}

char* getQuadArg1(Quad q){
    if(q.arg1 == NULL)
        return "    ";

    if(q.arg1->type == boolexpr_e){
        if(q.arg1->boolConst == 0)
            return "false";
        return "true";
    }

    return getQuadName(q.arg1->sym);
}  

char* getQuadArg2(Quad q){
    if(q.arg2 == NULL)
        return "    ";

    if(q.arg2->type == boolexpr_e){
        if(q.arg2->boolConst == 0)
            return "false";
        return "true";
    }

    return getQuadName(q.arg2 -> sym);
}


char* getQuadName(SymbolTableEntry* sym) {
    if(sym == NULL)
        return "    ";

    if(sym->funcVal == NULL){
        return sym->varVal->name;
    }

    return sym->funcVal->name;
}