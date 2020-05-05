%{
    #include <stdlib.h>
    #include <stdio.h>

    #include "SymbolTable.h"
    #include "Translation.h"
    #include "grammar.h"

    int yyerror(char* message);
    int yylex(void);

    extern int yylineno;
    extern char* yytext;
    extern FILE* yyin;

    int scope = 0;
    /*quad* quads= (quad*) = 0;
    unsigned int total = 0;
    unsigned int currentquad = 0; 
    */
    Function* temp_func;
    int arg_index = 0;

    int anonFuncCounter = 1;
%}

%union{
    int intVal;
    char *strVal;
    double doubleVal;
    //Call* callsuffix;
    //Call* normcall;
    //Call* methodcall;
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


%left SEMICOLON COLON COMMA DOUBLE_COLON
%left LEFT_BRACKET RIGHT_BRACKET
%left LEFT_BRACE RIGHT_BRACE
%left LEFT_PARENTHESIS RIGHT_PARENTHESIS

%right OPERATOR_ASSIGN
%left OPERATOR_OR
%left OPERATOR_AND

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

expr: assignexpr    {printf("assignexpr -> expr");
                        /*
                        $tmp = newexpr(arithexpr_e);
                        $tmp->sym = newtemp();
                        emit(assign, $1, null, $tmp);
                        quadcounter++;
                        hide($tmp);
                        */
                    }
    | expr OPERATOR_PLUS expr   {printf("expr + expr -> expr\n");
                                 /*$tmp1 = newexpr(arithexpr_e);
                                    lookupscope($tmp1,scope);
                                    insertEntry($tmp1);
                                   $tmp2 = newexpr(arithexpr_e);
                                   lookupscope($tmp2,scope);
                                    insertEntry($tmp2);
                                   $tmp3 = newexpr(arithexpr_e);
                                   lookupscope($tmp3,scope);
                                    insertEntry($tmp3); 
                                    emit(add,$tmp1,$tmp2,$tmp3);
                                    hide($tmp1);
                                    hide($tmp2);
                                    hide($tmp3); 
                                    meta pou kanoume to emit kanoume hide 
                                    tis metavlhtes gia na mporoume na tis xrhsimopoihsoume
                                    */
                                    
                                    /*
                                    $tmp = newexpr(arithexpr_e);
                                    $tmp->sym = newtemp();
                                    emit(add, $1, $3, $tmp);
                                    quadcount++; //den 3erw an uparxei auto
                                    hide($tmp);
                                    */
                                }
    | expr OPERATOR_MINUS expr  {printf("expr - expr -> expr\n");
                                  /*$tmp1 = newexpr(arithexpr_e);
                                    lookupscope($tmp1,scope);
                                    insertEntry($tmp1);
                                   $tmp2 = newexpr(arithexpr_e);
                                   lookupscope($tmp2,scope);
                                    insertEntry($tmp2);
                                   $tmp3 = newexpr(arithexpr_e);
                                   lookupscope($tmp3,scope);
                                    insertEntry($tmp3); 
                                    emit(sub,$tmp1,$tmp2,$tmp3);
                                    hide($tmp1);
                                    hide($tmp2);
                                    hide($tmp3);
                                     */ 

                                    /*
                                    $tmp = newexpr(arithexpr_e);
                                    $tmp->sym = newtemp();
                                    emit(sub, $1, $3, $tmp);
                                    quadcount++;
                                    hide($tmp);
                                    */                             
                                }
    | expr OPERATOR_MOD expr    {printf("expr % expr -> expr\n");
                                    /*$tmp1 = newexpr(arithexpr_e);
                                    lookupscope($tmp1,scope);
                                    insertEntry($tmp1);
                                   $tmp2 = newexpr(arithexpr_e);
                                   lookupscope($tmp2,scope);
                                    insertEntry($tmp2);
                                   $tmp3 = newexpr(arithexpr_e);
                                   lookupscope($tmp3,scope);
                                    insertEntry($tmp3); 
                                    emit(mod,$tmp1,$tmp2,$tmp3);
                                    hide($tmp1);
                                    hide($tmp2);
                                    hide($tmp3);
                                    */

                                    /*
                                    $tmp = newexpr(arithexpr_e);
                                    $tmp->sym = newtemp();
                                    emit(mod, $1, $3, $tmp);
                                    quadcount++;
                                    hide($tmp);
                                    */
                                }
    | expr OPERATOR_DIV expr    {printf("expr / expr -> expr\n");
                                    /*$tmp1 = newexpr(arithexpr_e);
                                    lookupscope($tmp1,scope);
                                    insertEntry($tmp1);
                                   $tmp2 = newexpr(arithexpr_e);
                                   lookupscope($tmp2,scope);
                                    insertEntry($tmp2);
                                   $tmp3 = newexpr(arithexpr_e);
                                   lookupscope($tmp3,scope);
                                    insertEntry($tmp3); 
                                    emit(add,$tmp1,$tmp2,$tmp3);
                                    hide($tmp1);
                                    hide($tmp2);
                                    hide($tmp3);*/

                                    /*
                                    $tmp = newexpr(arithexpr_e);
                                    $tmp->sym = newtemp();
                                    emit(div, $1, $3, $tmp);
                                    quadcount++;
                                    hide($tmp);
                                    */
                                }
    | expr OPERATOR_MUL expr    {printf("expr * expr -> expr\n");
                                    /*$tmp1 = newexpr(arithexpr_e);
                                    lookupscope($tmp1,scope);
                                    insertEntry($tmp1);
                                   $tmp2 = newexpr(arithexpr_e);
                                   lookupscope($tmp2,scope);
                                    insertEntry($tmp2);
                                   $tmp3 = newexpr(arithexpr_e);
                                   lookupscope($tmp3,scope);
                                    insertEntry($tmp3); 
                                    emit(mul,$tmp1,$tmp2,$tmp3);
                                    hide($tmp1);
                                    hide($tmp2);
                                    hide($tmp3);
                                    */
                                
                                    /*
                                    $tmp = newexpr(arithexpr_e);
                                    $tmp->sym = newtemp();
                                    emit(mul, $1, $3, $tmp);
                                    quadcount++;
                                    hide($tmp);
                                    */
                                }
    | expr OPERATOR_GRT expr    {printf("expr > expr -> expr\n");
                                        /*$tmp1 = newexpr(arithexpr_e);
                                          $tmp2 = newexpr(arithexpr_e);
                                          $tmp3 = newexpr(arithexpr_e);
                                          lookupscope(tmp1,scope);
                                          insertEntry(tmp1);
                                          lookupscope(tmp2,scope);
                                          insertEntry(tmp2);
                                          lookupscope(tmp3,scope);
                                          insertEntry(tmp3);
                                          emit(if_greater, $tmp1, $tmp2, label);
                                          emit(jump , label+2);
                                          emit(assign, $tmp3 ,true);
                                          emit(jump, label+2);
                                          emit(assign, $tmp3, false);
                                          hide($tmp1);
                                          hide($tmp2);
                                          hide($tmp3);*/
                                    
                                    /*  p.x. gia y > z 8a exoume
                                        1: if_greater y z 4 (4 = quadcounter+3)
                                        2: assign $tmp 'false'
                                        3: jump 5 (5 = quadcounter+2)
                                        4: assign $tmp 'true'
                                       
                                    $tmp = newexpr(boolexpr_e);
                                    $tmp->sym = newtemp();
                                    emit(if_greater, $1, $3, quadcounter+3);
                                    quadcounter++;
                                    emit(assign, $tmp, null, false);
                                    quadcounter++;
                                    emit(jump, null,null,quadcounter+2);
                                    quadcounter++;
                                    emit(assign, $tmp, null, true);
                                    quadcounter++;
                                    hide($tmp);
                                    */
                                }
    | expr OPERATOR_GRE expr    {printf("expr >= expr -> expr\n");
                                     /*$tmp1 = newexpr(arithexpr_e);
                                          $tmp2 = newexpr(arithexpr_e);
                                          $tmp3 = newexpr(arithexpr_e);
                                          lookupscope(tmp1,scope);
                                          insertEntry(tmp1);
                                          lookupscope(tmp2,scope);
                                          insertEntry(tmp2);
                                          lookupscope(tmp3,scope);
                                          insertEntry(tmp3);
                                          emit(if_greatereq, $tmp1, $tmp2, label);
                                          emit(jump , label+2);
                                          emit(assign, $tmp3 ,true);
                                          emit(jump, label+2);
                                          emit(assign, $tmp3, false);
                                          hide($tmp1);
                                          hide($tmp2);
                                          hide($tmp3);*/
                                    
                                    /*
                                    $tmp = newexpr(boolexpr_e);
                                    $tmp->sym = newtemp();
                                    emit(if_greatereq, $1, $3, quadcounter+3);
                                    quadcounter++;
                                    emit(assign, $tmp, null, false);
                                    quadcounter++;
                                    emit(jump, null,null,quadcounter+2);
                                    quadcounter++;
                                    emit(assign, $tmp, null, true);
                                    quadcounter++;
                                    hide($tmp);
                                    */
                                }
    | expr OPERATOR_LES expr    {printf("expr < expr -> expr\n");
                                         /*$tmp1 = newexpr(arithexpr_e);
                                          $tmp2 = newexpr(arithexpr_e);
                                          $tmp3 = newexpr(arithexpr_e);
                                          lookupscope(tmp1,scope);
                                          insertEntry(tmp1);
                                          lookupscope(tmp2,scope);
                                          insertEntry(tmp2);
                                          lookupscope(tmp3,scope);
                                          insertEntry(tmp3);
                                          emit(if_less, $tmp1, $tmp2, label);
                                          emit(jump , label+2);
                                          emit(assign, $tmp3 ,true);
                                          emit(jump, label+2);
                                          emit(assign, $tmp3, false);
                                          hide($tmp1);
                                          hide($tmp2);
                                          hide($tmp3);*/
                                
                                    /*
                                    $tmp = newexpr(boolexpr_e);
                                    $tmp->sym = newtemp();
                                    emit(if_less, $1, $3, quadcounter+3);
                                    quadcounter++;
                                    emit(assign, $tmp, null, false);
                                    quadcounter++;
                                    emit(jump, null,null,quadcounter+2);
                                    quadcounter++;
                                    emit(assign, $tmp, null, true);
                                    quadcounter++;
                                    hide($tmp);
                                    */
                                }
    | expr OPERATOR_LEE expr    {printf("expr <= expr -> expr\n");
                                        /*$tmp1 = newexpr(arithexpr_e);
                                          $tmp2 = newexpr(arithexpr_e);
                                          $tmp3 = newexpr(arithexpr_e);
                                          lookupscope(tmp1,scope);
                                          insertEntry(tmp1);
                                          lookupscope(tmp2,scope);
                                          insertEntry(tmp2);
                                          lookupscope(tmp3,scope);
                                          insertEntry(tmp3);
                                          emit(if_lesseq, $tmp1, $tmp2, label);
                                          emit(jump , label+2);
                                          emit(assign, $tmp3 ,true);
                                          emit(jump, label+2);
                                          emit(assign, $tmp3, false);
                                          hide($tmp1);
                                          hide($tmp2);
                                          hide($tmp3);*/
                                
                                    /*
                                    $tmp = newexpr(boolexpr_e);
                                    $tmp->sym = newtemp();
                                    emit(if_lesseq, $1, $3, quadcounter+3);
                                    quadcounter++;
                                    emit(assign, $tmp, null, false);
                                    quadcounter++;
                                    emit(jump, null,null,quadcounter+2);
                                    quadcounter++;
                                    emit(assign, $tmp, null, true);
                                    quadcounter++;
                                    hide($tmp);
                                    */
                                }
    | expr OPERATOR_EQ expr {printf("expr == expr -> expr\n");
                                        /*$tmp1 = newexpr(arithexpr_e);
                                          $tmp2 = newexpr(arithexpr_e);
                                          $tmp3 = newexpr(arithexpr_e);
                                          lookupscope(tmp1,scope);
                                          insertEntry(tmp1);
                                          lookupscope(tmp2,scope);
                                          insertEntry(tmp2);
                                          lookupscope(tmp3,scope);
                                          insertEntry(tmp3);
                                          emit(if_eq, $tmp1, $tmp2, label);
                                          emit(jump , label+2);
                                          emit(assign, $tmp3 ,true);
                                          emit(jump, label+2);
                                          emit(assign, $tmp3, false);
                                          hide($tmp1);
                                          hide($tmp2);
                                          hide($tmp3);*/
                            
                                /*
                                $tmp = newexpr(boolexpr_e);
                                $tmp->sym = newtemp();
                                emit(if_eq, $1, $3, quadcounter+3);
                                quadcounter++;
                                emit(assign, $tmp, null, false);
                                quadcounter++;
                                emit(jump, null,null,quadcounter+2);
                                quadcounter++;
                                emit(assign, $tmp, null, true);
                                quadcounter++;
                                hide($tmp);
                                */
                            }
    | expr OPERATOR_NEQ expr    {printf("expr != expr -> expr\n");
                                        /*$tmp1 = newexpr(arithexpr_e);
                                          $tmp2 = newexpr(arithexpr_e);
                                          $tmp3 = newexpr(arithexpr_e);
                                          lookupscope(tmp1,scope);
                                          insertEntry(tmp1);
                                          lookupscope(tmp2,scope);
                                          insertEntry(tmp2);
                                          lookupscope(tmp3,scope);
                                          insertEntry(tmp3);
                                          emit(if_greater, $tmp1, $tmp2, label);
                                          emit(jump , label+2);
                                          emit(assign, $tmp3 ,true);
                                          emit(jump, label+2);
                                          emit(assign, $tmp3, false);
                                          hide($tmp1);
                                          hide($tmp2);
                                          hide($tmp3);*/
                                
                                    /*
                                    $tmp = newexpr(boolexpr_e);
                                    $tmp->sym = newtemp();
                                    emit(if_noteq, $1, $3, quadcounter+3);
                                    quadcounter++;
                                    emit(assign, $tmp, null, false);
                                    quadcounter++;
                                    emit(jump, null,null,quadcounter+2);
                                    quadcounter++;
                                    emit(assign, $tmp, null, true);
                                    quadcounter++;
                                    hide($tmp);
                                    */
                                }
    | expr OPERATOR_AND expr    {printf("expr && expr -> expr\n");
                                        /*$tmp1 = newexpr(arithexpr_e);
                                          $tmp2 = newexpr(arithexpr_e);
                                          $tmp3 = newexpr(arithexpr_e);
                                          lookupscope(tmp1,scope);
                                          insertEntry(tmp1);
                                          lookupscope(tmp2,scope);
                                          insertEntry(tmp2);
                                          lookupscope(tmp3,scope);
                                          insertEntry(tmp3);
                                          emit(if_eq, $tmp1, true, label+2);
                                          emit(jump , label+5);
                                          emit(if_eq, $tmp2, true, label+2);
                                          emit(jump , label+3);
                                          emit(assign, $tmp3 ,true);
                                          emit(jump, label+2);
                                          emit(assign, $tmp3, false);
                                          hide($tmp1);
                                          hide($tmp2);
                                          hide($tmp3);*/
                                
                                    /*
                                    $tmp = newexpr(boolexpr_e);
                                    $tmp->sym = newtemp();
                                    emit(if_eq, $1, true, quadcounter+2); //estw quad 1
                                    quadcounter++;
                                    emint(jump, null, null, quadcounter+5); //quad 2 (to 1 apo ta 2 meli tou and einai false ara jump sto assign false)
                                    quadcounter++;
                                    emit(if_eq, $3, true, quadcounter+2); //quad 3
                                    quadcounter++;
                                    emint(jump, null, null, quadcounter+3); //quad 4 (to 1 apo ta 2 meli tou and einai false ara jump sto assign false)
                                    quadcounter++;
                                    emit(assign, $tmp, null, true); //quad 5 (kai ta duo einai true)
                                    quadcounter++;
                                    emint(jump, null, null, quadcounter+2); //quad 6 (skip tou assign false)
                                    quadcounter++;
                                    emit(assign, $tmp, null, false); //quad 7 (assign false)
                                    quadcounter++;
                                    hide($tmp);
                                    */
                                }
    | expr OPERATOR_OR expr {printf("expr || expr -> expr\n");
                                        /*$tmp1 = newexpr(arithexpr_e);
                                          $tmp2 = newexpr(arithexpr_e);
                                          $tmp3 = newexpr(arithexpr_e);
                                          lookupscope(tmp1,scope);
                                          insertEntry(tmp1);
                                          lookupscope(tmp2,scope);
                                          insertEntry(tmp2);
                                          lookupscope(tmp3,scope);
                                          insertEntry(tmp3);
                                          emit(if_eq, $tmp1, true, label+4);
                                          emit(jump , label+1);
                                          emit(if_eq, $tmp2, true, label+2);
                                          emit(jump , label+3);
                                          emit(assign, $tmp3 ,true);
                                          emit(jump, label+1);
                                          emit(assign, $tmp3, false);
                                          hide($tmp1);
                                          hide($tmp2);
                                          hide($tmp3);*/

                            /*
                            $tmp = newexpr(boolexpr_e);
                            $tmp->sym = newtemp();
                            emit(if_eq, $1, true, quadcounter+4); //quad 1
                            quadcounter++;
                            emint(jump, null, null, quadcounter+1); //quad 2 (to 1 apo ta 2 meli tou and einai false ara jump sto if_eq)
                            quadcounter++;
                            emit(if_eq, $3, true, quadcounter+2); //quad 3
                            quadcounter++;
                            emint(jump, null, null, quadcounter+3); //quad 4 (to 1 apo ta 2 meli tou and einai false ara jump sto assign false)
                            quadcounter++;
                            emit(assign, $tmp, null, true); //quad 5
                            quadcounter++;
                            emint(jump, null, null, quadcounter+2); //quad 6 (skip tou assign false)
                            quadcounter++;
                            emit(assign, $tmp, null, false); //quad 7 (assign false)
                            quadcounter++;
                            hide($tmp);
                            */
                            }
    |term   {printf("term -> expr\n");}  
    ;

term: LEFT_PARENTHESIS expr RIGHT_PARENTHESIS   {printf("(expr) -> term");}
    |OPERATOR_MINUS expr    {printf("- expr -> term\n");
                            /*$tmp1= newexpr(arithexpr_e); 
                              lookupscope($tmp1,scope);
                              insertEntry($tmp1);
                              emit(uminus, $tmp1 , lvalue);
                              hide($tmp1);*/
                                    }
    |OPERATOR_NOT expr  {printf("not expr -> term\n");
                                        /*$tmp1 = newexpr(arithexpr_e);
                                          lookupscope(tmp1,scope);
                                          insertEntry(tmp1);
                                          emit(if_noteq, $tmp1, lvalue, label+2);
                                          emit(jump , label+3);
                                          emit(assign, $tmp1 ,true);
                                          emit(jump, label+2);
                                          emit(assign, $tmp3, false);
                                          hide($tmp1);*/
                                          }
    |OPERATOR_PP lvalue {printf("++lvalue -> term\n");
                                        /*$tmp1 = newexpr(arithexpr_e);
                                          lookupscope(tmp1,scope);
                                          insertEntry(tmp1);
                                          emit(add,$tmp1,$tmp1,1);
                                          emit(assign,$tmp1,lvalue);
                                          hide($tmp1);*/
                                }
    |lvalue OPERATOR_PP {printf("lvalue++ -> term\n");
                                        /*$tmp1 = newexpr(arithexpr_e);
                                          lookupscope(tmp1,scope);
                                          insertEntry(tmp1);
                                          emit(assign,$tmp1,lvalue);
                                          emit(add,$tmp1,$tmp1,1);
                                          hide($tmp1);*/
                                                    }
    |OPERATOR_MM lvalue {printf("--lvalue -> term\n");
                                        /*$tmp1 = newexpr(arithexpr_e);
                                          lookupscope(tmp1,scope);
                                          insertEntry(tmp1);
                                          emit(add,$tmp1,$tmp1,1);
                                          emit(assign,$tmp1,lvalue);
                                          hide($tmp1);*/
                                          }
    |lvalue OPERATOR_MM {printf("lvalue-- -> term\n");
                                        /*$tmp1 = newexpr(arithexpr_e);
                                          lookupscope(tmp1,scope);
                                          insertEntry(tmp1);
                                          emit(assign,$tmp1,lvalue);
                                          emit(add,$tmp1,$tmp1,1);
                                          hide($tmp1);*/
                                          }
    |primary    {printf("primary -> term\n");}
    ;

assignexpr: lvalue OPERATOR_ASSIGN expr {printf("lvalue = expr -> assignexpr\n");
                                            /*
                                            if(member_item($1, $1.strVal) == null){ 
                                                $tmp = newexpr(assignexpr_e);
                                                $tmp->sym = newtemp();
                                                emit(assign, $1, null, $tmp);
                                                quadcounter++;
                                                hide($tmp);
                                            }else{
                                                $tmp = newexpr(tableitem_e);
                                                $tmp->sym = newtemp();
                                                emit(tablesetelem, $1.yylVal, null, $tmp);//8elw to periexomeno tou lvalue na alla3ei
                                                quadcounter++;
                                                hide($tmp);
                                            }
                                            */
                                        }
    ;

primary: lvalue {printf("lvalue -> primary\n");}
    |call   {printf("call -> primary\n");}
    |objectdef  {printf("objectdef -> primary\n");}
    |LEFT_PARENTHESIS funcdef RIGHT_PARENTHESIS {printf("(funcdef) -> primary\n");}
    |const  {printf("const -> primary\n");}
    ;

lvalue: ID  {
    printf("ID -> lvalue\n");
    /*$$ = $1;*/
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
                                
            if(ptr=="USERFUNC"){
                if(dummy->isActive==1){
                    yyerror("A function has taken already that name!");
                }else{
                    insertEntry(newnode);
                }
            }
        }else{
            comparelibfunc(yylval.strVal);     
            insertEntry(newnode);
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
                }
            }
        }else{
            comparelibfunc(yylval.strVal);    
            insertEntry(newnode);
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
            }

        }else{
            if(lookupScope(yylval.strVal,0)==NULL){
                yyerror("Global variable cannot be found");
            }
        }
                            
    }
    |member {printf("member -> lvalue\n");}
    ;

