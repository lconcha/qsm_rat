#!/bin/bash
source `which my_do_cmd`
fakeflag=""

scan_folder=$1
exam_number=$2
out_folder=$3

if [ -f ${out_folder}/magnitude.nii.gz ]
then
  echolor green "[INFO] Already converted: $out_folder"
  echolor green "       Will not overwrite. Quitting."
  exit 0
else
  echolor cyan "[INFO] Here we go..."
fi


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

#str=$(grep "REAL_IMAGE" ${scan_folder}/${exam_number}/pdata/*/visu_pars | head -n 1)
#real_reco_number=$(echo $str | awk -F: '{print $1}' | awk -F/ '{print $(NF-1)}')

#str=$(grep "IMAGINARY_IMAGE" ${scan_folder}/${exam_number}/pdata/*/visu_pars | head -n 1)
#imaginary_reco_number=$(echo $str | awk -F: '{print $1}' | awk -F/ '{print $(NF-1)}')

echo "[INFO] MAGNITUDE_IMAGE : $magnitude_reco_number"
echo "[INFO] PHASE_IMAGE : $phase_reco_number"
#echo "[INFO] REAL_IMAGE : $real_reco_number"
#echo "[INFO] IMAGINARY_IMAGE : $imaginary_reco_number"


## Convert
tmpDir=$(mktemp -d)
my_do_cmd $fakeflag brkraw tonii -b -o ${tmpDir}/magnitude -s $exam_number -r $magnitude_reco_number $scan_folder
my_do_cmd $fakeflag brkraw tonii -b -o ${tmpDir}/phase     -s $exam_number -r $phase_reco_number $scan_folder
#my_do_cmd $fakeflag brkraw tonii -b -o ${tmpDir}/real      -s $exam_number -r $real_reco_number $scan_folder
#my_do_cmd $fakeflag brkraw tonii -b -o ${tmpDir}/imaginary -s $exam_number -r $imaginary_reco_number $scan_folder

if [ ! -d $out_folder ]
then
  my_do_cmd $fakeflag mkdir $out_folder
fi

for reco in magnitude phase
do
  my_do_cmd $fakeflag mrcat -quiet -axis 3 ${tmpDir}/${reco}*.nii.gz ${out_folder}/${reco}.nii.gz
  my_do_cmd $fakeflag cp ${tmpDir}/${reco}*.json ${out_folder}/${reco}.json
done
cp /misc/lauterbur/lconcha/code/qsm_rat/header.mat ${out_folder}/

## full volume binary mask
#mrconvert -coord 3 0 ${out_folder}/magnitude.nii.gz - | mrcalc - 0 -mul 1 -add ${out_folder}/full_mask.nii.gz

## brain mask
dims=`mrinfo -spacing ${out_folder}/magnitude.nii.gz`
echolor cyan "original dims: $dims"
scaleFactor=10
arrdims=($dims)
x=${arrdims[0]}; xs=$(echo $x*$scaleFactor | bc -l)
y=${arrdims[1]}; ys=$(echo $y*$scaleFactor | bc -l)
z=${arrdims[2]}; zs=$(echo $z*$scaleFactor | bc -l)
echolor yellow "Computing brain mask"
my_do_cmd $fakeflag mrconvert \
  -coord 3 0 \
  -vox "${xs},${ys},${zs}" \
  ${out_folder}/magnitude.nii.gz \
  ${tmpDir}/mag.nii
my_do_cmd $fakeflag bet \
  ${tmpDir}/mag.nii \
  ${tmpDir}/mask \
  -m -n
mrconvert -vox "${x},${y},${z}" ${tmpDir}/mask_mask.nii.gz ${out_folder}/brain_mask.nii.gz

echo "----------------------------"
ls ${out_folder}

echolor yellow "[INFO] Attempt to convert T2_TurboRARE and T1_FLASH"
for strexam in T2_TurboRARE T1_FLASH
do
  str=$(grep $strexam ${scan_folder}/*/visu_pars)
  exam_number=$(echo $str | awk -F: '{print $1}' | awk -F/ '{print $(NF-1)}')
  if [ ! -z "$exam_number" ]
  then
    my_do_cmd $fakeflag brkraw tonii -b -o ${tmpDir}/${strexam} -s $exam_number $scan_folder
    my_do_cmd $fakeflab mrconvert ${tmpDir}/${strexam}*gz ${out_folder}/${strexam}.nii.gz
  else
    echo [WARN] Could not find a scan for $strexam
  fi
done

rm -fR $tmpDir