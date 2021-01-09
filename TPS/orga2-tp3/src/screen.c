/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Definicion de funciones del scheduler
*/

#include "screen.h"
#include "i386.h"



char* clock = "|/-\\";
void screen_incTasksClocks() {
    int8_t index = ultimo_fue_rick ? idx_rick : idx_morty;
    uint8_t y = ultimo_fue_rick ? 43 : 46;
    char char_clock = clock[current->isrNumber % 4];

    uint8_t x = 0;
    if (index == 0) {
        x = ultimo_fue_rick ? 14 + 4 : 21 + 40;
        y = 43;
    } else {
        x = 17 + index * 4;
    }

    print_char(char_clock, x, y, C_FG_WHITE | C_BG_BLACK);
    current->isrNumber++;
}

void screen_drawTasks() {
    for(int i = 1; i < 11; i++) {
        print_dec(i, 2, 17 + i * 4, 42, C_FG_LIGHT_RED | C_BG_BLACK);
        print("x", 17 + i * 4, 43, C_FG_WHITE | C_BG_BLACK);
    }

    for(int i = 1; i < 11; i++) {
        print_dec(i, 2, 17 + i * 4, 45, C_FG_LIGHT_BLUE | C_BG_BLACK);
        print("x", 17 + i * 4, 46, C_FG_WHITE | C_BG_BLACK);
    }

    print("R", 14 + 4, 42, C_FG_LIGHT_RED | C_BG_BLACK);
    print("M", 21 + 40, 42, C_FG_LIGHT_BLUE | C_BG_BLACK);
}

void print(const char *text, uint32_t x, uint32_t y, uint16_t attr)
{
  ca(*p)[VIDEO_COLS] = (ca(*)[VIDEO_COLS])VIDEO; // magia
  int32_t i;
  for (i = 0; text[i] != 0; i++)
  {
    p[y][x].c = (uint8_t)text[i];
    p[y][x].a = (uint8_t)attr;
    x++;
    if (x == VIDEO_COLS)
    {
      x = 0;
      y++;
    }
  }
}

void print_char(const char text, uint32_t x, uint32_t y, uint16_t attr)
{
  ca(*p)[VIDEO_COLS] = (ca(*)[VIDEO_COLS])VIDEO; // magia
  p[y][x].c = (uint8_t)text;
  p[y][x].a = (uint8_t)attr;
}

void print_dec(uint32_t numero, uint32_t size, uint32_t x, uint32_t y,
               uint16_t attr)
{
  ca(*p)[VIDEO_COLS] = (ca(*)[VIDEO_COLS])VIDEO; // magia
  uint32_t i;
  uint8_t letras[16] = "0123456789";

  for (i = 0; i < size; i++)
  {
    uint32_t resto = numero % 10;
    numero = numero / 10;
    p[y][x + size - i - 1].c = letras[resto];
    p[y][x + size - i - 1].a = attr;
  }
}

void print_hex(uint32_t numero, int32_t size, uint32_t x, uint32_t y,
               uint16_t attr)
{
  ca(*p)[VIDEO_COLS] = (ca(*)[VIDEO_COLS])VIDEO; // magia
  int32_t i;
  uint8_t hexa[8];
  uint8_t letras[16] = "0123456789ABCDEF";
  hexa[0] = letras[(numero & 0x0000000F) >> 0];
  hexa[1] = letras[(numero & 0x000000F0) >> 4];
  hexa[2] = letras[(numero & 0x00000F00) >> 8];
  hexa[3] = letras[(numero & 0x0000F000) >> 12];
  hexa[4] = letras[(numero & 0x000F0000) >> 16];
  hexa[5] = letras[(numero & 0x00F00000) >> 20];
  hexa[6] = letras[(numero & 0x0F000000) >> 24];
  hexa[7] = letras[(numero & 0xF0000000) >> 28];
  for (i = 0; i < size; i++)
  {
    p[y][x + size - i - 1].c = hexa[i];
    p[y][x + size - i - 1].a = attr;
  }
}

