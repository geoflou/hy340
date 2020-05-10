%{
    #include <stdlib.h>
    #include <stdio.h>
    #include "grammar.h"
    #include "Translation.h"
    
    int yyerror(char* message);
    int yylex(void);

    extern int yylineno;
    extern char* yytext;
    extern FILE* yyin;
    int label=0;
    int scope = 0;
    int old_offset = 0;

    Function* temp_func;
    int arg_index = 0;

    int anonFuncCounter = 1;

    int numquads = 1;

    E_list* paramListHead;
%}

%union{
    int intVal;
    char *strVal;
    double doubleVal;
    //Call* callsuffix;
    //Call* normcall;
    struct call* call;
   struct expr* exp;
}


%start program

%expect 1

%token <strVal> ID
%token <intVal> INTEGER
%token <doubleVal> REAL
%token <strVal> STRING

%token IF
%token ELSE
%token WHILE
%token FOR
%token <strVal> FUNCTION
%token RETURN
%token BREAK
%token CONTINUE
%token AND
%token NOT
%token OR
%token LOCAL_KEYWORD
%token TRUE
%token FALSE
%token NIL
%token WHITESPACE

%type <exp> expr
%type <exp> lvalue

%left SEMICOLON COLON COMMA DOUBLE_COLON
%left LEFT_BRACKET RIGHT_BRACKET
%left LEFT_BRACE RIGHT_BRACE
%left LEFT_PARENTHESIS RIGHT_PARENTHESIS

%right OPERATOR_ASSIGN
%left OR
%left AND

%nonassoc OPERATOR_EQ OPERATOR_NEQ
%right OPERATOR_GRT OPERATOR_LES OPERATOR_GRE OPERATOR_LEE
%left OPERATOR_PLUS OPERATOR_MINUS
%left OPERATOR_MUL OPERATOR_DIV OPERATOR_MOD
%right OPERATOR_NOT OPERATOR_PP OPERATOR_MM

%left DOT DOUBLE_DOT    

%%
program: set   {printf("set -> program\n");}
    |   {printf("EMPTY -> program\n");}
    ;

set: stmt
    |set stmt
    ;

stmt: expr SEMICOLON    {printf("expr ; -> stmt\n");}
    |ifstmt {printf("ifstmt -> stmt\n");}
    |whilestmt  {printf("whilestmt -> stmt\n");}
    |forstmt    {printf("forstmt -> stmt\n");}
    |returnstmt    {printf("returnstmt -> stmt\n");}
    |BREAK SEMICOLON    {printf("break; -> stmt\n");}
    |CONTINUE SEMICOLON {printf("continue; -> stmt\n");}
    |block  {printf("block -> stmt\n");}
    |funcdef    {printf("funcdef -> stmt\n");}
    |SEMICOLON  {printf("; -> stmt\n");}
    ;

