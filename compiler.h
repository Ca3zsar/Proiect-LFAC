#include <stdio.h>
#include "tree.h"
#include "y.tab.h"

FILE *symbol;

static int lbl;

int compile(nodeType *root,struct variables stack)
{
    int lbl1,lbl2;
    symbol = fopen("symbol_table.txt","w");

    if(!root)return 0;
    switch(root->type)
    {
        case constType :
            fprintf(symbol,"\tpush\t%d\n",root->con.value);
            break;
        case idType:
            fprintf(symbol,"\tpush\t%s\n",root->id.name);
            break;
        case operType:
            switch(root->opr.operation)
            {
                case WHILE:
                    fprintf(symbol,"L%03d:\n",lbl1=lbl++);
                    compile(root->opr.operands[0],stack);
                    fprintf(symbol,"\tjz\tL%03d\n",lbl2=lbl++);
                    compile(root->opr.operands[1],stack);
                    fprintf(symbol,"\tjmp\tL%03d\n",lbl1);
                    fprintf(symbol,"\tL%03d:\n",lbl2);
                    break;
                case IF:
                    compile(root->opr.operands[0],stack);
                    if(root->opr.operNumber > 2){
                        //if-else
                        fprintf(symbol,"\tjz\tL%03d\n",lbl1=lbl++);
                        compile(root->opr.operands[1],stack);
                        fprintf(symbol,"\tjmp\tL%03d\n",lbl2=lbl++);
                        fprintf(symbol,"L%03d:\n",lbl1);
                        compile(root->opr.operands[2],stack);
                    }  
            }

    }
}