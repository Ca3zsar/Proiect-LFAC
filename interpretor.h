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

stackType *var_stack = NULL;

stackType* exists_variable(char *name,stackType *current_stack)
{
  stackType *temp_stack = current_stack;
  while(temp_stack!=NULL)
  {
    printf("%s -- %s\n",name,temp_stack->var.name);
    if(strcmp(name,temp_stack->var.name)==0)
    {
      return temp_stack;
    }
    temp_stack = temp_stack->next;
  }
  return 0;
}

void declare_variable(declarNode node,stackType *current_stack)
{
    int i=0;
    if(current_stack == NULL)
    {
        current_stack = (stackType*)malloc(sizeof(stackType));
        current_stack->next = NULL;
        current_stack->var.value.value_type = strdup(node.pred_type);
        current_stack->var.name = strdup(node.names[0]);
        if(node.constant)current_stack->var.constant=1;
        else current_stack->var.constant = 0;
        i++;
    }
    for(;i<node.nr_declared;i++)
    {
        if(exists_variable(node.names[i],current_stack))
            yyerror("variable already defined in current scope!");

        stackType *current_temp = (stackType*)malloc(sizeof(stackType)); 
        current_temp = current_stack;
        while(current_temp->next != NULL){
            current_temp = current_temp->next;
        }

        current_temp = (stackType *) malloc(sizeof(stackType));

        current_temp->var.value.value_type = strdup(node.pred_type); 
        current_temp->var.name = strdup(node.names[i]);

        if(node.constant)current_temp->var.constant=1;
        else current_temp->var.constant = 0;
    
        current_temp -> next = NULL;

    }
    
}

void assign_variable(idNode node, valueType val,stackType *current_stack)
{
    char *var_name = strdup(node.name);
    stackType *found = (stackType*)malloc(sizeof(stackType));

    if(!(found=exists_variable(var_name,current_stack)))
        yyerror("variable not declared!");
    
    if(strcmp(val.value_type,found->var.value.value_type))
        yyerror("wrong type used!");
    
    if(strcmp(val.value_type,"int")==0)
    {
        found->var.value.i_value = val.i_value;
    }
    if(strcmp(val.value_type,"float")==0)
    {
        found->var.value.f_value = val.f_value;
    }
    if(strcmp(val.value_type,"bool")==0)
    {
        found->var.value.b_value = val.b_value;
    }
    if(strcmp(val.value_type,"char")==0 || strcmp(val.value_type,"string")==0)
    {
        found->var.value.string_value = strdup(val.string_value);
    }

}

valueType get_value(char *name,stackType *current_stack){
  int a=0;
  
  stackType *found = (stackType*)malloc(sizeof(stackType));

  if(!(found=exists_variable(name,current_stack)))
    yyerror("variable not declared");

  valueType tempVal;

  stackType *tempStack = current_stack;
  if(strcmp(tempStack->var.value.value_type,"float")==0)
  {
    tempVal.f_value=tempStack->var.value.f_value;
  }
  if(strcmp(tempStack->var.value.value_type,"int")==0)
  {
    tempVal.i_value=tempStack->var.value.i_value;
  }
  if(strcmp(tempStack->var.value.value_type,"bool")==0)
  {
    tempVal.b_value=tempStack->var.value.b_value;
  }
  if(strcmp(tempStack->var.value.value_type,"string")==0 || strcmp(tempStack->var.value.value_type,"char")==0)
  {
    tempVal.string_value=tempStack->var.value.string_value;
  }

  return tempVal;
}

void add_to_stack(stackType *next_el,stackType *current_stack)
{
    stackType *current_temp = current_stack;
    while(current_temp->next != NULL){
        current_temp = current_temp->next;
    }

    current_temp = (stackType *) malloc(sizeof(stackType));
    current_temp->tip = next_el->tip;
    if(next_el->tip==0)
    {
        current_temp->scope = strdup(next_el->scope);
    }else{
        current_temp->var = next_el->var;
    }
}

void print_value(valueType val)
{
    if(strcmp(val.value_type,"int")==0)
    {
        printf("%d\n",val.i_value);
    }
    if(strcmp(val.value_type,"float")==0)
    {
        printf("%f\n",val.f_value);
    }
    if(strcmp(val.value_type,"string")==0 || strcmp(val.value_type,"char")==0 )
    {
        printf("%s\n",val.string_value);
    }
    if(strcmp(val.value_type,"bool")==0)
    {
        if(val.b_value==0)printf("False\n");
        else printf("True");
    }
}


valueType interpret(nodeType *root,stackType *stack){
    valueType v;
    stackType *last;

    v.initialised = 0;

    if(!root) {
        return v;
    }
    switch(root->type)
    {
        case constType : return root->con.value;
        case idType : return get_value(root->id.name,stack);
        case declarType :   declare_variable(root->dec,stack);
                            printf("%s--\n",stack->var.name);
                            return v;
        case operType:
            switch(root->opr.operation){
                case WHILE : last = (stackType*)malloc(sizeof(stackType));
                             last->scope=strdup("while");
                             last->tip=0;
                             add_to_stack(last,stack);
                             while (interpret(root->opr.operands[0],stack).is_true)
                             {
                                interpret(root->opr.operands[1],stack);
                             }
                             return v;
                case IF: last = (stackType*)malloc(sizeof(stackType));
                         last->scope=strdup("if");
                         last->tip=0;
                         add_to_stack(last,stack);
                         if(interpret(root->opr.operands[0],stack).is_true)
                         {
                            interpret(root->opr.operands[1],stack);
                         }else if(root->opr.operNumber > 2)
                         {
                            interpret(root->opr.operands[2],stack);
                         }
                         return v;
                case PRINT: print_value(interpret(root->opr.operands[0],stack));
                case ASSIGN : assign_variable(root->opr.operands[0]->id,
                                        interpret(root->opr.operands[1],stack),stack);
                             
            }
    }
}


void yyerror(const char * s){
  printf("eroare: %s la linia:%d\n",s,yylineno);
  exit(0);
}

