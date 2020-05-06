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


void emit(
        enum iopcode op,
        Expr* arg1,
        Expr* arg2,
        Expr* result,
        unsigned label,
        unsigned line
        ){

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