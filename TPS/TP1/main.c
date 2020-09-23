#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>

#include "lib.h"

char* strings[10] = {
    "Mirame mama, alto tp de orga",
    "Te extraño pabellon 1",
    "AGUANTE EL 42",
    "1 + 1 = 3",
    "re dificil pensar 10 strings",
    "pero me rehuso a usar un for",
    "aguante boca",
    "moriste en madrid",
    "patricio damian bruno",
    "martin yoel saied"
};

float floats[5] = {
    3.14f,
    2.71f,
    1.42f,
    2.1f,
    1782391837.1323123f
};

void test_list(FILE *pfile){
    list_t* l1 = listNew(TypeString);
    for(int i=0; i<10;i++)
        listAdd(l1, strClone(strings[i]));

    list_t* l2 = listNew(TypeFloat);
    for(int i=0; i<10;i++)
        listAdd(l2, floatClone(&floats[i]));

    list_t* l1_cloned = listClone(l1);
    list_t* l2_cloned = listClone(l2);

    listPrint(l1_cloned, pfile);
    fprintf(pfile,"\n");
    listPrint(l2_cloned, pfile);
    fprintf(pfile,"\n");
    listDelete(l1);
    listDelete(l2);
    listDelete(l1_cloned);
    listDelete(l2_cloned);
}

void test_tree(FILE *pfile){
    tree_t* t = treeNew(TypeInt, TypeString, 1);
    int key1 = 24;
    int key2 = 34;
    int key3 = 24;
    int key4 = 11;
    int key5 = 31;
    int key6 = 11;
    int key7 = -2;
    treeInsert(t, &key1, "papanatas");
    treeInsert(t, &key2, "rima");
    treeInsert(t, &key3, "buscabullas");
    treeInsert(t, &key4, "musica");
    treeInsert(t, &key5, "Pikachu");
    treeInsert(t, &key6, "Bulbasaur");
    treeInsert(t, &key7, "Charmander");
    tree_t* t2 = treeNew(TypeInt, TypeString, 1);
    treeInsert(t, &key7, "Charmander");
    treeInsert(t, &key6, "Bulbasaur");
    treeInsert(t, &key5, "Pikachu");
    treeInsert(t, &key4, "musica");
    treeInsert(t, &key3, "buscabullas");
    treeInsert(t, &key2, "rima");
    treeInsert(t, &key1, "papanatas");

    treePrint(t, pfile);
    fprintf(pfile,"\n");
    treePrint(t2, pfile);
    fprintf(pfile,"\n");
    treeDelete(t);
    treeDelete(t2);

}

void test_document(FILE *pfile){
    int int1 = 12;
    int int2 = 14;
    float float1 = 3.14f;
    float float2 = 2.78f;
    char* string1 = "para cuando a vacuna, bill?";
    char* string2 = "nas ganas de salir a chupar picaportes";
    document_t* d = docNew(6,   TypeInt, &int1, TypeInt, &int2,
                                TypeFloat, &float1, TypeFloat, &float2,
                                TypeString, string1, TypeString, string2);
    document_t* d_cloned = docClone(d);

    docPrint(d, pfile);
    fprintf(pfile,"\n");
    docPrint(d_cloned, pfile);
    fprintf(pfile,"\n");
    docDelete(d);
    docDelete(d_cloned);
}

int main (void){
    FILE *pfile = fopen("salida.caso.propios.txt","w");
    test_list(pfile);
    test_tree(pfile);
    test_document(pfile);
    fclose(pfile);
    return 0;
}


