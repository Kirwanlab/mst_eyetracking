#!/bin/bash


# stderr and stdout are written to ${outDir}/error_* and ${outDir}/output_* for troubleshooting.
# job submission output are time stamped for troubleshooting


studyDir=~/fsl_groups/fslg_KirwanLab/compute/encoding_fmri_new/   ###??? update this
scriptDir=${studyDir}/code
rawdataDir=${studyDir}/rawdata
slurmDir=${studyDir}/derivatives/Slurm_out
time=`date '+%Y_%m_%d-%H_%M_%S'`
outDir=${slurmDir}/TaskStep1_${time}

mkdir -p $outDir

cd $rawdataDir
for i in sub*; do

    sbatch \
    -o ${outDir}/output_con1_${i}.txt \
    -e ${outDir}/error_con1_${i}.txt \
    ${scriptDir}/Task_step1_sbatch_preproc.sh $i

    sleep 1
done
