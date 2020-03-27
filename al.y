/*Syntax analysis*/


/*prologue*/
        %{
            #include <stdio.h>
            #include <stdlib.h>
            #include "SymbolTable.h"



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
                                        newnode -> value.varVal = newvar;
                                        newnode -> isActive = 1;
                                 
                                        insertEntry(newnode);
                                    }else{/*it's a local id*/
                                        Variable *newvar= (Variable *)malloc(sizeof(struct Variable));
                                        SymbolTableEntry *newnode= (SymbolTableEntry*)malloc(sizeof(struct SymbolTableEntry));
                                        newvar -> name = yytext;
                                        newvar -> scope = Scope;
                                        newvar -> line = yylineno;
                                        newnode -> type = LOCAL;
                                        newnode -> value.varVal = newvar;
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
                                    newnode -> value.varVal = newvar;
                                    newnode -> isActive = 1;

                                    insertEntry(newnode);
                                }else{/*it's a local id*/
                                    Variable *newvar= (Variable *)malloc(sizeof(struct Variable));
                                    SymbolTableEntry *newnode= (SymbolTableEntry*)malloc(sizeof(struct SymbolTableEntry));
                                    newvar -> name = yytext;
                                    newvar -> scope = Scope;
                                    newvar -> line = yylineno;
                                    newnode -> type = LOCAL;
                                    newnode -> value.varVal = newvar;                                        newnode -> isActive = 1;
                                 
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
                              newnode -> value.funcVal = newfunc;
                              newnode -> isActive = 1;
                             
                              insertEntry(newnode); 
                          }
                          | FUNCTION ID LEFT_PARENTHESIS idlist RIGHT_PARENTHESIS block
                          { 
<<<<<<< HEAD
                              if(yylval.strVal=="print" || yylval.strVal=="input" || yylval.strVal=="objectmemberkeys" || yylval.strVal=="objecttotalmembers" || 
                              yylval.strVal=="objectcopy" || yylval.strVal=="totalarguments" || yylval.strVal=="argument" ||
                               yylval.strVal=="typeof" || yylval.strVal=="strtonum" ||yylval.strVal=="sqrt" || yylval.strVal=="cos" || yylval.strVal=="sin"){
                                   yyerror("LIBRARY FUNCTIONS\n");
                               }
                               else{
                                    i = Scope;
                                    while(i>=0){
                                       tmp = lookupScope(yylval.strVal, i);
                                    if(tmp != NULL && i!=0){
                                        yyerror("Redeclaration of function");
                                    }
                                        i--;
                                        if(i==0 && tmp!= NULL){
                                            break;
                                                            }
                                                }
                               if(i<0){
                                   Function *newfunc= (Function *)malloc(sizeof(struct Function));
                                SymbolTableEntry *newnode= (SymbolTableEntry *)malloc(sizeof(struct SymbolTableEntry));
                                newfunc->name=yytext;
                                newfunc->scope=0;
                                newfunc->line=yylineno;
                                newnode->type=USERFUNC;
                                newnode-> value.funcVal=newfunc;
                                newnode->isActive=1;

                                insertEntry(newnode);
                                        }
                                   
                                    }
                          }
=======
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
                                    newnode -> value.funcVal = newfunc;
                                    newnode -> isActive = 1;
                             
                                    insertEntry(newnode);                                
                                }
                          }      