expr: assignexpr    {printf("assignexpr -> expr\n");
                        SymbolTableEntry symbol = newTemp(scope,yylineno); 
                       
                        SymbolTableEntry* symptr = (SymbolTableEntry*) malloc(sizeof(SymbolTableEntry) );
                        symptr = &symbol; 

                        Expr* tmp = (Expr*) malloc(sizeof(Expr) );
                        tmp = newExpr(4);
                        tmp -> sym = symptr;
                        $<exp>$ = tmp;
                        emit(assign, $<exp>1, NULL, $<exp>$, (unsigned int)NULL, (unsigned int)yylineno);
                        printf("%d: assign, tmp name: %s [line: %d]\n", numquads, tmp->sym->varVal->name, yylineno);
                        numquads++; //gia na me boi8aei sta jumps
                        //hideEntries(scope);
                    }
    | expr OPERATOR_PLUS expr   {printf("expr + expr -> expr\n");
                                    SymbolTableEntry symbol = newTemp(scope,yylineno); 
                       
                                    SymbolTableEntry* symptr = (SymbolTableEntry*) malloc(sizeof(SymbolTableEntry) );
                                    symptr = &symbol; 

                                    Expr* tmp = (Expr*) malloc(sizeof(Expr) );
                                    tmp = newExpr(arithexpr_e);
                                    tmp -> sym = symptr;
                                    $<exp>$ = tmp; 
                                    emit(add, $<exp>1, $<exp>3,$<exp>$, (unsigned int)NULL, (unsigned int)yylineno);
                                    printf("%d: add, tmp name: %s [line: %d]\n", numquads, tmp->sym->varVal->name, yylineno);
                                    numquads++;
                                    
                                }
    | expr OPERATOR_MINUS expr  {printf("expr - expr -> expr\n");
                                    SymbolTableEntry symbol = newTemp(scope,yylineno); 
                       
                                    SymbolTableEntry* symptr = (SymbolTableEntry*) malloc(sizeof(SymbolTableEntry) );
                                    symptr = &symbol; 

                                    Expr* tmp = (Expr*) malloc(sizeof(Expr) );
                                    tmp = newExpr(arithexpr_e);
                                    tmp -> sym = symptr; 
                                    $<exp>$ = tmp;
                                    emit(sub, $<exp>1, $<exp>3, $<exp>$, (unsigned int)NULL, (unsigned int)yylineno);
                                    printf("%d: sub, tmp name: %s [line: %d]\n", numquads, tmp->sym->varVal->name, yylineno);
                                    numquads++;
                                }
    | expr OPERATOR_MOD expr    {printf("expr % expr -> expr\n");
                                    SymbolTableEntry symbol = newTemp(scope,yylineno); 
                       
                                    SymbolTableEntry* symptr = (SymbolTableEntry*) malloc(sizeof(SymbolTableEntry) );
                                    symptr = &symbol; 

                                    Expr* tmp = (Expr*) malloc(sizeof(Expr) );
                                    tmp = newExpr(arithexpr_e);
                                    tmp -> sym = symptr; 
                                    $<exp>$ = tmp;
                                    emit(mod, $<exp>1, $<exp>3,$<exp>$, (unsigned int)NULL, (unsigned int)yylineno);
                                    printf("%d: mod, tmp name: %s [line: %d]\n", numquads, tmp->sym->varVal->name, yylineno);
                                    numquads++;
                                }
    | expr OPERATOR_DIV expr    {printf("expr / expr -> expr\n");
                                    SymbolTableEntry symbol = newTemp(scope,yylineno); 
                       
                                    SymbolTableEntry* symptr = (SymbolTableEntry*) malloc(sizeof(SymbolTableEntry) );
                                    symptr = &symbol; 

                                    Expr* tmp = (Expr*) malloc(sizeof(Expr) );
                                    tmp = newExpr(arithexpr_e);
                                    tmp -> sym = symptr; 
                                    $<exp>$ = tmp;
                                    emit(divide, $<exp>1, $<exp>3, $<exp>$, (unsigned int)NULL, (unsigned int)yylineno);
                                    printf("%d: divide, tmp name: %s [line: %d]\n", numquads, tmp->sym->varVal->name, yylineno);
                                    numquads++;
                                }
    | expr OPERATOR_MUL expr    {printf("expr * expr -> expr\n");
                                    SymbolTableEntry symbol = newTemp(scope,yylineno); 
                       
                                    SymbolTableEntry* symptr = (SymbolTableEntry*) malloc(sizeof(SymbolTableEntry) );
                                    symptr = &symbol; 

                                    Expr* tmp = (Expr*) malloc(sizeof(Expr) );
                                    tmp = newExpr(arithexpr_e);
                                    tmp -> sym = symptr; 
                                    $<exp>$ = tmp;
                                    emit(mul, $<exp>1, $<exp>3, $<exp>$, (unsigned int)NULL, (unsigned int)yylineno);
                                    printf("%d: mul, tmp name: %s [line: %d]\n", numquads, tmp->sym->varVal->name, yylineno);
                                    numquads++;
                                }
    | expr OPERATOR_GRT expr    {   printf("expr > expr -> expr\n");
                                    SymbolTableEntry symbol = newTemp(scope,yylineno); 
                       
                                    SymbolTableEntry* symptr = (SymbolTableEntry*) malloc(sizeof(SymbolTableEntry) );
                                    symptr = &symbol; 

                                    Expr* tmp = (Expr*) malloc(sizeof(Expr) );
                                    tmp = newExpr(boolexpr_e);
                                    tmp -> sym = symptr; 

                                    emit(if_greater, $<exp>1, $<exp>3, NULL, numquads+3, yylineno);
                                    printf("%d: if greater %s, %s, jump to: %d [line: %d]\n", numquads, (char*)$<exp>1, (char*)$<exp>3, numquads+3, yylineno);
                                    numquads++;
                                    //to false
                                    emit(assign, newExpr_constbool(0), NULL, tmp, (int)NULL, yylineno);
                                    printf("%d: assign %s, 'false' [line: %d]\n", numquads, tmp->sym->varVal->name, yylineno);
                                    numquads++;
                                    emit(jump, NULL, NULL, NULL, numquads+2, yylineno);
                                    printf("%d: jump to %d [line: %d]\n", numquads, numquads+2, yylineno);
                                    numquads++;
                                    //to true
                                    emit(assign, newExpr_constbool(1), NULL, tmp, (int)NULL, yylineno);
                                    printf("%d: assign %s, 'true' [line: %d]\n",numquads, tmp->sym->varVal->name, yylineno);
                                    numquads++;
                                }
    | expr OPERATOR_GRE expr    {   printf("expr >= expr -> expr\n");
                                    SymbolTableEntry symbol = newTemp(scope,yylineno); 
                       
                                    SymbolTableEntry* symptr = (SymbolTableEntry*) malloc(sizeof(SymbolTableEntry) );
                                    symptr = &symbol; 

                                    Expr* tmp = (Expr*) malloc(sizeof(Expr) );
                                    tmp = newExpr(boolexpr_e);
                                    tmp -> sym = symptr; 

                                    emit(if_greatereq, $<exp>1, $<exp>3, NULL, numquads+3, yylineno);
                                    printf("%d: if greatereq %s, %s, jump to: %d [line: %d]\n", numquads, (char*)$<exp>1, (char*)$<exp>3, numquads+3, yylineno);
                                    numquads++;
                                    //to false
                                    emit(assign, newExpr_constbool(0), NULL, tmp, (int)NULL, yylineno);
                                    printf("%d: assign %s, 'false' [line: %d]\n", numquads, tmp->sym->varVal->name, yylineno);
                                    numquads++;
                                    emit(jump, NULL, NULL, NULL, numquads+2, yylineno);
                                    printf("%d: jump to %d [line: %d]\n", numquads, numquads+2, yylineno);
                                    numquads++;
                                    //to true
                                    emit(assign, newExpr_constbool(1), NULL, tmp, (int)NULL, yylineno);
                                    printf("%d: assign %s, 'true' [line: %d]\n",numquads, tmp->sym->varVal->name, yylineno);
                                    numquads++;
                                }
    | expr OPERATOR_LES expr    {   printf("expr < expr -> expr\n");
                                    SymbolTableEntry symbol = newTemp(scope,yylineno); 
                       
                                    SymbolTableEntry* symptr = (SymbolTableEntry*) malloc(sizeof(SymbolTableEntry) );
                                    symptr = &symbol; 

                                    Expr* tmp = (Expr*) malloc(sizeof(Expr) );
                                    tmp = newExpr(boolexpr_e);
                                    tmp -> sym = symptr; 

                                    emit(if_less, $<exp>1, $<exp>3, NULL, numquads+3, yylineno);
                                    printf("%d: if less %s, %s, jump to: %d [line: %d]\n", numquads, (char*)$<exp>1, (char*)$<exp>3, numquads+3, yylineno);
                                    numquads++;
                                    //to false
                                    emit(assign, newExpr_constbool(0), NULL, tmp, (int)NULL, yylineno);
                                    printf("%d: assign %s, 'false' [line: %d]\n", numquads, tmp->sym->varVal->name, yylineno);
                                    numquads++;
                                    emit(jump, NULL, NULL, NULL, numquads+2, yylineno);
                                    printf("%d: jump to %d [line: %d]\n", numquads, numquads+2, yylineno);
                                    numquads++;
                                    //to true
                                    emit(assign, newExpr_constbool(1), NULL, tmp, (int)NULL, yylineno);
                                    printf("%d: assign %s, 'true' [line: %d]\n",numquads, tmp->sym->varVal->name, yylineno);
                                    numquads++;
                                }
    | expr OPERATOR_LEE expr    {   printf("expr <= expr -> expr\n");
                                    SymbolTableEntry symbol = newTemp(scope,yylineno); 
                       
                                    SymbolTableEntry* symptr = (SymbolTableEntry*) malloc(sizeof(SymbolTableEntry) );
                                    symptr = &symbol; 

                                    Expr* tmp = (Expr*) malloc(sizeof(Expr) );
                                    tmp = newExpr(boolexpr_e);
                                    tmp -> sym = symptr; 

                                    emit(if_lesseq, $<exp>1, $<exp>3, NULL, numquads+3, yylineno);
                                    printf("%d: if lesseq %s, %s, jump to: %d [line: %d]\n", numquads, (char*)$<exp>1, (char*)$<exp>3, numquads+3, yylineno);
                                    numquads++;
                                    //to false
                                    emit(assign, newExpr_constbool(0), NULL, tmp, (int)NULL, yylineno);
                                    printf("%d: assign %s, 'false' [line: %d]\n", numquads, tmp->sym->varVal->name, yylineno);
                                    numquads++;
                                    emit(jump, NULL, NULL, NULL, numquads+2, yylineno);
                                    printf("%d: jump to %d [line: %d]\n", numquads, numquads+2, yylineno);
                                    numquads++;
                                    //to true
                                    emit(assign, newExpr_constbool(1), NULL, tmp, (int)NULL, yylineno);
                                    printf("%d: assign %s, 'true' [line: %d]\n",numquads, tmp->sym->varVal->name, yylineno);
                                    numquads++;
                                }
    | expr OPERATOR_EQ expr     {   printf("expr == expr -> expr\n");
                                    SymbolTableEntry symbol = newTemp(scope,yylineno); 
                       
                                    SymbolTableEntry* symptr = (SymbolTableEntry*) malloc(sizeof(SymbolTableEntry) );
                                    symptr = &symbol; 

                                    Expr* tmp = (Expr*) malloc(sizeof(Expr) );
                                    tmp = newExpr(boolexpr_e);
                                    tmp -> sym = symptr; 

                                    emit(if_eq, $<exp>1, $<exp>3, NULL, numquads+3, yylineno);
                                    printf("%d: if eq %s, %s, jump to: %d [line: %d]\n", numquads, (char*)$<exp>1, (char*)$<exp>3, numquads+3, yylineno);
                                    numquads++;
                                    //to false
                                    emit(assign, newExpr_constbool(0), NULL, tmp, (int)NULL, yylineno);
                                    printf("%d: assign %s, 'false' [line: %d]\n", numquads, tmp->sym->varVal->name, yylineno);
                                    numquads++;
                                    emit(jump, NULL, NULL, NULL, numquads+2, yylineno);
                                    printf("%d: jump to %d [line: %d]\n", numquads, numquads+2, yylineno);
                                    numquads++;
                                    //to true
                                    emit(assign, newExpr_constbool(1), NULL, tmp, (int)NULL, yylineno);
                                    printf("%d: assign %s, 'true' [line: %d]\n",numquads, tmp->sym->varVal->name, yylineno);
                                    numquads++;
                                }
    | expr OPERATOR_NEQ expr    {   printf("expr != expr -> expr\n");
                                    SymbolTableEntry symbol = newTemp(scope,yylineno); 
                       
                                    SymbolTableEntry* symptr = (SymbolTableEntry*) malloc(sizeof(SymbolTableEntry) );
                                    symptr = &symbol; 

                                    Expr* tmp = (Expr*) malloc(sizeof(Expr) );
                                    tmp = newExpr(boolexpr_e);
                                    tmp -> sym = symptr; 

                                    emit(if_noteq, $<exp>1, $<exp>3, NULL, numquads+3, yylineno);
                                    printf("%d: if noteq %s, %s, jump to: %d [line: %d]\n", numquads, (char*)$<exp>1, (char*)$<exp>3, numquads+3, yylineno);
                                    numquads++;
                                    //to false
                                    emit(assign, newExpr_constbool(0), NULL, tmp, (int)NULL, yylineno);
                                    printf("%d: assign %s, 'false' [line: %d]\n", numquads, tmp->sym->varVal->name, yylineno);
                                    numquads++;
                                    emit(jump, NULL, NULL, NULL, numquads+2, yylineno);
                                    printf("%d: jump to %d [line: %d]\n", numquads, numquads+2, yylineno);
                                    numquads++;
                                    //to true
                                    emit(assign, newExpr_constbool(1), NULL, tmp, (int)NULL, yylineno);
                                    printf("%d: assign %s, 'true' [line: %d]\n",numquads, tmp->sym->varVal->name, yylineno);
                                    numquads++;
                                }
    | expr AND expr    {    printf("expr && expr -> expr\n");
                            SymbolTableEntry symbol = newTemp(scope,yylineno); 
                       
                            SymbolTableEntry* symptr = (SymbolTableEntry*) malloc(sizeof(SymbolTableEntry) );
                            symptr = &symbol; 

                            Expr* tmp = (Expr*) malloc(sizeof(Expr) );
                            tmp = newExpr(boolexpr_e);
                            tmp -> sym = symptr; 

                            emit(if_eq, $<exp>1, newExpr_constbool(1), NULL, numquads+2, yylineno);
                            printf("%d: if eq %s, 'true', jump to: %d [line: %d]\n", numquads, (char*)$<exp>1, numquads+2, yylineno);
                            numquads++;
                            emit(jump, NULL, NULL, NULL, numquads+5, yylineno);
                            printf("%d: jump to %d [line: %d]\n", numquads, numquads+5, yylineno);
                            numquads++;
                            emit(if_eq, $<exp>3, newExpr_constbool(1), NULL, numquads+2, yylineno);
                            printf("%d: if eq %s, 'true', jump to: %d [line: %d]\n", numquads, (char*)$<exp>3, numquads+2, yylineno);
                            numquads++;
                            emit(jump, NULL, NULL, NULL, numquads+3, yylineno);
                            printf("%d: jump to %d [line: %d]\n", numquads, numquads+3, yylineno);
                            numquads++;
                            //to true
                            emit(assign, newExpr_constbool(1), NULL, tmp, (int)NULL, yylineno);
                            printf("%d: assign %s, 'true' [line: %d]\n",numquads, tmp->sym->varVal->name, yylineno);
                            numquads++;
                            emit(jump, NULL, NULL, NULL, numquads+2, yylineno);
                            printf("%d: jump to %d [line: %d]\n", numquads, numquads+2, yylineno);
                            numquads++;
                            //to false
                            emit(assign, newExpr_constbool(0), NULL, tmp, (int)NULL, yylineno);
                            printf("%d: assign %s, 'false' [line: %d]\n", numquads, tmp->sym->varVal->name, yylineno);
                            numquads++;
                        }
    | expr OR expr  {   printf("expr || expr -> expr\n");
                        SymbolTableEntry symbol = newTemp(scope,yylineno); 
                       
                        SymbolTableEntry* symptr = (SymbolTableEntry*) malloc(sizeof(SymbolTableEntry) );
                        symptr = &symbol; 

                        Expr* tmp = (Expr*) malloc(sizeof(Expr) );
                        tmp = newExpr(boolexpr_e);
                        tmp -> sym = symptr; 

                        emit(if_eq, $<exp>1, newExpr_constbool(1), NULL, numquads+4, yylineno);
                        printf("%d: if eq %s, 'true', jump to: %d [line: %d]\n", numquads, (char*)$<exp>1, numquads+4, yylineno);
                        numquads++;
                        emit(jump, NULL, NULL, NULL, numquads+1, yylineno);
                        printf("%d: jump to %d [line: %d]\n", numquads, numquads+1, yylineno);
                        numquads++;
                        emit(if_eq, $<exp>3, newExpr_constbool(1), NULL, numquads+2, yylineno);
                        printf("%d: if eq %s, 'true', jump to: %d [line: %d]\n", numquads, (char*)$<exp>3, numquads+2, yylineno);
                        numquads++;
                        emit(jump, NULL, NULL, NULL, numquads+3, yylineno);
                        printf("%d: jump to %d [line: %d]\n", numquads, numquads+3, yylineno);
                        numquads++;
                        //to true
                        emit(assign, newExpr_constbool(1), NULL, tmp, (int)NULL, yylineno);
                        printf("%d: assign %s, 'true' [line: %d]\n",numquads, tmp->sym->varVal->name, yylineno);
                        numquads++;
                        emit(jump, NULL, NULL, NULL, numquads+2, yylineno);
                        printf("%d: jump to %d [line: %d]\n", numquads, numquads+2, yylineno);
                        numquads++;
                        //to false
                        emit(assign, newExpr_constbool(0), NULL, tmp, (int)NULL, yylineno);
                        printf("%d: assign %s, 'false' [line: %d]\n", numquads, tmp->sym->varVal->name, yylineno);
                        numquads++;
                    }
    |term   {printf("term -> expr\n");
    $<exp>$ = $<exp>1;}  
    ;

