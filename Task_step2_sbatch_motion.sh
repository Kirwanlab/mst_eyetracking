#!/bin/bash

#SBATCH --time=30:00:00   # walltime
#SBATCH --ntasks=6   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=8gb   # memory per CPU core
#SBATCH -J "TaskS2"   # job name

# Compatibility variables for PBS. Delete if not needed.
export PBS_NODEFILE=`/fslapps/fslutils/generate_pbs_nodefile`
export PBS_JOBID=$SLURM_JOB_ID
export PBS_O_WORKDIR="$SLURM_SUBMIT_DIR"
export PBS_QUEUE=batch

# Set the max number of threads to use for programs using OpenMP. Should be <= ppn. Does nothing if the program doesn't use OpenMP.
export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE




# Written by Nathan Muncy on 10/24/18


### --- Notes
#
# 1) just do the motion correction




subj=$1


													###??? update these variables/arrays - NEW: only this section needs to be updated!
parDir=~/fsl_groups/fslg_KirwanLab/compute/encoding_fmri_new				  			# parent dir, where derivatives is located
workDir=${parDir}/derivatives/$subj

cd $workDir


### --- Motion --- ###
#
# motion and censor files are constructed. Multiple motion files
# include mean and derivative of motion.


phase=contrecog
nruns=5

cat dfile.run-*${phase}.1D > dfile_rall_${phase}.1D
if [ ! -s censor_${phase}_combined.1D ]; then

    # files: de-meaned, motion params (per phase)
    1d_tool.py -infile dfile_rall_${phase}.1D -set_nruns $nruns -demean -write motion_demean_${phase}.1D
    1d_tool.py -infile dfile_rall_${phase}.1D -set_nruns $nruns -derivative -demean -write motion_deriv_${phase}.1D
    1d_tool.py -infile motion_demean_${phase}.1D -set_nruns $nruns -split_into_pad_runs mot_demean_${phase}
    1d_tool.py -infile dfile_rall_${phase}.1D -set_nruns $nruns -show_censor_count -censor_prev_TR -censor_motion 0.3 motion_${phase}


    # determine censor
    cat out.cen.run-*${phase}.1D > outcount_censor_${phase}.1D
    1deval -a motion_${phase}_censor.1D -b outcount_censor_${phase}.1D -expr "a*b" > censor_${phase}_combined.1D
fi