member: lvalue DOT ID   {printf("lvalue.ID -> mebmer\n");
                            /*
                            $$ = member_item($1, $3.strVal);//id.name 8eloume
                            */

                        }
    |lvalue LEFT_BRACE expr RIGHT_BRACE {printf("lvalue[expr] -> member\n");
                                            /*
                                            $1= emit_iftableitem($1);
                                            $$ = newexpr(tableitem_e);
                                            
                                            $$ = member_item($1, $3.yylVal);//id.periexomeno 8eloume
                                            */
                                        }
    |call DOT ID    {printf("call.id -> member\n");
                        /*
                        $$ = member_item($1, $3.yylVal);//id.periexomeno 8eloume
                        */
                    }
    |call LEFT_BRACE expr RIGHT_BRACE   {printf("call[expr] -> member\n");
                                             /*
                                            $$ = member_item($1, $3.yylVal);//id.periexomeno 8eloume
                                            */
                                        }
    ;

call: call LEFT_PARENTHESIS elist RIGHT_PARENTHESIS {printf("call(elist) -> call\n");
                                                        //$$ = make_call($1, $3);
                                                    }
    |lvalue callsuffix  {printf("lvalue() -> call\n");
                            /*
                            $1 = emit_iftableitem($1);

                            if($3.callsuffix.method){
                                expr* func = $1;
                                $1 = emit_iftableitem(member_item(func, $2.callsuffix.name));
                                $1.callsuffix.elist->next = func;
                            }

                            $$ = make_call($1, $2.callsuffix.elist);
                            */
                        }
    |LEFT_PARENTHESIS funcdef RIGHT_PARENTHESIS LEFT_PARENTHESIS elist RIGHT_PARENTHESIS
        {printf("(funcdef)(elist) -> call\n");
        /*
            expr* $tmp = newexpr(programfunc_e);
            $tmp->sym = $2;
            $$ = make_call($tmp, $5);
        */
        }
    ;

