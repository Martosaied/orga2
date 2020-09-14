/* 

Ejercicio 3
void gris(pixel* matriz, short n, uint8_t* resultado)

Dada una matriz de nˆn pixeles RGB (1 byte por componente), hacer una funcion que convierta los
pixeles a escala de grises usando la formula (R + 2 * G + B) / 4 

*/

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

void gris_ASM(uint8_t* imgRGB, short n, uint16_t* imgGray);

void gris_C(uint8_t* imgRGB, short n, uint16_t* imgGray) {
    uint16_t colorGray;
    uint8_t colorR, colorG, colorB;
    int nColor;
    int imgSize = n*n;

    for (int nPixel = 0; nPixel < imgSize; nPixel++) {
        nColor = 3 * nPixel;

        colorR = imgRGB[nColor + 0];
        colorG = imgRGB[nColor + 1];
        colorB = imgRGB[nColor + 2];

        colorGray = (colorR + 2*colorG + colorB) / 4;

		imgGray[nPixel] = colorGray;
    }
}

int main(void) {
	uint8_t imgRGB[2*2*3] = {0, 0, 0, 1, 1, 1, 51, 50, 53, 255, 255, 255};
	uint16_t imgGray_C[2*2*1];
	uint16_t imgGray_ASM[2*2*1];

	printf("Yo : %d, %d, %d, %d\r\n", 0, 1, 51, 255);

	gris_C(imgRGB, 2, imgGray_C);
	printf("C  : %d, %d, %d, %d\r\n", imgGray_C[0], imgGray_C[1], imgGray_C[2], imgGray_C[3]);

	gris_ASM(imgRGB, 2, imgGray_ASM);
	printf("ASM: %d, %d, %d, %d\r\n", imgGray_ASM[0], imgGray_ASM[1], imgGray_ASM[2], imgGray_ASM[3]);

	return EXIT_SUCCESS;
}

	