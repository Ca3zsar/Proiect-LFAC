%{
#include <stdio.h>
%}
type "int"|"float"|"char"|"string"|"bool"
digit_n [1-9]
digit [0-9]
number ({digit_n}{digit}+)|{digit}
space [' ''\t''\n']
sign [+-]
%option noyywrap
%%
{type} {printf("tip : %s\n",yytext);}
{sign}?{number} {printf("numar intreg: %s\n",yytext);}
{space} {}
%%
int main(void)
{
    yyin = fopen("program.txt","r");
    yylex();
    return 0;
}