#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#include "../tp2.h"
#include "../helper/utils.h"

void ColorBordes_c(
    uint8_t *src,
    uint8_t *dst,
    int width,
    int height,
    int src_row_size,
    int dst_row_size)
{
    bgra_t (*src_matrix)[(src_row_size+3)/4] = (bgra_t (*)[(src_row_size+3)/4]) src;
    bgra_t (*dst_matrix)[(dst_row_size+3)/4] = (bgra_t (*)[(dst_row_size+3)/4]) dst;


    for (int i = 1; i < height-1; i++) {
        for (int j = 1; j < width-1; j++) {

            int r=0;
            int g=0;
            int b=0;

	        for (int ii = i-1; ii <= i+1; ii++) {
                r += abs( src_matrix[ii][j-1].r - src_matrix[ii][j+1].r );
                g += abs( src_matrix[ii][j-1].g - src_matrix[ii][j+1].g );
                b += abs( src_matrix[ii][j-1].b - src_matrix[ii][j+1].b );
            }

	        for (int jj = j-1; jj <= j+1; jj++) {
                r += abs( src_matrix[i-1][jj].r - src_matrix[i+1][jj].r );
                g += abs( src_matrix[i-1][jj].g - src_matrix[i+1][jj].g );
                b += abs( src_matrix[i-1][jj].b - src_matrix[i+1][jj].b );
            }

	        dst_matrix[i][j].r = SAT(r);
	        dst_matrix[i][j].g = SAT(g);
	        dst_matrix[i][j].b = SAT(b);

        }
    }
    utils_paintBorders32(dst, width, height, src_row_size, 1, 0xFFFFFFFF);
}
