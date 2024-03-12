#!/bin/bash

convdir=/misc/mansfield/lconcha/exp/qsm/conv
linksdir=/misc/mansfield/lconcha/exp/qsm/links


for f in $linksdir/20*
do
  g=$(readlink -f $f)
  ff=$(basename $f)
  ratID=$(echo $ff | awk -F_ '{print $6}')
  ses=$(echo $ff | awk -F_ '{print $5}')
  echo $ratID $ses $ff
  qsm_convert_from_bruker.sh $g "" ${convdir}/${ratID}_${ses}
done
