#include "SymbolTable.h"


SymbolTableEntry *SymbolTable[1034];



int hashForBucket(char *symbolName){
    assert(symbolName != NULL);
    return (atoi(symbolName) * HASH_NUMBER) % NON_SCOPE_BUCKETS;
}


int hashForScope(int symbolScope){
    return ((symbolScope * HASH_NUMBER) % SCOPE_BUCKETS) + NON_SCOPE_BUCKETS;
}


void insertEntry(SymbolTableEntry *symbol){
}


SymbolTableEntry *lookupEverything(char *name){

}


SymbolTableEntry *lookupScope(char *name, int scope){

}


void hideEntries(int scope){

}