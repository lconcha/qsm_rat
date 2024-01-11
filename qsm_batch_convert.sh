#!/bin/bash

convdir=/misc/lauterbur/lconcha/TMP/qsm/conv
linksdir=/misc/lauterbur/lconcha/TMP/qsm/links

20231003_130248_hluna_piloFe_irm1_rata8_hluna_piloFe_irm1_r_1_1

for f in $linksdir/20*
do
  g=$(readlink -f $f)
  ff=$(basename $f)
  ratID=$(echo $ff | awk -F_ '{print $6}')
  ses=$(echo $ff | awk -F_ '{print $5}')
  echo $ratID $ses $ff
  qsm_convert_from_bruker.sh $g "" ${convdir}/${ratID}_${ses}
done
