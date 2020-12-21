%{
#include <stdio.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
%}
%start s
%token ID TYPE INT_NUM FLOAT_NUM CHAR TEXT UMINUS
%token BOOL_VAL

%left '+' '-'
%left '*' '/'
%left UMINUS

%%
s : expr {$$=$1; printf("s->expr : valoare : %d \n",$$);}
  ;
expr : expr '+' expr {$$=$1+$3; printf("expr->expr+expr\n");}
     | INT_NUM {$$=$1; printf("expr->%d\n",$1);}
     | FLOAT_NUM {$$=$1;printf("expr->%f\n",$1);}
%%
void yyerror(char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(void)
{
    yyin = fopen("program.txt","r");
    yyparse();
    return 0;
}