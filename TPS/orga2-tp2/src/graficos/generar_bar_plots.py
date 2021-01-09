import matplotlib.pyplot as plt; plt.rcdefaults()
import numpy as np
import matplotlib.pyplot as plt

implementaciones = ('128x64', '256x128', '512x256', '1024x512')
y_pos = np.arange(len(implementaciones))
# ciclos_de_procesador_imagenfantasma = [37449397,20478864,20372600,20385521,1787385]

# ciclos_de_procesador_colorbordes = [80298428,34577970,32556000,28635102, 2644068]
# ciclos_de_procesador_reforzarbrillo = [7231819,5178429,4971872,5272069,568558]
# ciclos_exp_pato = [2376578, 1718742, 2302064]
C_O3 = [298000.8970251716/38406.881278538815
,983493.1142191142/125382.74829931973
,2584768.875846501/314381.3549883991
,7101618.095454546/975015.4663461539]

plt.bar(y_pos, C_O3, align='center', alpha=0.5)
plt.xticks(y_pos, implementaciones)
plt.ylabel('Ratio promedio ciclos C y promedio ciclos ASM')
plt.title('''Relación entre promedios de ciclos de ejecucion entre C_O3 y ASM
Reforzar Brillo''')

plt.show()

# libraries
# import numpy as np
# import matplotlib.pyplot as plt
 
# # set width of bar
# barWidth = 0.25
 
# ASM = [60006.5306122449
# ,218847.97732426305
# ,579325.6162528216
# ,1559680.414918415]


# C_O3 = [715374.9817351598/60006.5306122449
# ,2513499.3272311212/218847.97732426305
# ,6243347.538461538/579325.6162528216
# ,16823928.943209875/1559680.414918415]


 
# # Set position of bar on X axis
# r1 = np.arange(len(ASM))
# r2 = [x + barWidth for x in r1]
 
# # Make the plot
# plt.bar(r1, ASM, color='#7f6d5f', width=barWidth, edgecolor='white', label='ASM')
# # plt.bar(r2, C_O3, color='#557f2d', width=barWidth, edgecolor='white', label='C_O3')
 
# # Add xticks on the middle of the group bars

# plt.xticks([r + barWidth for r in range(len(ASM))], ['128x64', '256x128', '512x256', '1024x512'])
# plt.ylabel('Ciclos de procesador')
# plt.title('''Comparación rendimiento por tamaño de imagen
# Color Bordes''')
# # Create legend & Show graphic
# plt.legend()
# plt.show()
