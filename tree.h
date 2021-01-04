#ifndef TREE_H
#define TREE_H

typedef struct{
    int i_value;
    int *i_array;
    float f_value;
    float *f_array;
    int b_value;
    int *b_array;
    char *string_value;
    int is_true;
    char *value_type;
}valueType;

typedef struct{
    char* name;
    int arr_size;
}info;

struct variables
{
  char *name;
  int constant;
  int initialised;
  int array_size;
  valueType value;
};

typedef struct stk{
    int tip;
    char *scope;
    struct variables var;
    struct stk *next;
} stackType;

typedef enum { constType, idType, idArrayType, operType, funcType,declarType} nodeTypes;
typedef enum { integer, floating, string, character, boolean} predefined; 


/* constant values */
typedef struct{
    nodeTypes type;
    valueType value;
} constNode;

/* identifiers */
typedef struct{
    nodeTypes type;
    char* name;
} idNode;

typedef struct{
    nodeTypes type;
    char* name;
    int position;
} idArrayNode;

/* operators */
typedef struct{
    nodeTypes type;
    int operation;
    int operNumber;
    struct nodeTypeTag *operands[1]; 
} operationNode;

/* functions */
typedef struct{
    nodeTypes type;
    char *name;
    char *return_type;
    int par_number;
    predefined *par_types[1];
    char *par_names[1];
} functionNode;

/* declaration */
typedef struct{
    nodeTypes type;
    info inf[100];
    char *pred_type;
    int constant;
    int nr_declared;
} declarNode;

typedef struct nodeTypeTag {
    nodeTypes type;
    constNode con;
    idNode id;
    idArrayNode idArr;
    operationNode opr;
    declarNode dec;
    functionNode fct;
} nodeType;

#endif