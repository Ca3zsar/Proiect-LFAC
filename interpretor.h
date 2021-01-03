#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "tree.h"
#include "y.tab.h"

extern FILE* yyin;
extern char* yytext;
extern int yylineno;

extern void yyerror(const char *s);

// global stack
stackType *global_head = NULL;
stackType *global_current;
stackType *global_last = NULL;


int exists_variable(char *name,stackType *current_stack)
{
  stackType *temp_stack = current_stack;
  while(temp_stack!=NULL)
  {
    if(strcmp(name,temp_stack->var.name)==0)
    {
      return 1;
    }
    temp_stack = temp_stack->next;
  }
  return 0;
}

void declare_variable(declarNode *node,stackType *current_stack)
{
    if(exists_variable(node->name,current_stack))
        yyerror("variable already defined in current scope!");
    
    stackType *current_temp = current_stack;
    while(current_temp->next != NULL){
        current_temp = current_temp->next;
    }

    current_temp = (stackType *) malloc(sizeof(stackType));

    current_temp->var.type = strdup(node->pred_type); 
    current_temp->var.name = strdup(node->name);

    if(node->constant)current_temp->var.constant=1;
    else current_temp->var.constant = 0;
  
    current_temp -> next = NULL;
}

valueType get_value(char *name,stackType *current_stack){
  int a=0;
  
  if(!exists_variable(name,current_stack))
    yyerror("variable not declared");

  valueType tempVal;

  stackType *tempStack = current_stack;
  while(tempStack!=NULL)
  {
    if(strcmp(tempStack->var.name,name)==0)
    {
      if(strcmp(tempStack->var.type,"float")==0)
      {
        tempVal.f_value=tempStack->var.value.f_value;
      }
      if(strcmp(tempStack->var.type,"int")==0)
      {
        tempVal.i_value=tempStack->var.value.i_value;
      }
      if(strcmp(tempStack->var.type,"bool")==0)
      {
        tempVal.b_value=tempStack->var.value.b_value;
      }
      if(strcmp(tempStack->var.type,"string")==0 || strcmp(tempStack->var.type,"char")==0)
      {
        tempVal.string_value=tempStack->var.value.string_value;
      }
      
      return tempVal;
    }
    tempStack = tempStack->next;
  }
  yyerror("variabile not declared");

}


valueType interpret(nodeType *root,stackType *stack){
    if(!root) {
        valueType v;
        v.initialised = 0;
        return v;
    }
    switch(root->type)
    {
        case constType : return root->con.value;
        case idType : return get_value(root->id.name,stack);
    }
}


void yyerror(const char * s){
  printf("eroare: %s la linia:%d\n",s,yylineno);
  exit(0);
}

