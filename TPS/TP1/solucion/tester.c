#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>
#include <stdbool.h>

#include "lib.h"

#define RUN(filename, action) pfile=fopen(filename,"a"); action; fclose(pfile);
#define NL(filename) pfile=fopen(filename,"a"); fprintf(pfile,"\n"); fclose(pfile);

char *filename_1 =  "salida.caso.1.txt";
char *filename_2 =  "salida.caso.2.txt";
void test_1(char* filename);
void test_2(char* filename);

int main() {
    srand(12345);
    remove(filename_1);
    test_1(filename_1);
    remove(filename_2);
    test_2(filename_2);
    return 0;
}

char* randomString(uint32_t l) {
    // 32 a 126 = caracteres validos
    char* s = malloc(l+1);
    for(uint32_t i=0; i<(l+1); i++)
       s[i] = (char)(33+(rand()%(126-33)));
    s[l] = 0;
    return s;
}

char* randomHexString(uint32_t l) {
    char* s = malloc(l+1);
    for(uint32_t i=0; i<(l+1); i++) {
        do {
            s[i] = (char)(rand()%256);
        } while (s[i]==0);
    }
    s[l] = 0;
    return s;
}

char* strings[10] = {"aa","bb","dd","ff","00","zz","cc","ee","gg","hh"};

/** Strings **/
void test_strings(FILE *pfile) {
    fprintf(pfile,"===== String\n");
    char *a, *b, *c;
    // clone
    fprintf(pfile,"==> Clone\n");
    a = strClone("casa");
    b = strClone("");
    strPrint(a,pfile);
    fprintf(pfile,"\n");
    strPrint(b,pfile);
    fprintf(pfile,"\n");
    strDelete(a);
    strDelete(b);
    // cmp
    fprintf(pfile,"==> Cmp\n");
    char* texts[5] = {"sar","23","taaa","tbb","tix"};
    for(int i=0; i<5; i++) {
        for(int j=0; j<5; j++) {
            fprintf(pfile,"cmp(%s,%s) -> %i\n",texts[i],texts[j],strCmp(texts[i],texts[j]));
        }
    }
}

/** List **/
void test_list(FILE *pfile) {
    fprintf(pfile,"===== List\n");
    char *a, *b, *c;
    list_t* l1;
    // listAdd
    fprintf(pfile,"==> listAdd\n");
    l1 = listNew(TypeString);
    for(int i=0; i<5;i++)
        listAdd(l1,strClone(strings[i]));
    listPrint(l1,pfile); fprintf(pfile,"\n");
    listDelete(l1);
    l1 = listNew(TypeString);
    for(int i=0; i<5;i++)
        listAdd(l1,strClone(strings[i]));
    listPrint(l1,pfile); fprintf(pfile,"\n");
    listDelete(l1);
    // listRemove
    fprintf(pfile,"==> listRemove\n");
    l1 = listNew(TypeString);
    listRemove(l1, strings[0]);
    for(int i=0; i<5;i++) {
        listAdd(l1,strClone(strings[i]));
        listRemove(l1, strings[0]);
    }
    listRemove(l1, strings[1]);
    listRemove(l1, strings[2]);
    listRemove(l1, "PRIMERO");
    listRemove(l1, "ULTIMO");
    listPrint(l1,pfile); fprintf(pfile,"\n");
    listDelete(l1);
}

