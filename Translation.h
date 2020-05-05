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
    div,
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

typedef struct expr{
    enum expr_t type;
    SymbolTableEntry* sym;
    expr* index;
    double numConst;
    char* strConst;
    unsigned char boolConst;
    expr* next;
} expr;

typedef struct quad{
    enum iopcode op;
    expr* result;
    expr* arg1;
    expr* arg2;
    unsigned int label;
    unsigned int line;
} quad;

typedef struct Call{
    expr* elist;
    unsigned char method;
    char* name;
} Call;


expr newExpr(enum expr_t type);

SymbolTableEntry newTemp();
/*estw oti auti i sunartisi ftiaxnei mia kainourgia metabliti gia na tin balei ston symboltable
prwta elegxei an uparxei idi (lookupscope) kai meta tin kanei insert i guess...*/

//TODO -> this will need some helper functions..
//kanonika einai iopcode, result, expr 1, expr 2 stin emit... dior8ose to
void emit(enum iopcode, expr arg1, expr arg2, expr result);

//slide 25 front4, exei kwdika gia ta tablelements pros8ese ton pliz
//episis pros8ese ena quadcounter++ kai ena hide($tmp);