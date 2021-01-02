%{
#include "calcul.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include "tree.h"
#include "compiler.h"

int yylex();
void yyerror(const char *s);

extern FILE* yyin;
extern char* yytext;
extern int yylineno;

struct variables *global_head = NULL;
struct variables *global_current;
struct variables *global_last = NULL;

struct variables temp[100];
int index_temp = 0;

char *global_type;


int exists_variable(char *name,struct variables *current_stack)
{
  struct variables *temp_stack = current_stack;
  while(temp_stack!=NULL)
  {
    if(strcmp(name,temp_stack->name)==0)
    {
      return 1;
    }
    temp_stack = temp_stack->next;
  }
  return 0;
}

/*void assign_value(char* type,char *name,char *constant,value_t v,int initialised)
{
  if(global_head==NULL)
  {
    global_head = (struct variables *) malloc(sizeof(struct variables));

     global_head->type = strdup(type);
     global_head->name = strdup(name);
     if(strcmp(constant,"yes")==0)global_head->constant=1;
     else global_head->constant = 0;

     if(initialised){
        if(strcmp(type,"int")==0)
        {
          global_head->value.int_value=v.int_value;
        }
        if(strcmp(type,"float")==0)
        {
          global_head->value.float_value=v.float_value;
        }
        if(strcmp(type,"char")==0 || strcmp(type,"string")==0)
        {
          global_head->value.content=strdup(v.content);
        }
     }
     global_head->next = global_last;
  }
  else{
    if(!exists_variable(name))
    {
      global_last = (struct variables *) malloc(sizeof(struct variables));

      global_last->type = strdup(type); 
      global_last->name = strdup(name);

      if(strcmp(constant,"yes")==0)global_last->constant=1;
      else global_last->constant = 0;

      if(initialised){
        if(strcmp(type,"int")==0)
        {
          global_last->value.int_value=v.int_value;
        }
        if(strcmp(type,"float")==0)
        {
          global_last->value.float_value=v.float_value;
        }
        if(strcmp(type,"char")==0 || strcmp(type,"string")==0)
        {
          global_last->value.content=strdup(v.content);
        }
      }
      //global_last = global_last->next;
      struct variables *global_current_temp;
      global_current_temp = global_head;

      while(global_current_temp->next != NULL){
        global_current_temp = global_current_temp->next;
      }
      
      global_current_temp -> next = global_last;
      global_current_temp -> next -> next = NULL;
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
    global_current = global_head;
    while(global_current!=NULL)
    {
      if(strcmp(temp[i].name,global_current->name)==0)
      {
        if(strcmp(global_current->type,temp[i].type))
        {
          yyerror("incompatible types!");
        }

        if(global_current->constant==1)
        {
          yyerror("cannot modify const");
        }

        if(strcmp(global_current->type,"int")==0)
        {
          global_current->value.int_value = temp[i].value.int_value;
        }
        if(strcmp(global_current->type,"float")==0){
          global_current->value.float_value = temp[i].value.float_value;
        }
        if(strcmp(global_current->type,"char")==0 || strcmp(global_current->type,"string")==0)
        {
          global_current->value.content = strdup(temp[i].value.content);
        }

        global_current->initialised = 1;
        
        found = 1;
        break;
      }
      global_current = global_current->next;
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
  
  global_current = global_head;
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
*/

nodeType *opr(int operation,int number, ...);
nodeType *id(char *name);
nodeType *constant(value_t value,char *type);
nodeType *func(char *name,char *type,...);
nodeType *dec(char *type,char *name,int constant,int array,struct variables *current_stack);

void freeNode(nodeType *p);
%}