term: LEFT_PARENTHESIS expr RIGHT_PARENTHESIS   {printf("(expr) -> term\n");}
    |OPERATOR_MINUS expr    {   printf("- expr -> term\n");
                                SymbolTableEntry symbol = newTemp(scope,yylineno); 
                                SymbolTableEntry* symptr = (SymbolTableEntry*) malloc(sizeof(SymbolTableEntry) );
                                symptr = &symbol;

                                Expr* tmp = (Expr*) malloc(sizeof(Expr) );
                                tmp = newExpr(arithexpr_e);
                                tmp -> sym = symptr;

                                emit(uminus, $<exp>2, NULL, tmp, (unsigned int)NULL, (unsigned int)yylineno);
                                printf("%d: uminus, tmp name: %s [line: %d]\n", numquads, tmp->sym->varVal->name, yylineno);
                                numquads++;
                            }
    |OPERATOR_NOT expr      {   printf("not expr -> term\n");
                                SymbolTableEntry symbol = newTemp(scope,yylineno); 
                       
                                SymbolTableEntry* symptr = (SymbolTableEntry*) malloc(sizeof(SymbolTableEntry) );
                                symptr = &symbol; 

                                Expr* tmp = (Expr*) malloc(sizeof(Expr) );
                                tmp = newExpr(boolexpr_e);
                                tmp -> sym = symptr; 

                                emit(if_eq, $<exp>1, newExpr_constbool(1), NULL, numquads+4, yylineno);
                                printf("%d: if eq %s, 'true' jump to: %d [line: %d]\n", numquads, (char*)$<exp>1, numquads+4, yylineno);
                                numquads++;
                                emit(jump, NULL, NULL, NULL, numquads+1, yylineno);
                                printf("%d: jump to %d [line: %d]\n", numquads, numquads+1, yylineno);
                                numquads++;
                                //to true
                                emit(assign, newExpr_constbool(1), NULL, tmp, (int)NULL, yylineno);
                                printf("%d: assign %s, 'true' [line: %d]\n",numquads, tmp->sym->varVal->name, yylineno);
                                numquads++;
                                emit(jump, NULL, NULL, NULL, numquads+2, yylineno);
                                printf("%d: jump to %d [line: %d]\n", numquads, numquads+2, yylineno);
                                numquads++;
                                //to false
                                emit(assign, newExpr_constbool(0), NULL, tmp, (int)NULL, yylineno);
                                printf("%d: assign %s, 'false' [line: %d]\n", numquads, tmp->sym->varVal->name, yylineno);
                                numquads++;
                            }
    |OPERATOR_PP lvalue     {   printf("++lvalue -> term\n");
                                if($<exp>2 -> type == tableitem_e){
                                    //printf("mphka\n");
                                   
                                    emit(add, $<exp>$, newExpr_constnum(1), $<exp>$, (unsigned int)NULL, (unsigned int)yylineno);
                                    printf("%d: add [line: %d]\n", numquads, yylineno);
                                    numquads++;
                                    
                                    SymbolTableEntry symbol = newTemp(scope,yylineno); 
                                    SymbolTableEntry* symptr = (SymbolTableEntry*) malloc(sizeof(SymbolTableEntry) );
                                    symptr = &symbol;
                                
                                    Expr* tmp = (Expr*) malloc(sizeof(Expr) );
                                    tmp = newExpr(arithexpr_e);
                                    tmp -> sym = symptr;

                                    emit(assign, $<exp>2, NULL, tmp, (unsigned int)NULL, (unsigned int)yylineno);
                                    printf("%d: assign, tmp name: %s [line: %d]\n", numquads, tmp->sym->varVal->name, yylineno);
                                    numquads++;
                                    
                                    emit(tablesetelem, $<exp>$, $<exp>2 -> index, $<exp>2, (unsigned int)NULL, (unsigned int)yylineno);
                                    printf("%d: tablesetelem [line: %d]\n", numquads, yylineno);
                                    numquads++;
                                   
                                    $<exp>$ = emit_iftableitem($<exp>2, scope, yylineno, (int)NULL);
                                    printf("%d: tablegetelem, [line: %d]\n",numquads, yylineno);
                                    numquads++;
                                
                                }else{
                                    
                                    emit(add, $<exp>2, newExpr_constnum(1), $<exp>2, (unsigned int)NULL, (unsigned int)yylineno);
                                    printf("%d: add [line: %d]\n", numquads, yylineno);
                                    numquads++;
                                
                                    SymbolTableEntry symbol = newTemp(scope,yylineno); 
                                    SymbolTableEntry* symptr = (SymbolTableEntry*) malloc(sizeof(SymbolTableEntry) );
                                    symptr = &symbol;
                                
                                    Expr* tmp = (Expr*) malloc(sizeof(Expr) );
                                    tmp = newExpr(arithexpr_e);
                                    tmp -> sym = symptr;

                                    emit(assign, $<exp>2, NULL, tmp, (unsigned int)NULL, (unsigned int)yylineno);
                                    printf("%d: assign, tmp name: %s [line: %d]\n", numquads, tmp->sym->varVal->name, yylineno);
                                    numquads++;
                                }
                            }
    |lvalue OPERATOR_PP     {   printf("lvalue++ -> term\n");
                                if($<exp>2 -> type == tableitem_e){
                                  
                                    SymbolTableEntry symbol = newTemp(scope,yylineno); 
                                    SymbolTableEntry* symptr = (SymbolTableEntry*) malloc(sizeof(SymbolTableEntry) );
                                    symptr = &symbol;
                                
                                    Expr* tmp = (Expr*) malloc(sizeof(Expr) );
                                    tmp = newExpr(arithexpr_e);
                                    tmp -> sym = symptr;
                                    emit(assign, $<exp>2, NULL, tmp, (unsigned int)NULL, (unsigned int)yylineno);
                                    printf("%d: assign, tmp name: %s [line: %d]\n", numquads, tmp->sym->varVal->name, yylineno);
                                    numquads++;
                                    
                                    emit(add, $<exp>$, newExpr_constnum(1), $<exp>$, (unsigned int)NULL, (unsigned int)yylineno);
                                    printf("%d: add [line: %d]\n", numquads, yylineno);
                                    numquads++;
                                    
                                    emit(tablesetelem, $<exp>$, $<exp>2 -> index, $<exp>2, (unsigned int)NULL, (unsigned int)yylineno);
                                    printf("%d: tablesetelem [line: %d]\n", numquads, yylineno);
                                    numquads++;
                                   
                                    $<exp>$ = emit_iftableitem($<exp>2, scope, yylineno, (int)NULL);
                                    printf("%d: tablegetelem, [line: %d]\n",numquads, yylineno);
                                    numquads++;
                                
                                }else{
                                   
                                    SymbolTableEntry symbol = newTemp(scope,yylineno); 
                                    SymbolTableEntry* symptr = (SymbolTableEntry*) malloc(sizeof(SymbolTableEntry) );
                                    symptr = &symbol;
                                
                                    Expr* tmp = (Expr*) malloc(sizeof(Expr) );
                                    tmp = newExpr(arithexpr_e);
                                    tmp -> sym = symptr;
                                    
                                    emit(assign, $<exp>2, NULL, tmp, (unsigned int)NULL, (unsigned int)yylineno);
                                    printf("%d: assign, tmp name: %s [line: %d]\n", numquads, tmp->sym->varVal->name, yylineno);
                                    numquads++;
                                   
                                    emit(add, $<exp>2, newExpr_constnum(1), $<exp>2, (unsigned int)NULL, (unsigned int)yylineno);
                                    printf("%d: add [line: %d]\n", numquads, yylineno);
                                    numquads++;
                                }
                            }
    |OPERATOR_MM lvalue     {   printf("--lvalue -> term\n");
                                if($<exp>2 -> type == tableitem_e){  
                                   
                                    emit(sub, $<exp>$, newExpr_constnum(1), $<exp>$, (unsigned int)NULL, (unsigned int)yylineno);
                                    printf("%d: sub [line: %d]\n", numquads, yylineno);
                                    numquads++;
                                    
                                    SymbolTableEntry symbol = newTemp(scope,yylineno); 
                                    SymbolTableEntry* symptr = (SymbolTableEntry*) malloc(sizeof(SymbolTableEntry) );
                                    symptr = &symbol;
                                
                                    Expr* tmp = (Expr*) malloc(sizeof(Expr) );
                                    tmp = newExpr(arithexpr_e);
                                    tmp -> sym = symptr;

                                    emit(assign, $<exp>2, NULL, tmp, (unsigned int)NULL, (unsigned int)yylineno);
                                    printf("%d: assign, tmp name: %s [line: %d]\n", numquads, tmp->sym->varVal->name, yylineno);
                                    numquads++;
                                    
                                    emit(tablesetelem, $<exp>$, $<exp>2 -> index, $<exp>2, (unsigned int)NULL, (unsigned int)yylineno);
                                    printf("%d: tablesetelem [line: %d]\n", numquads, yylineno);
                                    numquads++;
                                   
                                    $<exp>$ = emit_iftableitem($<exp>2, scope, yylineno, (int)NULL);
                                    printf("%d: tablegetelem, [line: %d]\n",numquads, yylineno);
                                    numquads++;
                                
                                }else{
                                    
                                    emit(sub, $<exp>2, newExpr_constnum(1), $<exp>2, (unsigned int)NULL, (unsigned int)yylineno);
                                    printf("%d: sub [line: %d]\n", numquads, yylineno);
                                    numquads++;
                                
                                    SymbolTableEntry symbol = newTemp(scope,yylineno); 
                                    SymbolTableEntry* symptr = (SymbolTableEntry*) malloc(sizeof(SymbolTableEntry) );
                                    symptr = &symbol;
                                
                                    Expr* tmp = (Expr*) malloc(sizeof(Expr) );
                                    tmp = newExpr(arithexpr_e);
                                    tmp -> sym = symptr;

                                    emit(assign, $<exp>2, NULL, tmp, (unsigned int)NULL, (unsigned int)yylineno);
                                    printf("%d: assign, tmp name: %s [line: %d]\n", numquads, tmp->sym->varVal->name, yylineno);
                                    numquads++;
                                }
                            }
    |lvalue OPERATOR_MM     {   printf("lvalue-- -> term\n");
                                 if($<exp>2 -> type == tableitem_e){
                                    
                                    SymbolTableEntry symbol = newTemp(scope,yylineno); 
                                    SymbolTableEntry* symptr = (SymbolTableEntry*) malloc(sizeof(SymbolTableEntry) );
                                    symptr = &symbol;
                                
                                    Expr* tmp = (Expr*) malloc(sizeof(Expr) );
                                    tmp = newExpr(arithexpr_e);
                                    tmp -> sym = symptr;

                                    emit(assign, $<exp>2, NULL, tmp, (unsigned int)NULL, (unsigned int)yylineno);
                                    printf("%d: assign, tmp name: %s [line: %d]\n", numquads, tmp->sym->varVal->name, yylineno);
                                    numquads++;
                                    
                                    emit(sub, $<exp>$, newExpr_constnum(1), $<exp>$, (unsigned int)NULL, (unsigned int)yylineno);
                                    printf("%d: sub [line: %d]\n", numquads, yylineno);
                                    numquads++;
                                    
                                    emit(tablesetelem, $<exp>$, $<exp>2 -> index, $<exp>2, (unsigned int)NULL, (unsigned int)yylineno);
                                    printf("%d: tablesetelem [line: %d]\n", numquads, yylineno);
                                    numquads++;
                                   
                                    $<exp>$ = emit_iftableitem($<exp>2, scope, yylineno, (int)NULL);
                                    printf("%d: tablegetelem, [line: %d]\n",numquads, yylineno);
                                    numquads++;
                                
                                }else{               
                                    SymbolTableEntry symbol = newTemp(scope,yylineno); 
                                    SymbolTableEntry* symptr = (SymbolTableEntry*) malloc(sizeof(SymbolTableEntry) );
                                    symptr = &symbol;
                    
                                    Expr* tmp = (Expr*) malloc(sizeof(Expr) );
                                    tmp = newExpr(arithexpr_e);
                                    tmp -> sym = symptr;
                                    $<exp>$ = tmp;
                                    emit(assign, $<exp>2, NULL, $<exp>$, (unsigned int)NULL, (unsigned int)yylineno);
                                    printf("%d: assign, tmp name: %s [line: %d]\n", numquads, tmp->sym->varVal->name, yylineno);
                                    numquads++;
                                    emit(sub, $<exp>2, newExpr_constnum(1), $<exp>2, (unsigned int)NULL, (unsigned int)yylineno);
                                    printf("%d: sub [line: %d]\n", numquads, yylineno);
                                    numquads++;
                                }
                            }
    |primary    {printf("primary -> term\n");
                    $<exp>$ = $<exp>1;}
    ;

