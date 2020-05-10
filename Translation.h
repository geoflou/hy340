/**
 * Header file.
 * Includes all the needed functions and structs
 * in order to create intermediate code
 * 
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include "SymbolTable.h"


enum iopcode{
    assign,
    add,
    sub,
    mul,
    divide,    
    mod,
    uminus,     
    and,    
    or,
    not,        
    if_eq,  
    if_noteq,
    if_lesseq,
    if_greatereq,
    if_less,
    if_greater,
    call,
    param,
    ret,
    getretval,
    funcstart,
    funcend,
    tablecreate,
    tablegetelem,
    tablesetelem,
    jump
};

enum expr_t{
    var_e,
    tableitem_e,

    programfunc_e,
    libraryfunc_e,

    arithexpr_e,
    boolexpr_e,
    assignexpr_e,
    newtable_e,

    constnum_e,
    constbool_e,
    conststring_e,

    nil_e
};

typedef struct expr{
    enum expr_t type;
    SymbolTableEntry* sym;
    struct expr* index;
    double numConst;
    char* strConst;
    unsigned char boolConst;
    struct expr* next;
} Expr;

typedef struct quad{
    enum iopcode op;
    Expr* result;
    Expr* arg1;
    Expr* arg2;
    unsigned label;
    unsigned line;
} Quad;

typedef struct e_list{
    char* e_list_name;
    struct e_list* next;
} E_list;

void expand(void);

void emit(enum iopcode op, Expr* arg1, Expr* arg2, Expr* result,
                                        unsigned label, int line);

char* newTempName(int counter);

char* newTempFuncName(int counter);

SymbolTableEntry newTemp(int scope, int line);

enum scopespace_t {
    programvar,
    functionlocal,
    formalarg
};

enum symbol_t {
    var_s,
    programfunc_s,
    libraryfunc_s
};

    typedef struct call{
        Expr* elist;
        int boolmethod;
        char* name;
    }Call;


enum scopespace_t currscopespace(void);

unsigned currscopeoffset(void);

void inccurrscopeoffset (void);

void enterscopespace(void);

void exitscopespace(void);

void restorelocaloffset(void);

void resetformalargsoffset(void);

void resetfunclocalsoffset(void);

void restorecurrscopespace(unsigned n);

void restorecurrscopeoffset(unsigned n);

unsigned nextquadlabel (void);

void patchlabel(unsigned quadNo, unsigned label);

Expr* newExpr(enum expr_t t);

Expr* newExpr_conststring(char *s);

Expr* newExpr_constbool(unsigned char b);

Expr* newExpr_constnum(double n);

Expr* emit_iftableitem(Expr* e ,int scope, int line, int label);

Expr* make_call(Expr* lvalue, int scope, int line,int label);

void printQuads();

char* getQuadOpcode(Quad q);

char* getQuadResult(Quad q);

char* getQuadArg1(Quad q);

char* getQuadArg2(Quad q);

Expr* make_call(Expr* lvalue, int scope, int line,int label);

Expr* lvalue_expr(SymbolTableEntry* sym);
