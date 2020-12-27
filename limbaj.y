%{
#include "calcul.h"
#include <stdio.h>
#include <stdlib.h>

int yylex();
void yyerror(const char *s);

extern FILE* yyin;
extern char* yytext;
extern int yylineno;

%}

%union {
  struct number num;
  int bool_val;
  char *string;
};

%start program
%token <string>ID
%token <string>TYPE
%token <string>CHAR 
%token <string>TEXT
%token <string>ARRAY
%token <string>CLASS
%token <num>INT_NUM
%token <num> FLOAT_NUM
%token <bool_val>BOOL_VAL
%token <string>IF
%token <string>ELSE
%token <string>FOR
%token <string>WHILE
%token <string>SWITCH
%token <string>GT
%token <string>GE
%token <string>LT
%token <string>LE
%token <string>EQ
%token <string>AND
%token <string>OR
%token <string>ASSIGN
%token <string>FUNCTION
%token <string> CONST

%type <num> expr
%type <num> instructiune

%left '+' '-'
%left '*' '/' '%'
%left '(' ')'
%%
program : blocuri {printf("program corect\n");}
        ;

blocuri : declaratie ';' blocuri
        | instructiune ';' blocuri
        | asignare ';' blocuri
        | /* empty */
        ;

declaratie : TYPE identificator
	     | TYPE ID '(' parameter_list ')' '{' blocuri '}'
           | CONST TYPE identificator
           | CLASS ID '{' class_dec '}'
           ;

parameter_list : parameter
		   | parameter_list ',' parameter
		   ;
		   
parameter : TYPE ID
	    | /* empty */
	    ;

class_dec : ID '(' parameter_list ')' '{' blocuri '}'
	    | declaratie
          ;

identificator : identificator ',' asignare
              | identificator ',' ID
              | identificator ',' ARRAY 
              | asignare
              | ID
              | ARRAY
              ;

asignare : ID ASSIGN expr
         | ID ASSIGN CHAR
         | ID ASSIGN TEXT
         | ID ASSIGN ID
         ;

instructiune : expr {$$=$1; ($$.is_rational)?printf("instr->expr : valoare : %f \n\n",$$.rational):
                                             printf("instr->expr : valoare : %d \n\n",$$.integer);}
             ;

expr : expr '+' expr {$$=addition($1,$3); printf("expr->expr+expr\n");}
     | expr '-' expr {$$=substraction($1,$3); printf("expr->expr-expr\n");}
     | expr '*' expr {$$=multiply($1,$3); printf("expr->expr*expr\n");}
     | expr '/' expr {$$=division($1,$3); printf("expr->expr/expr\n");}
     | expr '%' expr {$$=modulo($1,$3);if($$.modulo_error)yyerror("Modulo se poate doar pe intregi"); 
                        printf("expr->expr%%expr\n");}
     | '(' expr ')' {$$ = $2; printf("expr->(expr)\n");}
     | '-' expr {$$=negate($2);printf("expr-> -expr\n");}
     | INT_NUM {$$=$1; printf("expr->%d\n",$1);}
     | FLOAT_NUM {$$=$1;printf("expr->%f\n",$1.rational);}
     ;
%%
void yyerror(const char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
exit(0);
}

int main(void)
{
    yyin = fopen("program.txt","r");
    yyparse();
    return 0;
}
