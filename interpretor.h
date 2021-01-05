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
        if (temp_stack->tip == 1 && strcmp(name, temp_stack->var.name) == 0)
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
            global_head->tip = 1;
            global_head->var.initialised = 0;
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
            var_stack->tip = 1;
            var_stack->var.initialised = 0;
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
        last_stack->tip = 1;
        last_stack->var.initialised = 0;

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

    if (found->var.constant == 1)
        yyerror("cannot modify const");

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
    found->var.initialised = 1;
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

    if(found->var.initialised==0)
        yyerror("variable not initialised");

    valueType tempVal;

    if (strcmp(found->var.value.value_type, "float") == 0)
    {
        tempVal.f_value = found->var.value.f_value;
    }
    if (strcmp(found->var.value.value_type, "int") == 0)
    {
        tempVal.i_value = found->var.value.i_value;
    }
    if (strcmp(found->var.value.value_type, "bool") == 0)
    {
        tempVal.b_value = found->var.value.b_value;
    }
    if (strcmp(found->var.value.value_type, "string") == 0 || strcmp(found->var.value.value_type, "char") == 0)
    {
        tempVal.string_value = found->var.value.string_value;
    }
    tempVal.value_type = strdup(found->var.value.value_type);

    return tempVal;
}

stackType *add_to_stack(stackType *next_el, int is_global)
{
    stackType *current_stack = (stackType *)malloc(sizeof(stackType));

    if (is_global)
    {
        if (global_head == NULL)
        {
            global_head = (stackType *)malloc(sizeof(stackType));
            global_head->next = NULL;
            global_head->tip = 0;
            return 0;
        }
    }
    else
    {
        if (var_stack == NULL)
        {
            var_stack = (stackType *)malloc(sizeof(stackType));
            var_stack->next = NULL;
            var_stack->tip = 0;
            return 0;
        }
    }

    if (is_global)
    {
        current_stack = global_head;
    }
    else
    {
        current_stack = var_stack;
    }

    stackType *temp = (stackType *)malloc(sizeof(stackType));
    temp = current_stack;
    while (temp->next != NULL)
    {
        temp = temp->next;
    }

    temp->next = next_el;
    temp->next->next = NULL;

    return temp;
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
            printf("True\n");
    }
}

void printStack()
{
    if (global_head != NULL)
    {
        stackType *temp = (stackType *)malloc(sizeof(stackType));
        temp = global_head;
        while (temp != NULL)
        {
            if(temp->tip==1){
                printf("%s :: ", temp->var.name);
                print_value(temp->var.value);
            }
            else{
                printf("%s :: scope\n",temp->scope);
            }
            temp = temp->next;
        }
        printf("-----\n");
    }
}

