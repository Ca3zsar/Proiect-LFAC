%{
#include <stdio.h>

int yylex();
void yyerror(const char *s);

extern FILE* yyin;
extern char* yytext;
extern int yylineno;
%}
%start s
%token ID TYPE INT_NUM FLOAT_NUM CHAR TEXT UMINUS
%token BOOL_VAL

%left '+' '-'
%left '*' '/' '%'
%left '(' ')'
%%
s : expr {$$=$1; printf("s->expr : valoare : %f \n",$$);}
  ;
expr : expr '+' expr {$$=$1+$3; printf("expr->expr+expr\n");}
     | expr '-' expr {$$=$1-$3; printf("expr->expr-expr\n");}
     | expr '*' expr {$$=$1*$3; printf("expr->expr*expr\n");}
     | expr '/' expr {$$=$1/$3; printf("expr->expr/expr\n");}
     | '-' expr {$$=-$2;printf("expr-> -expr\n");}
     | INT_NUM {$$=$1; printf("expr->%d\n",$1);}
     | FLOAT_NUM {$$=$1;printf("expr->%f\n",$1);}
     ;
%%
void yyerror(const char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(void)
{
    yyin = fopen("program.txt","r");
    yyparse();
    return 0;
}