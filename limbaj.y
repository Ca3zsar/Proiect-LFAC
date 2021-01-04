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

nodeType *opr(int operation,int number, ...);
nodeType *id(char *name);
nodeType *idArray(char *name,int position);
nodeType *constant(valueType value,char *type);
nodeType *func(char *name,char *type,...);
nodeType *dec(char *type,char **names,int constant);

char *temp_ids[100];
int temp_arr[100];
int temp_index;

void freeNode(nodeType *p);
%}

%union {
  struct number num;
  char *string;
  struct nodeTypeTag *nodePointer;
};

%start program
%token <string>ID
%token <string>TYPE
%token <string>CHAR 
%token <string>TEXT
%token <string>CLASS
%token <num>INT_NUM
%token <num> FLOAT_NUM
%token <string>BOOL_VAL
%token <string>IF
%token <string>ELSE
%token <string>FOR
%token <string>WHILE
%token <string>GT GE LT LE NE EQ
%token <string>AND
%token <string>OR
%token <string>ASSIGN
%token <string>FUNCTION
%token <string> CONST
%token <string> NOT
%token <string> RETURN
%token <string> EVAL
%token PRINT

%type <nodePointer> expr
%type <nodePointer> assignation
%type <nodePointer> instruction
%type <nodePointer> conditions
%type <nodePointer> while_check if_check for_check
%type <nodePointer> statements interior_statements
%type <nodePointer> global function
%type <nodePointer> declaration

%left OR 
%left AND
%left NOT
%left GT GE LT LE EQ NE
%left '+' '-'
%left '*' '/' '%'
%left '(' ')'

%nonassoc IFX
%nonassoc ELSE

%%
program : program global {nodeType* temp = (nodeType*)malloc(sizeof(nodeType));temp = $2;
                          interpret($2,1);free($2);}
        | program function {compile($2,var_stack);interpret($2,0);free($2);}
        | /* empty */
        ;

global :  statements {$$ = $1;}
       ;

statements :declaration ';'  {$$ = $1;}
           | instruction ';'  {$$ = $1;}
           | assignation ';' {$$ = $1;}
           | if_check {$$ = $1;}
           | while_check {$$ = $1;}
           | for_check {$$ = $1;}
           | PRINT expr ';' {$$ = opr(PRINT,1,$2);}
           | PRINT TEXT ';' {valueType v; v.string_value=strdup($2);$$ = opr(PRINT,1,constant(v,"string"));}
           | PRINT CHAR ';' {valueType v; v.string_value=strdup($2);$$ = opr(PRINT,1,constant(v,"char"));}
           | RETURN expr ';'
           ;


interior_statements : statements { $$ = $1;}
                    | interior_statements statements {$$ = opr(';',2,$1,$2);}
                    ;

function : TYPE ID '(' parameter_list ')' '{' function_instr '}'
         ;

function_instr : function_instr statements
               | statements
               ;

declaration : TYPE identifier {$$=dec($1,temp_ids,0);}
           | CONST TYPE identifier {$$=dec($2,temp_ids,1);}
           | CLASS ID '{' class_dec '}'
           | ID ID 
           ;

identifier :  identifier ',' ID {temp_ids[temp_index]= strdup($3);temp_arr[temp_index]=-1;temp_index++;}
            | identifier ',' ID '[' INT_NUM ']' {temp_ids[temp_index] = strdup($3);if($5.integer <=0)yyerror("size of array must be positive!");
                                                temp_arr[temp_index]=$5.integer;temp_index++;}
            | ID  {temp_ids[temp_index] = strdup($1);temp_arr[temp_index]=-1;temp_index++;}
            | ID '[' INT_NUM ']' {temp_ids[temp_index] = strdup($1);if($3.integer <=0)yyerror("size of array must be positive!");
                                  temp_arr[temp_index]=$3.integer;temp_index++;}
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
            | ID '[' INT_NUM ']' ASSIGN expr {$$ = opr(ASSIGN,2,idArray($1,$3.integer),$6);}
            | ID '[' INT_NUM ']' ASSIGN CHAR {valueType v;v.string_value = strdup($6);v.value_type=strdup("char");$$ = opr(ASSIGN,2,idArray($1,$3.integer),constant(v,"char"));}
            | ID '[' INT_NUM ']' ASSIGN TEXT {valueType v;v.string_value = strdup($6);v.value_type=strdup("string");$$ = opr(ASSIGN,2,idArray($1,$3.integer),constant(v,"string"));}
            
            ;