callsuffix: methodcall  {printf("methodcall -> callsuffix\n");
                            /*
                            $$ = $1
                            */
                        }
    |normcall   {printf("normcall -> callsuffix\n");
                    /*
                    $$ = $1;
                    */
                }
    ;

normcall: LEFT_PARENTHESIS elist RIGHT_PARENTHESIS  {
                                                        /*
                                                        $$.normalcall.elist = $2;
                                                        $$.normalcall.method = 0;
                                                        $$.normalcall.name = NULL;
                                                        */
                                                    }
    ;

methodcall: DOUBLE_DOT ID normcall  {printf("..id(elist) -> methodcall\n");
                                        /*
                                        $$.methodcall.elist = $3; //prepei na mpei to head tis listas elist
                                        $$.methodcall.method = 1;
                                        $$.methodcall.name = $2.strVal;
                                        */
                                    }
    ;

elist: expr {
            /*
            $tmp = newexpr(var_e);
            $tmp->sym = newtemp();
            emit(param, $1, null, $tmp);
            quadcounter++;
            hide($tmp);
            */
            }
    |expr COMMA elist   {
                        /*
                        $tmp = newexpr(var_e);
                        $tmp->sym = newtemp();
                        emit(param, $1, null, $tmp);
                        quadcounter++;
                        hide($tmp);
                        */
                        }
    |
    ;

