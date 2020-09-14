#include "lib.h"

int dummy(){ return 0; }

funcCmp_t* getCompareFunction(type_t t) {
    switch (t) {
        case TypeNone:     return (funcCmp_t*)&dummy; break;
        case TypeInt:      return (funcCmp_t*)&intCmp; break;
        case TypeFloat:    return (funcCmp_t*)&floatCmp; break;
        case TypeString:   return (funcCmp_t*)&strCmp; break;
        case TypeDocument: return (funcCmp_t*)&docCmp; break;
        default: break;
    }
    return 0;
}

funcClone_t* getCloneFunction(type_t t) {
    switch (t) {
        case TypeNone:     return (funcClone_t*)&dummy; break;
        case TypeInt:      return (funcClone_t*)&intClone; break;
        case TypeFloat:    return (funcClone_t*)&floatClone; break;
        case TypeString:   return (funcClone_t*)&strClone; break;
        case TypeDocument: return (funcClone_t*)&docClone; break;
        default: break;
    }
    return 0;
}

funcDelete_t* getDeleteFunction(type_t t) {
    switch (t) {
        case TypeNone:     return (funcDelete_t*)&dummy; break;
        case TypeInt:      return (funcDelete_t*)&intDelete; break;
        case TypeFloat:    return (funcDelete_t*)&floatDelete; break;
        case TypeString:   return (funcDelete_t*)&strDelete; break;
        case TypeDocument: return (funcDelete_t*)&docDelete; break;
        default: break;
    }
    return 0;
}

funcPrint_t* getPrintFunction(type_t t) {
    switch (t) {
        case TypeNone:     return (funcPrint_t*)&dummy; break;
        case TypeInt:      return (funcPrint_t*)&intPrint; break;
        case TypeFloat:    return (funcPrint_t*)&floatPrint; break;
        case TypeString:   return (funcPrint_t*)&strPrint; break;
        case TypeDocument: return (funcPrint_t*)&docPrint; break;
        default: break;
    }
    return 0;
}

/** Int **/

int32_t intCmp(int32_t* a, int32_t* b){
    if(*a < *b) return 1;
    if(*a > *b) return -1;
    return 0;
}
int32_t* intClone(int32_t* a){
    int32_t* n = (int32_t*)malloc(sizeof(int32_t));
    *n = *a;
    return n;
}
void intDelete(int32_t* a){
    free(a);
}
void intPrint(int32_t* a, FILE *pFile){
    fprintf(pFile, "%i", *a);
}

/** Document **/

document_t* docNew(int32_t size, ... ){
    va_list valist;
    va_start(valist, size);
    document_t* n = (document_t*)malloc(sizeof(document_t));
    docElem_t* e = (docElem_t*)malloc(sizeof(docElem_t)*size);
    n->count = size;
    n->values = e;
    for(int i=0; i < size; i++) {
        type_t type = va_arg(valist, type_t);
        void* data = va_arg(valist, void*);
        funcClone_t* fc = getCloneFunction(type);
        e[i].type = type;
        e[i].data = fc(data);
    }
    va_end(valist);
    return n;
}
int32_t docCmp(document_t* a, document_t* b){
    // Sort by size
    if(a->count < b->count) return 1;
    if(a->count > b->count) return -1;
    // Sort by type
    for(int i=0; i < a->count; i++) {
        if(a->values[i].type < b->values[i].type) return 1;
        if(a->values[i].type > b->values[i].type) return -1;
    }
    // Sort by data
    for(int i=0; i < a->count; i++) {
        funcCmp_t* fc = getCompareFunction(a->values[i].type);
        int cmp = fc(a->values[i].data, b->values[i].data);
        if(cmp != 0) return cmp;
    }
    // Are equal
    return 0;
}
void docPrint(document_t* a, FILE *pFile){
    fprintf(pFile, "{");
    for(int i=0; i < a->count-1 ; i++ ) {
        funcPrint_t* fp = getPrintFunction(a->values[i].type);
        fp(a->values[i].data, pFile);
        fprintf(pFile, ", ");
    }
    funcPrint_t* fp = getPrintFunction(a->values[a->count-1].type);
    fp(a->values[a->count-1].data, pFile);
    fprintf(pFile, "}");
}

/** Lista **/

list_t* listNew(type_t t){
    list_t* l = malloc(sizeof(list_t));
    l->type = t;
    l->first = 0;
    l->last = 0;
    l->size = 0;
    return l;
}
void listAddLast(list_t* l, void* data){
    listElem_t* n = malloc(sizeof(listElem_t));
    l->size = l->size + 1;
    n->data = data;
    n->next = 0;
    n->prev = l->last;
    if(l->last == 0)
        l->first = n;
    else
        l->last->next = n;
    l->last = n;
}
void listRemove(list_t* l, void* data){
}
list_t* listClone(list_t* l) {
    funcClone_t* fn = getCloneFunction(l->type);
    list_t* lclone = listNew(l->type);
    listElem_t* current = l->first;
    while(current!=0) {
        void* dclone = fn(current->data);
        listAddLast(lclone, dclone);
        current = current->next;
    }
    return lclone;
}
void listDelete(list_t* l){
    funcDelete_t* fd = getDeleteFunction(l->type);
    listElem_t* current = l->first;
    while(current!=0) {
        listElem_t* tmp = current;
        current =  current->next;
        if(fd!=0) fd(tmp->data);
        free(tmp);
    }
    free(l);
}
void listPrint(list_t* l, FILE *pFile) {
    funcPrint_t* fp = getPrintFunction(l->type);
    fprintf(pFile, "[");
    listElem_t* current = l->first;
    if(current==0) {
        fprintf(pFile, "]");
        return;
    }
    while(current!=0) {
        if(fp!=0)
            fp(current->data, pFile);
        else
            fprintf(pFile, "%p",current->data);
        current = current->next;
        if(current==0)
            fprintf(pFile, "]");
        else
            fprintf(pFile, ",");
    }
}
/** Tree **/

tree_t* treeNew(type_t typeKey, type_t typeData, int duplicate) {
    tree_t* t = malloc(sizeof(tree_t));
    t->first = 0;
    t->size = 0;
    t->typeKey = typeKey;
    t->typeData = typeData;
    t->duplicate = duplicate;
    return t;
}
list_t* treeGet(tree_t* tree, void* key) {
    return 0;
}
void treeRemove(tree_t* tree, void* key, void* data) {
}
void treeDeleteAux(tree_t* tree, treeNode_t** node) {
    treeNode_t* nt = *node;
    if( nt != 0 ) {
        funcDelete_t* fdKey = getDeleteFunction(tree->typeKey);
        treeDeleteAux(tree, &(nt->left));
        treeDeleteAux(tree, &(nt->right));
        listDelete(nt->values);
        fdKey(nt->key);
        free(nt);
    }
}
void treeDelete(tree_t* tree) {
    treeDeleteAux(tree, &(tree->first));
    free(tree);
}