assignexpr: lvalue OPERATOR_ASSIGN expr {   printf("lvalue = expr -> assignexpr\n");
                                            emit(assign, $<exp>3, NULL,$<exp>1 ,(unsigned int)NULL,(unsigned int)yylineno);
                                            printf("%d: assign [line: %d]\n", numquads, yylineno);
                                            numquads++;   
                                        }
    ;

primary: lvalue {printf("lvalue -> primary\n");}
    |call   {printf("call -> primary\n");}
    |objectdef  {printf("objectdef -> primary\n");}
    |LEFT_PARENTHESIS funcdef RIGHT_PARENTHESIS {printf("(funcdef) -> primary\n");}
    |const  {printf("const -> primary\n");
                $<exp>$ = $<exp>1;}
    ;

lvalue: ID  {
    printf("ID -> lvalue\n");
    SymbolTableEntry *dummy = lookupScope(yylval.strVal,scope);
    Variable *newvar=(Variable*)malloc(sizeof(struct Variable));
    SymbolTableEntry *newnode=(SymbolTableEntry*)malloc(sizeof(struct SymbolTableEntry));
    newvar->name = yylval.strVal;
    newvar->scope = scope;
    newvar->line = yylineno;
    
    if(scope==0){
        newnode->type = GLOBAL;
    }else{
        newnode->type = LOCAL;
    }
    newnode->varVal = newvar;
    newnode->isActive = 1;
        
    if(dummy!=NULL){
        comparelibfunc(yylval.strVal);
        char *ptr= getEntryType(dummy);
                                
        if(strcmp(ptr,"USERFUNC")== 0){
            if(dummy->isActive==1){
                yyerror("A function has taken already that name!");
            }else{
                insertEntry(newnode);
                $<exp>$=lvalue_expr(newnode);
            }
        }else{
            if(lookupScope(yylval.strVal, 0)==NULL)
            {
                comparelibfunc(yylval.strVal);     
                $<exp>$ = lvalue_expr(newnode);
            }
        }
    }else{
        if(lookupScope(yylval.strVal, 0)==NULL)
            {
        comparelibfunc(yylval.strVal);     
        insertEntry(newnode);
        $<exp>$=lvalue_expr(newnode);
            }
    }
}

    |LOCAL_KEYWORD ID   {
    
        printf("local ID -> lvalue\n");
        SymbolTableEntry *dummy = lookupScope(yylval.strVal,scope);
        Variable *newvar=(Variable*)malloc(sizeof(struct Variable));
        SymbolTableEntry *newnode=(SymbolTableEntry*)malloc(sizeof(struct SymbolTableEntry));
        
        newvar->name = yylval.strVal;
        newvar->scope = scope;
        newvar->line = yylineno;
        
        if(scope==0){
            newnode->type = GLOBAL;
        }else{
            newnode->type = LOCAL;
        }

        newnode->varVal = newvar;
        newnode->isActive = 1;

        if(dummy!=NULL){
            char *ptr= getEntryType(dummy);
            comparelibfunc(yylval.strVal); 
            
            if(ptr=="USERFUNC"){
                if(dummy->isActive==1){
                    yyerror("A function has taken already that name!");
                }else{
                    insertEntry(newnode);
                    $<exp>$=lvalue_expr(newnode);
                }
            }
        }else{
            if(lookupScope(yylval.strVal, 0)==NULL)
            {
        comparelibfunc(yylval.strVal);     
        insertEntry(newnode);
        $<exp>$=lvalue_expr(newnode);
            }
    }
                           
    }
    |DOUBLE_COLON ID    {
        printf("::ID -> lvalue\n");
                        
        if(scope==0){
            if(lookupScope(yylval.strVal,0)){
                comparelibfunc(yylval.strVal);
            }else{
                comparelibfunc(yylval.strVal); 
                Variable *newvar=(Variable*)malloc(sizeof(struct Variable));
                SymbolTableEntry *newnode=(SymbolTableEntry*)malloc(sizeof(struct SymbolTableEntry));
                
                newvar->name = yylval.strVal;
                newvar->scope = scope;
                newvar->line = yylineno;
                newnode->type = GLOBAL;
                newnode->varVal = newvar;
                newnode->isActive = 1;
                
                insertEntry(newnode);
                $<exp>$=lvalue_expr(newnode);
            }

        }else{
            if(lookupScope(yylval.strVal,0)==NULL){
                yyerror("Global variable cannot be found");
            }
        }
                            
    }
    |member {printf("member -> lvalue\n");
        Expr* e= newExpr(tableitem_e);
        $<exp>$-> type= e-> type;

    }
    ;

