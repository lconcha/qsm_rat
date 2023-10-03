#!/bin/bash
source `which my_do_cmd`

inprefix=$1
idx_acq=$2
idx_mag=$3
idx_real=$4
idx_imag=$5
idx_phase=$6
outprefix=$7


ls_mag=$(ls ${inprefix}_${idx_acq}_${idx_mag}_*-??.nii.gz)
ls_real=$(ls ${inprefix}_${idx_acq}_${idx_real}_*-??.nii.gz)
ls_imag=$(ls ${inprefix}_${idx_acq}_${idx_imag}_*-??.nii.gz)
ls_phase=$(ls ${inprefix}_${idx_acq}_${idx_phase}_*-??.nii.gz)


printf '\nMagnitude:\n'
printf '  %s\n' $ls_mag
mrcat -quiet -axis 3 $ls_mag ${outprefix}_${idx_acq}_mag.nii.gz
echo ${outprefix}_${idx_acq}_mag.nii.gz

printf '\nReal:\n'
printf '  %s\n' $ls_real
mrcat -quiet -axis 3 $ls_real ${outprefix}_${idx_acq}_real.nii.gz
echo ${outprefix}_${idx_acq}_real.nii.gz

printf '\nImaginary:\n'
printf '  %s\n' $ls_imag
mrcat -quiet -axis 3 $ls_imag ${outprefix}_${idx_acq}_imag.nii.gz
echo ${outprefix}_${idx_acq}_imag.nii.gz

printf '\nPhase:\n'
printf '  %s\n' $ls_phase
mrcat -quiet -axis 3 $ls_phase ${outprefix}_${idx_acq}_phase.nii.gz
echo ${outprefix}_${idx_acq}_phase.nii.gz

