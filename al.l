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



      void commentCheck(int line,char *text){
       
    }
%}


%option yylineno
%option noyywrap
%x comment
ID              [a-zA-Z][a-zA-Z_0-9]*
WHITE_SPACE           [\r \t]
NEWLINE         \n
STRING          \"
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

SINGLE_COMMENT      "//".*
MULTI_LINE_COMMENT  "/*"
UNKNOWN_TOKEN       .
%%

{SINGLE_COMMENT}      {alphaListInsert(yylineno, yytext, "SINGLE_LINE_COMMENT");}
{MULTI_LINE_COMMENT}    {
                            int commentCloseFlag = 1;
                            int index = 2;
                            int line = yylineno;
                            char charIndex;
                            char* fixedToken = (char *)malloc(1024*sizeof(char*));

                            *(fixedToken + 0) = '/';
                            *(fixedToken + 1) = '*';

                            charIndex = input();
                            while(charIndex != EOF && commentCloseFlag != 0){

                                if(charIndex == '\n'){
                                    charIndex = input();
                                    continue;
                                }


                                if(charIndex == '/'){
                                    *(fixedToken + index) = charIndex;
                                    index++;
                                    charIndex = input();
                                    if(charIndex == '*'){
                                       *(fixedToken + index) = charIndex;
                                       commentCloseFlag++; 
                                       index++;
                                       charIndex = input();
                                       continue;
                                    }
                                }

                                if(charIndex == '*'){
                                    *(fixedToken + index) = charIndex;
                                    index++;
                                    charIndex = input();
                                    if(charIndex == '/'){
                                        *(fixedToken + index) = charIndex;
                                        commentCloseFlag--;
                                        index++;
                                        charIndex = input();
                                        if(commentCloseFlag == 0){
                                            break;
                                        }else{
                                            continue;
                                        }
                                    }
                                }

                                *(fixedToken + index) = charIndex;

                                charIndex = input();
                                index++;        
                            }

                            if(commentCloseFlag != 0){
                                alphaListInsert(line, "ERROR", "Comment never closed");
                                return;
                            }
                            alphaListInsert(line, fixedToken, "MULTI_LINE_COMMENT");
                            
}


