%{
    #include "AlphaToken.h"

%}


%option yylineno
%option noyywrap

id              [a-zA-Z][a-zA-Z_0-9]*
space           [\r \t]
newline         \n
string          "[a-z A-Z 0-9 \ ^  \n \t \\]*"
IF              if
ELSE            else
WHILE           while
FOR             for
FUNCTION        function
RETURN          return
BREAK           break
CONTINUE        continue
AND             and
NOT             not
OR              or
LOCAL           local
TRUE            true
FALSE           false
NIL             nil
OPERATOR_PLUS   +
OPERATOR_MINUS  -
OPERATOR_MUL    *
OPERATOR_DIV    /
OPERATOR_ASSIGN     =
OPERATOR_MOD    %
OPERATOR_EQ     ==
OPERATOR_NOT    !=
OPERATOR_PP     ++
OPERATOR_MM     --
OPERATOR_GRT    >
OPERATOR_LES    <
OPERATOR_GRE    >=
OPERATOR_LEE    <=
%%


%%

