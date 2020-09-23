#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>

#include "lib.h"

void test_list(FILE *pfile){
/*     list_t *lista = listNew(TypeFloat);
    float int1 = 1.2f;
    listAdd(lista, &int1);
    listPrint(lista, pfile);
    fprintf(pfile,"\n"); */
    char* str = "";
    strPrint(str, pfile);
    fprintf(pfile,"\n");
}

void test_tree(FILE *pfile){
    tree_t* t;
    int intA;
    float floatA;
    list_t* l;
    fprintf(pfile,"===== Tree\n");
    
    t = treeNew(TypeInt, TypeString, 1);
    intA = 28; treeInsert(t, &intA, "carola"); treeInsert(t, &intA, "ramon");
    intA = 12; treeInsert(t, &intA, "pepe");
    intA = 83; treeInsert(t, &intA, "rara");
    intA = 832; treeInsert(t, &intA, "rara");
    intA = 8323; treeInsert(t, &intA, "rara");
    intA = 43; treeInsert(t, &intA, "rara");
    intA = 3; treeInsert(t, &intA, "rara");
    intA = 4; treeInsert(t, &intA, "rara");
    intA = 23; treeInsert(t, &intA, "rara");
    intA = 1; treeInsert(t, &intA, "rara");
    intA = 32894; treeInsert(t, &intA, "rara");
    intA = 24; treeInsert(t, &intA, "rara");
    intA = 11; treeInsert(t, &intA, "rara");
    intA = 45; treeInsert(t, &intA, "rara");
    intA = 87; treeInsert(t, &intA, "rara");
    treePrint(t, pfile);
    treeDelete(t);
}

void test_document(FILE *pfile){
    
}

int main (void){
    FILE *pfile = fopen("salida.caso.propios.txt","w");
    //test_list(pfile);
    test_tree(pfile);
    //test_document(pfile);
    // float caca = 2.0f;
    // floatPrint(&caca, pfile);
    fclose(pfile);
    return 0;
}


