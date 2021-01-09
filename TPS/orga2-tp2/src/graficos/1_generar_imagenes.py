#!/usr/bin/env python3

from libtest import *
import subprocess
import sys

# Este script crea las multiples imagenes de prueba a partir de unas
# pocas imagenes base.

IMAGENES=["Misery.bmp","SweetNovember.bmp", "2001ASpaceOdyssey.bmp", "Atonement.bmp", "BladeRunner.bmp", "CidadeDeDeus.bmp", "DjangoUnchained.bmp","LaViteEBella.bmp", "Labyrinth.bmp"]

assure_dirs()

sizes=["128x64", "256x128", "512x256", "1024x512"]

for filename in IMAGENES:
	print(filename)
	for size in sizes:
		sys.stdout.write("  " + size)
		name = filename.split('.')
		file_in  = DATADIR + "/" + filename
		file_out = TESTINDIR + "/" + name[0] + "." + size + "." + name[1]
		resize = "convert -resize " + size + "! " + file_in + " " + file_out
		subprocess.call(resize, shell=True)
	print("")
