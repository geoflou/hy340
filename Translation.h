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
    div
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
    conststring_e,

    nil_e
};

struct expr{
    expr_t type;
    SymbolTableEntry* sym;
    expr* index;
    double numConst;
    char* strConst;
    unsigned char boolConst;
    expr* next;
};

struct quad{
    iopcode op;
    expr* result;
    expr* arg1;
    expr* arg2;
    unsigned int label;
    unsigned int line;
};