{LEFT_BRACE}          {alphaListInsert(yylineno,yytext,"LEFT_BRACE");}
{RIGHT_BRACE}         {alphaListInsert(yylineno,yytext,"RIGHT_BRACE");}
{SEMICOLON}           {alphaListInsert(yylineno,yytext,"SEMICOLON");}
{COMMA}               {alphaListInsert(yylineno,yytext,"COMMA");}
{COLON}               {alphaListInsert(yylineno,yytext,"COLON");}
{DOUBLE_COLON}        {alphaListInsert(yylineno,yytext,"DOUBLE_COLON");}
{DOT}                 {alphaListInsert(yylineno,yytext,"DOT");}
{DOUBLE_DOT}          {alphaListInsert(yylineno,yytext,"DOUBLE_COLON");}
{IF}                  {alphaListInsert(yylineno, yytext, "IF_KEYWORD");}
{ELSE}                {alphaListInsert(yylineno, yytext, "ELSE_KEYWORD");}
{WHILE}               {alphaListInsert(yylineno, yytext, "WHILE_KEYWORD");}
{FOR}                 {alphaListInsert(yylineno, yytext, "FOR_KEYWORD");}
{FUNCTION}            {alphaListInsert(yylineno, yytext, "FUNCTION_KEYWORD");}
{RETURN}              {alphaListInsert(yylineno, yytext, "RETURN_KEYWORD");}
{BREAK}               {alphaListInsert(yylineno, yytext, "BREAK_KEYWORD");}
{CONTINUE}            {alphaListInsert(yylineno, yytext, "CONTINUE_KEYWORD");}
{AND}                 {alphaListInsert(yylineno, yytext, "AND_KEYWORD");}
{OR}                  {alphaListInsert(yylineno, yytext, "OR_KEYWORD");}
{LOCAL}               {alphaListInsert(yylineno, yytext, "LOCAL_KEYWORD");}
{TRUE}                {alphaListInsert(yylineno, yytext, "TRUE_KEYWORD");}
{FALSE}               {alphaListInsert(yylineno, yytext, "FALSE_KEYWORD");}
{NIL}                 {alphaListInsert(yylineno, yytext, "NIL_KEYWORD");}
{WHITE_SPACE}         {}
{NEWLINE}             {}
{OPERATOR_PLUS}       {alphaListInsert(yylineno,yytext,"PLUS");}
{OPERATOR_MINUS}      {alphaListInsert(yylineno,yytext,"MINUS");}
{OPERATOR_MUL}        {alphaListInsert(yylineno,yytext,"MULTIPLICATION");}
{OPERATOR_DIV}        {alphaListInsert(yylineno,yytext,"DIVISION");}
{OPERATOR_ASSIGN}     {alphaListInsert(yylineno,yytext,"ASSIGNMENT");}
{OPERATOR_MOD}        {alphaListInsert(yylineno,yytext,"MODULO");}
{OPERATOR_EQ}         {alphaListInsert(yylineno,yytext,"EQUAL");}
{OPERATOR_NOT}        {alphaListInsert(yylineno,yytext,"NOT");}
{OPERATOR_PP}         {alphaListInsert(yylineno,yytext,"INCREMENT");}
{OPERATOR_MM}         {alphaListInsert(yylineno,yytext,"DECREMENT");}
{OPERATOR_GRT}        {alphaListInsert(yylineno,yytext,"GREATER");}
{OPERATOR_LES}        {alphaListInsert(yylineno,yytext,"LESSER");}
{OPERATOR_GRE}        {alphaListInsert(yylineno,yytext,"GREATER EQUAL");}
{OPERATOR_LEE}        {alphaListInsert(yylineno,yytext,"LESSER EQUAL");}
{INTEGER}             {alphaListInsert(yylineno,yytext,"INT");}
{REAL}                {alphaListInsert(yylineno,yytext,"REAL");}
{LEFT_BRACKET}        {alphaListInsert(yylineno,yytext,"LEFT_BRACKET");}
{RIGHT_BRACKET}       {alphaListInsert(yylineno,yytext,"RIGHT_BRACKET");}
{LEFT_PARENTHESIS}    {alphaListInsert(yylineno,yytext,"LEFT_PARENTHESIS");}
{RIGHT_PARENTHESIS}   {alphaListInsert(yylineno,yytext,"RIGHT_PARENTHESIS");}

{STRING}              {
            char charIndex = '\"';
            int index = 0;
            int backSlashCounter = 0;
            int line = yylineno;
            int closingQuoteFlag = 1;
            char * fixedString =(char*) malloc(1024*sizeof(char*));

            *(fixedString + index) = charIndex;
            index++;

            charIndex = input();
            while(charIndex != EOF){

                if(charIndex == '\\'){
                    charIndex = input();

                    if(charIndex == 'n'){
                        *(fixedString + index) = '\n';
                        index += 1;
                        charIndex = input();
                        continue;
                    }

                    if(charIndex == 't'){
                        *(fixedString + index) = '\t';
                        index += 1;
                        charIndex = input();
                        continue;
                    }

                    
                    if(charIndex == '\"'){
                        *(fixedString + index) = '\"';
                        index += 1;
                        charIndex = input();
                        continue;
                    }

                    if(charIndex == '\\'){
                        backSlashCounter++;
                        *(fixedString + index) = '\\';
                        index += 1;
                        charIndex = input();
                        continue;
                    }
                    
                    backSlashCounter++;
                }


                if(charIndex == '\"'){
                    *(fixedString + index) = charIndex;
                    closingQuoteFlag = 0;
                    break;
                }


                *(fixedString + index) = charIndex;


                index++;
                charIndex = input();
            }

            if(backSlashCounter % 2 != 0){
                alphaListInsert(line, "ERROR", "Invalid backslash escape sequence");
                return;
            }

            if(closingQuoteFlag == 0){
                alphaListInsert(line, fixedString, "STRING");
            }
            else{
                alphaListInsert(line, "ERROR", "Closing '\"' expected!");
            }

}

{ID}    {alphaListInsert(yylineno, yytext, "ID");}

{UNKNOWN_TOKEN} {alphaListInsert(yylineno, yytext, "UNKNOWN_TOKEN");}

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