member: lvalue DOT ID   {printf("lvalue.ID -> mebmer\n");
                            SymbolTableEntry symbol = newTemp(scope,yylineno);
                            $<exp>$ = member_item($<exp>1, "name", scope, yylineno, (int)NULL); 
                            /*den 3eroume pws na paroume to name*/
                            printf("%d: tablegetelem, [line: %d]\n",numquads, yylineno);
                            numquads++;

                            if($<exp>3 != NULL){
                                char* idkifthisworks =(char*) $<exp>3->strConst;   
                                printf("name of $3: %s\n", idkifthisworks);
                            }
                            $<exp>$ = $<exp>1;
                        }
    |lvalue LEFT_BRACE expr RIGHT_BRACE {printf("lvalue[expr] -> member\n");
                                            SymbolTableEntry symbol = newTemp(scope,yylineno);
                                            $<exp>1 = emit_iftableitem($<exp>1, scope, yylineno, (int)NULL);
                                            $<exp>$ = newExpr(tableitem_e);
                                            $<exp>$->sym = $<exp>1->sym;
                                            $<exp>$->index = $<exp>3;

                                            $<exp>$ = member_item($<exp>1, "name", scope, yylineno, (int)NULL);
                                            /*pali den 3eroume to $3.yylVal pws na o kanoume access*/
                                            printf("%d: tablegetelem, [line: %d]\n",numquads, yylineno);
                                            numquads++;
                                        }
    |call DOT ID    {printf("call.id -> member\n");
                        SymbolTableEntry symbol = newTemp(scope,yylineno); 
                        $<exp>$ = member_item($<exp>1, "name", scope, yylineno, (int)NULL); 
                        /*den 3eroume pws na paroume to name*/
                        printf("%d: tablegetelem, [line: %d]\n",numquads, yylineno);
                        numquads++;
                    
    }
    |call LEFT_BRACE expr RIGHT_BRACE   {printf("call[expr] -> member\n");
                        SymbolTableEntry symbol = newTemp(scope,yylineno); 
                        $<exp>$ = member_item($<exp>1, "name", scope, yylineno, (int)NULL); 
                        /*den 3eroume pws na paroume to name*/
                        printf("%d: tablegetelem, [line: %d]\n",numquads, yylineno);
                        numquads++;
                    
    }
    ;

