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
                %right OPERATOR_ASSIGN /*= == != ++ -- > < >= <=*/
                %nonassoc OPERATOR_EQ     
                %right OPERATOR_NOT    
                %right OPERATOR_PP     
                %right OPERATOR_MM     
                %right OPERATOR_GRT    
                %right OPERATOR_LES    
                %right OPERATOR_GRE    
                %right OPERATOR_LEE    

                %left OPERATOR_MINUS OPERATOR_PLUS /*+, - ,*, / , %*/
                %left OPERATOR_MUL OPERATOR_DIV
                %left OPERATOR_MOD


                %left LEFT_PARENTHESIS RIGHT_PARENTHESIS /*() {} []*/
                %left LEFT_BRACKET RIGHT_BRACKET
                %left LEFT_BRACES RIGHT_BRACES


                %left SEMICOLON COLON COMMA DOUBLE_COLON DOT DOUBLE_DOT /*; : , :: . ..*/
              %%
/*syntax analyser*/


            %%