import re
import numpy as np
from scipy import stats
import matplotlib.pyplot as plt
import subprocess
import sys

args = sys.argv
filtro = args[1]
muestras = int(args[2])
filtro_args = args[3:]

data_asm = []
data_O0 = []
data_O1 = []
data_O2 = []
data_O3 = []

def reject_outliers(data, mean, std, m=2):
    return np.array(data)[abs(data - mean) < m * std]

imagenes = [
    '2001ASpaceOdyssey',
    'Atonement',
    'BladeRunner',
    'CidadeDeDeus',
    'DjangoUnchained',
    'Labyrinth',
    'LaViteEBella',
    'Misery',
    'SweetNovember']
#ASM
data_asm_std = []
data_asm_var = []
data_asm_trimmed = []
for imagen in imagenes:
    for i in range(muestras):
        command_asm = ['../build/tp2', filtro, '-i', 'asm',
                    f'data/imagenes_a_testear/{imagen}.1024x512.bmp'] + filtro_args
        p = subprocess.Popen(
            command_asm, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        out, err = p.communicate()
        cant_ciclos = re.search(
            b'totales     : ([0-9]*)', out).group(1).decode("utf-8")
        data_asm.append(int(cant_ciclos))
data_asm_std.append(np.std(data_asm))
data_asm_var.append(np.var(data_asm))
data_asm_trimmed.append(
    np.mean(
        reject_outliers(data_asm, np.mean(data_asm), np.std(data_asm)
        )
    )
)

#O3
data_o3_std = []
data_o3_var = []
data_o3_trimmed = []
for imagen in imagenes:
    for i in range(muestras):
        command_c = ['../builds_optimizados/O3/tp2', filtro, '-i',
                    'c', f'data/imagenes_a_testear/{imagen}.1024x512.bmp'] + filtro_args
        p = subprocess.Popen(
            command_c, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        out, err = p.communicate()
        cant_ciclos = re.search(
            b'.totales     : ([0-9]*)', out).group(1).decode("utf-8")
        data_O3.append(int(cant_ciclos))
data_o3_std.append(np.std(data_O3))
data_o3_var.append(np.var(data_O3))
data_o3_trimmed.append(
    np.mean(
        reject_outliers(data_O3, np.mean(data_O3), np.std(data_O3)
        )
    )
)

f = open(f'results_tamaños_varios_{filtro}.txt', "a")
f.write(' '.join(args))

f.write('\n' + str(data_asm_trimmed))
f.write('\n' + str(data_o3_trimmed))

# f.write('\nASM STD: ' + ' '.join(str(data_asm_std)))
# f.write('\nASM TRIMMED: ' + ' '.join(str(data_asm_trimmed)))
# f.write('\nASM VAR: ' + ' '.join(str(data_asm_var)))

# f.write('\nO0  STD: ' + ' '.join(str(data_o0_std)))
# f.write('\nO0  TRIMMED: ' + ' '.join(str(data_o0_trimmed)))
# f.write('\nO0  VAR: ' + ' '.join(str(data_o0_var)))

# f.write('\nO1  STD: ' + ' '.join(str(data_o1_std)))
# f.write('\nO1  TRIMMED: ' + ' '.join(str(data_o1_trimmed)))
# f.write('\nO1  VAR: ' + ' '.join(str(data_o1_var)))

# f.write('\nO2  STD: ' + ' '.join(str(data_o2_std)))
# f.write('\nO2  TRIMMED: ' + ' '.join(str(data_o2_trimmed)))
# f.write('\nO2  VAR: ' + ' '.join(str(data_o2_var)))

# f.write('\nO3  STD: ' + ' '.join(str(data_o3_std)))
# f.write('\nO3  TRIMMED: ' + ' '.join(str(data_o3_trimmed)))
# f.write('\nO3  VAR: ' + ' '.join(str(data_o3_var)))
f.close()
#fig1, ax1 = plt.subplots()
#ax1.set_title('ASM')
#ax1.boxplot(data_asm)

#fig2, ax2 = plt.subplots()
#ax2.set_title('C')
#ax2.boxplot(data_c)


#plt.show()