>>>>>>> Anna
                          ;

            const:        INTEGER
                          |REAL
                          |STRING
                          |NIL
                          |TRUE
                          |FALSE
                          ;

            idlist:       |idlist
                          |ID
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
                                  newnode -> value.varVal = newvar;                                        newnode -> isActive = 1;
                                 
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
        printf("OK\n");
        /*adding library function in hashtable*/
        Function *funcPrint= (Function *)malloc(sizeof(struct Function));
        SymbolTableEntry *print= (SymbolTableEntry*)malloc(sizeof(struct SymbolTableEntry));
        funcPrint -> name = "print";
        funcPrint -> scope = 0;
        funcPrint -> line = 0;
        print -> type = LIBFUNC;
        print -> value.funcVal = funcPrint;
        print -> isActive = 1;
                                 
        insertEntry(print);
    
		Function *funcInput= (Function *)malloc(sizeof(struct Function));
        SymbolTableEntry *input= (SymbolTableEntry*)malloc(sizeof(struct SymbolTableEntry));
        funcInput -> name = "input";
        funcInput -> scope = 0;
        funcInput -> line = 0;
        input -> type = LIBFUNC;
        input -> value.funcVal = funcInput;
        input -> isActive = 1;
                                 
        insertEntry(input);

        Function *funcObjectmemberkeys= (Function *)malloc(sizeof(struct Function));
        SymbolTableEntry *objectmemberkeys= (SymbolTableEntry*)malloc(sizeof(struct SymbolTableEntry));
        funcObjectmemberkeys -> name = "objectmemberkeys";
        funcObjectmemberkeys -> scope = 0;
        funcObjectmemberkeys -> line = 0;
        objectmemberkeys -> type = LIBFUNC;
        objectmemberkeys -> value.funcVal = funcObjectmemberkeys;
        objectmemberkeys -> isActive = 1;

        insertEntry(objectmemberkeys);

        Function *funcObjecttotalmembers= (Function *)malloc(sizeof(struct Function));
        SymbolTableEntry *objecttotalmembers= (SymbolTableEntry*)malloc(sizeof(struct SymbolTableEntry));
        funcObjecttotalmembers -> name = "objecttotalmembers";
        funcObjecttotalmembers -> scope = 0;
        funcObjecttotalmembers -> line = yylineno;
        objecttotalmembers -> type = 0;
        objecttotalmembers -> value.funcVal = funcObjecttotalmembers;
        objecttotalmembers -> isActive = 1;

        insertEntry(objecttotalmembers);
        
		Function *funcObjectcopy= (Function *)malloc(sizeof(struct Function));
        SymbolTableEntry *objectcopy= (SymbolTableEntry*)malloc(sizeof(struct SymbolTableEntry));
        funcObjectcopy -> name = "objectcopy";
        funcObjectcopy -> scope = 0;
        funcObjectcopy -> line = 0;
        objectcopy -> type = LIBFUNC;
        objectcopy -> value.funcVal = funcObjectcopy;
        objectcopy -> isActive = 1;

        insertEntry(objectcopy);
        
		Function *funcTotalarguments= (Function *)malloc(sizeof(struct Function));
        SymbolTableEntry *totalarguments= (SymbolTableEntry*)malloc(sizeof(struct SymbolTableEntry));
        funcTotalarguments -> name = "totalarguments";
        funcTotalarguments -> scope = 0;
        funcTotalarguments -> line = 0;
        totalarguments -> type = LIBFUNC;
        totalarguments -> value.funcVal = funcTotalarguments;
        totalarguments -> isActive = 1;

        insertEntry(totalarguments);
        
		Function *funcArgument= (Function *)malloc(sizeof(struct Function));
        SymbolTableEntry *argument= (SymbolTableEntry*)malloc(sizeof(struct SymbolTableEntry));
        funcArgument -> name = "argument";
        funcArgument -> scope = 0;
        funcArgument -> line = 0;
        argument -> type = LIBFUNC;
        argument -> value.funcVal = funcArgument;
        argument -> isActive = 1;

        insertEntry(argument);

		Function *funcTypeof= (Function *)malloc(sizeof(struct Function));
        SymbolTableEntry *ptrtypeof= (SymbolTableEntry*)malloc(sizeof(struct SymbolTableEntry));
        funcTypeof -> name = "typeof";
        funcTypeof -> scope = 0;
        funcTypeof -> line = 0;
        ptrtypeof -> type = LIBFUNC;
        ptrtypeof -> value.funcVal = funcTypeof;
        ptrtypeof -> isActive = 1;

        insertEntry(ptrtypeof);

		Function *funcStrtonum= (Function *)malloc(sizeof(struct Function));
        SymbolTableEntry *strtonum= (SymbolTableEntry*)malloc(sizeof(struct SymbolTableEntry));
        funcStrtonum -> name = "strtonum";
        funcStrtonum -> scope = 0;
        funcStrtonum -> line = 0;
        strtonum -> type = LIBFUNC;
        strtonum -> value.funcVal = funcStrtonum;
        strtonum -> isActive = 1;

        insertEntry(strtonum);

        Function *funcSqrt= (Function *)malloc(sizeof(struct Function));
        SymbolTableEntry *sqrt= (SymbolTableEntry*)malloc(sizeof(struct SymbolTableEntry));
        funcSqrt -> name = "sqrt";
        funcSqrt -> scope = 0;
        funcSqrt -> line = 0;
        sqrt -> type = LIBFUNC;
        sqrt -> value.funcVal = funcSqrt;
        sqrt -> isActive = 1;

        insertEntry(sqrt);		
		
        Function *funcCos= (Function *)malloc(sizeof(struct Function));
        SymbolTableEntry *cos= (SymbolTableEntry*)malloc(sizeof(struct SymbolTableEntry));
        funcCos -> name = "cos";
        funcCos -> scope = 0;
        funcCos -> line = 0;
        cos -> type = LIBFUNC;
        cos -> value.funcVal = funcCos;
        cos -> isActive = 1;

        insertEntry(cos);

		Function *funcSin= (Function *)malloc(sizeof(struct Function));
        SymbolTableEntry *sin= (SymbolTableEntry*)malloc(sizeof(struct SymbolTableEntry));
        funcSin -> name = "sin";
        funcSin -> scope = 0;
        funcSin -> line = 0;
        sin -> type = LIBFUNC;
        sin -> value.funcVal = funcSin;
        sin -> isActive = 1;

        insertEntry(sin);
		
        yyparse();
        printEntries();
        return 0;
      }
     


