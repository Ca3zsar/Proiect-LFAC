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

typedef union{
    int int_value;
    float float_value;
    int *int_array;
    float *float_array;
    char *content;
  } value_t;

struct variables
{
  char *type;
  char *name;
  int constant;
  int initialised;
  value_t value;
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

void assign_value(char* type,char *name,char *constant,value_t v,int initialised)
{
  if(var_head==NULL)
  {
    var_head = (struct variables *) malloc(sizeof(struct variables));

     var_head->type = strdup(type);
     var_head->name = strdup(name);
     if(strcmp(constant,"yes")==0)var_head->constant=1;
     else var_head->constant = 0;

     if(initialised){
        if(strcmp(type,"int")==0)
        {
          var_head->value.int_value=v.int_value;
        }
        if(strcmp(type,"float")==0)
        {
          var_head->value.float_value=v.float_value;
        }
        if(strcmp(type,"char")==0 || strcmp(type,"string")==0)
        {
          var_head->value.content=strdup(v.content);
        }
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

      if(initialised){
        if(strcmp(type,"int")==0)
        {
          var_last->value.int_value=v.int_value;
        }
        if(strcmp(type,"float")==0)
        {
          var_last->value.float_value=v.float_value;
        }
        if(strcmp(type,"char")==0 || strcmp(type,"string")==0)
        {
          var_last->value.content=strdup(v.content);
        }
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

void add_to_temp(char *type,char* name,value_t value,int initialised)
{
  temp[index_temp].type = strdup(type);
  temp[index_temp].name = strdup(name);

  if(initialised){
    if(strcmp(type,"int")==0)
    {
      temp[index_temp].value.int_value = value.int_value;
    }
    if(strcmp(type,"float")==0)
    {
      temp[index_temp].value.float_value = value.float_value;
    }
    if(strcmp(type,"string")==0 || strcmp(type,"char")==0)
    {
      temp[index_temp].value.content = strdup(value.content);
    }
  }
  temp[index_temp].initialised = initialised;
  index_temp ++;
}

void add_to_linked(char* is_const,char *type)
{
  for(int i=0;i<index_temp;i++)
  {
    if(!temp[i].type[0] == ' ' && strcmp(temp[i].type,type))
    {
      yyerror("Incompatible types!");
    }

    assign_value(type,temp[i].name,is_const,temp[i].value,temp[i].initialised);
    temp[i].initialised=0;

  }
  index_temp = 0;
}

void modify_linked()
{
  for(int i=0;i<index_temp;i++)
  {
    int found = 0;
    var_current = var_head;
    while(var_current!=NULL)
    {
      if(strcmp(temp[i].name,var_current->name)==0)
      {
        if(strcmp(var_current->type,temp[i].type))
        {
          yyerror("incompatible types!");
        }

        if(var_current->constant==1)
        {
          yyerror("cannot modify const");
        }

        if(strcmp(var_current->type,"int")==0)
        {
          var_current->value.int_value = temp[i].value.int_value;
        }
        if(strcmp(var_current->type,"float")==0){
          var_current->value.float_value = temp[i].value.float_value;
        }
        if(strcmp(var_current->type,"char")==0 || strcmp(var_current->type,"string")==0)
        {
          var_current->value.content = strdup(temp[i].value.content);
        }

        var_current->initialised = 1;
        
        found = 1;
        break;
      }
      var_current = var_current->next;
    }
    if(!found)
    {
      yyerror("variable not declared!");
    }
  }
  index_temp = 0;
}

struct number get_value(char *name){
  struct number num = {0,0,0,0};
  int a=0;
  
  var_current = var_head;
  while(var_current!=NULL)
  {
    a++;
    if(strcmp(var_current->name,name)==0)
    {
      if(strcmp(var_current->type,"float")==0)
      {
        num.is_rational=1;
        num.rational=var_current->value.float_value;
      }else{
        num.is_rational=0;
        num.integer =var_current->value.int_value;
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
              | identificator ',' ID {value_t v;add_to_temp(" ",$3,v,0);}
              | identificator ',' ARRAY 
              | asignare 
              | ID  {value_t v;add_to_temp(" ",$1,v,0);}
              | ARRAY
              ;

asignari : asignare {modify_linked();} 
         ;

asignare : ID ASSIGN expr {if($3.is_rational){value_t v;v.float_value=$3.rational;add_to_temp("float",$1,v,1);}
                                            else{value_t v;v.int_value=$3.integer;add_to_temp("int",$1,v,1);}}

         | ID ASSIGN CHAR {value_t v;v.content = strdup($3);add_to_temp("char",$1,v,1);}
         | ID ASSIGN TEXT {value_t v;v.content = strdup($3);add_to_temp("string",$1,v,1);}
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

void print_table()
{
  char* filename = "symbol_table.txt";
  FILE *symbol = fopen(filename,"w");
  fprintf(symbol,"---The declared variables are: ---\n");
  var_current = var_head;

  while(var_current != NULL)
  {
    var_current=var_current->next;
  }

}

int main(void)
{
    yyin = fopen("program.txt","r");
    yyparse();
    print_table();
    return 0;
}
