#include "lib.h"

extern int docSimilar(document_t* a, document_t* b, uint8_t* bitmap);

int main(void) {
  // Documento A
  int dataI1 = 10;
  float dataF1 = (float)0.67;
  char* dataS1 = "hola";
  document_t* docuA =
      docNew(3, TypeInt, &(dataI1), TypeString, dataS1, TypeFloat, &(dataF1));

  // Documento B
  int dataI2 = 10;
  float dataF2 = (float)0.69;
  char* dataS2 = "hola";
  document_t* docuB =
      docNew(3, TypeInt, &(dataI2), TypeString, dataS2, TypeFloat, &(dataF2));

  // bitmap
  uint8_t bitmap = 0x01;

  // Ejecutar funcion
  int result = docSimilar(docuA, docuB, &bitmap);

  printf("compare: %i\n", result);

  // Borrar documentos creados
  docDelete(docuA);
  docDelete(docuB);

  return 0;
}
