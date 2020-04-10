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
    program: stmt   {printf("stmt -> program\n");}
        |program WHITESPACE stmt    {printf("program WHITESPACE stmt -> program\n");}
        ;

    stmt: expr SEMICOLON    {printf("expr ; -> stmt\n");}
        |ifstmt {printf("IF -> stmt\n");} 
        |whilestmt  {printf("WHILE -> stmt\n");}
        |forstmt    {printf("FOR -> stmt\n");}
        |returnstmt {printf("RETURN -> stmt\n");}
        |BREAK SEMICOLON    {printf("BREAK -> stmt\n");}
        |CONTINUE SEMICOLON {printf("CONTINUE ->stmt\n");}
        |block  {printf("block -> stmt\n");}
        |funcdef    {printf("funcdef -> stmt\n");}
        ;

    epxr: assignexpr    {printf("assignexpr -> expr\n");}
        |expr op expr   {printf("expr OP expr -> expr\n");}
        |term   {printf("term -> expr\n");}
        ;

    op: OPERATOR_PLUS
        |OPERATOR_MINUS
        |OPERATOR_MUL
        |OPERATOR_DIV
        |OPERATOR_MOD
        |OPERATOR_GRT
        |OPERATOR_LES
        |OPERATOR_GRE
        |OPERATOR_LEE
        |OPERATOR_EQ
        |OPERATOR_NEW
        |OPERATOR_AND
        |OPERATOR_OR
        ;

    term: LEFT_PARENTHESIS expr RIGHT_PARENTHESIS   {printf("(expr) -> term\n");}
        |OPERATOR_MINUS expr    {printf("-expr -> term\n");}
        |OPERATOR_NOT expr  {printf("NOT expr -> term\n");}
        |OPERATOR_PP lvalue {printf("++lvalue -> term\n");}
        |lvalue OPERATOR_PP {printf("lvalue++ -> term\n");}
        |OPERATOR_MM lvalue {printf("--lvalue -> term\n");}
        |lvalue OPERATOR_MM {printf("lvalue-- -> term\n");}
        |primary    {printf("primary -> term\n");}
        ;

    assignexpr: lvalue OPERATOR_ASSIGN expr {printf("lvalue = expr -> assignexpr\n");}
        ;

    primary: lvalue  {printf("lvalue -> primary\n");}
        |call   {printf("call -> primary\n");}
        |objectdef  {printf("objectdef -> primary\n");}
        |LEFT_PARENTHESIS funcdef RIGHT_PARENTHESIS {printf("(funcdef) -> primary\n");}
        |const  {printf("const -> primary\n");}
        ;

    lvalue: ID  {printf("ID -> lvalue\n");}
        |LOCAL_KEYWORD ID   {printf("local ID -> lvalue\n");}
        |DOUBLE_COLON ID  {printf("::ID -> lvalue\n");}
        |member {printf("member -> lvalue");}
        ;

    member: lvalue DOT ID   {printf("lvalue.ID -> member\n");}
        |lvalue LEFT_BRACE expr RIGHT_BRACE {printf("lvalue[expr] -> member\n");}
        |call DOT ID    {printf("call.ID -> member\n");}
        |call LEFT_BRACE expr RIGHT_BRACE   {printf("call[expr] -> member\n");}
        ;
    
    call: call LEFT_PARENTHESIS elist RIGHT_PARENTHESIS    {printf("(call) -> call\n");}
        |lvalue callsuffix  {printf("lvalue callsuffix -> call\n");}
        |LEFT_PARENTHESIS funcdef RIGHT_PARENTHESIS LEFT_PARENTHESIS elist RIGHT_PARENTHESIS
            {printf("(funcdef)(elist) ->  call\n");}
        ;

    callsuffix: normcall    {printf("normcall -> callsuffix\n");}
        |methodcall {printf("methodcall -> callsuffix\n");}
        ;

    normcall: LEFT_PARENTHESIS elist RIGHT_PARENTHESIS  {printf("(elist) -> normcall\n");}
        ;

    methodcall: DOUBLE_DOT ID LEFT_PARENTHESIS elist RIGHT_PARENTHESIS  {printf("..ID(elist) -> methodcall\n");}
        ;

    elist: expr {printf("expr -> elist\n");}
        |COMMA elist    {printf(", elist -> elist\n");}
        |   {printf("EMPTY -> elist\n");} 
        ;

    objectdef: LEFT_BRACE elist RIGHT_BRACE {printf("[elist] -> objectdef\n");}
        |LEFT_BRACE indexed RIGHT_BRACE {printf("[indexed] -> object def\n");}
        |   {printf("EMPTY -> objectdef\n");}
        ;   

    indexed: indexedelem    {printf("indexelem -> indexed\n");}
        |COMMA indexed  {printf(", indexed -> indexed\n");}
        |   {printf("EMPTY -> indexed\n");}
        ;

    indexedelem: LEFT_BRACKET expr COLON expr RIGHT_BRACKET {printf("{expr : expr} -> indexedelem\n");}
        ;

    block: LEFT_BRACKET stmt RIGHT_BRACKET  {printf("{stmt} -> block\n");}
        |LEFT_BRACKET RIGHT_BRACKET {printf("{} -> block\n");}
        ;

    funcdef: FUNCTION LEFT_PARENTHESIS idlist RIGHT_PARENTHESIS block
                {pritnf("function(idlist){} -> funcdef\n");}
        |FUNCTION ID LEFT_PARENTHESIS idlist RIGHT_PARENTHESIS block
            {printf("function ID(idlist){} -> funcdef\n");}
        ;

    const: INTEGER  {printf("INTEGER -> const\n");}  
        |REAL   {printf("REAL -> const\n");}
        |STRING {printf("STRING -> const\n");}
        |NIL    {printf("NIL -> const\n");}
        |TRUE   {printf("TRUE -> const\n");}
        |FALSE  {printf("FALSE -> const\n");}
        ;

    idlist: ID  {printf("ID -> idlist\n");}
        |COMMA idlist   {printf(",idlist -> idlist\n");}
        |   {printf("EMPTY -> idlist\n");}
        ;
    
    ifstmt: IF LEFT_PARENTHESIS expr RIGHT_PARENTHESIS stmt {printf("IF(expr)stmt -> ifstmt\n");}
        |IF LEFT_PARENTHESIS expr RIGHT_PARENTHESIS stmt ELSE stmt 
            {printf("IF(expr) stmt ELSE stmt -> ifstmt\n");}
        ;

    whilestmt: WHILE LEFT_PARENTHESIS expr RIGHT_PARENTHESIS stmt   {printf("while(expr) stmt -> whilestmt\n");}
        ;

    forstmt: FOR LEFT_PARENTHESIS elist SEMICOLON expr SEMICOLON elist RIGHT_PARENTHESIS stmt
                {printf("for(elist;expr;elist) stmt -> forstmt\n");}
        ;

    returnstmt: RETURN expr SEMICOLON   {printf("RETURN expr; -> returnstmt\n");}
        |RETURN SEMICOLON   {printf("RETURN; -> returnstmt\n");}
        ;
        
%%


int yyerror(char *message){
    printf("%s: in line %d\n", message, yylineno); 
}

int main(int argc, char* argv[]){
    initTable();
    printEntries();
    return 0;
}