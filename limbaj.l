%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
%}

type "int"|"float"|"char"|"string"|"bool"

digit_n [1-9]
digit [0-9]

number ({digit_n}{digit}+)|{digit}
float_number {number}"."{digit}+
sign -

bool_val "True"|"False"

character \'.\'
text \"[^\"]*\"

identificator [_a-zA-Z][_0-9a-zA-Z]*

operator [+\-\*%]

space [' ''\t''\n']

%option noyywrap
%%
{type} {printf("tip : %s\n",yytext);return TYPE;}
{number} {yylval = atoi(yytext);printf("numar intreg: %s\n",yytext);return INT_NUM;}
{float_number} {yylval= 2.2;printf("numar rational : %f\n",yylval);return FLOAT_NUM;}
{character} {printf("single character : %s\n",yytext);return CHAR;}
{text} {printf("text : %s\n",yytext);return TEXT;}
{bool_val} {printf("bool value : %s\n",yytext);return BOOL_VAL;}
{identificator} {printf("id : %s\n",yytext);return ID;}
{identificator}\[{number}\] {printf("array : %s\n",yytext);return ID;}
{operator} {printf("operator : %c\n",yytext[0]);return yytext[0];}
{space} ;
. ;
%%