void screen_draw_box(uint32_t fInit, uint32_t cInit, uint32_t fSize,
                     uint32_t cSize, uint8_t character, uint8_t attr)
{
  ca(*p)[VIDEO_COLS] = (ca(*)[VIDEO_COLS])VIDEO;
  uint32_t f;
  uint32_t c;
  for (f = fInit; f < fInit + fSize; f++)
  {
    for (c = cInit; c < cInit + cSize; c++)
    {
      p[f][c].c = character;
      p[f][c].a = attr;
    }
  }
}

void screen_init()
{
  ca(*p)[VIDEO_COLS] = (ca(*)[VIDEO_COLS])VIDEO;
  for (int f = 0; f < VIDEO_FILS - 10; f++) {
    for (int c = 0; c < VIDEO_COLS; c++) {
      p[f][c].c = 0;
      p[f][c].a = C_BG_GREEN;
    }
  }
  screen_draw_box(43, 7, 3, 9, 0, C_BG_RED);
  screen_draw_box(43, 64, 3, 9, 0, C_BG_BLUE);
  screen_drawTasks();
}

ca (*pantalla_vieja)[VIDEO_COLS * VIDEO_FILS] = {0};

uint8_t fue_copiada = 0;

void copiar_pantalla()
{
  fue_copiada = 1;
  ca(*p)[VIDEO_COLS] = (ca(*)[VIDEO_COLS])VIDEO;
  uint32_t f;
  uint32_t c;
  for (f = 0; f < SIZE_M; f++)
  {
    for (c = 0; c < SIZE_N; c++)
    {
      pantalla_vieja[f][c].c = p[f][c].c;
      pantalla_vieja[f][c].a = p[f][c].a;
    }
  }
}
void restaurar_pantalla()
{
  if (fue_copiada) {
    fue_copiada = 0;
    ca(*p)[VIDEO_COLS] = (ca(*)[VIDEO_COLS])VIDEO;
    uint32_t f;
    uint32_t c;
    for (f = 0; f < SIZE_M; f++) {
        for (c = 0; c < SIZE_N; c++) {
            p[f][c].c = pantalla_vieja[f][c].c;
            p[f][c].a = pantalla_vieja[f][c].a;
        }
    }
  }
}

