import re
import numpy as np
import matplotlib.pyplot as plt
import subprocess
import sys
from termcolor import colored
from libtest import *

DATADIR = "./data"
PRIMER_SCRIPT = "1_generar_imagenes.py"
TESTINDIR = DATADIR + "/imagenes_a_testear"
CATEDRADIR = DATADIR + "/resultados_catedra"
ALUMNOSDIR = DATADIR + "/resultados_nuestros"
TP2ALU = "../build/tp2"
TP2CAT = "./tp2catedra"
DIFF = "../build/bmpdiff"
DIFFFLAGS = ""
corrida = {'filtro': 'ImagenFantasma', 'tolerancia': 0, 'params': '1 1'},


ret = subprocess.run(["make", "-C", "../"])
if ret.returncode != 0:
    print(colored(
        'La compilación falló, intentá correr make desde la raíz del proyecto', 'red'))
    exit()

print(colored('Iniciando test de diferencias ASM vs. la catedra...', 'blue'))


archivos = archivos_tests()
error_OG = []
iter_OG = []
error_V2 = []
iter_V2 = []
error_V3 = []
iter_V3 = []


for imagen in archivos:
    archivo_out_cat = correr_catedra('ImagenFantasma', 'asm', imagen, '1 1')

    res_OG = correr_alumno('ImagenFantasma', 'asm', imagen, '1 1')

    iter_OG.append(float(res_OG['promedio']))


    res_v2 = correr_alumno('ImagenFantasma', 'asm_v2', imagen, '1 1')

    iter_V2.append(float(res_v2['promedio']))

    res_v3 = correr_alumno('ImagenFantasma', 'asm_v3', imagen, '1 1')
    iter_V3.append(float(res_v3['promedio']))


    comandoOG = DIFF + " " + DIFFFLAGS + " " + CATEDRADIR + "/" + \
        archivo_out_cat + " " + ALUMNOSDIR + "/" + res_OG['archivo_out'] + " 0"
    resOG = subprocess.check_output(comandoOG, shell=True).decode('utf-8').strip()

    error_OG.append(float(resOG))



    comando2 = DIFF + " " + DIFFFLAGS + " " + CATEDRADIR + "/" + \
        archivo_out_cat + " " + ALUMNOSDIR + "/" + res_v2['archivo_out'] + " 0"
    res2 = subprocess.check_output(comando2, shell=True).decode('utf-8').strip()

    error_V2.append(float(res2))


    comando3 = DIFF + " " + DIFFFLAGS + " " + CATEDRADIR + "/" + \
        archivo_out_cat + " " + ALUMNOSDIR + "/" + res_v3['archivo_out'] + " 0"
    res3 = subprocess.check_output(comando3, shell=True).decode('utf-8').strip()
    
    error_V3.append(float(res3))

f = open("results.txt", "a")

f.write('Implementación Original\n')
f.write(f'promedio error: {np.mean(error_OG)}\n')
f.write(f"promedio iteraciones: {np.mean(iter_OG)}\n")
f.write('Implementación más rápida\n')
f.write(f'promedio error: {np.mean(error_V2)}\n')
f.write(f"promedio iteraciones: {np.mean(iter_V2)}\n")
f.write('Implementación intermedia\n')
f.write(f'promedio error: {np.mean(error_V3)}\n')
f.write(f"promedio iteraciones: {np.mean(iter_V3)}\n")
f.close()

