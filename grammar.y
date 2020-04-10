%{
    #include <stdlib.h>
    #include <stdio.h>
    #include "SymbolTable.h"
    #include "grammar.h"

    int yyerror(char* message);
    int yylex(void);

    extern int yylineno;
    extern char* yytext;
    extern FILE* yyin();
%}

%union{
    int intVal;
    char *strVal;
    double doubleVal;
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

%%


int yyerror(char *message){
    printf("%s: in line %d\n", message, yylineno); 
}

int main(int argc, char* argv[]){
    initTable();
    printEntries();
    return 0;
}