objectdef: LEFT_BRACE elist RIGHT_BRACE {printf("[elist] -> objectdef\n");}
    |LEFT_BRACE indexed RIGHT_BRACE {printf("[indexed] -> objectdef\n]");}
    ;

indexed: indexedelem
    |indexedelem COMMA indexed
    ;

indexedelem: LEFT_BRACKET expr COLON expr RIGHT_BRACKET {printf("{expr : expr} -> indexed elem\n");}
    ;

block: LEFT_BRACKET {scope++;} set RIGHT_BRACKET {
        printf("block with stmts -> block");
        hideEntries(scope);
        scope--;
    } 
    |LEFT_BRACKET {scope++;} RIGHT_BRACKET   {
            printf("empty block -> block\n");
            hideEntries(scope);
            scope--;
        }
    ;

funcdef: FUNCTION ID {

        temp_func -> name = yylval.strVal;
        temp_func -> scope = scope + 1;
        temp_func -> line = yylineno;

        /*
        emit(jump, null, null, quadcounter+3);
        quadcounter++;

        $tmp = newexpr(programfunc_e);
        $tmp->sym = newtemp();
        emit(funcstart, $2, null, $tmp);
        quadcounter++;
        hide($tmp);
        */

    }   LEFT_PARENTHESIS idlist RIGHT_PARENTHESIS {
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
        int i = 0;
        temp_func -> name = "";
        temp_func -> scope = 0;
        temp_func -> line = 0;
        for(i = 0;i < arg_index;i++)
        temp_func -> arguments[i] = "";   
    
        /*
        $tmp = newexpr(programfunc_e);
        $tmp->sym = newtemp();
        emit(funcend, $2, null, $tmp);
        quadcounter++;
        hide($tmp);
        */
    }
    |FUNCTION{
        sprintf(temp_func -> name, "_anon_func_%d", anonFuncCounter);
        anonFuncCounter++;
        temp_func -> scope = scope + 1;
        temp_func -> line = yylineno;
        /*
        emit(jump, null, null, quadcounter+3);
        quadcounter++;
        
        $tmp = newexpr(programfunc_e);
        $tmp->sym = newtemp();
        emit(funcstart, temp_func -> name, null, $tmp);
        quadcounter++;
        hide($tmp);
        */

    } LEFT_PARENTHESIS idlist RIGHT_PARENTHESIS {
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
        printf("function (idlist)block -> funcdef\n");
        int i = 0;
        temp_func -> name = "";
        temp_func -> scope = 0;
        temp_func -> line = 0;
        for(i = 0;i < arg_index;i++)
            temp_func -> arguments[i] = "";  
    
        /*
        $tmp = newexpr(programfunc_e);
        $tmp->sym = newtemp();
        emit(funcend, temp_func -> name, null, $tmp);
        quadcounter++;
        hide($tmp);
        */
    }
    ;

