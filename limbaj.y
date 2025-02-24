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
nodeType *constant(valueType value,char *type);
nodeType *dec(char *type,char **names,int constant,int array);
nodeType *function(char *type,char *name,int inClass);

int exists_function(char *return_type,char *name,int inClass);
int search_function(char *name,int inClass);
void create_stack(int f_index);
void assign_class(char *class_n);
void assign_variables(char *class_n);
void freeNode(nodeType *p);

int general_scope=-1;
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
%type <nodePointer> assignement
%type <nodePointer> instruction
%type <nodePointer> conditions
%type <nodePointer> while_check if_check for_check
%type <nodePointer> statements interior_statements function_instr class_instr
%type <nodePointer> global function_call
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
program : program global {interpret($2,general_scope);general_scope=-1;}
        | program dec_function 
        | /* empty */
        ;

global :  statements {$$ = $1;}
       ;

statements :declaration ';'  {$$ = $1;}
           | instruction ';'  {$$ = $1;}
           | assignement ';' {$$ = $1;}
           | if_check {$$ = $1;}
           | while_check {$$ = $1;}
           | for_check {$$ = $1;}
           | PRINT expr ';' {$$ = opr(PRINT,1,$2);}
           | PRINT TEXT ';' {valueType v; v.string_value=strdup($2);$$ = opr(PRINT,1,constant(v,"string"));}
           | PRINT CHAR ';' {valueType v; v.string_value=strdup($2);$$ = opr(PRINT,1,constant(v,"char"));}
           | RETURN expr ';' {$$ = opr(RETURN,1,$2);}
           ;


interior_statements : statements { $$ = $1;}
                    | interior_statements statements {$$ = opr(';',2,$1,$2);}
                    ;

dec_function : TYPE ID '(' parameter_list ')' '{' function_instr '}' {fct_to_run[func_index] = 
                                           opr('f',2,dec_functions[func_index]=function($1,$2,0),$7);func_index++;}
         ;

function_instr : statements {$$ = $1;}
               | function_instr statements {$$ = opr(';',2,$1,$2);}
               ;

declaration : TYPE identifier {$$=dec($1,temp_ids,0,0);}
           | CONST TYPE identifier {$$=dec($2,temp_ids,1,0);}
           | CLASS ID '{' class_dec '}' {assign_class($2);assign_variables($2);class_index++;}
           | ID ID '(' arguments  ')'
           ;

identifier : /* identifier ',' assignement */ 
             identifier ',' ID {temp_ids[temp_index]= strdup($3);temp_arr[temp_index]=0;temp_index++;}
            | identifier ',' ID '[' INT_NUM ']' {temp_ids[temp_index] = strdup($3);temp_arr[temp_index]=$5.integer;temp_index++;}
            | /* assignation */
            | ID  {temp_ids[temp_index] = strdup($1);temp_arr[temp_index]=0;temp_index++;}
            | ID '[' INT_NUM ']' {temp_ids[temp_index] = strdup($1);temp_arr[temp_index]=$3.integer;temp_index++;}
            ;

class_dec : class_declaration ';' class_dec
          | class_declaration ';'
          | class_function  class_dec
          | class_function 
          ;

class_declaration : TYPE identifier {declarations[dec_index]=dec($1,temp_ids,0,0);dec_index++;}
                  | CONST TYPE identifier {declarations[dec_index]=dec($2,temp_ids,1,0);dec_index++;}
                  ;

class_function : TYPE ID '(' parameter_list ')' '{' function_instr '}' {fct_to_run[func_index] = 
                                           opr('f',2,dec_functions[func_index]=function($1,$2,1),$7);func_index++;}
               | ID '(' parameter_list ')' '{' class_instr'}' {fct_to_run[func_index] = 
                                                          opr('f',2,dec_functions[func_index]=function("constructor",$1,1),$6);func_index++;}
               ;

