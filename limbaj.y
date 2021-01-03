%{
#include "calcul.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include "tree.h"
#include "compiler.h"
#include "interpretor.h"

int yylex();

/*
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
*/

nodeType *opr(int operation,int number, ...);
nodeType *id(char *name);
nodeType *constant(valueType value,char *type);
nodeType *func(char *name,char *type,...);
nodeType *dec(char *type,char **names,int constant,int array);

char *temp_ids[100];
int temp_index;

void freeNode(nodeType *p);
%}

%union {
  struct number num;
  int bool_val;
  char *string;
  struct nodeTypeTag *nodePointer;
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
%token <string>NE
%token <string>EQ
%token <string>AND
%token <string>OR
%token <string>ASSIGN
%token <string>FUNCTION
%token <string> CONST
%token <string> NOT
%token <string> RETURN
%token PRINT

%type <nodePointer> expr
%type <nodePointer> assignation
%type <nodePointer> instruction
%type <nodePointer> conditions
%type <nodePointer> while_check
%type <nodePointer> if_check
%type <nodePointer> statements interior_statements statements_list
%type <nodePointer> global function
%type <nodePointer> declaration

%left OR 
%left AND
%left NOT
%left GT GE LT LE EQ NE
%left '+' '-'
%left '*' '/' '%'
%left '(' ')'
%left UMINUS

%nonassoc IFX
%nonassoc ELSE

%%
program : program global {interpret($2,1);free($2);}
        | program function {compile($2,var_stack);interpret($2,0);free($2);}
        | /* empty */
        ;

global :  statements
       ;

statements :declaration ';'  {$$ = $1;}
           | instruction ';'  {$$ = $1;}
           | assignation ';' {$$ = $1;}
           | if_check 
           | while_check
           | PRINT expr ';' {$$ = opr(PRINT,1,$2);}
           | RETURN expr ';'
           ;


interior_statements : interior_statements statements
                    | statements
                    ;

function : TYPE ID '(' parameter_list ')' '{' function_instr '}'
         ;

function_instr : function_instr statements
               | statements
               ;

declaration : TYPE identifier {$$=dec($1,temp_ids,0,0);}
           | CONST TYPE identifier {$$=dec($1,temp_ids,1,0);}
           | CLASS ID '{' class_dec '}'
           | ID ID 
           ;

identifier : /* identifier ',' assignation */ 
             identifier ',' ID {temp_ids[temp_index]= strdup($3);temp_index++;}
            | identifier ',' ARRAY 
            | /* assignation */
            | ID  {temp_ids[temp_index] = strdup($1);temp_index++;}
            | ARRAY
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
            | class_instr PRINT ';'
            | /* empty */

parameter_list : parameter
                | parameter_list ',' parameter
                ;

parameter : TYPE ID 
	    | /* empty */
	    ;

assignation : ID ASSIGN expr {$$ = opr(ASSIGN,2,id($1),$3);}
            | ID ASSIGN CHAR {valueType v;v.string_value = strdup($3);v.value_type=strdup("char");$$ = opr(ASSIGN,2,id($1),constant(v,"char"));}
            | ID ASSIGN TEXT {valueType v;v.string_value = strdup($3);v.value_type=strdup("string");$$ = opr(ASSIGN,2,id($1),constant(v,"string"));}
            ;

instruction : expr {$$=$1;}
             | function_call
             | ID '.' ID
             | ID '.' function_call
             ;

function_call : ID '(' arguments ')'
             ;
             
arguments : arguments ',' expr
          | arguments ',' function_call
          | expr
          | function_call
          | /* empty */
          ;

if_check : IF '(' conditions ')' '{' interior_statements '}'
                                    {$$ = opr(IF,2,$3,$6);}
         | IF '(' conditions ')' '{' interior_statements '}' ELSE '{' interior_statements '}'
                                    {$$ = opr(IF,3,$3,$6,$10);}
         ;

while_check : WHILE '(' conditions ')' '{' interior_statements '}' 
                                    {$$ = opr(WHILE,2,$3,$6);}
            ;

conditions : conditions AND conditions {$$ = opr(AND,2,$1,$3);printf("expr->expr&&expr\n");}
           | conditions OR conditions  {$$ = opr(OR,2,$1,$3);printf("expr->expr||expr\n");}
           | '(' conditions AND conditions ')' {$$ = opr(AND,2,$2,$4);printf("expr->expr&&expr\n");}
           | '(' conditions OR conditions ')'{$$ = opr(OR,2,$2,$4);printf("expr->expr||expr\n");}
           | NOT conditions {$$ = opr(NOT,1,$2);printf("expr->!expr\n");}
           | expr {$$ = $1;}
           ;

expr : ID {$$=id($1);printf("expr->%s\n",$1);}
     | expr '+' expr {$$=opr('+',2,$1,$3); printf("expr->expr+expr\n");}
     | expr '-' expr {$$=opr('-',2,$1,$3); printf("expr->expr-expr\n");}
     | expr '*' expr {$$=opr('*',2,$1,$3); printf("expr->expr*expr\n");}
     | expr '/' expr {$$=opr('/',2,$1,$3); printf("expr->expr/expr\n");}
     | expr '%' expr {$$=opr('%',2,$1,$3); printf("expr->expr%%expr\n");}
     | expr EQ expr {$$=opr(EQ,2,$1,$3); printf("expr->expr==expr\n");}
     | expr NE expr {$$=opr(NE,2,$1,$3); printf("expr->expr!=expr\n");}
     | expr GT expr {$$=opr(GT,2,$1,$3); printf("expr->expr>expr\n");}
     | expr GE expr {$$=opr(GE,2,$1,$3); printf("expr->expr>=expr\n");}
     | expr LT expr {$$=opr(LT,2,$1,$3); printf("expr->expr<expr\n");}
     | expr LE expr {$$=opr(LE,2,$1,$3); printf("expr->expr<=expr\n");}
     | '(' expr ')' {$$ = $2; printf("expr->(expr)\n");}
     | '-' expr {$$=opr(UMINUS,1,$2);printf("expr-> -expr\n");}
     | INT_NUM {valueType v;v.i_value=$1.integer;v.value_type=strdup("int");$$=constant(v,"int"); printf("expr->%d\n",$1.integer);}
     | FLOAT_NUM {valueType v;v.f_value=$1.rational;v.value_type=strdup("float");$$=constant(v,"float");printf("expr->%f\n",$1.rational);}
     ;
%%


nodeType *constant(valueType value,char* type)
{
  nodeType *p;

  // allocate node
  if ((p = malloc(sizeof(constNode))) == NULL)
    yyerror("cannot allocate node");

  // copy info
  p->type = constType;
  p->con.value.value_type= strdup(type);
  if(strcmp(type,"char")==0 || strcmp(type,"string")==0)
  {
    p->con.value.string_value = strdup(value.string_value);
  }
  if(strcmp(type,"int")==0)
  {
    p->con.value.i_value = value.i_value;
  }
  if(strcmp(type,"float")==0)
  {
    p->con.value.f_value = value.f_value;
  }
  if(strcmp(type,"bool")==0)
  {
    p->con.value.b_value = value.i_value;
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

nodeType *dec(char *type,char **name,int constant,int array)
{
  nodeType *p;

  // allocate node
  if ((p = (nodeType*)malloc(sizeof(declarNode))) == NULL)
    yyerror("cannot allocate node");

  p->type = declarType;
  for(int i=0;i<temp_index;i++)
  {
    p->dec.names[i] = strdup(temp_ids[i]);
  }
  p->dec.pred_type = strdup(type);
  p->dec.constant = constant;
  p->dec.arr_size = array;
  p->dec.nr_declared = temp_index;

  temp_index=0;

  return p;
}

nodeType *opr(int operation,int number, ...)
{
  va_list ap;
  nodeType *p;
  size_t size;
  int i;

  size = sizeof(operationNode) + (number ) * sizeof(nodeType*);
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
    // printStack();
    return 0;
}