const: REAL {   /*//8a dimiourgei ena entry ston symbol table: expr* me type constnum_e
                //kai numConst = yylval.dbVal;
                $tmp = newexpr(constnum_e);
                $tmp->numConst = yylval.dbVal;
                */                  
            }
    |INTEGER{   /*//8a dimiourgei ena entry ston symbol table: expr* me type constnum_e
                //kai numConst = yylval.intVal; to numConst einai double, den 3erw an 8a exei 8ema
                $tmp = newexpr(constnum_e);
                $tmp->numConst = yylval.intVal;
                */                  
            }
    |STRING {   /*//8a dimiourgei ena entry ston symbol table: expr* me type conststring_e
                //kai strConst = yylval.strVal;
                $tmp = newexpr(conststring_e);
                $tmp->strConst = yylval.strVal;
                */                  
            }
    |NIL    {   /*//8a dimiourgei ena entry ston symbol table: expr* me type nill_e
                $tmp = newexpr(nill_e);
                */                  
            }
    |TRUE   {   /*//8a dimiourgei ena entry ston symbol table: expr* me type constbool_e
                //kai boolConst = 1;
                $tmp = newexpr(boolexpr_e);
                $tmp->boolConst = '1';
                */                  
            }
    |FALSE  {  /*//8a dimiourgei ena entry ston symbol table: expr* me type constbool_e
                //kai boolConst = 0;
                $tmp = newexpr(boolexpr_e);
                $tmp->boolConst = '0';
                */                  
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
        /*
        $tmp = newexpr(var_e);
        $tmp->sym = newtemp();
        emit(param, $1, null, $tmp);
        quadcounter++;
        hide($tmp);
        */
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

        /*
        $tmp = newexpr(var_e);
        $tmp->sym = newtemp();
        emit(param, $1, null, $tmp);
        quadcounter++;
        hide($tmp);
        */
        } COMMA idlist
    |
    ;