void imprimir_excepcion(int numero, char *mensaje, uint32_t cr0, uint32_t cr2, uint32_t cr3, uint32_t cr4,
                        uint16_t cs, uint16_t ds, uint16_t es, uint16_t fs, uint16_t gs, uint16_t ss,
                        uint32_t edi, uint32_t esi, uint32_t ebp, uint32_t esp0, uint32_t ebx, uint32_t edx, uint32_t ecx, uint32_t eax,
                        uint32_t eip, uint32_t cs3, uint32_t eflags, uint32_t esp, uint32_t ss3, uint32_t err)
{

  print_dec(ss3, 0, 0, 10, 0x70);
  print_dec(esp, 0, 0, 10, 0x70);
  print_dec(cs3, 0, 0, 10, 0x70);

  copiar_pantalla();

  uint32_t trace[5] = {0};
  back_trace((uint32_t *)&trace, ebp);
  
  // hacer recuadro
  print("                              ", 9, 0, 0x00); 
  print("                              ", 9, 1, 0x00); 
  print("                              ", 9, 2, 0x00); print(mensaje, 9, 2, 0X0A); print_dec(numero, 2, 9, 20, 0X0A);
  print(" eax                          ", 9, 3, 0X0A); print_hex(eax, 8, 9 + 5, 3, 0X0A);
  print("               cr0            ", 9, 4, 0X0A); print_hex(cr0, 8, 9 + 19, 4, 0X0A);
  print(" ebx                          ", 9, 5, 0X0A); print_hex(ebx, 8, 9 + 5, 5, 0X0A);
  print("               cr2            ", 9, 6, 0X0A); print_hex(cr2, 8, 9 + 19, 6, 0X0A);
  print(" ecx                          ", 9, 7, 0X0A); print_hex(ecx, 8, 9 + 5, 7, 0X0A);
  print("               cr3            ", 9, 8, 0X0A); print_hex(cr3, 8, 9 + 19, 8, 0X0A);
  print(" edx                          ", 9, 9, 0X0A); print_hex(edx, 8, 9 + 5, 9, 0X0A);
  print("               cr4            ", 9, 10, 0X0A); print_hex(cr4, 8, 9 + 19, 10, 0X0A);
  print(" esi                          ", 9, 11, 0X0A); print_hex(esi, 8, 9 + 5, 11, 0X0A);
  print("               err            ", 9, 12, 0X0A); print_hex(err, 8, 9 + 19, 12, 0X0A);
  print(" edi                          ", 9, 13, 0X0A); print_hex(edi, 8, 9 + 5, 13, 0X0A);
  print("                              ", 9, 14, 0X0A);
  print(" ebp                          ", 9, 15, 0X0A); print_hex(ebp, 8, 9 + 5, 15, 0X0A);
  print("                              ", 9, 16, 0X0A);
  print(" esp           stack          ", 9, 17, 0X0A); print_hex(esp, 8, 9 + 5, 17, 0X0A);
  print("                              ", 9, 18, 0X0A);
  print(" eip                          ", 9, 19, 0X0A); print_hex(eip, 8, 9 + 5, 19, 0X0A);
  print("                              ", 9, 20, 0X0A);
  print("  cs                          ", 9, 21, 0X0A); print_hex(cs, 8, 9 + 5, 21, 0X0A);
  print("                              ", 9, 22, 0X0A);
  print("  ds           backtrace      ", 9, 23, 0X0A); print_hex(ds, 8, 9 + 5, 23, 0X0A);
  print("                              ", 9, 24, 0X0A);
  print("  es                          ", 9, 25, 0X0A); print_hex(es, 8, 9 + 5, 25, 0X0A);
  print("                              ", 9, 26, 0X0A);
  print("  fs                          ", 9, 27, 0X0A); print_hex(fs, 8, 9 + 5, 27, 0X0A);
  print("                              ", 9, 28, 0X0A);
  print("  gs                          ", 9, 29, 0X0A); print_hex(gs, 8, 9 + 5, 29, 0X0A);
  print("                              ", 9, 30, 0X0A);
  print("  ss                          ", 9, 31, 0X0A); print_hex(ss, 8, 9 + 5, 31, 0X0A);
  print("                              ", 9, 32, 0X0A);
  print("                              ", 9, 33, 0X0A);
  print("  eflags                      ", 9, 34, 0X0A); print_hex(eflags, 8, 9 + 9, 34, 0X0A);
  print("                              ", 9, 35, 0X0A);
  print("                              ", 9, 36, 0X0A);
  print("                              ", 9, 38, 0X0A);
  print(" ----PRESS 'Y' TO CONTINUE----", 9, 37, 0X0A);
  print("                              ", 9, 39, 0x00);

  // bordes negros
  for (int i = 0; i < 40; ++i)
  {
    print(" ", 8, i, 0x00);
    print(" ", 39, i, 0x00);
  }

  uint32_t *stack = (uint32_t *)esp0;
  print_hex((uint32_t)(*stack), 8, 9 + 15, 18, 0x0A);
  print_hex((uint32_t)(*(stack + 4)), 8, 9 + 15, 19, 0x0A);
  print_hex((uint32_t)(*(stack + 8)), 8, 9 + 15, 20, 0x0A);

 print_hex(trace[0], 8, 9 + 15,24,0X0A);
 print_hex(trace[1], 8, 9 + 15,25, 0X0A);
 print_hex(trace[2], 8, 9 + 15,26, 0X0A);
 print_hex(trace[3], 8, 9 + 15,27, 0X0A);
 print_hex(trace[4], 8, 9 + 15,28, 0X0A);
}
