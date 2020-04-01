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

              program:    stmt  {print("stmt -> program\n");}
                          | program WHITESPACE stmt {print("program WHITESPACE stmt -> program\n");}
                          ;

              stmt:       expr SEMICOLON        {print("expr ; -> stmt\n");}
                          |ifstmt               {print("IF -> stmt\n");}
                          |whilestmt            {print("WHILE -> stmt\n");}
                          |forstmt              {print("FOR -> stmt\n");}
                          |returnstmt           {print("RETURN -> stmt\n");}
                          |BREAK SEMICOLON      {print("BREAK -> stmt\n");}
                          |CONTINUE SEMICOLON   {print("CONTINUE -> stmt\n");}
                          |block                {print("BLOCK -> stmt\n");}
                          |funcdef              {print("FUNCDEF -> stmt\n");}
                          |/*empty*/            {print("EMPTY -> stmt\n");}
                          ;
              
              expr:       assignexpr                   {print("assignexpr -> expr\n");}
                          | expr OPERATOR_PLUS expr    {print("expr + expr -> expr\n");}
                          | expr OPERATOR_MINUS expr   {print("expr - expr -> expr\n");}
                          | expr OPERATOR_MOD expr     {print("expr % expr -> expr\n");}
                          | expr OPERATOR_DIV expr     {print("expr / expr -> expr\n");}
                          | expr OPERATOR_MUL expr     {print("expr * expr -> expr\n");}
                          | expr OPERATOR_GRT expr     {print("expr > expr -> expr\n");}
                          | expr OPERATOR_GRE expr     {print("expr >= expr -> expr\n");}
                          | expr OPERATOR_LES expr     {print("expr < expr -> expr\n");}
                          | expr OPERATOR_LEE expr     {print("expr <= expr -> expr\n");}
                          | expr OPERATOR_EQ expr      {print("expr == expr -> expr\n");}
                          | expr OPERATOR_NEQ expr     {print("expr != expr -> expr\n");}
                          | expr OPERATOR_AND expr     {print("expr && expr -> expr\n");}
                          | expr OPERATOR_OR expr      {print("expr || expr -> expr\n");}
                          | term                       {print("term -> expr\n");}
                          ;
            

             term:        LEFT_PARENTHESIS expr RIGHT_PARENTHESIS   {print("( expr ) -> term\n");}
                          |OPERATOR_MINUS expr                      {print("- expr -> term\n");}
                          |OPERATOR_NOT expr                        {print("! expr -> term\n");}
                          |OPERATOR_PP lvalue                       {print("++ expr -> term\n");}
                          |lvalue OPERATOR_PP                       {print("expr ++ -> term\n");}
                          |OPERATOR_MM lvalue                       {print("-- expr -> term\n");}
                          |lvalue OPERATOR_MM                       {print("expr -- -> term\n");}
                          |primary                                  {print("primary -> term\n");}
                          ;                  

            assignexpr:   lvalue OPERATOR_ASSIGN expr   {print("lvalue = expr -> assignexpr\n");}
                          ;

            primary:       call                                         {print("call -> primary\n");}
                          |lvalue                                       {print("lvalue -> primary\n");}
                          |objectdef                                    {print("objectdef -> primary\n");}
                          |LEFT_PARENTHESIS funcdef RIGHT_PARENTHESIS   {print("( funcdef ) -> primary\n");}
                          |const                                        {print("const -> primary\n");}
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
                              print("ID -> lvalue\n");
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
                                    newnode -> varVal = newvar;
                                    newnode -> isActive = 1;
                                 
                                    insertEntry(newnode);
                                }
                          print("LOCAL ID -> lvalue\n");
                          }
                          | DOUBLE_COLON ID
                          {
                            tmp = lookupScope(yylval.strVal, 0);

                            if(tmp == NULL){ /*we didn't find xxx in scope 0*/
                                printf("ERROR: could not find global %s\n", yylval.strVal);
                            }
                          print(":: ID -> lvalue\n");
                          }
                          |member   {print("member -> lvalue\n");}
                          ;
                         

            member:       lvalue DOT ID                         {print("lvalue . ID -> member\n");}
                          | lvalue LEFT_BRACE expr RIGHT_BRACE  {print("lvalue ( expr ) -> member\n");}
                          | call DOT ID                         {print("call . ID -> member\n");}
                          | call LEFT_BRACE expr RIGHT_BRACE    {print("call ( expr ) -> member\n");}
                          ;     

            call:         call LEFT_PARENTHESIS elist RIGHT_PARENTHESIS                                         {print("call ( elist ) -> call\n");}
                          | lvalue callsuffix                                                                   {print("lvalue callsuffix -> member\n");}
                          |LEFT_PARENTHESIS funcdef RIGHT_PARENTHESIS LEFT_PARENTHESIS elist RIGHT_PARENTHESIS  {print("( funcdef ) ( elist ) -> member\n");}
                          ;       

            callsuffix:   normalcall        {print("normalcall -> callsuffix\n");}
                          | methodcall      {print("methodcall -> callsuffix\n");}
                          ;

            normalcall:   LEFT_PARENTHESIS elist RIGHT_PARENTHESIS  {print("( elist ) -> normalcall\n");}
                          ; 

            methodcall:   DOUBLE_DOT ID LEFT_PARENTHESIS elist RIGHT_PARENTHESIS    {print(":: ID ( elist ) -> methodcall\n");}
                          ;

            elist:        expr            {print("expr -> elist\n");}
                          | COMMA elist   {print(", expr -> elist\n");}
                          |/*empty*/      {print("EMPTY -> elist\n");}
                          ;

            objectdef:    LEFT_BRACE  RIGHT_BRACE           {print("[ ] -> obgectdef\n");}
                          |LEFT_BRACE elist RIGHT_BRACE     {print("[ elist ] -> obgectdef\n");}
                          |LEFT_BRACE indexed RIGHT_BRACE   {print("[ indexed ] -> obgectdef\n");}
                          ;

            indexed:      indexdelem            {print("indexdelem -> indexed\n");}
                          | COMMA indexdelem    {print(", indexdelem -> indexed\n");}
                          |/*empty*/            {print("EMPTY -> indexed\n");}
                          ;

            indexdelem:   LEFT_BRACKET expr COLON expr RIGHT_BRACKET    {print("{ expr : expr } -> indexdelem\n");}    
                          ;

            block:        LEFT_BRACKET {Scope++;} RIGHT_BRACKET    
                            {/*when we see { we increase Scope and when we see }
                            we first hide all entries in this scope because they are local
                            and then we decrease Scope*/
                             hideEntries(Scope);
                             Scope--;
                             printf("{ } -> block\n");
                            }
                          | LEFT_BRACKET {Scope++;} stmt RIGHT_BRACKET 
                            {/*when we see { we increase Scope and when we see }
                            we first hide all entries in this scope because they are local
                            and then we decrease Scope*/
                             hideEntries(Scope);
                             Scope--;
                             printf("{ stmt } -> block\n");
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
                              printf("function ( idlist ) block -> funcdef\n");
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
                                printf("function ID ( idlist ) block -> funcdef\n");
                          }      
                          ;

            const:        INTEGER   {printf("INTEGER -> const\n");}
                          |REAL     {printf("REAL -> const\n");}
                          |STRING   {printf("STRING -> const\n");}   
                          |NIL      {printf("NILL -> const\n");}
                          |TRUE     {printf("TRUE -> const\n");}
                          |FALSE    {printf("FALSE -> const\n");}
                          ;

            idlist:     ID          {printf("ID -> idlist\n");}
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
                              printf(", ID -> idlist\n");
                          }
                          | /*EMPTY*/   {printf("EMPTY -> idlist\n");}
                          ;

            ifstmt:       IF LEFT_PARENTHESIS expr RIGHT_PARENTHESIS stmt               {printf("IF ( expr ) stmt -> ifstmt\n");}
                          | IF LEFT_PARENTHESIS expr RIGHT_PARENTHESIS stmt ELSE stmt   {printf("IF ( expr ) stmt ELSE stmt -> ifstmt\n");}
                          ;

            whilestmt:    WHILE LEFT_PARENTHESIS expr RIGHT_PARENTHESIS stmt    {printf("WHILE ( expr ) stmt -> whilestmt\n");}
                          ;

            forstmt:      FOR LEFT_PARENTHESIS elist SEMICOLON expr SEMICOLON elist RIGHT_PARENTHESIS stmt 
                            {printf("FOR ( elist ; expr ; elist ) stmt -> forstmt\n");}
                          ;

            returnstmt:   RETURN            {printf("RETURN -> returnstmt\n");}
                          | RETURN expr     {printf("RETURN expr -> returnstmt\n");}
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
     