ifstmt: IF LEFT_PARENTHESIS expr RIGHT_PARENTHESIS {/*$tmp = newexpr(boolexpr_e);
                                                    $tmp->sym = newtemp();
                                                    emit(if_eq, $3, true, quadcounter+1); //mporei na min 8elei to expr alla tin krufi metabliti stin opoia balame to apotelesma
                                                    quadcounter++;
                                                    emit(jump, null, null, ??); //den exw tin paramikri idea pws briskoume auto to label
                                                    quadcounter++;
                                                    hide($tmp);
                                                    */
                                                    }
        stmt   {printf("if(expr) -> ifstmt\n");}
    |IF LEFT_PARENTHESIS expr RIGHT_PARENTHESIS {/*$tmp = newexpr(boolexpr_e);
                                                    $tmp->sym = newtemp();
                                                    emit(if_eq, $3, true, quadcounter+1); //mporei na min 8elei to expr alla tin krufi metabliti stin opoia balame to apotelesma
                                                    quadcounter++;
                                                    emit(jump, null, null, ??); //den exw tin paramikri idea pws briskoume auto to label
                                                    quadcounter++;
                                                    hide($tmp);
                                                    */
                                                }
    stmt ELSE   {/*emit(jump, null, null, ??); //den exw tin paramikri idea pws briskoume auto to label
                quadcounter++;
                */}
    stmt    {printf("if(expr) else -> ifstmt\n");}
    ;