class_instr : class_instr declaration ';' {$$ = opr(';',2,$1,$2);}
            | class_instr instruction ';' {$$ = opr(';',2,$1,$2);}
            | class_instr assignement ';' {$$ = opr(';',2,$1,$2);}
            | class_instr PRINT expr ';' {$$ = opr(';',2,$1,opr(PRINT,1,$3));}
            | class_instr PRINT TEXT ';' {$$ = opr(';',2,$1,opr(PRINT,1,$3));}
            | class_instr PRINT CHAR ';' {$$ = opr(';',2,$1,opr(PRINT,1,$3));}
            | /* empty */ {}

parameter_list : TYPE ID {par_types[par_index]=strdup($1);par[par_index]=strdup($2);par_index++;}
                | parameter_list ',' TYPE ID {par_types[par_index]=strdup($3);par[par_index]=strdup($4);par_index++;}
                | /* empty */
                ;

assignement : ID ASSIGN expr {$$ = opr(ASSIGN,2,id($1),$3);}
            | ID ASSIGN CHAR {valueType v;v.string_value = strdup($3);v.value_type=strdup("char");$$ = opr(ASSIGN,2,id($1),constant(v,"char"));}
            | ID ASSIGN TEXT {valueType v;v.string_value = strdup($3);v.value_type=strdup("string");$$ = opr(ASSIGN,2,id($1),constant(v,"string"));}
            | ID '[' INT_NUM ']' ASSIGN expr
            | ID '[' INT_NUM ']' ASSIGN CHAR
            | ID '[' INT_NUM ']' ASSIGN TEXT
            ;

instruction :  EVAL '(' expr ')' {$$=opr(EVAL,1,$3);}
             | expr {$$ = $1;}
             | ID '.' ID
             | ID '.' ID '(' arguments ')'
             ;

function_call : ID '(' arguments ')' { int a = search_function($1,0);if(a==-1)yyerror("cannot find function with specified signature");
                                      var_stack[a] = NULL; general_scope=a;
                                      create_stack(a); par_index=0;                                      
                                      $$ = fct_to_run[a];
                                      }
             ;
             
arguments : arguments ',' expr {valueType v=interpret($3,general_scope);
                                par_types[par_index] = strdup(v.value_type);
                                temp_var[par_index].value = v; par_index++;
                               }
          | arguments ',' TEXT {  valueType vtemp ; vtemp.string_value = strdup($3); vtemp.value_type=strdup("string");
                                valueType v=interpret(constant(vtemp,"string"),general_scope);
                                par_types[par_index] = strdup(v.value_type);
                                temp_var[par_index].value = v; par_index++;
                              }
          | arguments ',' CHAR {  valueType vtemp ; vtemp.string_value = strdup($3); vtemp.value_type=strdup("char");
                                  valueType v=interpret(constant(vtemp,"char"),general_scope);
                                  par_types[par_index] = strdup(v.value_type);
                                  temp_var[par_index].value = v; par_index++;
                                }

          | CHAR {  valueType vtemp ; vtemp.string_value = strdup($1); vtemp.value_type=strdup("char");
                    valueType v=interpret(constant(vtemp,"char"),general_scope);
                    par_types[par_index] = strdup(v.value_type);
                    temp_var[par_index].value = v; par_index++;
                 }
          | TEXT {  valueType vtemp ; vtemp.string_value = strdup($1); vtemp.value_type=strdup("string");
                    valueType v=interpret(constant(vtemp,"string"),general_scope);
                    par_types[par_index] = strdup(v.value_type);
                    temp_var[par_index].value = v; par_index++;
                 }
          | expr {valueType v=interpret($1,general_scope);
                                par_types[par_index] = strdup(v.value_type);
                                temp_var[par_index].value = v; par_index++;
                               }
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


