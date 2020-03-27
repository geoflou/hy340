#include "SymbolTable.h"


SymbolTableEntry *SymbolTable[1034];


void initTable(void){
    int i;

    for(i = 0;i < SYMBOL_TABLE_BUCKETS;i++){
        SymbolTable[i] = (SymbolTableEntry*)malloc(sizeof(SymbolTableEntry));
        SymbolTable[i] -> isActive = 0;
        SymbolTable[i] -> next = NULL;
        SymbolTable[i] -> type = GLOBAL;
        SymbolTable[i] -> funcVal = NULL;
        SymbolTable[i] -> varVal = NULL;
    }

    return;
}


int hashForBucket(char *symbolName){
    assert(symbolName != NULL);
    return (atoi(symbolName) * HASH_NUMBER) % NON_SCOPE_BUCKETS;
}


int hashForScope(int symbolScope){
    return (symbolScope % SCOPE_BUCKETS) + NON_SCOPE_BUCKETS;
}


void insertEntry(SymbolTableEntry *symbol){
    int bucket, scopeLink;
    int scope;
    char *name;
    SymbolTableEntry *scopeLinkSymbol, *symbolIndex;

    assert(symbol != NULL);

    if(symbol -> funcVal != NULL){
        scope = symbol -> funcVal -> scope;
        name =  symbol -> funcVal -> name;
    }

    if(symbol -> varVal != NULL){
        scope = symbol -> varVal -> scope;
        name = symbol -> varVal -> name;
    }

    scopeLinkSymbol = (SymbolTableEntry *) malloc(sizeof(SymbolTableEntry));
    scopeLinkSymbol -> isActive = symbol ->isActive;
    scopeLinkSymbol -> varVal = symbol -> varVal;
    scopeLinkSymbol -> funcVal = symbol -> funcVal;
    scopeLinkSymbol -> next = NULL;
    scopeLinkSymbol -> type = symbol -> type;

    bucket = hashForBucket(name);
    scopeLink = hashForScope(scope);

    assert(SymbolTable[bucket] != NULL);
    assert(SymbolTable[scopeLink] != NULL);

    if(SymbolTable[bucket] -> next == NULL){
        SymbolTable[bucket] -> next = symbol;
    }    
    else{
        symbolIndex = SymbolTable[bucket] -> next;
        while(symbolIndex -> next != NULL){
            symbolIndex = symbolIndex -> next;
        }

        symbolIndex -> next = symbol;
    }

    if(SymbolTable[scopeLink] -> next == NULL){
        SymbolTable[scopeLink] -> next = scopeLinkSymbol;
    }
    else{
        symbolIndex = SymbolTable[scopeLink] -> next;
        while(symbolIndex -> next != NULL){
            symbolIndex = symbolIndex -> next;
        }

        symbolIndex -> next = scopeLinkSymbol;
    }

    return;
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

    symbolIndex = SymbolTable[bucket];

    while(symbolIndex != NULL){
        
        if(symbolIndex -> varVal != NULL){
            varTMP = symbolIndex -> varVal;
            if(strcmp(varTMP -> name, name) == 0){
                return symbolIndex;
            }
        }

        if(symbolIndex -> funcVal != NULL){
            funcTMP = symbolIndex -> funcVal;
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
        
        if(symbolIndex -> varVal != NULL){
            varTMP = symbolIndex -> varVal;
            if(strcmp(varTMP -> name, name) == 0){
                return symbolIndex;
            }
        }

        if(symbolIndex -> funcVal != NULL){
            funcTMP = symbolIndex -> funcVal;
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
 
            if(symbolIndex -> varVal != NULL){
                varTMP = symbolIndex -> varVal;
                if(varTMP -> scope == scope){
                    symbolIndex -> isActive = 0;
                }
            }

            if(symbolIndex -> funcVal != NULL){
                funcTMP = symbolIndex -> funcVal;
                if(funcTMP -> scope == scope){
                    symbolIndex -> isActive = 0;
                }
            }

            symbolIndex = symbolIndex ->next;
        }
    }

    return;
}


void printEntries(void){
    int i;
    SymbolTableEntry *symbolIndex;
    Variable *varTMP;
    Function *funcTMP; 

    for(i = 0;i < 10;i++){
       
        printf("---------------  Scope #%d  ---------------\n", i);
        symbolIndex = SymbolTable[NON_SCOPE_BUCKETS + i];
       
        if(symbolIndex == NULL){
           continue;
        }
        symbolIndex = symbolIndex -> next;
        while(symbolIndex != NULL){
            printf("\"%s\"  [%s]    (line %d)   (scope %d)\n",getEntryName(symbolIndex),
                getEntryType(symbolIndex), getEntryLine(symbolIndex), getEntryScope(symbolIndex));
            symbolIndex = symbolIndex -> next;
        }

    }
    return;
}


char *getEntryType(SymbolTableEntry *symbol){
    switch (symbol -> type)
    {
    case GLOBAL:
        return "global variable";
    
    case LOCAL:
        return "local variable";
    
    case FORMAL:
        return "formal argument";

    case USERFUNC:
        return "user function";

    case LIBFUNC:
        return "library function";
    
    default:
        assert(0);
    }
}


char *getEntryName(SymbolTableEntry *symbol){
    Variable *varTMP;
    Function *funcTMP;

    if(symbol -> funcVal != NULL){
        funcTMP = symbol -> funcVal;
        return funcTMP -> name;
    }

    if(symbol -> varVal != NULL){
        varTMP = symbol -> varVal;
        return varTMP -> name;
    }

    assert(0);
}


int getEntryLine(SymbolTableEntry *symbol){
    Variable *varTMP;
    Function *funcTMP;

    if(symbol -> funcVal != NULL){
        funcTMP = symbol -> funcVal;
        return funcTMP -> line;
    }

    if(symbol -> varVal != NULL){
        varTMP = symbol -> varVal;
        return varTMP -> line;
    }

    assert(0);
}


int getEntryScope(SymbolTableEntry *symbol){
    Variable *varTMP;
    Function *funcTMP;

    if(symbol -> funcVal != NULL){
        funcTMP = symbol -> funcVal;
        return funcTMP -> scope;
    }

    if(symbol -> varVal != NULL){
        varTMP = symbol -> varVal;
        return varTMP -> scope;
    }

    assert(0);
}



void main(void){
    SymbolTableEntry *symbol = (SymbolTableEntry*)malloc(sizeof(SymbolTableEntry));
    Variable *var = (Variable*)malloc(sizeof(Variable));

    var -> line = 1;
    var -> name = "Elpizw na doylepseis";
    var -> scope = 7;

    initTable();

    symbol -> isActive = 1;
    symbol -> type = GLOBAL;
    symbol -> varVal = var;
    symbol -> funcVal = NULL;
    symbol -> next = NULL;

    lookupEverything(symbol->varVal->name);
    insertEntry(symbol);
    printEntries();

    return;
}