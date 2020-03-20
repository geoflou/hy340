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

                NEWLINE        { printf(" \n"); }
                STRING         { printf("%s",yytext); }
                IF             { printf("if"); }
                ELSE           { printf("else"); }
                WHILE          { printf("while"); }
                FOR            { printf("for"); }
                FUNCTION       { printf("function"); }
                RETURN         { printf("return"); }
                BREAK          { printf("break"); }
                CONTINUE       { printf("continue"); }
                AND            { printf("and"); }
                NOT            { printf("not"); }
                OR             { printf("or"); }
                LOCAL          { printf("local"); }
                TRUE           { printf("true"); }
                FALSE          { printf("false"); }
                NIL            { printf("nil"); }

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