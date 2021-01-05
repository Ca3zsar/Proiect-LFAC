#include <stdio.h>
#include "tree.h"
#include "y.tab.h"

FILE *symbol;

static int lbl;

int compile(nodeType *root,int is_global)
{
    int lbl1,lbl2;
    
    if(!root)return 0;
    switch(root->type)
    {
        case constType :
             if (strcmp(root->con.value.value_type, "int") == 0)
            {
                fprintf(symbol,"%d\n", root->con.value.i_value);
            }
            if (strcmp(root->con.value.value_type, "float") == 0)
            {
                fprintf(symbol,"%f\n", root->con.value.f_value);
            }
            if (strcmp(root->con.value.value_type, "string") == 0 || strcmp(root->con.value.value_type, "char") == 0)
            {
                fprintf(symbol,"%s\n", root->con.value.string_value);
            }
            if (strcmp(root->con.value.value_type, "bool") == 0)
            {
                if (root->con.value.b_value == 0)
                    fprintf(symbol,"False\n");
                else
                    fprintf(symbol,"True\n");
            }
            break;
        case idType:
            fprintf(symbol,"\tpush\t%s %s\n",root->id.id_type,root->id.name);
            break;
        case declarType:
            for(int i=0;i<root->dec.nr_declared;i++)
            {
                if(is_global<0)
                {
                    if(is_global==-1)
                        fprintf(symbol, "< global > ");
                    if(is_global==-2)
                        fprintf(symbol, "< while > ");
                    if(is_global==-3)
                        fprintf(symbol, "< if > ");
                    if(is_global==-4)
                        fprintf(symbol,"< for >");
                }else{
                    fprintf(symbol,"< %s >",dec_functions[is_global]->fct.class_name);
                }
                fprintf(symbol,"%s %s\n",root->dec.pred_type,root->dec.names[i]);
            }
        case operType:
            switch(root->opr.operation)
            {
                case WHILE:
                    compile(root->opr.operands[0],is_global);
                    compile(root->opr.operands[1],-2);
                    break;
                case IF:
                    compile(root->opr.operands[0],is_global);
                    if(root->opr.operNumber > 2){
                        //if-else
                        compile(root->opr.operands[1],-3);
                        compile(root->opr.operands[2],-3);
                    }
                    break;
                case ASSIGN:
                    fprintf(symbol,"%s := ",root->opr.operands[0]->id.name);
                    compile(root->opr.operands[1],is_global);
                    break ;
                case ';':
                    compile(root->opr.operands[0],is_global);
                    compile(root->opr.operands[1],is_global);

            }

    }
}