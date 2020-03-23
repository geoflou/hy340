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

             term:        (expr)/*den eimai sigouros gia ta 3 prwta*/
                          |-expr
                          |NOT expr
                          |++lvalue
                          |lvalue++
                          |--lvalue
                          |lvalue--
                          |primary
                          ;                  

            assignexpr:   lvalue=expr ;


            primary:      lvalue
                          |call
                          |objectdef
                          |(funcdef)
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
            %%