/** Document **/
void test_document(FILE *pfile) {
    fprintf(pfile,"===== Document\n");
    int dataI = 4;
    int dataF = 0.43;
    document_t* a1 = docNew(3,TypeInt,&(dataI),TypeString,"hola",TypeFloat,&(dataF));
    docPrint(a1, pfile); fprintf(pfile,"\n");
    dataI = 81;
    dataF = 3.772;
    document_t* a2 = docNew(3,TypeInt,&(dataI),TypeString,"Perro",TypeFloat,&(dataF));
    docPrint(a2, pfile); fprintf(pfile,"\n");
    fprintf(pfile,"cmp %i\n",docCmp(a1, a2));
    fprintf(pfile,"cmp %i\n",docCmp(a2, a1));
    fprintf(pfile,"cmp %i\n",docCmp(a1, a1));
    fprintf(pfile,"cmp %i\n",docCmp(a2, a2));
    document_t* copia_a1 = docClone(a1);
    docPrint(copia_a1, pfile); fprintf(pfile,"\n");
    document_t* copia_a2 = docClone(a2);
    docPrint(copia_a2, pfile); fprintf(pfile,"\n");
    docDelete(copia_a1);
    docDelete(copia_a2);
    docDelete(a1);
    docDelete(a2);
}

/** Tree **/
void test_tree(FILE *pfile) {
    tree_t* t;
    int intA;
    float floatA;
    list_t* l;
    fprintf(pfile,"===== Tree\n");
    
    t = treeNew(TypeInt, TypeString, 1);
    treePrint(t, pfile); fprintf(pfile,"\n");
    treeDelete(t);

    t = treeNew(TypeInt, TypeString, 1);
    intA = 28; treeInsert(t, &intA, "carola"); treeInsert(t, &intA, "ramon");
    intA = 12; treeInsert(t, &intA, "pepe");
    intA = 83; treeInsert(t, &intA, "rara");
    treePrint(t, pfile); fprintf(pfile,"\n");
    treeDelete(t);

    t = treeNew(TypeInt, TypeString, 1);
    intA = 28; treeInsert(t, &intA, "carola"); treeInsert(t, &intA, "ramon");
    intA = 12; treeInsert(t, &intA, "pepe");
    intA = 83; treeInsert(t, &intA, "rara");
    intA = 10; treeRemove(t, &intA, "pepe");
    treePrint(t, pfile); fprintf(pfile,"\n");
    intA = 12; treeRemove(t, &intA, "pepe");
    treePrint(t, pfile); fprintf(pfile,"\n");
    intA = 83; treeRemove(t, &intA, "rara");
    treePrint(t, pfile); fprintf(pfile,"\n");
    intA = 28; treeRemove(t, &intA, "carola"); treeRemove(t, &intA, "ramon");
    intA = 99; treeRemove(t, &intA, "pepe");
    treeDelete(t);

    t = treeNew(TypeInt, TypeString, 1);
    intA = 12; treeInsert(t, &intA, "pepe");
    intA = 28; treeInsert(t, &intA, "carola"); treeInsert(t, &intA, "ramon");
    intA = 83; treeInsert(t, &intA, "rara"); treeInsert(t, &intA, "ramon");
    intA = 12; treeRemove(t, &intA, "pepe");
    treePrint(t, pfile); fprintf(pfile,"\n");
    intA = 12; l = treeGet(t, &intA);
    listPrint(l, pfile); fprintf(pfile,"\n");
    listDelete(l);
    intA = 28; l = treeGet(t, &intA);
    listPrint(l, pfile); fprintf(pfile,"\n");
    listDelete(l);
    intA = 83; l = treeGet(t, &intA);
    listPrint(l, pfile); fprintf(pfile,"\n");
    listDelete(l);
    treeDelete(t);

    t = treeNew(TypeInt, TypeString, 0);
    intA = 12; treeInsert(t, &intA, "pepe");
    intA = 28; treeInsert(t, &intA, "carola"); treeInsert(t, &intA, "ramon");
    intA = 83; treeInsert(t, &intA, "rara"); treeInsert(t, &intA, "ramon");
    intA = 12; treeRemove(t, &intA, "pepe");
    treePrint(t, pfile); fprintf(pfile,"\n");
    intA = 12; l = treeGet(t, &intA);
    listPrint(l, pfile); fprintf(pfile,"\n");
    listDelete(l);
    intA = 28; l = treeGet(t, &intA);
    listPrint(l, pfile); fprintf(pfile,"\n");
    listDelete(l);
    intA = 83; l = treeGet(t, &intA);
    listPrint(l, pfile); fprintf(pfile,"\n");
    listDelete(l);
    treeDelete(t);

    t = treeNew(TypeInt, TypeFloat, 1);
    intA = 12; floatA=6.2; treeInsert(t, &intA, &floatA);
    intA = 28; floatA=4.4; treeInsert(t, &intA, &floatA); floatA=1.4; treeInsert(t, &intA, &floatA);
    intA = 83; floatA=1.2; treeInsert(t, &intA, &floatA); floatA=5.4; treeInsert(t, &intA, &floatA);
    intA = 12; treeRemove(t, &intA, &floatA);
    treePrint(t, pfile); fprintf(pfile,"\n");
    intA = 12; l = treeGet(t, &intA);
    listPrint(l, pfile); fprintf(pfile,"\n");
    listDelete(l);
    intA = 28; l = treeGet(t, &intA);
    listPrint(l, pfile); fprintf(pfile,"\n");
    listDelete(l);
    intA = 83; l = treeGet(t, &intA);
    listPrint(l, pfile); fprintf(pfile,"\n");
    listDelete(l);
    treeDelete(t);

    t = treeNew(TypeInt, TypeFloat, 0);
    intA = 12; floatA=6.2; treeInsert(t, &intA, &floatA);
    intA = 28; floatA=4.4; treeInsert(t, &intA, &floatA); floatA=1.4; treeInsert(t, &intA, &floatA);
    intA = 83; floatA=1.2; treeInsert(t, &intA, &floatA); floatA=5.4; treeInsert(t, &intA, &floatA);
    intA = 12; treeRemove(t, &intA, &floatA);
    treePrint(t, pfile); fprintf(pfile,"\n");
    intA = 12; l = treeGet(t, &intA);
    listPrint(l, pfile); fprintf(pfile,"\n");
    listDelete(l);
    intA = 28; l = treeGet(t, &intA);
    listPrint(l, pfile); fprintf(pfile,"\n");
    listDelete(l);
    intA = 83; l = treeGet(t, &intA);
    listPrint(l, pfile); fprintf(pfile,"\n");
    listDelete(l);
    treeDelete(t);
}