instruction :  function_call
             | EVAL '(' expr ')' {$$=opr(EVAL,1,$3);}
             | expr {$$ = $1;}
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

for_check : FOR '(' expr ':' expr ')' '{' interior_statements '}'
                                    {$$ = opr(FOR,3,$3,$5,$8);}


conditions : conditions AND conditions {$$ = opr(AND,2,$1,$3);printf("expr->expr&&expr\n");}
           | conditions OR conditions  {$$ = opr(OR,2,$1,$3);printf("expr->expr||expr\n");}
           | '(' conditions AND conditions ')' {$$ = opr(AND,2,$2,$4);printf("expr->expr&&expr\n");}
           | '(' conditions OR conditions ')'{$$ = opr(OR,2,$2,$4);printf("expr->expr||expr\n");}
           | NOT conditions {$$ = opr(NOT,1,$2);printf("expr->!expr\n");}
           | expr {$$ = $1;}
           ;

expr : ID {$$=id($1);}
     | ID '[' INT_NUM ']' {$$ = idArray($1,$3.integer);}
     | INT_NUM {valueType v;v.i_value=$1.integer;v.value_type=strdup("int");$$=constant(v,"int");}
     | FLOAT_NUM {valueType v;v.f_value=$1.rational;v.value_type=strdup("float");$$=constant(v,"float");}
     | BOOL_VAL {valueType v;
                if(strcmp($1,"True")==0)
                  v.b_value = 1;
                else v.b_value=0;
                v.value_type=strdup("bool");
                $$=constant(v,"bool");
                }
     
     | expr '+' expr {$$=opr('+',2,$1,$3);}
     | expr '-' expr {$$=opr('-',2,$1,$3);}
     | expr '*' expr {$$=opr('*',2,$1,$3);}
     | expr '/' expr {$$=opr('/',2,$1,$3);}
     | expr '%' expr {$$=opr('%',2,$1,$3);}
     | '(' expr ')' {$$ = $2;}
     | '-' expr{$$=opr('-',1,$2);}
     | expr EQ expr {$$=opr(EQ,2,$1,$3);} 
     | expr NE expr {$$=opr(NE,2,$1,$3);}
     | expr GT expr {$$=opr(GT,2,$1,$3);}
     | expr GE expr {$$=opr(GE,2,$1,$3);}
     | expr LT expr {$$=opr(LT,2,$1,$3);}
     | expr LE expr {$$=opr(LE,2,$1,$3);}
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

nodeType *idArray(char *name,int position)
{
  nodeType *p;
  //alocate node
  if ((p = malloc(sizeof(idArrayNode))) == NULL)
    yyerror("cannot allocate node");

  p->type = idArrayType;
  p->idArr.name = strdup(name);
  p->idArr.position = position;

  return p;
}

nodeType *dec(char *type,char **name,int constant)
{
  nodeType *p;

  // allocate node
  if ((p = (nodeType*)malloc(sizeof(declarNode))) == NULL)
    yyerror("cannot allocate node");

  p->type = declarType;
  p->dec.arr_size = (int*)calloc(temp_index,sizeof(int));
  for(int i=0;i<temp_index;i++)
  {
    p->dec.names[i] = strdup(temp_ids[i]);
    p->dec.arr_size[i] = temp_arr[i];
  }
  p->dec.pred_type = strdup(type);
  p->dec.constant = constant;
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
    p->opr.operands[i] = malloc(sizeof(nodeType));
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
