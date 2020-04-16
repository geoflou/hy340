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

    int scope = 0;

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
    | expr OPERATOR_PLUS expr   {printf("expr + expr -> expr\n");}
    | expr OPERATOR_MINUS expr  {printf("expr - expr -> expr\n");}
    | expr OPERATOR_MOD expr    {printf("expr % expr -> expr\n");}
    | expr OPERATOR_DIV expr    {printf("expr / expr -> expr\n");}
    | expr OPERATOR_MUL expr    {printf("expr * expr -> expr\n");}
    | expr OPERATOR_GRT expr    {printf("expr > expr -> expr\n");}
    | expr OPERATOR_GRE expr    {printf("expr >= expr -> expr\n");}
    | expr OPERATOR_LES expr    {printf("expr < expr -> expr\n");}
    | expr OPERATOR_LEE expr    {printf("expr <= expr -> expr\n");}
    | expr OPERATOR_EQ expr {printf("expr == expr -> expr\n");}
    | expr OPERATOR_NEQ expr    {printf("expr != expr -> expr\n");}
    | expr OPERATOR_AND expr    {printf("expr && expr -> expr\n");}
    | expr OPERATOR_OR expr {printf("expr || expr -> expr\n");}
    |term   {printf("term -> expr\n");}  
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
    |LOCAL_KEYWORD ID   {
        printf("local ID -> lvalue\n");
        if(lookupScope(yylval.strVal,scope)){
            comparelibfunc(yylval.strVal);
                            
        }else{
            Variable *newvar=(Variable*)malloc(sizeof(struct Variable));
            SymbolTableEntry *newnode=(SymbolTableEntry*)malloc(sizeof(struct SymbolTableEntry));
            newvar->name = yylval.strVal;
            newvar->scope = scope;
            newvar->line = yylineno;
            
            if(scope==0){
                newnode->type = GLOBAL;
            }else{
                newnode->type = LOCAL;
            }

            newnode->varVal = newvar;
            newnode->isActive = 1;
            insertEntry(newnode);
        }
                           
    }
    |DOUBLE_COLON ID    {
        printf("::ID -> lvalue\n");
        if(scope==0){
            if(lookupScope(yylval.strVal,0)){
                comparelibfunc(yylval.strVal);
                }else{
                    Variable *newvar=(Variable*)malloc(sizeof(struct Variable));
                    SymbolTableEntry *newnode=(SymbolTableEntry*)malloc(sizeof(struct SymbolTableEntry));
                    newvar->name = yylval.strVal;
                    newvar->scope = scope;
                    newvar->line = yylineno;
                    newnode->type = GLOBAL;
                    newnode->varVal = newvar;
                    newnode->isActive = 1;
                    insertEntry(newnode);
                }   
        }else{
            if(lookupScope(yylval.strVal,0)==NULL){
                yyerror("Global variable cannot be found");
            }
        }
                            
    }
    |member {printf("member -> lvalue\n");}
    ;

member: lvalue DOT ID   {printf("lvalue.ID -> mebmer\n");}
    |lvalue LEFT_BRACE expr RIGHT_BRACE {printf("lvalue[expr] -> member\n");}
    |call DOT ID    {printf("call.id -> member\n");}
    |call LEFT_BRACE expr RIGHT_BRACE   {printf("call[expr] -> member\n");}
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
    |LEFT_BRACE indexed RIGHT_BRACE {printf("[indexed] -> objectdef\n]");}
    ;

indexed: indexedelem
    |indexedelem COMMA indexed
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

ifstmt: IF LEFT_PARENTHESIS expr RIGHT_PARENTHESIS stmt   {printf("if(expr) -> ifstmt\n");}
    |IF LEFT_PARENTHESIS expr RIGHT_PARENTHESIS stmt ELSE stmt    {printf("if(expr) else -> ifstmt\n");}
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

    printEntries();

    return 0;
}