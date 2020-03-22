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
    int bucket;
    SymbolTableEntry *symbolIndex;
    Variable *varTMP;
    Function *funcTMP;

    assert(name != NULL);

    bucket = hashForBucket(name);
    if(SymbolTable[bucket] == NULL){
        return NULL;
    }

    symbolIndex = SymbolTable[bucket] -> next;
    assert(symbolIndex != NULL);

    while(symbolIndex != NULL){
        
        if(symbolIndex -> value.varVal != NULL){
            varTMP = symbolIndex -> value.varVal;
            if(strcmp(varTMP -> name, name) == 0){
                return symbolIndex;
            }
        }

        if(symbolIndex -> value.funcVal != NULL){
            funcTMP = symbolIndex -> value.funcVal;
            if(strcmp(funcTMP -> name, name) == 0){
                return symbolIndex;
            }
        }
        symbolIndex = symbolIndex -> next;
    }

    return NULL;
}


SymbolTableEntry *lookupScope(char *name, int scope){
    int bucket;
    SymbolTableEntry *symbolIndex;
    Variable *varTMP;
    Function *funcTMP;

    assert(name != NULL);

    bucket = hashForScope(scope);
    if(SymbolTable[bucket] == NULL){
        return NULL;
    }

    symbolIndex = SymbolTable[bucket] -> next;

    while(symbolIndex != NULL){
        
        if(symbolIndex -> value.varVal != NULL){
            varTMP = symbolIndex -> value.varVal;
            if(strcmp(varTMP -> name, name) == 0){
                return symbolIndex;
            }
        }

        if(symbolIndex -> value.funcVal != NULL){
            funcTMP = symbolIndex -> value.funcVal;
            if(strcmp(funcTMP -> name, name) == 0){
                return symbolIndex;
            }
        }
        symbolIndex = symbolIndex -> next;
    }

    return NULL;
}


void hideEntries(int scope){
    hideFromScopeLink(scope);
    hideFromBuckets(scope);
    return;
}

void hideFromScopeLink(int scope){
    int bucket;
    SymbolTableEntry *symbolIndex;

    bucket = hashForScope(scope);
    if(SymbolTable[bucket] == NULL){
        return;
    }

    symbolIndex = SymbolTable[bucket] -> next;

    while(symbolIndex != NULL){
        symbolIndex -> isActive = 0;
        symbolIndex = symbolIndex ->next;
    }

    return;
}

void hideFromBuckets(int scope){
    int i;
    SymbolTableEntry *symbolIndex;
    Variable *varTMP;
    Function *funcTMP;
    
    for(i = 0;i < NON_SCOPE_BUCKETS;i++){
        
        if(SymbolTable[i] == NULL){
            continue;
        }

        symbolIndex = SymbolTable[i] -> next;

        while(symbolIndex != NULL){
 
            if(symbolIndex -> value.varVal != NULL){
                varTMP = symbolIndex -> value.varVal;
                if(varTMP -> scope == scope){
                    symbolIndex -> isActive = 0;
                }
            }

            if(symbolIndex -> value.funcVal != NULL){
                funcTMP = symbolIndex -> value.funcVal;
                if(funcTMP -> scope == scope){
                    symbolIndex -> isActive = 0;
                }
            }

            symbolIndex = symbolIndex ->next;
        }
    }

    return;
}