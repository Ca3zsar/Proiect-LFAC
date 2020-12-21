%{
#include <stdio.h>
#include "y.tab.h"
%}
type "int"|"float"|"char"|"string"|"bool"

digit_n [1-9]
digit [0-9]

number ({digit_n}{digit}+)|{digit}
float_number {number}\.{digit}+
sign -

bool_val "True"|"False"

character \'.\'
text \"[^\"]*\"

identificator [_a-zA-Z][_0-9a-zA-Z]*

space [' ''\t''\n']

%option noyywrap
%%
{type} {printf("tip : %s\n",yytext);return TYPE;}
{sign}?{number} {printf("numar intreg: %s\n",yytext);return INT_NUM;}
{sign}?{float_number} {printf("numar rational : %s\n",yytext);return FLOAT_NUM;}
{character} {printf("single character : %s\n",yytext);return CHAR;}
{text} {printf("text : %s\n",yytext);return TEXT;}
{bool_val} {printf("bool value : %s\n",yytext);return BOOL_VAL;}
{identificator} {printf("id : %s\n",yytext);return ID;}
{identificator}\[{number}\] {printf("array : %s\n",yytext);return ID;}

{space} {}
%%
int main(void)
{
    yyin = fopen("program.txt","r");
    yylex();
    return 0;
}
