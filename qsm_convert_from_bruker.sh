#!/bin/bash
source `which my_do_cmd`
fakeflag=""

scan_folder=$1
exam_number=$2
outbase=$3

strT2=T2star_map_MGE_ax


## Find exam number if not provided
if [ -z "$exam_number" ]
then
  # find the correct acquisition
  str=$(grep $strT2 ${scan_folder}/*/visu_pars)
  nmatches=$(echo $str | wc -l)
  if [ $nmatches -ne 1 ]
  then
    echo "[ERROR] Cannot determine where the acquisition is. Possibilities are:"
    echo $str
  fi
  echo "[INFO] Found one acquisition that matches $strT2"
  echo "       $str"
  exam_number=$(echo $str | awk -F: '{print $1}' | awk -F/ '{print $(NF-1)}')
fi
echo [INFO] Exam number is : $exam_number


## Get the reconstructions
magnitude_reco_number=1;# this is always one

str=$(grep "PHASE_IMAGE" ${scan_folder}/${exam_number}/pdata/*/visu_pars | head -n 1)
phase_reco_number=$(echo $str | awk -F: '{print $1}' | awk -F/ '{print $(NF-1)}')

str=$(grep "REAL_IMAGE" ${scan_folder}/${exam_number}/pdata/*/visu_pars | head -n 1)
real_reco_number=$(echo $str | awk -F: '{print $1}' | awk -F/ '{print $(NF-1)}')

str=$(grep "IMAGINARY_IMAGE" ${scan_folder}/${exam_number}/pdata/*/visu_pars | head -n 1)
imaginary_reco_number=$(echo $str | awk -F: '{print $1}' | awk -F/ '{print $(NF-1)}')

echo "[INFO] MAGNITUDE_IMAGE : $magnitude_reco_number"
echo "[INFO] PHASE_IMAGE : $phase_reco_number"
echo "[INFO] REAL_IMAGE : $real_reco_number"
echo "[INFO] IMAGINARY_IMAGE : $imaginary_reco_number"


## Convert
tmpDir=$(mktemp -d)
my_do_cmd $fakeflag brkraw tonii -b -o ${tmpDir}/magnitude -s $exam_number -r $magnitude_reco_number $scan_folder
my_do_cmd $fakeflag brkraw tonii -b -o ${tmpDir}/phase     -s $exam_number -r $phase_reco_number $scan_folder
my_do_cmd $fakeflag brkraw tonii -b -o ${tmpDir}/real      -s $exam_number -r $real_reco_number $scan_folder
my_do_cmd $fakeflag brkraw tonii -b -o ${tmpDir}/imaginary -s $exam_number -r $imaginary_reco_number $scan_folder

for reco in magnitude phase real imaginary
do
  my_do_cmd $fakeflag mrcat -quiet -axis 3 ${tmpDir}/${reco}*.nii.gz ${outbase}_${reco}.nii.gz
  my_do_cmd $fakeflag cp ${tmpDir}/${reco}*.json ${outbase}_${reco}.json
done

echo "----------------------------"
ls ${outbase}*

rm -fR $tmpDir