conditions : conditions AND conditions {$$ = opr(AND,2,$1,$3);}
           | conditions OR conditions  {$$ = opr(OR,2,$1,$3);}
           | '(' conditions AND conditions ')' {$$ = opr(AND,2,$2,$4);}
           | '(' conditions OR conditions ')'{$$ = opr(OR,2,$2,$4);}
           | NOT conditions {$$ = opr(NOT,1,$2);}
           | expr {$$ = $1;}
           ;

expr : ID {$$=id($1);}
     | INT_NUM {valueType v;v.i_value=$1.integer;v.value_type=strdup("int");$$=constant(v,"int");}
     | FLOAT_NUM {valueType v;v.f_value=$1.rational;v.value_type=strdup("float");$$=constant(v,"float");}
     | BOOL_VAL {valueType v;
                if(strcmp($1,"True")==0)
                  v.b_value = 1;
                else v.b_value=0;
                v.value_type=strdup("bool");
                $$=constant(v,"bool");
                }
     | function_call {$$ = $1;}
     | ID '[' INT_NUM ']'
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
    p->con.value.b_value = value.b_value;
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
  if ((p = malloc(sizeof(operationNode) + (number-1)*sizeof(nodeType))) == NULL)
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

nodeType *function(char *type,char *name,int inClass)
{
  nodeType *p;
  size_t size;

  if(exists_function(type,name,inClass))
    yyerror("cannot declare function with identical signature in the same scope");

  size = sizeof(functionNode);
  if((p = malloc(sizeof(size))) == NULL)
    yyerror("cannot allocate node");

  p->type = funcType;
  p->fct.name = strdup(name);
  p->fct.par_number = par_index;
  p->fct.return_type = strdup(type);
  p->fct.class_name = NULL;
  p->fct.in_class = inClass;

  for(int i = 0; i<par_index;i++)
  {
    p->fct.par_names[i]=strdup(par[i]);
    p->fct.par_types[i]=strdup(par_types[i]);
  }

  par_index=0;

  return p;
}

void create_stack(int f_index)
{
  if(par_index)
  {
    int j = 0;

    var_stack[f_index] = (stackType *)malloc(sizeof(stackType));
    var_stack[f_index]->next = NULL;
    var_stack[f_index]->var.value = temp_var[0].value;
    var_stack[f_index]->var.name = strdup(dec_functions[f_index]->fct.par_names[0]);
    var_stack[f_index]->tip = 1;
    var_stack[f_index]->var.initialised = 1;
    var_stack[f_index]->var.constant = 0;
    
    j++;

    for (; j < par_index; j++)
    {
      stackType *last_stack = (stackType *)malloc(sizeof(stackType));

      last_stack->var.value = temp_var[j].value;
      last_stack->var.name = strdup(dec_functions[f_index]->fct.par_names[j]);
      last_stack->var.constant = 0;
      last_stack->next = NULL;
      last_stack->tip = 1;
      last_stack->var.initialised = 1;

      stackType *temp;
      temp = var_stack[f_index];
      while (temp->next != NULL)
      {
          temp = temp->next;
      }

      temp->next = last_stack;
      temp->next->next = NULL;
    }
    

  }
}

int search_function(char *name,int inClass)
{
  for(int i=0;i<func_index;i++)
  {
    if(dec_functions[i]->fct.in_class == inClass)
    {
      if(strcmp(dec_functions[i]->fct.name,name)==0)
      {
        if(dec_functions[i]->fct.par_number == par_index)
        {
          int ok=0;
          for(int j=0;j<par_index;j++)
          {
            if(strcmp(dec_functions[i]->fct.par_types[j],par_types[j]))
              ok = 1;
            
            if(ok)
              break;
          }
          if(!ok)return i;
        }
      }
    }
  }
  return -1;
}

