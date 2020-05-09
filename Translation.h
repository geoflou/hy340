#include <stdio.h>
#include <assert.h>
#include <string.h>
#include <stdlib.h>

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
    tablesetelem
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
    constring_e,

    nil_e
};

typedef struct expr{
    enum expr_t type;
    SymbolTableEntry* sym;
    struct expr* index;
    double numConst;
    char* strConst;
    unsigned char boolConst;
    expr* next;
} Expr;

typedef struct quad{
    enum iopcode op;
    Expr* result;
    Expr* arg1;
    Expr* arg2;
    unsigned label;
    unsigned line;
} Quad;


void expand(void);

void emit(enum iopcode op, Expr* arg1, Expr* arg2, Expr* result, 
    unsigned label, unsigned line);

char* newTempName(void);

SymbolTableEntry newTemp(int scope, int line);

Expr* lvalue_expr(SymbolTableEntry* sym);