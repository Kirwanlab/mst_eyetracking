#!/bin/bash

#Let's do some group analyses!

parDir=/Volumes/Yorick/encoding/fMRI_new
derDir=${parDir}/derivatives
outDir=${derDir}/grp-031319
templateDir=${parDir}/code/templates
refFile=${derDir}/sub-01/run-1_similarity_stats+tlrc.HEAD

cd ${derDir}

for sub in sub*; do
	cd ${derDir}/${sub}
	
	#blur deconvolution outputs
	if [ ! -f similarity_stats_blur4+tlrc.HEAD ]; then
		3dmerge -prefix similarity_stats_blur4 -1blur_fwhm 4.0 -doall contrecog_stats+tlrc
	fi

done    

cd ${derDir}

#create an output folder
if [ ! -d $outDir ]; then
    mkdir $outDir
fi

cd $outDir

#create mask
# if [ ! -f Intersection_GM_mask+tlrc.HEAD ]; then
# 	3dcalc -a ${templateDir}/Prior2.nii.gz -b ${templateDir}/Prior4.nii.gz -prefix tmp_Prior_GM.nii.gz -expr "a+b"
# 	3dresample -master $refFile -rmode NN -input tmp_Prior_GM.nii.gz -prefix tmp_Template_GM_mask.nii.gz
# 	3dcopy tmp_Template_GM_mask.nii.gz Template_GM_mask+tlrc
# 	3dmask_tool -input ../sub-*/mask_epi_anat+tlrc.HEAD -frac 0.3 -prefix Group_epi_mask
# 	3dcalc -a Template_GM_mask+tlrc -b Group_epi_mask+tlrc -prefix Intersection_GM_prob_mask+tlrc -expr 'a*b'
# 	3dcalc -a Intersection_GM_prob_mask+tlrc -prefix Intersection_GM_mask+tlrc -expr 'step(a-0.1)'
# fi

AFNI_SHELL_GLOB=YES


if [ ! -f ${outDir}/ttest_hit2-hit1+tlrc.HEAD ]; then
    3dttest++ -prefix ttest_hit2-hit1 -mask Intersection_GM_mask+tlrc. -paired \
    -setA '../sub-*/similarity_stats_blur4+tlrc.HEAD[1]' \
    -setB '../sub-*/similarity_stats_blur4+tlrc.HEAD[0]'
fi

#I ran ETAC
3dttest++ -prefix ttest_hit2-hit1_etac -paired \
    -mask Intersection_GM_mask+tlrc \
    -prefix_clustsim ttest_hit2-hit1_clustsim \
    -ETAC \
    -ETAC_blur 4 \
    -ETAC_opt name=NN1:NN1:2sid:pthr=0.01,0.005,0.001 \
    -setA '../sub-*/similarity_stats+tlrc.HEAD[1]' \
    -setB '../sub-*/similarity_stats+tlrc.HEAD[0]'

#and then I did this in AFNI GUI with the output:
 3dclust -1Dformat -nosum -1dindex 0 -1tindex 0 -dxyz=1 -savemask ttest_hit2-hit1_ETAC_clusters_mask 1.01 10 ttest_hit2-hit1_clustsim.NN1.ETACmask.2sid.5perc.nii.gz

#and then I pulled betas 
3dROIstats -mask ttest_hit2-hit1_ETAC_clusters_mask+tlrc -1DRformat ../sub-*/similarity_stats_blur4+tlrc.HEAD > ttest_hit2-hit1_collapsed_betas.txt