int exists_function(char *return_type,char *name,int inClass)
{
  for(int i=0;i<func_index;i++)
  {
    if(dec_functions[i]->fct.in_class == inClass)
    {
      if(inClass != 0)
      {
        if(dec_functions[i]->fct.class_name == NULL)
        {
          if(strcmp(name,dec_functions[i]->fct.name)==0){
            if(strcmp(return_type,dec_functions[i]->fct.return_type))
              yyerror("cannot declare 2 functions with same name and different return types");

            if(par_index == dec_functions[i]->fct.par_number)
            {
              int ok=0;
              for(int j=0;j<par_index;j++)
              {
                
                if(strcmp(par_types[j],dec_functions[i]->fct.par_types[j]))
                  ok = 1;
                
                if(ok)break;
              }
              if(!ok)
                return 1;
            }
          }

        }
      }else{
        if(strcmp(name,dec_functions[i]->fct.name)==0){
            if(strcmp(return_type,dec_functions[i]->fct.return_type))
              yyerror("cannot declare 2 functions with same name and different return types");

            if(par_index == dec_functions[i]->fct.par_number)
            {
              int ok=0;
              for(int j=0;j<par_index;j++)
              {
                
                if(strcmp(par_types[j],dec_functions[i]->fct.par_types[j]))
                  ok = 1;
                
                if(ok)break;
              }
              if(!ok)
                return 1;
            }
          }
      }
    }
  }
  return 0;
}

void assign_class(char *class_n)
{
  for(int i=0;i<func_index;i++)
  {
    if(dec_functions[i]->fct.in_class)
    {
      if(dec_functions[i]->fct.class_name == NULL)
      {
        if(strcmp(dec_functions[i]->fct.return_type,"constructor")==0)
        {
          if(strcmp(dec_functions[i]->fct.name,class_n))
            yyerror("constructor of class needs to have the same name as class");
        }
        dec_functions[i]->fct.class_name = strdup(class_n);
      }
    }
  }
}

void assign_variables(char *class_n)
{
  int ind=0;
  temp_class[class_index].class_name = strdup(class_n);
  for(int i=0;i<dec_index;i++)
  {
    for(int j=0;j<declarations[i]->dec.nr_declared;j++)
    {
        temp_class[class_index].type[ind] = strdup(declarations[i]->dec.pred_type);
        temp_class[class_index].names[ind] = strdup(declarations[i]->dec.names[j]);
        temp_class[class_index].constant[ind] = declarations[i]->dec.constant;
        ind++;
    }
  }
  temp_class[class_index].nr_var = ind;
}

void freeNode(nodeType *p)
{
  int i;
  if(!p || (p->type == operType && p->opr.operation == 'f'))return;
  if(p->type == operType && p->opr.operation != 'f')
  {
    for(i=0;i<p->opr.operNumber;i++)
    {
      freeNode(p->opr.operands[i]);
    }
  }
  free(p);
}

