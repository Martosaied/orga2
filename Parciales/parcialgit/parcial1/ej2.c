#include <stdio.h>
#include <stdlib.h>
#include "lib.h"

extern int treeTrim(tree_t* tree, list_t** key);

treeNode_t* treeNewNode(int key, float data) {
  treeNode_t* nt = malloc(sizeof(treeNode_t));
  funcClone_t* fcKey = getCloneFunction(TypeInt);
  funcClone_t* fcData = getCloneFunction(TypeFloat);
  nt->key = fcKey(&key);
  nt->values = listNew(TypeFloat);
  nt->left = 0;
  nt->right = 0;
  listAdd(nt->values, fcData(&data));
  return nt;
}

int main(void) {
  // Arbol generado manualmente
  treeNode_t* n54 = treeNewNode(54, (float)0.78);
  treeNode_t* n23 = treeNewNode(23, (float)0.73);
  treeNode_t* n87 = treeNewNode(87, (float)0.35);
  treeNode_t* n13 = treeNewNode(13, (float)0.28);
  treeNode_t* n56 = treeNewNode(56, (float)0.13);
  treeNode_t* n55 = treeNewNode(55, (float)0.66);
  treeNode_t* n57 = treeNewNode(57, (float)1.08);
  n54->left = n23;
  n54->right = n87;
  n23->left = n13;
  n23->right = n56;
  n87->left = n55;
  n87->right = n57;
  tree_t* tree = malloc(sizeof(tree_t));
  tree->first = n54;
  tree->size = 7;
  tree->typeKey = TypeInt;
  tree->typeData = TypeFloat;
  tree->duplicate = 0;

  // Donde guardar los resultados
  list_t* key = 0;

  // Ejecutar funcion
  int result = treeTrim(tree, &key);

  printf("trim: %i\n", result);

  // Borrar arboles
  treeDelete(tree);
  if (key != 0)
    listDelete(key);

  return 0;
}
