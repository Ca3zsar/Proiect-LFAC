%{
#include <stdio.h>
#include <stdlib.h>
#include "calcul.h"
#include "y.tab.h"
%}

type "int"|"float"|"char"|"string"|"bool"

digit_n [1-9]
digit [0-9]

number ({digit_n}{digit}+)|{digit}
float_number {number}"."{digit}+

bool_val "True"|"False"

character \'.\'
text \"[^\"]*\"

identificator [_a-zA-Z][_0-9a-zA-Z]*

operator [+\-\*%]
negation "!"

space [' ''\t']

%option noyywrap
%%
"if" {printf("if token\n");return IF;}
"else" {return ELSE;}
"for" {return FOR;}
"while" {return WHILE;}

"function" {return FUNCTION;}

">" {return GT;}
">=" {return GE;}
"<" {return LT;}
"<=" {return LE;}
"==" {return EQ;}
"!" {return NOT;}

"&&" {return AND;}
"||" {return OR;}

"=" {return ASSIGN;}

"const" {return CONST;}
{type} {yylval.string = strdup(yytext);
                         return TYPE;}

"class" {yylval.string = strdup(yytext);
        return CLASS;}

{number} {yylval.num = (struct number){atoi(yytext),0,0};
         return INT_NUM;}

{float_number} {yylval.num = (struct number){0,atof(yytext),1};
                return FLOAT_NUM;}

{character} {yylval.string = strdup(yytext);
            return CHAR;}

{text} {yylval.string = strdup(yytext);
                        return TEXT;}

{bool_val} { yylval.string = strdup(yytext);
            return BOOL_VAL;}

{identificator} {yylval.string = strdup(yytext);
                return ID;}

{identificator}\[{number}\] {yylval.string = strdup(yytext);
                            return ARRAY;}
{operator} {return yytext[0];}


{space} ;
\n {yylineno++;}
. {return yytext[0];}
%%