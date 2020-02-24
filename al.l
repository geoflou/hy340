%{
    #include <assert.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdio.h>

    struct AlphaToken{
    
        int line;
        char* type;
        char* value;    

        struct AlphaToken* next;

    };
    
    struct AlphaToken * tokenListHead = NULL;

    
    void alphaListInsert(int line, char* value, char* type){
        struct AlphaToken* newToken, *tmp;

        assert(value != NULL);
        assert(type != NULL);


        newToken = (struct AlphaToken *) malloc(sizeof(struct AlphaToken));
        newToken -> line = line;
        newToken -> value = strdup(value);
        newToken -> type = type;
        newToken -> next = NULL;

        tmp = tokenListHead;

        if(tmp == NULL){
            tokenListHead = newToken;
            return;
        }

        while(tmp -> next != NULL){
        tmp = tmp -> next;
    }

        tmp -> next = newToken;
        return;

    }

    void printAlphaList(){
        struct AlphaToken * tmp = tokenListHead;
        int tokenCount = 1;

        if(tmp == NULL){
            printf("No tokens recognized\n");
           return;
        }

        while(tmp != NULL){
            printf("%d:  #%d   \"%s\"  %s\n", tmp->line, tokenCount, tmp -> value, tmp-> type);
            tokenCount++;
            tmp = tmp -> next;
        }

        return;
    }

%}


%option yylineno
%option noyywrap

ID              [a-zA-Z][a-zA-Z_0-9]*
WHITE_SPACE           [\r \t]
NEWLINE         \n
STRING          "[a-z A-Z 0-9 \ ^  \n \t \\]*"
IF              "if"
ELSE            "else"
WHILE           "while"
FOR             "for"
FUNCTION        "function"
RETURN          "return"
BREAK           "break"
CONTINUE        "continue"
AND             "and"
NOT             "not"
OR              "or"
LOCAL           "local"
TRUE            "true"
FALSE           "false"
NIL             "nil"
OPERATOR_PLUS   "+"
OPERATOR_MINUS  "-"
OPERATOR_MUL    "*"
OPERATOR_DIV    "/"
OPERATOR_ASSIGN "="
OPERATOR_MOD    "%"
OPERATOR_EQ     "=="
OPERATOR_NOT    "!="
OPERATOR_PP     "++"
OPERATOR_MM     "--"
OPERATOR_GRT    ">"
OPERATOR_LES    "<"
OPERATOR_GRE    ">="
OPERATOR_LEE    "<="
INTEGER         [][0-9]{1,}
REAL            [0-9]*\.?[0-9]{1,}
LEFT_BRACKET        "{"
RIGHT_BRACKET       "}"
LEFT_PARENTHESIS    "("
RIGHT_PARENTHESIS   ")"
LEFT_BRACE          "["
RIGHT_BRACE         "]"
SEMICOLON           ";"
COMMA               ","
COLON               ":"
DOUBLE_COLON        "::"
DOT                 "."
DOUBLE_DOT          ".."

COMMENT_1           //
%%

{WHILE} {alphaListInsert(yylineno, yytext, "WHILE");}
{WHITE_SPACE}   {}
{ID}    {alphaListInsert(yylineno, yytext, "ID");}

%%

int main(int argc, char* argv[]){
    
    if(argc < 2){
        printf("No input file!\n");
        return -1;
    }

    if(!(yyin = fopen(argv[1], "r"))){
        printf("Cannot read file!\n");
        return -1;
    }

    yylex();
    printAlphaList();

    return 0;    
}