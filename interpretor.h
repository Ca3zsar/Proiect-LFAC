#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "tree.h"
#include "y.tab.h"

extern FILE *yyin;
extern char *yytext;
extern int yylineno;

extern void yyerror(const char *s);

// global stack
stackType *global_head = NULL;
stackType *global_last = NULL;

stackType *var_stack = NULL;

stackType *exists_variable(char *name, int is_global)
{

    stackType *temp_stack = (stackType *)malloc(sizeof(stackType));
    if (is_global)
    {
        temp_stack = global_head;
    }
    else
    {
        temp_stack = var_stack;
    }

    while (temp_stack != NULL)
    {
        if (strcmp(name, temp_stack->var.name) == 0)
        {
            return temp_stack;
        }
        temp_stack = temp_stack->next;
    }
    return 0;
}

void declare_variable(declarNode node, int is_global)
{
    int i = 0;

    if (is_global)
    {
        if (global_head == NULL)
        {
            global_head = (stackType *)malloc(sizeof(stackType));
            global_head->next = NULL;
            global_head->var.value.value_type = strdup(node.pred_type);
            global_head->var.name = strdup(node.names[0]);
            if (node.constant)
                global_head->var.constant = 1;
            else
                global_head->var.constant = 0;
            i++;
        }
    }
    else
    {
        if (var_stack == NULL)
        {
            var_stack = (stackType *)malloc(sizeof(stackType));
            var_stack->next = NULL;
            var_stack->var.value.value_type = strdup(node.pred_type);
            var_stack->var.name = strdup(node.names[0]);
            if (node.constant)
                var_stack->var.constant = 1;
            else
                var_stack->var.constant = 0;
            i++;
        }
    }

    stackType *current_stack = (stackType *)malloc(sizeof(stackType));
    if (is_global)
    {
        current_stack = global_head;
    }
    else
    {
        current_stack = var_stack;
    }

    for (; i < node.nr_declared; i++)
    {
        if (exists_variable(node.names[i], is_global))
            yyerror("variable already defined in current scope!");

        stackType *last_stack = (stackType *)malloc(sizeof(stackType));

        last_stack->var.value.value_type = strdup(node.pred_type);
        last_stack->var.name = strdup(node.names[i]);

        if (node.constant)
            last_stack->var.constant = 1;
        else
            last_stack->var.constant = 0;

        last_stack->next = NULL;

        stackType *temp;
        temp = current_stack;
        while (temp->next != NULL)
        {
            temp = temp->next;
        }

        temp->next = last_stack;
        temp->next->next = NULL;
    }
}

void assign_variable(idNode node, valueType val, int is_global)
{

    char *var_name = strdup(node.name);
    stackType *found = (stackType *)malloc(sizeof(stackType));

    stackType *current_stack = (stackType *)malloc(sizeof(stackType));
    if (is_global)
    {
        current_stack = global_head;
    }
    else
    {
        current_stack = var_stack;
    }

    if (!(found = exists_variable(var_name, is_global)))
        yyerror("variable not declared!");



    if (strcmp(val.value_type, found->var.value.value_type))
        yyerror("wrong type used!");

    if (strcmp(val.value_type, "int") == 0)
    {
        found->var.value.i_value = val.i_value;
    }
    if (strcmp(val.value_type, "float") == 0)
    {
        found->var.value.f_value = val.f_value;
    }
    if (strcmp(val.value_type, "bool") == 0)
    {
        found->var.value.b_value = val.b_value;
    }
    if (strcmp(val.value_type, "char") == 0 || strcmp(val.value_type, "string") == 0)
    {
        found->var.value.string_value = strdup(val.string_value);
    }
}

