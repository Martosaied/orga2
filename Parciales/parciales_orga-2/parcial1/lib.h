#pragma once

#include <stdint.h>
#include <stdio.h>

typedef enum e_type {
  TypeNone = 0,
  TypeInt = 1,
  TypeFloat = 2,
  TypeString = 3,
  TypeDocument = 4,
} type_t;

typedef int32_t(funcCmp_t)(void*, void*);
typedef void*(funcClone_t)(void*);
typedef void(funcDelete_t)(void*);
typedef void(funcPrint_t)(void*, FILE* pFile);

funcCmp_t* getCompareFunction(type_t t);
funcClone_t* getCloneFunction(type_t t);
funcDelete_t* getDeleteFunction(type_t t);
funcPrint_t* getPrintFunction(type_t t);

/** Int **/

int32_t intCmp(int32_t* a, int32_t* b);
int32_t* intClone(int32_t* a);
void intDelete(int32_t* a);
void intPrint(int32_t* a, FILE* pFile);

/** Float **/

int32_t floatCmp(float* a, float* b);
float* floatClone(float* a);
void floatDelete(float* a);
void floatPrint(float* a, FILE* pFile);

/* String */

uint32_t strLen(char* a);
int32_t strCmp(char* a, char* b);
char* strClone(char* a);
void strDelete(char* a);
void strPrint(char* a, FILE* pFile);

/* Document */

typedef struct s_docElem {
  type_t type;
  void* data;
} docElem_t;

typedef struct s_document {
  int count;
  docElem_t* values;
} document_t;

document_t* docNew(int32_t size, ...);
int32_t docCmp(document_t* a, document_t* b);
document_t* docClone(document_t* a);
void docDelete(document_t* a);
void docPrint(document_t* a, FILE* pFile);

/* List */

typedef struct s_listElem {
  void* data;
  struct s_listElem* next;
  struct s_listElem* prev;
} listElem_t;

typedef struct s_list {
  type_t type;
  uint32_t size;
  listElem_t* first;
  listElem_t* last;
} list_t;

list_t* listNew(type_t t);
void listAdd(list_t* l, void* data);
void listRemove(list_t* l, void* data);
list_t* listClone(list_t* l);
void listDelete(list_t* l);
void listPrint(list_t* l, FILE* pFile);

/* Tree */

typedef struct s_treeNode {
  void* key;
  list_t* values;
  struct s_treeNode* left;
  struct s_treeNode* right;
} treeNode_t;

typedef struct s_tree {
  treeNode_t* first;
  uint32_t size;
  type_t typeKey;
  int duplicate;
  type_t typeData;
} tree_t;

tree_t* treeNew(type_t typeKey, type_t typeData, int duplicate);
int treeInsert(tree_t* tree, void* key, void* data);
list_t* treeGet(tree_t* tree, void* key);
void treeRemove(tree_t* tree, void* key, void* data);
void treeDelete(tree_t* tree);
void treePrint(tree_t* tree, FILE* pFile);
