#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#include "../tp2.h"
#include "../helper/utils.h"

void PixeladoDiferencial_c(
    uint8_t *src,
    uint8_t *dst,
    int width,
    int height,
    int src_row_size,
    int dst_row_size,
    int limit)
{
    bgra_t (*src_matrix)[(src_row_size+3)/4] = (bgra_t (*)[(src_row_size+3)/4]) src;
    bgra_t (*dst_matrix)[(dst_row_size+3)/4] = (bgra_t (*)[(dst_row_size+3)/4]) dst;

    for (int i = 0; i <= height-4; i=i+4) {
        for (int j = 0; j <= width-4; j=j+4) {

            int r = 0;
            int g = 0;
            int b = 0;

            // (1) Promedio de pixeles
	        for (int ii = i; ii < i+4; ii++) {
	            for (int jj = j; jj < j+4; jj++) {
	                r = r + src_matrix[ii][jj].r;
	                g = g + src_matrix[ii][jj].g;
	                b = b + src_matrix[ii][jj].b;
	            }
            }
            b = SAT(b/16);
            g = SAT(g/16);
            r = SAT(r/16);

            // (2) Calculo de diferencia
            int value = 0;
            for (int ii = i; ii < i+4; ii++) {
	            for (int jj = j; jj < j+4; jj++) {
                    value += abs(r - src_matrix[ii][jj].r) +
                             abs(g - src_matrix[ii][jj].g) +
	                         abs(b - src_matrix[ii][jj].b);
	            }
            }

            // (3) Aplicacion segun umbral
            if ( value < limit ) {
                for (int ii = i; ii < i+4; ii++) {
                    for (int jj = j; jj < j+4; jj++) {
                        dst_matrix[ii][jj].b = src_matrix[ii][jj].b;
                        dst_matrix[ii][jj].g = src_matrix[ii][jj].g;
                        dst_matrix[ii][jj].r = src_matrix[ii][jj].r;
                    }
                }
            } else {
                for (int ii = i; ii < i+4; ii++) {
                    for (int jj = j; jj < j+4; jj++) {
                        dst_matrix[ii][jj].b = b;
                        dst_matrix[ii][jj].g = g;
                        dst_matrix[ii][jj].r = r;
                    }
                }
            }
        }
    }
}