%union {
  struct number num;
  int bool_val;
  char *string;
  struct nodeTypeTag *nPtr;
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
%token <string> NOT
%token <string> RETURN

%type <nPtr> expr
%type <nPtr> assignation
%type <nPtr> instruction

%left OR 
%left AND
%left NOT
%left GT GE LT LE EQ 
%left '+' '-'
%left '*' '/' '%'
%left '(' ')'
%left UMINUS

%nonassoc IFX
%nonassoc ELSE

%%
program : program global
        | program function
        | /* empty */
        ;

global :  statements
       ;

statements : declaration ';'  
           | instruction ';' 
           | assignation ';' 
           | RETURN expr ';'
           ;

function : TYPE ID '(' parameter_list ')' '{' function_instr '}'
         ;

function_instr : function_instr statements
               | statements
               ;

declaration : TYPE identifier 
           | CONST TYPE identifier
           | CLASS ID '{' class_dec '}'
           | ID ID 
           ;

class_dec : declaration ';' class_dec
          | declaration ';'
          | ID '(' parameter_list ')' '{' class_instr'}'
          | function class_dec
          | function 
          ;

class_instr : class_instr declaration ';'
            | class_instr instruction ';'
            | class_instr assignation ';'
            | /* empty */

parameter_list : parameter
                | parameter_list ',' parameter
                ;
		   
parameter : TYPE ID
	    | /* empty */
	    ;

identifier : identifier ',' assignation 
              | identifier ',' ID 
              | identifier ',' ARRAY 
              | assignation
              | ID  
              | ARRAY
              ;

assignation : ID ASSIGN expr {$$ = opr('=',2,id($1),$3);}
         | ID ASSIGN CHAR {value_t v;v.content = strdup($3);$$ = opr('=',2,id($1),constant(v,"char"));}
         | ID ASSIGN TEXT {value_t v;v.content = strdup($3);$$ = opr('=',2,id($1),constant(v,"string"));}
         ;

instruction : expr {$$=$1;}
             | function_call
             | ID '.' ID
             | ID '.' function_call
             | if_check 
             | while_check
             ;

function_call : ID '(' arguments ')'
             ;
             
arguments : arguments ',' expr
          | arguments ',' function_call
          | expr
          | function_call
          | /* empty */
          ;

if_check : IF '(' conditions ')' '{' statements '}'
         ;

while_check : WHILE '(' conditions ')' '{' statements '}'

conditions : condition AND condition 
         | condition OR condition 
         | NOT conditions
         | '(' conditions ')'
         | condition
         ;

condition : expr EQ expr
         | expr GT expr
         | expr GE expr
         | expr LT expr
         | expr LE expr
         | expr
         ;

expr : expr '+' expr {$$=opr('+',2,$1,$3); printf("expr->expr+expr\n");}
     | expr '-' expr {$$=opr('-',2,$1,$3); printf("expr->expr-expr\n");}
     | expr '*' expr {$$=opr('*',2,$1,$3); printf("expr->expr*expr\n");}
     | expr '/' expr {$$=opr('/',2,$1,$3); printf("expr->expr/expr\n");}
     | expr '%' expr {$$=opr('%',2,$1,$3); printf("expr->expr%%expr\n");}
     | '(' expr ')' {$$ = $2; printf("expr->(expr)\n");}
     | '-' expr {$$=opr(UMINUS,1,$2);printf("expr-> -expr\n");}
     | INT_NUM {value_t v;v.int_value=$1.integer;$$=constant(v,"int"); printf("expr->%d\n",$1.integer);}
     | FLOAT_NUM {value_t v;v.int_value=$1.rational;$$=constant(v,"float");printf("expr->%f\n",$1.rational);}
     | ID {$$=id($1);printf("expr->%s\n",$1);}
     ;
%%
void yyerror(const char * s){
  printf("eroare: %s la linia:%d\n",s,yylineno);
  exit(0);
}

nodeType *constant(value_t value,char* type)
{
  nodeType *p;

  // allocate node
  if ((p = malloc(sizeof(constNode))) == NULL)
    yyerror("cannot allocate node");

  // copy info
  p->type = constType;
  p->con.value_type = strdup(type);
  if(strcmp(type,"char")==0 || strcmp(type,"string")==0)
  {
    p->con.value.string_value = strdup(value.content);
  }
  if(strcmp(type,"int")==0)
  {
    p->con.value.i_value = value.int_value;
  }
  if(strcmp(type,"float")==0)
  {
    p->con.value.f_value = value.float_value;
  }
  if(strcmp(type,"bool")==0)
  {
    p->con.value.b_value = value.int_value;
  }

  return p;
}

nodeType *id(char *name)
{
  nodeType *p;

  // allocate node
  if ((p = malloc(sizeof(idNode))) == NULL)
    yyerror("cannot allocate node");

  p->type = idType;
  p->id.name = strdup(name);

  return p;
}

nodeType *dec(char *type,char *name,int constant,int array,struct variables *current_stack)
{
  nodeType *p;

  // allocate node
  if ((p = malloc(sizeof(declarNode))) == NULL)
    yyerror("cannot allocate node");

  p->type = declarType;
  p->dec.name = strdup(name);
  p->dec.pred_type = strdup(type);
  p->dec.constant = constant;
  p->dec.arr_size = array;

  current_stack = (struct variables *) malloc(sizeof(struct variables));

  current_stack->type = strdup(type); 
  current_stack->name = strdup(name);

  if(constant)current_stack->constant=1;
  else current_stack->constant = 0;

  struct variables *global_current_temp;
  global_current_temp = global_head;

  while(global_current_temp->next != NULL){
    global_current_temp = global_current_temp->next;
  }
  
  global_current_temp -> next = current_stack;
  global_current_temp -> next -> next = NULL;
  
  return p;
}

nodeType *opr(int operation,int number, ...)
{
  va_list ap;
  nodeType *p;
  size_t size;
  int i;

  size = sizeof(operationNode) + (number - 1) * sizeof(nodeType*);
  if ((p = malloc(sizeof(constNode))) == NULL)
    yyerror("cannot allocate node");

  // copy info
  p->type = operType;
  p->opr.operation = operation;
  p->opr.operNumber = number;
  va_start(ap,number);

  for(i=0;i<number;i++)
  {
    p->opr.operands[i] = va_arg(ap,nodeType*);
  }
  va_end(ap);
  return p;
}

void freeNode(nodeType *p)
{
  int i;
  if(!p)return;
  if(p->type == operType)
  {
    for(i=0;i<p->opr.operNumber;i++)
    {
      freeNode(p->opr.operands[i]);
    }
  }
  free(p);
}

int main(void)
{
    yyin = fopen("program.txt","r");
    yyparse();
    return 0;
}
