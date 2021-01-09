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


ret = subprocess.run(["make", "-C", "../"])
if ret.returncode != 0:
    print(colored(
        'La compilación falló, intentá correr make desde la raíz del proyecto', 'red'))
    exit()



archivos = archivos_tests()
cantIterGOOD=[]
cantIterTHEBAD=[]

for i in range(1000):
    iteraciones = correr_alumno('ReforzarBrillo', 'c', 'SweetNovember.512x256.bmp', '150 151 0 0')
    cantIterTHEBAD.append(int(iteraciones))
    iteraciones = correr_alumno('ReforzarBrillo', 'c', 'mierda.bmp', '-- -1 0 0 0')
    cantIterGOOD.append(int(iteraciones))

data = [cantIterGOOD, cantIterTHEBAD]
fig1, ax1 = plt.subplots()
ax1.set_ylabel('Cantidad de Ciclos')
ax1.set_title('Branch controlado vs. no controlado')
ax1.boxplot(data)

plt.show()