call: call LEFT_PARENTHESIS elist RIGHT_PARENTHESIS {printf("call(elist) -> call\n");
                                                        $<exp>$ = make_call($<exp>1, scope, yylineno, (int)NULL);
                                                        printf("%d: call [line: %d]\n", numquads, yylineno);
                                                        numquads++;
                                                        printf("%d: getretval [line: %d]\n",numquads, yylineno);
                                                        numquads++;
                                    }
    |lvalue callsuffix  {printf("lvalue() -> call\n");
                            $<exp>$ = make_call($<exp>1, scope, yylineno, (int)NULL);
                            printf("%d: call [line: %d]\n", numquads, yylineno);
                            numquads++;
                            printf("%d: getretval [line: %d]\n",numquads, yylineno);
                            numquads++;
                        }
    |LEFT_PARENTHESIS funcdef RIGHT_PARENTHESIS LEFT_PARENTHESIS elist RIGHT_PARENTHESIS
        {   printf("(funcdef)(elist) -> call\n");
            
            E_list* tmpnode = paramListHead;
            while(tmpnode){
                emit(param, (Expr*)tmpnode->e_list_name, NULL, NULL, (int)NULL, yylineno);
                printf("%d: param %s [line: %d]\n",numquads, tmpnode->e_list_name, yylineno);
                tmpnode = tmpnode->next;
                numquads++;
            }

            Expr* func = newExpr(programfunc_e);
            func->sym = $<exp>2;
            $<exp>$ = make_call($<exp>2, scope, yylineno, (int)NULL);
            printf("%d: call [line: %d]\n", numquads, yylineno);
            numquads++;
            printf("%d: getretval [line: %d]\n",numquads, yylineno);
            numquads++;
        }
    ;

callsuffix: methodcall {    printf("methodcall -> callsuffix\n");
                            $<exp>$ = $<exp>1;
                            
                        }
    |normcall   {
                    printf("normcall -> callsuffix\n");
                    $<exp>$ = $<exp>1;
                }
    ;

normcall: LEFT_PARENTHESIS elist RIGHT_PARENTHESIS  {
                                                        E_list* tmpnode = paramListHead;
                                                        while(tmpnode){
                                                            emit(param, (Expr*)tmpnode->e_list_name, NULL, NULL, (int)NULL, yylineno);
                                                            printf("%d: param %s [line: %d]\n",numquads, tmpnode->e_list_name, yylineno);
                                                            tmpnode = tmpnode->next;
                                                            numquads++;
                                                        }
                                                    }
    ;

methodcall: DOUBLE_DOT ID normcall  {printf("..id(elist) -> methodcall\n");
                    $<call>$ -> elist = $<exp>2;
                    $<call>$ -> boolmethod = 1;
                    $<call>$ -> name = (char*) $<exp>1;
                                    }
    ;

elist: expr {   printf("lala\n");
                E_list* dummy = (E_list*)malloc(sizeof(E_list*));
                dummy->e_list_name = (char*)$<exp>1;

                if(paramListHead == NULL){
                    dummy->next = NULL;
                    paramListHead = dummy;
                }else{
                    dummy->next = paramListHead;
                    paramListHead = dummy;
                }
            }
    |expr COMMA elist   {   printf("lala1\n");
                            E_list* dummy = (E_list*)malloc(sizeof(E_list*));
                            dummy->e_list_name = (char*)$<exp>1;
                            
                            if(paramListHead == NULL){
                                dummy->next = NULL;
                                paramListHead = dummy;
                            }else{
                                dummy->next = paramListHead;
                                paramListHead = dummy;
                            }
                        }
    |
    ;

objectdef: LEFT_BRACE elist RIGHT_BRACE {printf("[elist] -> objectdef\n");
                        int i;
                        Expr* t = newExpr(newtable_e);
                        SymbolTableEntry symbol = newTemp(scope,yylineno); 
                        SymbolTableEntry* symptr = (SymbolTableEntry*) malloc(sizeof(SymbolTableEntry) );
                        symptr = &symbol;
                        t -> sym = symptr;
                        $<exp>$=t;
                        printf("mphka\n");
                        emit(tablecreate,NULL,NULL,$<exp>$,NULL,yylineno);
                        for(i=0; $<exp>2; $<exp>2 = $<exp>2 -> next){
                            printf("mphka sthn loop\n");
                            emit(tablesetelem,newExpr_constnum(i++),$<exp>2,t,NULL,yylineno);
                        }
                        $<exp>$=t;
                                    }
    |LEFT_BRACE indexed RIGHT_BRACE {printf("[indexed] -> objectdef\n]");}
    ;

indexed: indexedelem
    |indexedelem COMMA indexed
    ;

indexedelem: LEFT_BRACKET expr COLON expr RIGHT_BRACKET {printf("{expr : expr} -> indexed elem\n");}
    ;

block: LEFT_BRACKET {scope++;} set RIGHT_BRACKET {
        printf("block with stmts -> block\n");
        //hideEntries(scope);
        scope--;
    } 
    |LEFT_BRACKET {scope++;} RIGHT_BRACKET   {
            printf("empty block -> block\n");
            //hideEntries(scope);
            scope--;
        }
    ;

