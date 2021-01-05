#ifndef TREE_H
#define TREE_H

typedef struct{
    int i_value;
    int *i_array;
    float f_value;
    float *f_array;
    int b_value;
    char *string_value;
    int is_true;
    char *value_type;
    int initialised;
}valueType;

struct variables
{
  char *name;
  int constant;
  int initialised;
  valueType value;
};

typedef struct stk{
    int tip;
    char *scope;
    struct variables var;
    struct stk *next;
} stackType;

typedef enum { constType, idType, operType, funcType,declarType} nodeTypes;


/* constant values */
typedef struct{
    nodeTypes type;
    valueType value;
} constNode;

/* identifiers */
typedef struct{
    nodeTypes type;
    char* id_type;
    char* name;
} idNode;

/* operators */
typedef struct{
    nodeTypes type;
    int operation;
    int operNumber;
    struct nodeTypeTag *operands[1]; 
} operationNode;

typedef struct{
    nodeTypes type;
    char *name;
    char *return_type;
    int par_number;
    int in_class;
    char *class_name;
    char *par_types[100];
    char *par_names[100];
} functionNode;

typedef struct{
    nodeTypes type;
    char *pred_type;
    char *names[100];
    int constant;
    int arr_size;
    int nr_declared;
} declarNode;

typedef struct nodeTypeTag {
    nodeTypes type;
    constNode con;
    idNode id;
    operationNode opr;
    declarNode dec;
    functionNode fct;
} nodeType;

#endif