void create_table()
{
  FILE *symbol = fopen("symbol_table.txt","w");
  // Print the functions.
  fprintf(symbol,":::: FUNCTIONS ::::\n");
  for(int i=0;i<func_index;i++)
    {
      fprintf(symbol,"%s ",dec_functions[i]->fct.return_type);
      fprintf(symbol,"%s ",dec_functions[i]->fct.name);
      
      fprintf(symbol,"( ");
      for(int j=0;j<dec_functions[i]->fct.par_number;j++)
      {
        fprintf(symbol,"%s %s, ",dec_functions[i]->fct.par_types[j],dec_functions[i]->fct.par_names[j]);
      }
      if(dec_functions[i]->fct.par_number)
        fseek(symbol,-2,SEEK_END);
      fprintf(symbol," )");

      if(dec_functions[i]->fct.in_class)
      {
        fprintf(symbol," :: class %s\n",dec_functions[i]->fct.class_name);
      }else{
        fprintf(symbol," :: global\n");
      }
      fprintf(symbol,"----------\n");
    }

  fprintf(symbol,"\n:::: GLOBAL VARIABLES ::::\n");

  stackType *temp = (stackType*)malloc(sizeof(stackType));
  if(global_head!=NULL){
    temp=global_head;
    while(temp!=NULL)
    {
      if(temp->var.constant)
        fprintf(symbol," <global> const %s %s = ",temp->var.value.value_type,temp->var.name);
      else {
        fprintf(symbol," <global> %s %s = ",temp->var.value.value_type,temp->var.name);
      }
      if (strcmp(temp->var.value.value_type, "int") == 0)
      {
          fprintf(symbol,"%d\n", temp->var.value.i_value);
      }
      if (strcmp(temp->var.value.value_type, "float") == 0)
      {
          fprintf(symbol,"%f\n", temp->var.value.f_value);
      }
      if (strcmp(temp->var.value.value_type, "string") == 0 || strcmp(temp->var.value.value_type, "char") == 0)
      {
          fprintf(symbol,"%s\n", temp->var.value.string_value);
      }
      if (strcmp(temp->var.value.value_type, "bool") == 0)
      {
          if (temp->var.value.b_value == 0)
              fprintf(symbol,"False\n");
          else
              fprintf(symbol,"True\n");
      }
      temp=temp->next;
    }
  }else{
    fprintf(symbol,"\tNone\n");
  }
  int i=0;
  for(;i<func_index;i++){
    fprintf(symbol,"\n:::: %s VARIABLES ::::\n",dec_functions[i]->fct.name);
    fprintf(symbol,"function arguments : \n");
    if(dec_functions[i]->fct.par_number)
    {
      for(int j=0;j<dec_functions[i]->fct.par_number;j++)
      {
        fprintf(symbol, "\t%s %s\n",dec_functions[i]->fct.par_types[j],dec_functions[i]->fct.par_names[j]); 
      }
    }else{
      fprintf(symbol,"\tNone\n");
    }
    fprintf(symbol,"function stack :\n");
    stackType *temp;
    temp = var_stack[i];
    while (temp != NULL)
    {
        if(temp->tip){
          if(temp->var.constant)
            fprintf(symbol," <%s> const %s %s = ",dec_functions[i]->fct.name,temp->var.value.value_type,temp->var.name);
          else {
            fprintf(symbol," <%s> %s %s = ",dec_functions[i]->fct.name,temp->var.value.value_type,temp->var.name);
          }
          if (strcmp(temp->var.value.value_type, "int") == 0)
          {
              fprintf(symbol,"%d\n", temp->var.value.i_value);
          }
          if (strcmp(temp->var.value.value_type, "float") == 0)
          {
              fprintf(symbol,"%f\n", temp->var.value.f_value);
          }
          if (strcmp(temp->var.value.value_type, "string") == 0 || strcmp(temp->var.value.value_type, "char") == 0)
          {
              fprintf(symbol,"\"%s\"\n", temp->var.value.string_value);
          }
          if (strcmp(temp->var.value.value_type, "bool") == 0)
          {
          if (temp->var.value.b_value == 0)
              fprintf(symbol,"False\n");
          else
              fprintf(symbol,"True\n");
          }
        }
        temp = temp->next;
    }
    
  }
  i=0;
  for(;i<class_index;i++)
  {
    fprintf(symbol,"\n:::: %s CLASS VARIABLES ::::\n",temp_class[i].class_name);
    for(int j=0;j<temp_class[i].nr_var;j++)
    {
      if(temp_class[i].constant[j])
        fprintf(symbol," <%s> const %s\n",temp_class[i].class_name,temp_class[i].type[j],temp_class[i].names[j]);
      else {
        fprintf(symbol," <%s> %s %s\n",temp_class[i].class_name,temp_class[i].type[j],temp_class[i].names[j]);
      }
    }
  }
}

int main(void)
{
    yyin = fopen("program.txt","r");
    symbol = fopen("symbol_table.txt","w");
    yyparse();
    create_table();
    
    return 0;
}