funcdef: FUNCTION ID {

        temp_func -> name = yylval.strVal;
        temp_func -> scope = scope;
        temp_func -> line = yylineno;
         $<exp>2 -> sym = temp_func ;
        // $<exp>2 -> sym -> funcVal -> name = temp_func -> name;

        lvalue_expr($<exp>2->sym);
        printf("%s\n",yylval.strVal);
        
        emit(funcstart, NULL, NULL, (Expr*)temp_func -> name, (unsigned)NULL, numquads);
        printf("%d: funcstart, function name: %s [line: %d]\n", numquads, temp_func -> name, yylineno);
        numquads++;
        old_offset = currscopeoffset();
        enterscopespace();
        resetformalargsoffset();

    }   LEFT_PARENTHESIS idlist RIGHT_PARENTHESIS {

        enterscopespace();
        resetfunclocalsoffset();

        SymbolTableEntry *temp;
        SymbolTableEntry *new_entry;
        Function *new_func;
        int i;

        temp = lookupEverything(temp_func -> name);

        if(temp == NULL){
            new_entry = (SymbolTableEntry *)malloc(sizeof(SymbolTableEntry));
            new_func =  (Function *)malloc(sizeof(Function));
            new_func -> arguments = (char**)malloc(10*sizeof(char *));

            new_func -> name = strdup(temp_func -> name);
            new_func -> scope = temp_func -> scope;
            new_func -> line = temp_func -> line;
            for(i = 0;i < arg_index;i++)
                new_func -> arguments[i] = strdup(temp_func -> arguments[i]);

            new_entry -> isActive = 1;
            new_entry -> varVal = NULL;
            new_entry -> funcVal = new_func;
            new_entry -> type = USERFUNC;

            insertEntry(new_entry);
        }
        else{
            if(temp -> type == LIBFUNC){
                printf("ERROR: FUNCTION NAME REDEFINITION! %s IS A LIBRARY FUNCTION\n", temp_func -> name);
                return;
            }

            if(temp -> type == USERFUNC){
                printf("ERROR: FUNCTION NAME REDEFINITION %s IS ALREADY IN USE\n", temp_func -> name);
                return;
            }

            new_entry = (SymbolTableEntry *)malloc(sizeof(SymbolTableEntry));
            new_func =  (Function *)malloc(sizeof(Function));
            new_func -> arguments = (char**)malloc(10*sizeof(char *));

            new_func -> name = strdup(temp_func -> name);
            new_func -> scope = temp_func -> scope;
            new_func -> line = temp_func -> line;
            for(i = 0;i < arg_index;i++)
            new_func -> arguments[i] = strdup(temp_func -> arguments[i]);

            new_entry -> isActive = 1;
            new_entry -> varVal = NULL;
            new_entry -> funcVal = new_func;
            new_entry -> type = USERFUNC;

            insertEntry(new_entry);
             
        }

    } block    {
        printf("function id(idlist)block -> funcdef\n", yytext);

        exitscopespace();//exiting function locals space
        exitscopespace();//exiting function definition space
        
        //restorecurrscopeoffset(old_offset);
        emit(funcend, NULL, NULL, (Expr*)temp_func -> name, (unsigned)NULL, yylineno);
        printf("%d: funcend, function name: %s [line: %d]\n", numquads, temp_func -> name, yylineno);
        numquads++;

        int i = 0;
        temp_func -> name = "";
        temp_func -> scope = 0;
        temp_func -> line = 0;
        for(i = 0;i < arg_index;i++)
            temp_func -> arguments[i] = "";


    }
    |FUNCTION{
        temp_func -> name = newTempFuncName(anonFuncCounter);
        anonFuncCounter++;
        temp_func -> scope = scope + 1;
        temp_func -> line = yylineno;

        emit(funcstart, NULL, NULL, (Expr*)temp_func -> name, (unsigned)NULL, numquads);
        printf("%d: funcstart, function name: %s [line: %d]\n", numquads, temp_func -> name, yylineno);
        numquads++;
        old_offset = currscopeoffset();
        enterscopespace();
        resetformalargsoffset();

    } LEFT_PARENTHESIS idlist RIGHT_PARENTHESIS {

        enterscopespace();
        resetfunclocalsoffset();

        SymbolTableEntry *temp;
        SymbolTableEntry *new_entry;
        Function *new_func;
        int i;

        temp = lookupEverything(temp_func -> name);

        if(temp == NULL){
            new_entry = (SymbolTableEntry *)malloc(sizeof(SymbolTableEntry));
            new_func =  (Function *)malloc(sizeof(Function));
            new_func -> arguments = (char**)malloc(10*sizeof(char *));

            new_func -> name = strdup(temp_func -> name);
            new_func -> scope = temp_func -> scope;
            new_func -> line = temp_func -> line;
            for(i = 0;i < arg_index;i++)
                new_func -> arguments[i] = strdup(temp_func -> arguments[i]);

            new_entry -> isActive = 1;
            new_entry -> varVal = NULL;
            new_entry -> funcVal = new_func;
            new_entry -> type = USERFUNC;

            insertEntry(new_entry);
            lvalue_expr(new_entry);
        }
        else{
            if(temp -> type == LIBFUNC){
                printf("ERROR: FUNCTION NAME REDEFINITION! %s IS A LIBRARY FUNCTION\n", temp_func -> name);
                return;
            }

            if(temp -> type == USERFUNC){
                printf("ERROR: FUNCTION NAME REDEFINITION %s IS ALREADY IN USE\n", temp_func -> name);
                return;
            }

            new_entry = (SymbolTableEntry *)malloc(sizeof(SymbolTableEntry));
            new_func =  (Function *)malloc(sizeof(Function));
            new_func -> arguments = (char**)malloc(10*sizeof(char *));

            new_func -> name = strdup(temp_func -> name);
            new_func -> scope = temp_func -> scope;
            new_func -> line = temp_func -> line;
            for(i = 0;i < arg_index;i++)
            new_func -> arguments[i] = strdup(temp_func -> arguments[i]);

            new_entry -> isActive = 1;
            new_entry -> varVal = NULL;
            new_entry -> funcVal = new_func;
            new_entry -> type = USERFUNC;

            insertEntry(new_entry);
        }

    } block    {
        printf("function (idlist)block -> funcdef\n");

        exitscopespace();//exiting function locals space
        exitscopespace();//exiting function definition space
        
        //restorecurrscopeoffset(old_offset);
        emit(funcend, NULL, NULL, (Expr*)temp_func -> name, (unsigned)NULL, yylineno);
        printf("%d: funcend, function name: %s [line: %d]\n", numquads, temp_func -> name, yylineno);
        numquads++;

        int i = 0;
        temp_func -> name = "";
        temp_func -> scope = 0;
        temp_func -> line = 0;
        for(i = 0;i < arg_index;i++)
            temp_func -> arguments[i] = "";  
    }
    ;

const: REAL     {
                   

                    $<exp>$ = newExpr_constnum(yylval.doubleVal);  
                    printf("const real: %f\n", yylval.doubleVal);

                }
    |INTEGER    {
                   
                    $<exp>$ = newExpr_constnum(yylval.intVal);
                    printf("const int: %d\n", yylval.intVal);
                }
    |STRING     {
                    
                    $<exp>$ = newExpr_conststring((char*)$<exp>1)
                    printf("const str: %s\n",  (char*)$<exp>1);
                }
    |NIL        {
                   
                    printf("nil\n");
                }
    |TRUE       {
                   

                    Expr* tmp = (Expr*) malloc(sizeof(Expr) );
                    tmp = newExpr(boolexpr_e);
                    tmp -> boolConst = 1; 
                    printf("true\n");
                }
    |FALSE      {
                    Expr* tmp = (Expr*) malloc(sizeof(Expr) );
                    tmp = newExpr(boolexpr_e);
                    tmp -> boolConst = 0; 
                    printf("false\n");
                }
    ;

