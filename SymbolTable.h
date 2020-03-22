#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>

#define SYMBOL_TABLE_BUCKETS 1034
#define NON_SCOPE_BUCKETS 1024

enum SymbolType{
    GLOBAL,
    LOCAL,
    FORMAL,
    USERFUNC,
    LIBFUNC
};

typedef struct Variable{
    const char *name;
    unsigned int scope;
    unsigned int line;
} Variable;


typedef struct Function{
    const char *name;
    char ** arguments;
    unsigned int scope;
    unsigned int line;
} Function;


typedef struct SymbolTableEntry{
    int isActive;
    union{
        Variable *varVal;
        Function *funcVal;
    } value;
    enum SymbolType type;
    struct SymbolTableEntry *next;
} SymbolTableEntry;


int hashForBucket(char *symbolName);

int hashForScope(int symbolScope);

void InsertEntry(SymbolTableEntry *symbol);

SymbolTableEntry *lookupEverything(char *name);

SymbolTableEntry *lookupScope(int scope);

void hideEntries(int scope);