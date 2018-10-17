#! /bin/bash 
## David R. Hill 2018-10-17

### -------------------------------------------------------------------------
### Script:       pbs_writer.sh
### Written by:   Hill DR
### -------------------------------------------------------------------------

### wrapper script for generating PBS requests

# ---------------------------------------------------------------------------
# Supply arguments to script from the command line
# ---------------------------------------------------------------------------
## default values
# number of threads for trimmomatic
THREADS=8
EMAIL=hilldr@med.umich.edu
PBS_l="nodes=1:ppn=8,pmem=8gb,walltime=24:00:00"
PBS_o=$(pwd)\/PBS_Log/
SCRIPT=test.sh

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
    -e=*|--email=*)
    EMAIL="${i#*=}"
    shift # past argument=value
    ;;
    -l=*|--pbs_l=*)
    PBS_l="${i#*=}"
    shift # past argument=value
    ;;
    -o=*|--pbs_o=*)
    PBS_o="${i#*=}"
    shift # past argument=value
    ;;

esac
done

# ---------------------------------------------------------------------------
# Main text of PBS script
# ---------------------------------------------------------------------------
cat << EOF > ${SCRIPT%.*}.pbs
### Run script ($SCRIPT) on high-performance computing
### ------------------------------------------------------------------------
### Start of the PBS directives
### Output and error file by default will be copied -o

#PBS -S /bin/sh
#PBS -N ${SCRIPT%.*}
#PBS -l $PBS_l
#PBS -A youngvi_fluxm
#PBS -l qos=flux
#PBS -q fluxm
#PBS -M $EMAIL
#PBS -m abe
#PBS -j oe
#PBS -o $PBS_o
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

### Define script name variable:
Script=$SCRIPT
### Run your script (.sh)
# make directory for PBS log file
mkdir -p $PBS_o
sh $(pwd)/$SCRIPT
EOF

## print pbs script to STDOUT
cat ${SCRIPT%.*}.pbs

## prompt user input to proceed to qsub
while true; do
    echo -e "--- END OF ${SCRIPT%.*}.pbs ---\n"
    read -p "Please review the PBS file above...`echo $'\n> '` Is this PBS file ready to submit [y/n]?" yn
    case $yn in
        [Yy]* )
	    echo "qsub ${SCRIPT%.*}.pbs"
	    break;;
	[Nn]* ) exit;;
        * ) echo "Please answer y or n.";;
    esac
done