void test_1(char* filename){
    FILE *pfile;
    RUN(filename,test_strings(pfile););
    RUN(filename,test_document(pfile););
    RUN(filename,test_list(pfile););
    RUN(filename,test_tree(pfile););
}

document_t* randomDocument() {
    int dataI = rand()%1000;
    float dataF = ((float)(rand()%10000))/1000.0;
    char* dataS = randomString(10);
    document_t* d = docNew(3,TypeInt,&(dataI),TypeString,dataS,TypeFloat,&(dataF));
    strDelete(dataS);
    return d;
}

void test_2(char* filename){
    FILE *pfile;
    char* k;
    document_t* v;

    tree_t* t = treeNew(TypeString, TypeDocument, 1);
    for(int i=0; i<100; i++) {
        for(int i=0; i<10; i++) {
            k = randomString(3);
            v = randomDocument();
            RUN(filename,strPrint(k,pfile); fprintf(pfile,"\n"););
            RUN(filename,docPrint(v,pfile); fprintf(pfile,"\n"););
            treeInsert(t, k, v);
            strDelete(k);
            docDelete(v);
        }
        RUN(filename,treePrint(t,pfile); fprintf(pfile,"\n"););
    }
    treeDelete(t);

    t = treeNew(TypeInt, TypeDocument, 0);
    for(int i=0; i<100; i++) {
        for(int i=0; i<10; i++) {
            int ki = rand()%100;
            v = randomDocument();
            RUN(filename,intPrint(&ki,pfile); fprintf(pfile,"\n"););
            RUN(filename,docPrint(v,pfile); fprintf(pfile,"\n"););
            treeInsert(t, &ki, v);
            docDelete(v);
        }
        RUN(filename,treePrint(t,pfile); fprintf(pfile,"\n"););
    }
    treeDelete(t);
}
