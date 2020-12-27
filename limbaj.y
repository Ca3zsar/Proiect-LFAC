%{
#include "calcul.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int yylex();
void yyerror(const char *s);

extern FILE* yyin;
extern char* yytext;
extern int yylineno;

struct variables
{
  char *type;
  char *name;
  char *content;
  int constant;
  int int_value;
  float float_value;
  struct variables *next;
};

struct variables *var_head = NULL;
struct variables *var_current;
struct variables *var_last = NULL;

struct variables temp[100];
int index_temp = 0;

char *global_type;

int exists_variable(char *name)
{
  var_current = var_head;
  while(var_current!=NULL)
  {
    if(strcmp(name,var_current->name)==0)
    {
      return 1;
    }
    var_current = var_current->next;
  }
  return 0;
}

void assign_value(char* type,char *name,char *constant,int i_value,float f_value)
{
  if(var_head==NULL)
  {
    var_head = (struct variables *) malloc(sizeof(struct variables));

     var_head->type = strdup(type);
     var_head->name = strdup(name);
     if(strcmp(constant,"yes")==0)var_head->constant=1;
     else var_head->constant = 0;
     if(strcmp(type,"int")==0)
     {
       var_head->int_value=i_value;
     }else{
       var_head->float_value=f_value;
     }
     var_head->next = var_last;
  }
  else{
    if(!exists_variable(name))
    {
      var_last = (struct variables *) malloc(sizeof(struct variables));

      var_last->type = strdup(type); 
      var_last->name = strdup(name);
      if(strcmp(constant,"yes")==0)var_last->constant=1;
      else var_last->constant = 0;
      if(strcmp(type,"int")==0)
      {
        var_last->int_value=i_value;
      }else{
        var_last->float_value=f_value;
      }
      //var_last = var_last->next;
      struct variables *var_current_temp;
      var_current_temp = var_head;

      while(var_current_temp->next != NULL){
        var_current_temp = var_current_temp->next;
      }
      
      var_current_temp -> next = var_last;
      var_current_temp -> next -> next = NULL;
      return;
    }
    yyerror("already defined variable");
   }
}

void add_to_temp(char* name,int i_value,float f_value)
{
  temp[index_temp].name = strdup(name);
  temp[index_temp].int_value = i_value;
  temp[index_temp].float_value = f_value;
  index_temp ++;
}

void add_to_linked(char* is_const,char *type)
{
  for(int i=0;i<index_temp;i++)
  {
    assign_value(type,temp[i].name,is_const,temp[i].int_value,temp[i].float_value);
    temp[i].int_value = 0;
    temp[i].float_value = 0;
  }
  index_temp = 0;
}

void modify_linked()
{
  for(int i=0;i<index_temp;i++)
  {

  }
}

struct number get_value(char *name){
  struct number num;
  int a=0;
  
  var_current = var_head;
  while(var_current!=NULL)
  {
    printf("%d\n",a);
    a++;
    if(strcmp(var_current->name,name)==0)
    {
      if(strcmp(var_current->type,"float")==0)
      {
        num.is_rational=1;
        num.rational=var_current->float_value;
      }else{
        num.is_rational=0;
        num.integer =var_current->int_value;
      }
      return num;
    }
    var_current = var_current->next;
  }
  yyerror("variabile not declared");

}

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
        | asignari ';' blocuri
        | /* empty */
        ;

declaratie : TYPE identificator {add_to_linked("no",$1);}
	         | TYPE ID '(' parameter_list ')' '{' blocuri '}'
           | CONST TYPE identificator {add_to_linked("yes",$2);}
           | CLASS ID '{' class_dec '}'
           | ID ID 
           ;

class_dec : declaratie ';' class_dec
          | declaratie ';'
          |  ID '(' parameter_list ')' '{' blocuri '}'
          ;

parameter_list : parameter
                | parameter_list ',' parameter
                ;
		   
parameter : TYPE ID
	    | /* empty */
	    ;

identificator : identificator ',' asignare 
              | identificator ',' ID
              | identificator ',' ARRAY 
              | asignare 
              | ID  {add_to_temp($1,0,0);}
              | ARRAY
              ;

asignari : asignare {modify_linked();} 
         ;

asignare : ID ASSIGN expr {($3.is_rational)?add_to_temp($1,0,$3.rational):
                                            add_to_temp($1,$3.integer,0);}

         | ID ASSIGN CHAR
         | ID ASSIGN TEXT
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
     | ID {$$=get_value($1);printf("expr->%s\n",$1);}
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
