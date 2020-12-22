%{
#include <stdio.h>

int yylex();
void yyerror(const char *s);

extern FILE* yyin;
extern char* yytext;
extern int yylineno;
%}
%start program
%token ID TYPE INT_NUM FLOAT_NUM CHAR TEXT ARRAY
%token BOOL_VAL
%token IF ELSE FOR WHILE SWITCH GT GE LT LE EQ AND OR ASSIGN FUNCTION


%left '+' '-'
%left '*' '/' '%'
%left '(' ')'
%%
program : blocuri {printf("program corect\n");}
        ;

blocuri : bloc bloc
        ;

bloc : declaratii
     | asignare
     | instructiuni
     | /* empty */
     ;
declaratii : declaratie ';'
           | declaratii declaratie ';'
           ;

declaratie : TYPE identificator 
           ;

identificator : identificator ',' ID
              | identificator ',' ARRAY      
              | ID
              | ARRAY
              ;

asignare : ID ASSIGN INT_NUM
         | ID ASSIGN FLOAT_NUM
         | ID ASSIGN CHAR
         | ID ASSIGN TEXT
         ;

instructiuni : instructiune ';'
             | instructiuni instructiune ';'
             ;

instructiune : s 
             ;

s : expr {$$=$1; printf("s->expr : valoare : %d \n",$$);}
  ;
expr : expr '+' expr {$$=$1+$3; printf("expr->expr+expr\n");}
     | expr '-' expr {$$=$1-$3; printf("expr->expr-expr\n");}
     | expr '*' expr {$$=$1*$3; printf("expr->expr*expr\n");}
     | expr '/' expr {$$=$1/$3; printf("expr->expr/expr\n");}
     | expr '%' expr {$$=$1%$3; printf("expr->expr%expr\n");}
     | '(' expr ')' {$$ = $2; printf("expr->(expr)\n");}
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