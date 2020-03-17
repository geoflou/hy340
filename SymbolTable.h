#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>


typedef struct Variable{
    const char *name;
    unsigned int scope;
    unsigned int line;

} Variable;


typedef struct Function{
    const char *name;
    //TODO: Find a way to display function arguments
    unsigned int scope;
    unsigned int line;

} Function;

enum SymbolType{
    GLOBAL, LOCAL, FORMAL,
    USERFUNC, LIBFUNC
};


typedef struct SymbolTableEntry{
    int isActive;
    union{
        Variable *varVal;
        Function *funcVal;
    }value;

    enum SymbolTableType type;

} SymbolTableEntry;