valueType interpret(nodeType *root, int is_global)
{
    valueType v, v2, vcompare;
    stackType *last, *ante_last;

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
        case 'f':
            last = (stackType *)malloc(sizeof(stackType));
            ante_last = (stackType *)malloc(sizeof(stackType));
            last->scope = strdup(root->opr.operands[0]->fct.name);
            last->tip = 0;
            ante_last = add_to_stack(last, is_global);

            interpret(root->opr.operands[1],is_global);

            if (ante_last == NULL){
                if(is_global){
                    global_head = NULL;
                }else{
                    var_stack = NULL;
                }
            }
            else
            {
                ante_last->next = NULL;
            }
        case WHILE:
            while (interpret(root->opr.operands[0], is_global).is_true)
            {
                last = (stackType *)malloc(sizeof(stackType));
                ante_last = (stackType *)malloc(sizeof(stackType));

                last->scope = strdup("while");
                last->tip = 0;
                ante_last = add_to_stack(last, is_global);

                interpret(root->opr.operands[1], is_global);

                if (ante_last == NULL){
                    if(is_global){
                        global_head = NULL;
                    }else{
                        var_stack = NULL;
                    }
                }
                else
                {
                    ante_last->next = NULL;
                }
            }
            return v;
        case IF:
            last = (stackType *)malloc(sizeof(stackType));
            ante_last = (stackType *)malloc(sizeof(stackType));

            last->scope = strdup("if");
            last->tip = 0;
            ante_last = add_to_stack(last, is_global);
            if (interpret(root->opr.operands[0], is_global).is_true)
            {
                interpret(root->opr.operands[1], is_global);
            }
            else if (root->opr.operNumber > 2)
            {
                interpret(root->opr.operands[2], is_global);
            }
            if (ante_last == NULL){
                if(is_global){
                    global_head = NULL;
                }else{
                    var_stack = NULL;
                }
            }
            else
            {
                ante_last->next = NULL;
            }
        return v;
        case FOR:

            if(root->opr.operands[0]->type != constType || root->opr.operands[1]->type != constType)
                yyerror("only constant values in -for- syntax");
            if(strcmp(root->opr.operands[0]->con.value.value_type,"int") ||
              strcmp(root->opr.operands[1]->con.value.value_type,"int"))
                yyerror("only int const in -for- syntax");

            int start = root->opr.operands[0]->con.value.i_value;
            int final = root->opr.operands[1]->con.value.i_value;          

            while(start<=final)
            {
                last = (stackType *)malloc(sizeof(stackType));
                ante_last = (stackType *)malloc(sizeof(stackType));

                last->scope = strdup("while");
                last->tip = 0;
                ante_last = add_to_stack(last, is_global);

                interpret(root->opr.operands[2], is_global);

                if (ante_last == NULL){
                    if(is_global){
                        global_head = NULL;
                    }else{
                        var_stack = NULL;
                    }
                }
                else
                {
                    ante_last->next = NULL;
                }

                start++;
            }
            return v;
        case EVAL:
            v = interpret(root->opr.operands[0],is_global);

            if(strcmp(v.value_type,"int"))
                yyerror("Eval function only take int expressions!");

            print_value(v);
            return v;
        case PRINT:
            print_value(interpret(root->opr.operands[0], is_global));
            return v;
        case ASSIGN:
            assign_variable(root->opr.operands[0]->id,
                            interpret(root->opr.operands[1], is_global), is_global);
        case ';':
            interpret(root->opr.operands[0], is_global);
            return interpret(root->opr.operands[1], is_global);
        case '+':
            v = interpret(root->opr.operands[0], is_global);
            v2 = interpret(root->opr.operands[1], is_global);

            if (strcmp(v.value_type, v2.value_type) || strcmp(v.value_type, "char") == 0)
                yyerror("incompatibles types for addition");

            if (strcmp(v.value_type, "int") == 0)
            {
                v.value_type = strdup("int");
                v.i_value += v2.i_value;
            }
            if (strcmp(v.value_type, "float") == 0)
            {
                v.value_type = strdup("float");
                v.f_value += v2.f_value;
            }
            if (strcmp(v.value_type, "bool") == 0)
            {
                v.value_type = strdup("bool");
                v.b_value = v.b_value || v2.b_value;
            }
            if (strcmp(v.value_type, "string") == 0)
            {
                v.value_type = strdup("string");
                char *temp = strdup(v.string_value);
                v.string_value = (char *)calloc(strlen(temp) + strlen(v2.string_value), sizeof(char));
                strcat(v.string_value, temp);
                strcat(v.string_value, v2.string_value);
            }
            return v;
        case '-':
            if (root->opr.operNumber == 2)
            {
                v = interpret(root->opr.operands[0], is_global);
                v2 = interpret(root->opr.operands[1], is_global);

                if (strcmp(v.value_type, v2.value_type) || strcmp(v.value_type, "char") == 0 || strcmp(v.value_type, "string") == 0)
                    yyerror("incompatibles types for substraction");

                if (strcmp(v.value_type, "int") == 0)
                {
                    v.value_type = strdup("int");
                    v.i_value -= v2.i_value;
                }
                if (strcmp(v.value_type, "float") == 0)
                {
                    v.value_type = strdup("float");
                    v.f_value -= v2.f_value;
                }
                if (strcmp(v.value_type, "bool") == 0)
                {
                    v.value_type = strdup("bool");
                    v.b_value = v.b_value ^ v2.b_value;
                }

                return v;
            }
            else
            {
                v = interpret(root->opr.operands[0], is_global);

                if (strcmp(v.value_type, "int") && strcmp(v.value_type, "float"))
                    yyerror("unary minus doesn't work with other types than int or float");
                else
                {
                    if (strcmp(v.value_type, "int") == 0)
                    {
                        v.value_type = strdup("int");
                        v.i_value = -v.i_value;
                    }
                    else
                    {
                        v.value_type = strdup("float");
                        v.f_value = -v.f_value;
                    }
                    return v;
                }
            }

        case '*':
            v = interpret(root->opr.operands[0], is_global);
            v2 = interpret(root->opr.operands[1], is_global);

            if(strcmp(v.value_type,"string")==0 && strcmp(v2.value_type,"int")==0)
            {
                v.value_type = strdup("string");
                char *temp = strdup(v.string_value);
                v.string_value = (char*)calloc(strlen(temp)*v2.i_value,sizeof(char));
                for(int i=0;i<v2.i_value;i++)
                {
                    strcat(v.string_value,temp);
                }
                return v;
            }

            if (strcmp(v.value_type, v2.value_type) || strcmp(v.value_type, "char") == 0 || strcmp(v.value_type, "string") == 0)
                yyerror("incompatibles types for multipication");

            if (strcmp(v.value_type, "int") == 0)
            {
                v.value_type = strdup("int");
                v.i_value *= v2.i_value;
            }
            if (strcmp(v.value_type, "float") == 0)
            {
                v.value_type = strdup("float");
                v.f_value *= v2.f_value;
            }
            

            return v;
        case '/':
            v = interpret(root->opr.operands[0], is_global);
            v2 = interpret(root->opr.operands[1], is_global);

            if (strcmp(v.value_type, v2.value_type) || strcmp(v.value_type, "char") == 0 || strcmp(v.value_type, "string") == 0)
                yyerror("incompatibles types for division");

            if (strcmp(v.value_type, "int") == 0)
            {
                if (v2.i_value == 0)
                    yyerror("division by 0 not permitted!");
                v.value_type = strdup("int");
                v.i_value /= v2.i_value;
            }
            if (strcmp(v.value_type, "float") == 0)
            {
                if (v2.f_value == 0.0)
                    yyerror("division by 0 not permitted!");
                v.value_type = strdup("float");
                v.f_value /= v2.f_value;
            }
            return v;
        case '%':
            v = interpret(root->opr.operands[0], is_global);
            v2 = interpret(root->opr.operands[1], is_global);

            if (strcmp(v.value_type, "int") || strcmp(v.value_type, "int"))
                yyerror("only integers can be used for modulo!");

            if (strcmp(v.value_type, "int") == 0)
            {
                v.value_type = strdup("int");
                v.i_value %= v2.i_value;
            }

            return v;
        case GE:
            v = interpret(root->opr.operands[0], is_global);
            v2 = interpret(root->opr.operands[1], is_global);

            if (strcmp(v.value_type, v2.value_type))
                yyerror("can't compare different types!");

            if (strcmp(v.value_type, "int") == 0)
            {
                if (v.i_value >= v2.i_value)
                {
                    vcompare.is_true = 1;
                }
                else
                    vcompare.is_true = 0;
            }
            if (strcmp(v.value_type, "float") == 0)
            {
                if (v.f_value >= v2.f_value)
                {
                    vcompare.is_true = 1;
                }
                else
                    vcompare.is_true = 0;
            }
            if (strcmp(v.value_type, "bool") == 0)
            {
                if (v.b_value >= v2.b_value)
                {
                    vcompare.is_true = 1;
                }
                else
                    vcompare.is_true = 0;
            }
            if (strcmp(v.value_type, "char") == 0 || strcmp(v.value_type, "string") == 0)
            {
                if (strcmp(v.string_value, v2.string_value) >= 0)
                {
                    vcompare.is_true = 1;
                }
                else
                    vcompare.is_true = 0;
            }
            return vcompare;
        case GT:
            v = interpret(root->opr.operands[0], is_global);
            v2 = interpret(root->opr.operands[1], is_global);

            if (strcmp(v.value_type, v2.value_type))
                yyerror("can't compare different types!");

            if (strcmp(v.value_type, "int") == 0)
            {
                if (v.i_value > v2.i_value)
                {
                    vcompare.is_true = 1;
                }
                else
                    vcompare.is_true = 0;
            }
            if (strcmp(v.value_type, "float") == 0)
            {
                if (v.f_value > v2.f_value)
                {
                    vcompare.is_true = 1;
                }
                else
                    vcompare.is_true = 0;
            }
            if (strcmp(v.value_type, "bool") == 0)
            {
                if (v.b_value > v2.b_value)
                {
                    vcompare.is_true = 1;
                }
                else
                    vcompare.is_true = 0;
            }
            if (strcmp(v.value_type, "char") == 0 || strcmp(v.value_type, "string") == 0)
            {
                if (strcmp(v.string_value, v2.string_value) > 0)
                {
                    vcompare.is_true = 1;
                }
                else
                    vcompare.is_true = 0;
            }
            return vcompare;
        case LE:
            v = interpret(root->opr.operands[0], is_global);
            v2 = interpret(root->opr.operands[1], is_global);

            if (strcmp(v.value_type, v2.value_type))
                yyerror("can't compare different types!");

            if (strcmp(v.value_type, "int") == 0)
            {
                if (v.i_value <= v2.i_value)
                {
                    vcompare.is_true = 1;
                }
                else
                    vcompare.is_true = 0;
            }
            if (strcmp(v.value_type, "float") == 0)
            {
                if (v.f_value <= v2.f_value)
                {
                    vcompare.is_true = 1;
                }
                else
                    vcompare.is_true = 0;
            }
            if (strcmp(v.value_type, "bool") == 0)
            {
                if (v.b_value <= v2.b_value)
                {
                    vcompare.is_true = 1;
                }
                else
                    vcompare.is_true = 0;
            }
            if (strcmp(v.value_type, "char") == 0 || strcmp(v.value_type, "string") == 0)
            {
                if (strcmp(v.string_value, v2.string_value) <= 0)
                {
                    vcompare.is_true = 1;
                }
                else
                    vcompare.is_true = 0;
            }
            return vcompare;
        case LT:
            v = interpret(root->opr.operands[0], is_global);
            v2 = interpret(root->opr.operands[1], is_global);

            if (strcmp(v.value_type, v2.value_type))
                yyerror("can't compare different types!");

            if (strcmp(v.value_type, "int") == 0)
            {
                if (v.i_value < v2.i_value)
                {
                    vcompare.is_true = 1;
                }
                else
                    vcompare.is_true = 0;
            }
            if (strcmp(v.value_type, "float") == 0)
            {
                if (v.f_value < v2.f_value)
                {
                    vcompare.is_true = 1;
                }
                else
                    vcompare.is_true = 0;
            }
            if (strcmp(v.value_type, "bool") == 0)
            {
                if (v.b_value < v2.b_value)
                {
                    vcompare.is_true = 1;
                }
                else
                    vcompare.is_true = 0;
            }
            if (strcmp(v.value_type, "char") == 0 || strcmp(v.value_type, "string") == 0)
            {
                if (strcmp(v.string_value, v2.string_value) < 0)
                {
                    vcompare.is_true = 1;
                }
                else
                    vcompare.is_true = 0;
            }
            return vcompare;
        case EQ:
            v = interpret(root->opr.operands[0], is_global);
            v2 = interpret(root->opr.operands[1], is_global);

            if (strcmp(v.value_type, v2.value_type))
                yyerror("can't compare different types!");

            if (strcmp(v.value_type, "int") == 0)
            {
                if (v.i_value == v2.i_value)
                {
                    vcompare.is_true = 1;
                }
                else
                    vcompare.is_true = 0;
            }
            if (strcmp(v.value_type, "float") == 0)
            {
                if (v.f_value == v2.f_value)
                {
                    vcompare.is_true = 1;
                }
                else
                    vcompare.is_true = 0;
            }
            if (strcmp(v.value_type, "bool") == 0)
            {
                if (v.b_value == v2.b_value)
                {
                    vcompare.is_true = 1;
                }
                else
                    vcompare.is_true = 0;
            }
            if (strcmp(v.value_type, "char") == 0 || strcmp(v.value_type, "string") == 0)
            {
                if (strcmp(v.string_value, v2.string_value) == 0)
                {
                    vcompare.is_true = 1;
                }
                else
                    vcompare.is_true = 0;
            }
            return vcompare;
        case NE:
            v = interpret(root->opr.operands[0], is_global);
            v2 = interpret(root->opr.operands[1], is_global);

            if (strcmp(v.value_type, v2.value_type))
                yyerror("can't compare different types!");

            if (strcmp(v.value_type, "int") == 0)
            {
                if (v.i_value != v2.i_value)
                {
                    vcompare.is_true = 1;
                }
                else
                    vcompare.is_true = 0;
            }
            if (strcmp(v.value_type, "float") == 0)
            {
                if (v.f_value != v2.f_value)
                {
                    vcompare.is_true = 1;
                }
                else
                    vcompare.is_true = 0;
            }
            if (strcmp(v.value_type, "bool") == 0)
            {
                if (v.b_value != v2.b_value)
                {
                    vcompare.is_true = 1;
                }
                else
                    vcompare.is_true = 0;
            }
            if (strcmp(v.value_type, "char") == 0 || strcmp(v.value_type, "string") == 0)
            {
                if (strcmp(v.string_value, v2.string_value) != 0)
                {
                    vcompare.is_true = 1;
                }
                else
                    vcompare.is_true = 0;
            }
            return vcompare;
        case AND:
            v = interpret(root->opr.operands[0], is_global);
            v2 = interpret(root->opr.operands[1], is_global);

            vcompare.is_true = v.is_true && v2.is_true;
            return vcompare;
        case OR:
            v = interpret(root->opr.operands[0], is_global);
            v2 = interpret(root->opr.operands[1], is_global);

            vcompare.is_true = v.is_true || v2.is_true;
            return vcompare;
        case NOT:
            v = interpret(root->opr.operands[0], is_global);

            vcompare.is_true = 1 - v.is_true;
            return vcompare;
        }
    }
}

void yyerror(const char *s)
{
    printf("ERROR AT LINE %d : %s \n", yylineno,s);
    exit(0);
}
