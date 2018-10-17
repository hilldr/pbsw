#! /bin/bash 
## David R. Hill 2018-10-17

### -------------------------------------------------------------------------
### Script:       pbs_writer.sh
### Written by:   Hill DR
### -------------------------------------------------------------------------

### wrapper script for generating PBS requests

# ---------------------------------------------------------------------------
# (0) Supply arguments to script from the command line
# ---------------------------------------------------------------------------
## default values
# number of threads for trimmomatic
THREADS=8

## user-supplied values (will overwrite defaults)
## format: '--threads=8'
## https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash#
for i in "$@"
do
case $i in
    -t=*|--threads=*)
    THREADS="${i#*=}"
    shift # past argument=value
    ;;
esac
done
echo "THREADS  = ${THREADS}"

cat << EOF > pbs_test.sh
### Run script (QualityControl1_FastQCpre.sh) on high-performance computing
### ------------------------------------------------------------------------
### Start of the PBS directives
### Output and error file by default will be copied -o

#PBS -S /bin/sh
#PBS -N QualityControl1_FastQCpre
#PBS -l nodes=1:ppn=8,pmem=8gb,walltime=24:00:00
#PBS -A youngvi_fluxm
#PBS -l qos=flux
#PBS -q fluxm
#PBS -M rjcieza@med.umich.edu
#PBS -m abe
#PBS -j oe
#PBS -o /scratch/youngvi_fluxm/rjcieza/projects/NEC/src/PBS_Log/
#PBS -V

### End of PBS directives

### ------------------------------------------------------------------------
### Switch to the working directory (\$PBS_O_WORKDIR);
### by default TORQUE launches processes from your home directory.
cd \$PBS_O_WORKDIR
echo Running from \$PBS_O_WORKDIR
### ------------------------------------------------------------------------
### Calculate the number of processors allocated to this run.
NPROCS=\`wc -l < \$PBS_NODEFILE\`
### Calculate the number of nodes allocated.
NNODES=\`uniq \$PBS_NODEFILE | wc -l\`
### ------------------------------------------------------------------------
### Display the job context
echo Running on host `hostname`
echo Time is `date`
echo Directory is `pwd`
echo Using \${NPROCS} processors across \${NNODES} nodes
echo "I ran on:"
cat \$PBS_NODEFILE
### ------------------------------------------------------------------------
## Display the job information
echo 'Job identifiers are'
echo \$PBS_JOBID
echo \$PBS_JOBNAME
### ------------------------------------------------------------------------

### Define Project name variable:
Project=NEC
### Define scritpt name variable:
Script=QualityControl1_FastQCpre.sh
### Run your script (.sh)
mkdir -p /scratch/youngvi_fluxm/rjcieza/projects/$Project/src/PBS_Log/
sh /scratch/youngvi_fluxm/rjcieza/projects/$Project/src/$Script
EOF

cat pbs_test.sh
