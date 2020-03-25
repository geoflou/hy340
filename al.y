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
            
            %}

/*yacc stuff*/
%start program
                %expect 1
                %token ID INTEGER REAL /*tokens*/
                %token STRING         
                %token IF             
                %token ELSE           
                %token WHILE          
                %token FOR            
                %token FUNCTION       
                %token RETURN         
                %token BREAK          
                %token CONTINUE       
                %token AND            
                %token NOT            
                %token OR             
                %token LOCAL          
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

              program: stmt
                      | program WHITESPACE stmt
                          ;

              stmt:       expr;
                          |ifstmt
                          |whilestmt
                          |forstmt
                          |returnstmt
                          |BREAK;
                          |CONTINUE;
                          |block
                          |funcdef
                          |/*empty*/
                          ;
              
              expr:        assignexpr
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

            assignexpr:   lvalue OPERATOR_ASSIGN expr ;


            primary:       call
                          |lvalue
                          |objectdef
                          |LEFT_PARENTHESIS funcdef RIGHT_PARENTHESIS
                          |const
                          ;


            lvalue:       ID
                          | LOCAL ID /*mallon prepei na ftia3w ena token pou 8a legetai local token alla den eimai sigouros*/
                          | DOUBLE_COLON ID
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

            callsuffix:    normalcall
                           | methodcall
                           ;


            normalcall:    LEFT_PARENTHESIS elist RIGHT_PARENTHESIS; 


            methodcall:    DOUBLE_DOT ID LEFT_PARENTHESIS elist RIGHT_PARENTHESIS
                           
                           ;


            elist:         expr
                           | LEFT_PARENTHESIS COMMA expr RIGHT_PARENTHESIS COMMA elist
                           ;


            objectdef:     LEFT_BRACE  RIGHT_BRACE
                           |LEFT_BRACE elist RIGHT_BRACE 
                           |LEFT_BRACE indexed RIGHT_BRACE 
                           ;


            indexed:       indexdelem
                           | LEFT_PARENTHESIS COMMA indexdelem RIGHT_PARENTHESIS COMMA indexed
                           ;

            indexdelem:    LEFT_BRACKET expr COLON expr RIGHT_BRACKET;

            block:         LEFT_BRACKET stmt RIGHT_BRACKET
                            
                           ;


            funcdef:        FUNCTION LEFT_PARENTHESIS idlist RIGHT_PARENTHESIS block
                            | FUNCTION ID LEFT_PARENTHESIS idlist RIGHT_PARENTHESIS block
                            ;


            const:          INTEGER
                            |REAL
                            |STRING
                            |NIL
                            |TRUE
                            |FALSE
                            ;




            idlist:         |idlist
                              ID
                            | COMMA ID
                              
                              ;


            ifstmt:         IF LEFT_PARENTHESIS expr RIGHT_PARENTHESIS stmt  
                            | IF LEFT_PARENTHESIS expr RIGHT_PARENTHESIS stmt ELSE stmt
                            ;


            whilestmt:      WHILE LEFT_PARENTHESIS expr RIGHT_PARENTHESIS stmt;



            forstmt:        FOR LEFT_PARENTHESIS elist SEMICOLON expr SEMICOLON elist RIGHT_PARENTHESIS stmt;


            returnstmt:     RETURN 
                            | RETURN expr;                            
            %%

              /*epilogue*/
      int yyerror(char* message){
        printf("%s: in line %d",message, yylineno);
      }

      int main(int argc, char* argv[]){
        if(argc < 2){
          printf("No input file!\n");
          return -1;
        }
		
		if(argc > 1){
			if(!(yyin = fopen(argv[1], "r"))){
				printf("Cannot read file!\n");
				return 1;
			}
		}else{
			yyin = stdin;
		}
        
        /*adding library function in hashtable
		ta next ta exw balei ola null*/
        SymbolTableEntry *print;
        print -> isActive = 1;
        print -> value.funcVal -> name = "print";
        print -> value.funcVal -> scope = 0;
        print -> value.funcVal -> line = 0;
        print -> type = LIBFUNC;
        print -> next = NULL;
        insertEntry(print);
		
		SymbolTableEntry *input;
        input -> isActive = 1;
        input -> value.funcVal -> name = "input";
        input -> value.funcVal -> scope = 0;
        input -> value.funcVal -> line = 0;
        input -> type = LIBFUNC;
        input -> next = NULL;
        insertEntry(input);

		SymbolTableEntry *objectmemberkeys;
        objectmemberkeys -> isActive = 1;
        objectmemberkeys -> value.funcVal -> name = "objectmemberkeys";
        objectmemberkeys -> value.funcVal -> scope = 0;
        objectmemberkeys -> value.funcVal -> line = 0;
        objectmemberkeys -> type = LIBFUNC;
        objectmemberkeys -> next = NULL;
        insertEntry(objectmemberkeys);

		SymbolTableEntry *objecttotalmembers;
        objecttotalmembers -> isActive = 1;
        objecttotalmembers -> value.funcVal -> name = "objecttotalmembers";
        objecttotalmembers -> value.funcVal -> scope = 0;
        objecttotalmembers -> value.funcVal -> line = 0;
        objecttotalmembers -> type = LIBFUNC;
        objecttotalmembers -> next = NULL;
        insertEntry(objecttotalmembers);

		SymbolTableEntry *objectcopy;
        objectcopy -> isActive = 1;
        objectcopy -> value.funcVal -> name = "objectcopy";
        objectcopy -> value.funcVal -> scope = 0;
        objectcopy -> value.funcVal -> line = 0;
        objectcopy -> type = LIBFUNC;
        objectcopy -> next = NULL;
        insertEntry(objectcopy);
		
		SymbolTableEntry *totalarguments;
        totalarguments -> isActive = 1;
        totalarguments -> value.funcVal -> name = "totalarguments";
        totalarguments -> value.funcVal -> scope = 0;
        totalarguments -> value.funcVal -> line = 0;
        totalarguments -> type = LIBFUNC;
        totalarguments -> next = NULL;
        insertEntry(totalarguments);
		
		SymbolTableEntry *argument;
        argument -> isActive = 1;
        argument -> value.funcVal -> name = "argument";
        argument -> value.funcVal -> scope = 0;
        argument -> value.funcVal -> line = 0;
        argument -> type = LIBFUNC;
        argument -> next = NULL;
        insertEntry(argument);
		
		SymbolTableEntry *typeof;
        typeof -> isActive = 1;
        typeof -> value.funcVal -> name = "typeof";
        typeof -> value.funcVal -> scope = 0;
        typeof -> value.funcVal -> line = 0;
        typeof -> type = LIBFUNC;
        typeof -> next = NULL;
        insertEntry(typeof);
		
		SymbolTableEntry *strtonum;
        strtonum -> isActive = 1;
        strtonum -> value.funcVal -> name = "strtonum";
        strtonum -> value.funcVal -> scope = 0;
        strtonum -> value.funcVal -> line = 0;
        strtonum -> type = LIBFUNC;
        strtonum -> next = NULL;
        insertEntry(strtonum);
		
		SymbolTableEntry *sqrt;
        sqrt -> isActive = 1;
        sqrt -> value.funcVal -> name = "sqrt";
        sqrt -> value.funcVal -> scope = 0;
        sqrt -> value.funcVal -> line = 0;
        sqrt -> type = LIBFUNC;
        sqrt -> next = NULL;
        insertEntry(sqrt);
		
		SymbolTableEntry *cos;
        cos -> isActive = 1;
        cos -> value.funcVal -> name = "cos";
        cos -> value.funcVal -> scope = 0;
        cos -> value.funcVal -> line = 0;
        cos -> type = LIBFUNC;
        cos -> next = NULL;
        insertEntry(cos);
		
		SymbolTableEntry *sin;
        sin -> isActive = 1;
        sin -> value.funcVal -> name = "sin";
        sin -> value.funcVal -> scope = 0;
        sin -> value.funcVal -> line = 0;
        sin -> type = LIBFUNC;
        sin -> next = NULL;
        insertEntry(sin);
		
		
        yyparse();
        return 0;
      }