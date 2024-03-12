
addpath('/misc/mansfield/lconcha/software/sepia')
sepia_addpath;

images_dir = '/misc/lauterbur/lconcha/TMP/qsm/conv';

% General algorithm parameters
algorParam = struct();
algorParam.general.isBET = 0 ;
algorParam.general.isInvert = 0 ;
algorParam.general.isRefineBrainMask = 0 ;
% Total field recovery algorithm parameters
algorParam.unwrap.echoCombMethod = 'Optimum weights' ;
algorParam.unwrap.unwrapMethod = 'Laplacian (MEDI)' ;
algorParam.unwrap.isEddyCorrect = 0 ;
algorParam.unwrap.isSaveUnwrappedEcho = 0 ;
% Background field removal algorithm parameters
algorParam.bfr.refine_method = '3D Polynomial' ;
algorParam.bfr.refine_order = 4 ;
algorParam.bfr.erode_radius = 0 ;
algorParam.bfr.erode_before_radius = 0 ;
algorParam.bfr.method = 'VSHARP' ;
algorParam.bfr.radius = [10:-1:3] ;
% QSM algorithm parameters
algorParam.qsm.reference_tissue = 'None' ;
algorParam.qsm.method = 'Star-QSM' ;
algorParam.qsm.padsize     = ones(1,3)*12 ;


d = dir(images_dir)
for r = 3 : length(d)
    this_rat = d(r).name;
    % Input/Output filenames
    input = struct();
    input = fullfile(images_dir,this_rat);
    output_basename = fullfile(images_dir,this_rat,'output','sepiabatch');
    mask_filename = fullfile(images_dir,this_rat,'brain_mask.nii.gz') ;
    
    fcheck=fullfile([output_basename '_Chimap.nii.gz']);
    if isfile(fcheck)
      fprintf(1,'[INFO] File exists: %s\n       Will not overwrite.\n',fcheck);
      continue;
    else
      fprintf(1,'Will create files with prefix: %s\n',output_basename);
      sepiaIO(input,output_basename,mask_filename,algorParam);
    end
end



