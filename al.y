/*Syntax analysis*/


/*prologue*/
        %{
            #include <stdio.h>
            #include <stdlib.h>
            #include "SymbolTable.h"
            
            %}

/*yacc stuff*/
%start program

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

              program:    stmt*
                          |/*empty*/
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
                           | expr op expr
                           | term
                           ;

              op:          +
                           |-
                           |*
                           |/
                           |%
                           |>
                           |>=
                           |<
                           |<=
                           |==
                           |!=
                           |AND
                           |OR 
                           ;         

             term:        LEFT_PARENTHESIS expr RIGHT_PARENTHESIS
                          |OPERATOR_MINUS expr
                          |OPERATOR_NOT expr
                          |++lvalue
                          |lvalue++
                          |--lvalue
                          |lvalue--
                          |primary
                          ;                  

            assignexpr:   lvalue OPERATOR_ASSIGN expr ;


            primary:      lvalue
                          |call
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
                           | DOT ID LEFT_PARENTHESIS lvalue COMMA elist RIGHT_PARENTHESIS /*den eimai sigouros gi auto den katalava thn ekfwnhsh */
                           ;


            elist:         expr
                           | (COMMA expr)*
                           ;


            objectdef:     LEFT_BRACE  RIGHT_BRACE
                           |LEFT_BRACE elist RIGHT_BRACE 
                           |LEFT_BRACE indexed RIGHT_BRACE 
                           ;


            indexed:       indexdelem
                           | ( COMMA indexdelem )*
                           ;

            indexdelem:    LEFT_BRACKET expr COLON expr RIGHT_BRACKET;

            block:         LEFT_BRACKET RIGHT_BRACKET
                           |LEFT_BRACKET stmt RIGHT_BRACKET 
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




            idlist:         ID* 
                            | COMMA ID*  
                              ;


            ifstmt:         IF LEFT_PARENTHESIS expr RIGHT_PARENTHESIS stmt  
                            | IF LEFT_PARENTHESIS expr RIGHT_PARENTHESIS stmt ELSE stmt
                            ;


            whilestmt:      WHILE LEFT_PARENTHESIS expr RIGHT_PARENTHESIS stmt;



            forstmt:        FOR LEFT_PARENTHESIS elist SEMICOLON expr SEMICOLON elist RIGHT_PARENTHESIS stmt;


            returnstmt:     RETURN 
                            | RETURN expr;                            
            %%