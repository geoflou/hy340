/*Syntax analysis*/


/*prologue*/
        %{
            #include <stdio.h>
            #include <stdlib.h>
            #include "SymbolTable.h"
            #include "al1.h"



            int yyerror (char* message);
            int yylex(void);


            extern int yylineno;
            extern char* yytext;
            extern FILE* yyin();

            int Scope = 0;
            int i;
            SymbolTableEntry* tmp;
            char* funcname1 = "$f";
            int funcname2 = 1;
            char* funcname;

            %}

/*yacc stuff*/
  
  %union { 
    int intVal; 
    char *strVal; 
    double doubleVal; 
  } 

%start program
                %expect 1
                %token <strVal> ID /*tokens*/
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
               
                   

                /*dependencies from lower to higher*/
                %left SEMICOLON COLON COMMA DOUBLE_COLON  

                %left LEFT_BRACKET RIGHT_BRACKET

                %right OPERATOR_ASSIGN

                %left OPERATOR_OR

                %left OPERATOR_AND

                %nonassoc OPERATOR_EQ OPERATOR_NEQ

                %right OPERATOR_GRT OPERATOR_LES OPERATOR_GRE OPERATOR_LEE 

                %left  OPERATOR_PLUS OPERATOR_MINUS

                %left OPERATOR_MUL OPERATOR_DIV OPERATOR_MOD

                %right OPERATOR_NOT OPERATOR_PP OPERATOR_MM

                %left DOT DOUBLE_DOT

                %left LEFT_BRACE RIGHT_BRACE    
                
                %left LEFT_PARENTHESIS RIGHT_PARENTHESIS

                
                 
              %%
      /*File -> preferences -> color theme -> install additional color themes -> Abyss, thank me later*/


            /*Alpha grammar rules*/

              program:    stmt
                          | program WHITESPACE stmt
                          ;

              stmt:       expr SEMICOLON
                          |ifstmt
                          |whilestmt
                          |forstmt
                          |returnstmt
                          |BREAK SEMICOLON
                          |CONTINUE SEMICOLON
                          |block
                          |funcdef
                          |/*empty*/
                          ;
              
              expr:       assignexpr
                          | expr OPERATOR_PLUS expr    
                          | expr OPERATOR_MINUS expr   
                          | expr OPERATOR_MOD expr          
                          | expr OPERATOR_DIV expr           
                                                       
                          | expr OPERATOR_MUL expr     
                          | expr OPERATOR_GRT expr     
                          | expr OPERATOR_GRE expr     
                          | expr OPERATOR_LES expr
                          | expr OPERATOR_LEE expr
                          | expr OPERATOR_EQ expr
                          | expr OPERATOR_NEQ expr
                          | expr OPERATOR_AND expr
                          | expr OPERATOR_OR expr
                          | term
                          ;
            

             term:        LEFT_PARENTHESIS expr RIGHT_PARENTHESIS
                          |OPERATOR_MINUS expr
                          |OPERATOR_NOT expr
                          |OPERATOR_PP lvalue
                          |lvalue OPERATOR_PP
                          |OPERATOR_MM lvalue
                          |lvalue OPERATOR_MM
                          |primary
                          ;                  

            assignexpr:   lvalue OPERATOR_ASSIGN expr
                          ;

            primary:       call
                          |lvalue
                          |objectdef
                          |LEFT_PARENTHESIS funcdef RIGHT_PARENTHESIS
                          |const
                          ;

            lvalue:       ID {
                                i = Scope;
                                yylval.strVal = yytext;

                                while(i >= 0){
                                    tmp = lookupScope(yylval.strVal, i);

                                    if(tmp != NULL){ /*we found xxx in this scope*/
                                        if((*getEntryType(tmp) == USERFUNC) || (*getEntryType(tmp) == LIBFUNC)){
                                        /*check if there is a redefinitio or if this function can access this var*/
                                            printf("ERROR: var %s redefined as a function\n", yylval.strVal);
                                        }
                                        break;
                                    }
                                    i--;
                                }

                                if(i < 0){ /*we didn't find id in the table so we add it*/
                                    if(Scope == 0){/*we have a global id*/
                                        Variable *newvar= (Variable *)malloc(sizeof(struct Variable));
                                        SymbolTableEntry *newnode= (SymbolTableEntry*)malloc(sizeof(struct SymbolTableEntry));
                                        newvar -> name = yytext;
                                        newvar -> scope = 0;
                                        newvar -> line = yylineno;
                                        newnode -> type = GLOBAL;
                                        newnode -> varVal = newvar;
                                        newnode -> isActive = 1;
                                 
                                        insertEntry(newnode);
                                    }else{/*it's a local id*/
                                        Variable *newvar= (Variable *)malloc(sizeof(struct Variable));
                                        SymbolTableEntry *newnode= (SymbolTableEntry*)malloc(sizeof(struct SymbolTableEntry));
                                        newvar -> name = yytext;
                                        newvar -> scope = Scope;
                                        newvar -> line = yylineno;
                                        newnode -> type = LOCAL;
                                        newnode -> varVal = newvar;
                                        newnode -> isActive = 1;
                                 
                                        insertEntry(newnode);
                                    }
                                }
                              }
                          | LOCAL_KEYWORD ID 
                          {
                            tmp = lookupScope(yylval.strVal, 0);

                                if(tmp != NULL){ /*we found xxx in this scope*/
                                    if(*getEntryType(tmp) == LIBFUNC){
                                    /*check if this var can shadow a lib function*/
                                        printf("ERROR: var %s cannot shadow a library function\n", yylval.strVal);
                                    }
                                }
                                /*we didn't find id in the table so we add it*/
                                if(Scope == 0){/*we have a global id*/
                                    Variable *newvar= (Variable *)malloc(sizeof(struct Variable));
                                    SymbolTableEntry *newnode= (SymbolTableEntry*)malloc(sizeof(struct SymbolTableEntry));
                                    newvar -> name = yytext;
                                    newvar -> scope = 0;
                                    newvar -> line = yylineno;
                                    newnode -> type = GLOBAL;
                                    newnode -> varVal = newvar;
                                    newnode -> isActive = 1;

                                    insertEntry(newnode);
                                }else{/*it's a local id*/
                                    Variable *newvar= (Variable *)malloc(sizeof(struct Variable));
                                    SymbolTableEntry *newnode= (SymbolTableEntry*)malloc(sizeof(struct SymbolTableEntry));
                                    newvar -> name = yytext;
                                    newvar -> scope = Scope;
                                    newvar -> line = yylineno;
                                    newnode -> type = LOCAL;
                                    newnode -> varVal = newvar;                                        newnode -> isActive = 1;
                                 
                                    insertEntry(newnode);
                                }
                          }
                          | DOUBLE_COLON ID
                          {
                            tmp = lookupScope(yylval.strVal, 0);

                            if(tmp == NULL){ /*we didn't find xxx in scope 0*/
                                printf("ERROR: could not find global %s\n", yylval.strVal);
                            }
                          }
                          |member
                          ;
                         

            member:       lvalue DOT ID
                          | lvalue LEFT_BRACE expr RIGHT_BRACE
                          | call DOT ID
                          | call LEFT_BRACE expr RIGHT_BRACE
                          ;     

            call:         call LEFT_PARENTHESIS elist RIGHT_PARENTHESIS
                          | lvalue callsuffix
                          |LEFT_PARENTHESIS funcdef RIGHT_PARENTHESIS LEFT_PARENTHESIS elist RIGHT_PARENTHESIS
                          ;       

            callsuffix:   normalcall
                          | methodcall
                          ;

            normalcall:   LEFT_PARENTHESIS elist RIGHT_PARENTHESIS
                          ; 

            methodcall:   DOUBLE_DOT ID LEFT_PARENTHESIS elist RIGHT_PARENTHESIS 
                          ;

            elist:        expr
                          | LEFT_PARENTHESIS COMMA expr RIGHT_PARENTHESIS COMMA elist
                          ;

            objectdef:    LEFT_BRACE  RIGHT_BRACE
                          |LEFT_BRACE elist RIGHT_BRACE 
                          |LEFT_BRACE indexed RIGHT_BRACE 
                          ;

            indexed:      indexdelem
                          | LEFT_PARENTHESIS COMMA indexdelem RIGHT_PARENTHESIS COMMA indexed
                          ;

            indexdelem:   LEFT_BRACKET expr COLON expr RIGHT_BRACKET
                          ;

            block:        LEFT_BRACKET {Scope++;} stmt RIGHT_BRACKET 
                            {/*when we see { we increase Scope and when we see }
                            we first hide all entries in this scope because they are local
                            and then we decrease Scope*/
                             hideEntries(Scope);
                             Scope--;
                            } 
                          ;

            funcdef:      FUNCTION LEFT_PARENTHESIS idlist RIGHT_PARENTHESIS block
                          {
                              funcname = strcat(funcname1, (char*)funcname2);
                              funcname2++;
                            
                              Function *newfunc= (Function *)malloc(sizeof(struct Function));
                              SymbolTableEntry *newnode= (SymbolTableEntry*)malloc(sizeof(struct SymbolTableEntry));
                              newfunc -> name = funcname;
                              newfunc -> scope = Scope;
                              newfunc -> line = yylineno;
                              newnode -> type = USERFUNC;
                              newnode -> funcVal = newfunc;
                              newnode -> isActive = 1;
                             
                              insertEntry(newnode); 
                          }
                          | FUNCTION ID LEFT_PARENTHESIS idlist RIGHT_PARENTHESIS block
                          { 
                                i = Scope;
                                yylval.strVal = yytext;

                                while(i >= 0){
                                   tmp = lookupScope(yylval.strVal, i);

                                    if(tmp != NULL){ /*we found xxx in this scope*/
                                        if(*getEntryType(tmp) == USERFUNC){
                                            printf("ERROR: function %s already exists\n", yylval.strVal);
                                        }else if(*getEntryType(tmp) == LIBFUNC){
                                            printf("ERROR: function %s cannot shadow a library function\n", yylval.strVal);
                                        }
                                        break;
                                    }
                                    i--;
                                }

                                if(i < 0){ /*we didn't find id in the table so we add it*/
                                    Function *newfunc= (Function *)malloc(sizeof(struct Function));
                                    SymbolTableEntry *newnode= (SymbolTableEntry*)malloc(sizeof(struct SymbolTableEntry));
                                    newfunc -> name = yytext;
                                    newfunc -> scope = Scope;
                                    newfunc -> line = yylineno;
                                    newnode -> type = USERFUNC;
                                    newnode -> funcVal = newfunc;
                                    newnode -> isActive = 1;
                             
                                    insertEntry(newnode);                                
                                }
                          }      
                          ;

            const:        INTEGER
                          |REAL
                          |STRING
                          |NIL
                          |TRUE
                          |FALSE
                          ;

            idlist:     |ID
                        | COMMA ID  
                          {
                              yylval.strVal = yytext;
                              tmp = lookupScope(yylval.strVal, Scope);
                              if(tmp != NULL){
                                  if(*getEntryType(tmp) == LIBFUNC){
                                  /*check if this var can shadow a lib function*/
                                      printf("ERROR: var %s cannot shadow a library function\n", yylval.strVal);   
                                  }else{
                                      printf("ERROR: formal redeclaration of var %s\n", yylval.strVal);
                                  }
                              }else{
                                  /*add the new formal*/
                                  Variable *newvar= (Variable *)malloc(sizeof(struct Variable));
                                  SymbolTableEntry *newnode= (SymbolTableEntry*)malloc(sizeof(struct SymbolTableEntry));
                                  newvar -> name = yytext;
                                  newvar -> scope = Scope;
                                  newvar -> line = yylineno;
                                  newnode -> type = FORMAL;
                                  newnode -> varVal = newvar;        
                                  newnode -> isActive = 1;
                                  insertEntry(newnode);
                              }
                          }
                          ;

            ifstmt:       IF LEFT_PARENTHESIS expr RIGHT_PARENTHESIS stmt  
                          | IF LEFT_PARENTHESIS expr RIGHT_PARENTHESIS stmt ELSE stmt
                          ;

            whilestmt:    WHILE LEFT_PARENTHESIS expr RIGHT_PARENTHESIS stmt
                          ;

            forstmt:      FOR LEFT_PARENTHESIS elist SEMICOLON expr SEMICOLON elist RIGHT_PARENTHESIS stmt
                          ;

            returnstmt:   RETURN 
                          | RETURN expr
                          ;                            
            %%

              /*epilogue*/
      int yyerror(char* message){
        printf("%s: in line %d",message, yylineno);
      }

      int main(int argc, char* argv[]){

        initTable();   
        /*adding library function in hashtable
		ta next ta exw balei ola null*/
        SymbolTableEntry *print = (SymbolTableEntry*)malloc(sizeof(SymbolTableEntry));
        Function *printFunc = (Function *)malloc(sizeof(Function));
        print -> isActive = 1;
        printFunc -> name = "print";
        printFunc -> scope = 0;
        printFunc -> line = 0;
        print -> funcVal = printFunc;
        print -> type = LIBFUNC;
        print -> next = NULL;
        insertEntry(print);
        lookupEverything(print->funcVal->name);

		SymbolTableEntry *input= (SymbolTableEntry*)malloc(sizeof(SymbolTableEntry));
        Function *inputFunc = (Function*)malloc(sizeof(Function));
        input -> isActive = 1;
        inputFunc -> name = "input";
        inputFunc -> scope = 0;
        inputFunc -> line = 0;
        input -> funcVal = inputFunc;
        input -> type = LIBFUNC;
        input -> next = NULL;
        insertEntry(input);

		SymbolTableEntry *objectmemberkeys= (SymbolTableEntry*)malloc(sizeof(SymbolTableEntry));
        Function *objectmemberkeysFunc = (Function*)malloc(sizeof(Function));
        objectmemberkeys -> isActive = 1;
        objectmemberkeysFunc -> name = "objectmemberkeys";
        objectmemberkeysFunc -> scope = 0;
        objectmemberkeysFunc -> line = 0;
        objectmemberkeys -> funcVal = objectmemberkeysFunc;
        objectmemberkeys -> type = LIBFUNC;
        objectmemberkeys -> next = NULL;
        insertEntry(objectmemberkeys);

		SymbolTableEntry *objecttotalmembers= (SymbolTableEntry*)malloc(sizeof(SymbolTableEntry));
        Function *objecttotalmembersFunc = (Function*)malloc(sizeof(Function));
        objecttotalmembers -> isActive = 1;
        objecttotalmembersFunc -> name = "objecttotalmembers";
        objecttotalmembersFunc -> scope = 0;
        objecttotalmembersFunc -> line = 0;
        objecttotalmembers -> funcVal = objecttotalmembersFunc;
        objecttotalmembers -> type = LIBFUNC;
        objecttotalmembers -> next = NULL;
        insertEntry(objecttotalmembers);

		SymbolTableEntry *objectcopy= (SymbolTableEntry*)malloc(sizeof(SymbolTableEntry));
        Function *objectcopyFunc = (Function*)malloc(sizeof(Function));
        objectcopy -> isActive = 1;
        objectcopyFunc -> name = "objectcopy";
        objectcopyFunc -> scope = 0;
        objectcopyFunc -> line = 0;
        objectcopy -> funcVal = objectcopyFunc;
        objectcopy -> type = LIBFUNC;
        objectcopy -> next = NULL;
        insertEntry(objectcopy);
		
		SymbolTableEntry *totalarguments= (SymbolTableEntry*)malloc(sizeof(SymbolTableEntry));
        Function *totalargumentsFunc = (Function*)malloc(sizeof(Function));
        totalarguments -> isActive = 1;
        totalargumentsFunc -> name = "totalarguments";
        totalargumentsFunc -> scope = 0;
        totalargumentsFunc -> line = 0;
        totalarguments -> funcVal = totalargumentsFunc;
        totalarguments -> type = LIBFUNC;
        totalarguments -> next = NULL;
        insertEntry(totalarguments);
		
		SymbolTableEntry *argument= (SymbolTableEntry*)malloc(sizeof(SymbolTableEntry));
        Function *argumentFunc = (Function*)malloc(sizeof(Function));
        argument -> isActive = 1;
        argumentFunc -> name = "argument";
        argumentFunc -> scope = 0;
        argumentFunc -> line = 0;
        argument -> funcVal = argumentFunc;
        argument -> type = LIBFUNC;
        argument -> next = NULL;
        insertEntry(argument);
		
		SymbolTableEntry *Typeof= (SymbolTableEntry*)malloc(sizeof(SymbolTableEntry));
        Function *TypeofFunc = (Function*)malloc(sizeof(Function));
        Typeof -> isActive = 1;
        TypeofFunc -> name = "typeof";
        TypeofFunc -> scope = 0;
        TypeofFunc -> line = 0;
        Typeof -> funcVal = TypeofFunc;
        Typeof -> type = LIBFUNC;
        Typeof -> next = NULL;
        insertEntry(Typeof);
		
		SymbolTableEntry *strtonum= (SymbolTableEntry*)malloc(sizeof(SymbolTableEntry));
        Function *strtonumFunc =  (Function*)malloc(sizeof(Function));
        strtonum -> isActive = 1;
        strtonumFunc -> name = "strtonum";
        strtonumFunc -> scope = 0;
        strtonumFunc -> line = 0;
        strtonum -> funcVal = strtonumFunc;
        strtonum -> type = LIBFUNC;
        strtonum -> next = NULL;
        insertEntry(strtonum);
		
		SymbolTableEntry *sqrt= (SymbolTableEntry*)malloc(sizeof(SymbolTableEntry));
        Function *sqrtFunc = (Function*)malloc(sizeof(Function));
        sqrt -> isActive = 1;
        sqrtFunc -> name = "sqrt";
        sqrtFunc -> scope = 0;
        sqrtFunc -> line = 0;
        sqrt -> funcVal = sqrtFunc;
        sqrt -> type = LIBFUNC;
        sqrt -> next = NULL;
        insertEntry(sqrt);
		
		SymbolTableEntry *cos= (SymbolTableEntry*)malloc(sizeof(SymbolTableEntry));
        Function *cosFunc =  (Function*)malloc(sizeof(Function));
        cos -> isActive = 1;
        cosFunc -> name = "cos";
        cosFunc -> scope = 0;
        cosFunc -> line = 0;
        cos -> funcVal = cosFunc;
        cos -> type = LIBFUNC;
        cos -> next = NULL;
        insertEntry(cos);
		
		SymbolTableEntry *sin= (SymbolTableEntry*)malloc(sizeof(SymbolTableEntry));
        Function *sinFunc = (Function*)malloc(sizeof(Function));
        sin -> isActive = 1;
        sinFunc -> name = "sin";
        sinFunc -> scope = 0;
        sinFunc -> line = 0;
        sin -> funcVal = sinFunc;
        sin -> type = LIBFUNC;
        sin -> next = NULL;
        insertEntry(sin);
		
		printEntries();
        yyparse();
        printEntries();
        return 0;
      }
     


