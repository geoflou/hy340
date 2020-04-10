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

%%

%%


int yyerror(char *message){
    printf("%s: in line %d\n", message, yylineno); 
}

int main(int argc, char* argv[]){
    initTable();
    return 0;
}