whilestmt: WHILE LEFT_PARENTHESIS {/*int quadforwhile = quadcount;*/} 
            expr RIGHT_PARENTHESIS {/*$tmp = newexpr(boolexpr_e);
                                    $tmp->sym = newtemp();
                                    emit(if_eq, $4, true, quadcounter+1); //mporei na min 8elei to expr alla tin krufi metabliti stin opoia balame to apotelesma
                                    quadcounter++;
                                    emit(jump, null, null, ??); //den exw tin paramikri idea pws briskoume auto to label
                                    quadcounter++;
                                    hide($tmp);
                                    */}
            stmt    {printf("while(expr) -> whilestmt\n");                                                   
                        /*emit(jump, null, null, quadforwhile);
                        quadcounter++;
                        int endofwhile = quadcounter; //isws etsi alla den eimai sigouri
                        */
                    }
    ;    

forstmt: FOR LEFT_PARENTHESIS elist SEMICOLON {/*int quadforfor = quadcount;*/} 
            expr SEMICOLON {/*$tmp = newexpr(boolexpr_e);
                            $tmp->sym = newtemp();
                            emit(if_eq, $6, true, quadcounter+1); //mporei na min 8elei to expr alla tin krufi metabliti stin opoia balame to apotelesma
                            quadcounter++;
                            emit(jump, null, null, ??); //den exw tin paramikri idea pws briskoume auto to label alla paei sto stmtquad
                            quadcounter++;
                            hide($tmp);
                            int quadforelist = quadcounter;*/}
            elist RIGHT_PARENTHESIS {/*emit(jump, null, null, quadforfor); //den exw tin paramikri idea pws briskoume auto to label
                                      quadcounter++;
                                      int stmtquad = curentquad;
                                      */}
            stmt {printf("for(elist;expr;elist)stmt -> forstmt\n");
                 /*
                emit(jump, null, null, quadforelist); 
                quadcounter++;
                 */
                 }
    ;

returnstmt: RETURN expr SEMICOLON   {printf("return expr ; -> returnstmt\n");
                                        /*
                                        $tmp = newexpr(var_e);
                                        $tmp->sym = newtemp();
                                        emit(return, $2, null, $tmp);
                                        quadcounter++;
                                        hide($tmp);
                                        */
                                    } 
    |RETURN SEMICOLON    {printf("return ; -> returnstmt\n");
                            /*
                            emit(return, null, null, null);
                            quadcounter++;
                            */
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

    return 0;
}