valueType get_value(char *name, int is_global)
{
    int a = 0;
    stackType *found = (stackType *)malloc(sizeof(stackType));

    stackType *current_stack = (stackType *)malloc(sizeof(stackType));
    if (is_global)
    {
        current_stack = global_head;
    }
    else
    {
        current_stack = var_stack;
    }

    if (!(found = exists_variable(name, is_global)))
        yyerror("variable not declared");

    valueType tempVal;

    stackType *tempStack = current_stack;
    if (strcmp(tempStack->var.value.value_type, "float") == 0)
    {
        tempVal.f_value = tempStack->var.value.f_value;
    }
    if (strcmp(tempStack->var.value.value_type, "int") == 0)
    {
        tempVal.i_value = tempStack->var.value.i_value;
    }
    if (strcmp(tempStack->var.value.value_type, "bool") == 0)
    {
        tempVal.b_value = tempStack->var.value.b_value;
    }
    if (strcmp(tempStack->var.value.value_type, "string") == 0 || strcmp(tempStack->var.value.value_type, "char") == 0)
    {
        tempVal.string_value = tempStack->var.value.string_value;
    }
    tempVal.value_type = strdup(tempStack->var.value.value_type);

    return tempVal;
}

void add_to_stack(stackType *next_el, int is_global)
{
    stackType *current_temp = (stackType *)malloc(sizeof(stackType));
    if (is_global)
    {
        current_temp = global_head;
    }
    else
    {
        current_temp = var_stack;
    }

    while (current_temp->next != NULL)
    {
        current_temp = current_temp->next;
    }

    current_temp = (stackType *)malloc(sizeof(stackType));
    current_temp->tip = next_el->tip;
    if (next_el->tip == 0)
    {
        current_temp->scope = strdup(next_el->scope);
    }
    else
    {
        current_temp->var = next_el->var;
    }
}

void print_value(valueType val)
{
    if (strcmp(val.value_type, "int") == 0)
    {
        printf("%d\n", val.i_value);
    }
    if (strcmp(val.value_type, "float") == 0)
    {
        printf("%f\n", val.f_value);
    }
    if (strcmp(val.value_type, "string") == 0 || strcmp(val.value_type, "char") == 0)
    {
        printf("%s\n", val.string_value);
    }
    if (strcmp(val.value_type, "bool") == 0)
    {
        if (val.b_value == 0)
            printf("False\n");
        else
            printf("True");
    }
}

void printStack()
{
    if(global_head!=NULL)
    {
        stackType *temp = (stackType*)malloc(sizeof(stackType));
        temp=global_head;
        while(temp!=NULL)
        {
            printf("%s :: \n",temp->var.name);
            print_value(temp->var.value);
            temp=temp->next;
        }
        printf("-----\n");
    }
}

valueType interpret(nodeType *root, int is_global)
{
    valueType v;
    stackType *last;

    // printStack();

    v.initialised = 0;

    if (!root)
    {
        return v;
    }
    switch (root->type)
    {
    case constType:
        return root->con.value;
    case idType:
        return get_value(root->id.name, is_global);
    case declarType:
        declare_variable(root->dec, is_global);
        return v;
    case operType:
        switch (root->opr.operation)
        {
        case WHILE:
            last = (stackType *)malloc(sizeof(stackType));
            last->scope = strdup("while");
            last->tip = 0;
            add_to_stack(last, is_global);
            while (interpret(root->opr.operands[0], is_global).is_true)
            {
                interpret(root->opr.operands[1], is_global);
            }
            return v;
        case IF:
            last = (stackType *)malloc(sizeof(stackType));
            last->scope = strdup("if");
            last->tip = 0;
            add_to_stack(last, is_global);
            if (interpret(root->opr.operands[0], is_global).is_true)
            {
                interpret(root->opr.operands[1], is_global);
            }
            else if (root->opr.operNumber > 2)
            {
                interpret(root->opr.operands[2], is_global);
            }
            return v;
        case PRINT:
            print_value(interpret(root->opr.operands[0], is_global));
        case ASSIGN:
            assign_variable(root->opr.operands[0]->id,
                            interpret(root->opr.operands[1], is_global), is_global);
        case ';':
            interpret(root->opr.operands[0],is_global);
            return interpret(root->opr.operands[1],is_global);
        case UMINUS: v = interpret(root->opr.operands[0],is_global);
                     if(strcmp(v.value_type,"int") && strcmp(v.value_type,"float"))
                        yyerror("unary minus doesn't work with other types than int or float");
                     else{
                         if(strcmp(v.value_type,"int")==0)
                        {
                            v.i_value = -v.i_value;
                        }else{
                            v.f_value = -v.f_value;
                        }
                        return v;
                     }   
        }
    }
}

void yyerror(const char *s)
{
    printf("eroare: %s la linia:%d\n", s, yylineno);
    exit(0);
}
