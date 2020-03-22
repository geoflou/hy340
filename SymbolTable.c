#include "SymbolTable.h"

SymbolTableEntry SymbolTable[1034];

int hashForBucket(char *symbolName){
    return (atoi(symbolName) * HASH_NUMBER) % NON_SCOPE_BUCKETS;
}

int hashForScope(int symbolScope){
    return ((symbolScope * HASH_NUMBER) % SCOPE_BUCKETS) + NON_SCOPE_BUCKETS;
}