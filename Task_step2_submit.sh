#!/bin/bash




###??? update these
parDir=~/fsl_groups/fslg_KirwanLab/compute/encoding_fmri_new				  			# parent dir, where derivatives is located
workDir=${parDir}/derivatives
scriptDir=${parDir}/code
slurmDir=${workDir}/Slurm_out

time=`date '+%Y_%m_%d-%H_%M_%S'`
outDir=${slurmDir}/TaskStep2_${time}

mkdir -p $outDir

cd $workDir
for i in sub*; do

    sbatch \
    -o ${outDir}/output_TaskN2_${i}.txt \
    -e ${outDir}/error_TaskN2_${i}.txt \
    ${scriptDir}/Task_step2_sbatch_motion.sh $i

    sleep 1
done