idlist: ID {
        SymbolTableEntry *temp;
        SymbolTableEntry *new_entry;
        Variable *new_var;

        temp = lookupEverything(yylval.strVal);

        if(temp == NULL){
            new_entry = (SymbolTableEntry*)malloc(sizeof(SymbolTableEntry));
            new_var = (Variable*)malloc(sizeof(Variable));

            temp_func -> arguments[arg_index] = yylval.strVal;
            arg_index++;

            new_var -> name = yylval.strVal;
            new_var -> scope = scope + 1;
            new_var -> line = yylineno;

            new_entry -> isActive = 1;
            new_entry -> varVal = new_var;
            new_entry -> funcVal = NULL;
            new_entry -> type = FORMAL;

            insertEntry(new_entry);
           
        }else{
            if(temp -> type == LIBFUNC){
                printf("ERROR: ARGUMENT NAME REDEFINITION! %s IS A LIBRARY FUNCTION\n", yylval.strVal);
                return;
            }

            if(temp -> type == USERFUNC && temp -> isActive == 1){
                printf("ERROR: ARGUMENT NAME REDEFINITION! %s IS AN ACTIVE USER FUNCTION\n", yylval.strVal);
                return;
            }

            new_entry = (SymbolTableEntry*)malloc(sizeof(SymbolTableEntry));
            new_var = (Variable*)malloc(sizeof(Variable));

            temp_func -> arguments[arg_index] = yylval.strVal;
            arg_index++;

            new_var -> name = yylval.strVal;
            new_var -> scope = scope + 1;
            new_var -> line = yylineno;

            new_entry -> isActive = 1;
            new_entry -> varVal = new_var;
            new_entry -> funcVal = NULL;
            new_entry -> type = FORMAL;

            insertEntry(new_entry);
        }

    }
    |ID {
            SymbolTableEntry *temp;
            SymbolTableEntry *new_entry;
            Variable *new_var;

            temp = lookupEverything(yylval.strVal);

            if(temp == NULL){
                new_entry = (SymbolTableEntry*)malloc(sizeof(SymbolTableEntry));
                new_var = (Variable*)malloc(sizeof(Variable));

                temp_func -> arguments[arg_index] = yylval.strVal;
                arg_index++;

                new_var -> name = yylval.strVal;
                new_var -> scope = scope + 1;
                new_var -> line = yylineno;

                new_entry -> isActive = 1;
                new_entry -> varVal = new_var;
                new_entry -> funcVal = NULL;
                new_entry -> type = FORMAL;

                insertEntry(new_entry);

            }else{
                if(temp -> type == LIBFUNC){
                    printf("ERROR: ARGUMENT NAME REDEFINITION! %s IS A LIBRARY FUNCTION\n", yylval.strVal);
                    return;
                }

                if(temp -> type == USERFUNC && temp -> isActive == 1){
                    printf("ERROR: ARGUMENT NAME REDEFINITION! %s IS AN ACTIVE USER FUNCTION\n", yylval.strVal);
                    return;
                }

                new_entry = (SymbolTableEntry*)malloc(sizeof(SymbolTableEntry));
                new_var = (Variable*)malloc(sizeof(Variable));

                temp_func -> arguments[arg_index] = yylval.strVal;
                arg_index++;

                new_var -> name = yylval.strVal;
                new_var -> scope = scope + 1;
                new_var -> line = yylineno;

                new_entry -> isActive = 1;
                new_entry -> varVal = new_var;
                new_entry -> funcVal = NULL;
                new_entry -> type = FORMAL;

                insertEntry(new_entry);
            } 

        } COMMA idlist
    |
    ;

ifstmt: IF LEFT_PARENTHESIS expr RIGHT_PARENTHESIS stmt   {printf("if(expr) -> ifstmt\n");
                                    Expr* ifexpr = newExpr(boolexpr_e);
                                    ifexpr -> boolConst = 1;
                                    emit(if_eq,ifexpr,NULL,$<exp>3,label+2, yylineno);
                                    printf("%d: if_eq %s [line: %d]\n",numquads, yylval.strVal ,yylineno);
                                    emit(jump,NULL,NULL,NULL,label + 2,yylineno);
                                    printf("%d: jump %d [line: %d]\n",numquads, label, yylineno);}
    |IF LEFT_PARENTHESIS expr RIGHT_PARENTHESIS stmt ELSE stmt    {printf("if(expr) else -> ifstmt\n");
                                    Expr* ifexpr = newExpr(boolexpr_e);
                                    ifexpr -> boolConst = 1;
                                    emit(if_eq,ifexpr,NULL,$<exp>3,label+2, yylineno);
                                    printf("%d: if_eq %s [line: %d]\n",numquads, yylval.strVal ,yylineno);
                                    emit(jump,NULL,NULL,NULL,label,yylineno);
                                    printf("%d: jump %d [line: %d]\n",numquads, label, yylineno);
                                    emit(jump,NULL,NULL,NULL,label,yylineno);
                                    printf("%d: jump %d [line: %d]\n",numquads, label, yylineno);
                                                                        }
    ;

whilestmt: WHILE LEFT_PARENTHESIS expr RIGHT_PARENTHESIS stmt   {printf("while(expr) -> whilestmt\n");
                                    Expr* ifexpr = newExpr(boolexpr_e);
                                    ifexpr -> boolConst = 1;
                                    emit(if_eq,ifexpr,NULL,$<exp>3,label+2, yylineno);
                                    printf("%d: if_eq %s [line: %d]\n",numquads, yylval.strVal ,yylineno);
                                    emit(jump,NULL,NULL,NULL,label,yylineno);
                                    printf("%d: jump %d [line: %d]\n",numquads, label, yylineno);
                                    emit(jump,NULL,NULL,NULL,label,yylineno);
                                    printf("%d: jump %d [line: %d]\n",numquads, label, yylineno);      
                                                }
    ;    

forstmt: FOR LEFT_PARENTHESIS elist SEMICOLON expr SEMICOLON elist RIGHT_PARENTHESIS stmt
        {printf("for(elist;expr;elist)stmt -> forstmt\n");
         Expr* ifexpr = newExpr(boolexpr_e);
                                    ifexpr -> boolConst = 1;
                                    emit(if_eq,ifexpr,NULL,$<exp>3,label+2, yylineno);
                                    printf("%d: if_eq %s [line: %d]\n",numquads, yylval.strVal ,yylineno);
                                    emit(jump,NULL,NULL,NULL,label,yylineno);
                                    printf("%d: jump %d [line: %d]\n",numquads, label, yylineno);
                                    emit(jump,NULL,NULL,NULL,label,yylineno);
                                    printf("%d: jump %d [line: %d]\n",numquads, label, yylineno);  
                                    }
    ;

returnstmt: RETURN expr SEMICOLON   {printf("return expr ; -> returnstmt\n");
                        emit(jump,$<exp>2,NULL,NULL,label,yylineno);
                        printf("%d: return %s [line:%d]\n",numquads,yylval.strVal,yylineno);
                                        } 
    |RETURN SEMICOLON    {printf("return ; -> returnstmt\n");
    emit(ret,NULL,NULL,NULL,NULL,yylineno);
    printf("%d: return  [line:%d]\n",numquads,yylineno);
    }
    ;
%%


int yyerror(char *message){
    printf("%s: in line %d\n", message, yylineno); 
}


int main(int argc, char* argv[]){

    temp_func = (Function *)malloc(sizeof(Function));
    temp_func -> arguments =(char**)malloc(10*sizeof(char*));


    initTable();

    yyparse();

    printEntries();
    printQuads();

    return 0;
}