%{
    #include <stdlib.h>
    #include <stdio.h>
    #include "SymbolTable.h"
    #include "grammar.h"

    int yyerror(char* message);
    int yylex(void);

    extern int yylineno;
    extern char* yytext;
    extern FILE* yyin;
%}

%union{
    int intVal;
    char *strVal;
    double doubleVal;
}


%start program

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
program: set   {printf("set -> program\n");}
    |   {printf("EMPTY -> program\n");}
    ;

set: stmt
    |set stmt
    ;

stmt: expr SEMICOLON    {printf("expr ; -> stmt\n");}
    |ifstmt {printf("ifstmt -> stmt\n");}
    |whilestmt  {printf("whilestmt -> stmt\n");}
    |forstmt    {printf("forstmt -> stmt\n");}
    |returnstmt    {printf("returnstmt -> stmt\n");}
    |BREAK SEMICOLON    {printf("break; -> stmt\n");}
    |CONTINUE SEMICOLON {printf("continue; -> stmt\n");}
    |block  {printf("block -> stmt\n");}
    |funcdef    {printf("funcdef -> stmt\n");}
    |SEMICOLON  {printf("; -> stmt\n");}
    ;

expr: assignexpr    {printf("assignexpr -> expr");}
    |expr op expr  {printf("expr op expr -> expr");}
    |term
    ;

op: OPERATOR_PLUS
    |OPERATOR_MINUS
    |OPERATOR_MUL
    |OPERATOR_DIV
    |OPERATOR_MOD
    |OPERATOR_GRT
    |OPERATOR_GRE
    |OPERATOR_LES
    |OPERATOR_LEE
    |OPERATOR_EQ
    |OPERATOR_NEQ
    |OPERATOR_AND
    |OPERATOR_OR
    ;

term: LEFT_PARENTHESIS expr RIGHT_PARENTHESIS   {printf("(expr) -> term");}
    |OPERATOR_MINUS expr    {printf("- expr -> term\n");}
    |OPERATOR_NOT expr  {printf("not expr -> term\n");}
    |OPERATOR_PP lvalue {printf("++lvalue -> term\n");}
    |lvalue OPERATOR_PP {printf("lvalue++ -> term\n");}
    |OPERATOR_MM lvalue {printf("--lvalue -> term\n");}
    |lvalue OPERATOR_MM {printf("lvalue-- -> term\n");}
    |primary    {printf("primary -> term\n");}
    ;

assignexpr: lvalue OPERATOR_ASSIGN expr {printf("lvalue = expr -> assignexpr\n");}
    ;

primary: lvalue {printf("lvalue -> primary\n");}
    |call   {printf("call -> primary\n");}
    |objectdef  {printf("objectdef -> primary\n");}
    |LEFT_PARENTHESIS funcdef RIGHT_PARENTHESIS {printf("(funcdef) -> primary\n");}
    |const  {printf("const -> primary\n");}
    ;

lvalue: ID  {printf("ID -> lvalue\n");}
    |LOCAL_KEYWORD ID   {printf("local ID -> lvalue\n");}
    |DOUBLE_COLON ID    {printf("::ID -> lvalue\n");}
    |member {printf("member -> lvalue\n");}
    ;

member: lvalue DOT ID   {printf("lvalue.ID -> mebmer\n");}
    |lvalue LEFT_BRACE expr RIGHT_BRACE {printf("lvalue[expr] -> member\n");}
    ;

call: call LEFT_PARENTHESIS elist RIGHT_PARENTHESIS {printf("call(elist) -> call\n");}
    |lvalue callsuffix  {printf("lvalue() -> call\n");}
    |LEFT_PARENTHESIS funcdef RIGHT_PARENTHESIS LEFT_PARENTHESIS elist RIGHT_PARENTHESIS
        {printf("(funcdef)(elist) -> call\n");}
    ;

callsuffix: methodcall {printf("methodcall -> callsuffix\n");}
    |normcall   {printf("normcall -> callsuffix\n");}
    ;

normcall: LEFT_PARENTHESIS elist RIGHT_PARENTHESIS
    ;

methodcall: DOUBLE_DOT ID normcall  {printf("..id(elist) -> methodcall\n");}
    ;

elist: expr
    |expr COMMA elist
    |
    ;

objectdef: LEFT_BRACE elist RIGHT_BRACE {printf("[elist] -> objectdef\n");}
    |LEFT_BRACE indexed RIGHT_BRACE {printf("[index] -> objectdef\n]");}
    ;

indexed: indexedelem
    |indexed COMMA indexedelem
    |
    ;

indexedelem: LEFT_BRACKET expr COLON expr RIGHT_BRACKET {printf("{expr : expr} -> indexed elem\n");}
    ;

block: LEFT_BRACKET set RIGHT_BRACKET {printf("block with stmts -> block");} 
    |LEFT_BRACKET RIGHT_BRACKET   {printf("empty block -> block\n");}
    ;

funcdef: FUNCTION ID LEFT_PARENTHESIS idlist RIGHT_PARENTHESIS block    {printf("function id(idlist)block -> funcdef\n");}
    |FUNCTION LEFT_PARENTHESIS idlist RIGHT_PARENTHESIS block    {printf("function (idlist)block -> funcdef\n");}
    ;

const: REAL
    |INTEGER
    |STRING 
    |NIL
    |TRUE
    |FALSE
    ;

idlist: ID
    |ID COMMA idlist
    |
    ;

ifstmt: IF LEFT_PARENTHESIS expr RIGHT_PARENTHESIS stmt ELSE stmt    {printf("if(expr) else -> ifstmt\n");}
    |IF LEFT_PARENTHESIS expr RIGHT_PARENTHESIS stmt   {printf("if(expr) -> ifstmt\n");}
    ;

whilestmt: WHILE LEFT_PARENTHESIS expr RIGHT_PARENTHESIS stmt   {printf("while(expr) -> whilestmt\n");}
    ;    

forstmt: FOR LEFT_PARENTHESIS elist SEMICOLON expr SEMICOLON elist RIGHT_PARENTHESIS stmt
    {printf("for(elist;expr;elist)stmt -> forstmt\n");}
    ;

returnstmt: RETURN expr SEMICOLON   {printf("return expr ; -> returnstmt\n");} 
    |RETURN SEMICOLON    {printf("return ; -> returnstmt\n");}
    ;
%%


int yyerror(char *message){
    printf("%s: in line %d\n", message, yylineno); 
}

int main(int argc, char* argv[]){
    initTable();

    yyparse();

    //printEntries();

    return 0;
}