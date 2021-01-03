#ifndef TREE_H
#define TREE_H

typedef union{
    int i_value;
    int *i_array;
    float f_value;
    float *f_array;
    int b_value;
    char *string_value;
    int initialised;
}valueType;

struct variables
{
  char *type;
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
typedef enum { integer, floating, string, character, boolean} predefined; 


/* constant values */
typedef struct{
    nodeTypes type;
    valueType value;
    char *value_type;
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
    predefined *par_types[1];
    char *par_names[1];
} functionNode;

typedef struct{
    nodeTypes type;
    char *pred_type;
    char *name;
    int constant;
    int arr_size;
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