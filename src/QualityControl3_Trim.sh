#!/bin/bash

# ---------------------------------------------------------------------------
# Script:       QualityControl3_Trim.sh
# Written by:   Cieza RJ
# Purpose:      Trim and crop Illumina data (Fastq) and remove adapters
# ---------------------------------------------------------------------------

# Trimmomatic (v 0.38)
# -----------
# A flexible read trimming tool for Illumina NGS data
# http://www.usadellab.org/cms/?page=trimmomatic
# http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/TrimmomaticManual_V0.32.pdf

# DIR tree
# --------
# Script DIR structure
# Script should be run from the DIR src within a PROJECT

#  .
#  ├── bin
#  |   └── Trimmomatic-0.38
#  |        └── adapters
#  └── projects
#      └── NEC
#          ├── data
#          ├── results
#          |   └── Trimm
#          └── src

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

# ---------------------------------------------------------------------------
# (1) Set up job environment for Trimmomatic
# ---------------------------------------------------------------------------
# Define Trimmomatic '.jar' variable
Trimm_jar=../../../bin/Trimmomatic-0.38/trimmomatic-0.38.jar

# Define the variable of the adapter
# TruSeq3 adapters are used by HiSeq and MiSeq machines
# Adapter used below: Line 76
Adapter=../../../bin/Trimmomatic-0.38/adapters/TruSeq3-PE-2-NexteraPE-PE_combined.fa


# ---------------------------------------------------------------------------
# (2) Verify Trimmomatic can be executed and is correct version
# ---------------------------------------------------------------------------
if [[ $(java -jar $Trimm_jar -version) == '0.38' ]];
then
      echo "Trimmomatic version" $(java -jar $Trimm_jar -version)
else
      echo "Trimmomatic not found or wrong version"
fi

echo 'Trimmomatic will remove these adapters:' $Adapter


# ---------------------------------------------------------------------------
# (3) Generate a list of the strains present in the DIR data
# ---------------------------------------------------------------------------
# The DIR data contains paired end (PE) reads
# Each strain has:
# Forward (*_R1.fastq.gz)
# Reverse (*_R2.fastq.gz)
# Make a list of unique names in the DIR (Keep only the strain name)

# find:   Find strains in DIR data
# -name:  List unique names
# sed:    Remove the ending of file names only keeping the unique name
# sort:   Sort by unique name
STRAIN_NAME=$(find ../data/ -name '*.fastq.gz' | \
		  sed 's/\_R[1-2].fastq.gz//' | \
		  sort -u)


# ---------------------------------------------------------------------------
# (4) Trimmomatic parameters (Array loaded in line 149)
# ---------------------------------------------------------------------------
trimmomatic_options=(
    ILLUMINACLIP:$Adapter:2:30:10:8:true \
# ILLUMINACLIP
# Cut adapter and illumina-specific sequences from the read
#   * Remove Illumina adapters provided in TruSeq3-PE-2-NexteraPE-PE_combined.fa file
#   * Looks for seeds matches (16 bases) allowing maximally 2 mismatches
#   * Seeds are extended and clipped if PE reads score 30 (around 50 bp)
#   * Seeds are extended and clipped if SE reads score 10 (around 17 bp)
#   * Detect minimum length of adapter (default = 8 bases)
#   * "true" retains the reverse read
	SLIDINGWINDOW:4:15 \
# SLIDINGWINDOW:
# Performs a sliding window trimming approach
#   * Scan the read with a 4-base sliding window
#   * Cuts the read when the average quality per base drops below 15
	MINLEN:36 \
# MINLEN:
# Drop the read if it is below a specified length
#   * Less than 36 bases
)


# ---------------------------------------------------------------------------
# (5) Run Trimmomatic & create a DIR to deposit the results for EACH strain
# ---------------------------------------------------------------------------
for strain in $STRAIN_NAME
do

  # (a) Define DIRNAME
  DIRNAME=${strain##*/}

  # (b) Define input files
  # Forward 'fastq.gz'
  # Reverse 'fastq.gz'
  TRIMINP=$(echo \
		$strain\_R1.fastq.gz \
		$strain\_R2.fastq.gz)

  # (c) Define the output DIR and files
  # DIR where results will be saved
  Trimm_Out=../results/$DIRNAME/Trimm/
  # Output files:
  # ------------
  # Forward Paired
  R1P=$Trimm_Out$DIRNAME\_R1_paired.fastq.gz
  # Forward Unpaired
  R1U=$Trimm_Out$DIRNAME\_R1_unpaired.fastq.gz
  # Reverse Paired
  R2P=$Trimm_Out$DIRNAME\_R2_paired.fastq.gz
  # Reverse Unpaired
  R2U=$Trimm_Out$DIRNAME\_R2_unpaired.fastq.gz

  # (d) Make a DIR to deposit the results
  mkdir -p $Trimm_Out

  # (e) Run Trimmomatic on paired end (PE) reads
  # PARAMETERS:
  # ----------
  # java -jar <path to trimmomatic.jar>
  # PE
  # -threads:    8 (Adjust accordingly)
  # input:      <input 1> <input 2>
  # output:     <paired output 1> <unpaired output 1> <paired output 2> <unpaired output 2>
  # Options:    <Trimmomatic options: Load the options from array>
  java -jar $Trimm_jar \
       PE \
       -threads $THREADS \
       $TRIMINP \
       $R1P \
       $R1U \
       $R2P \
       $R2U \
       "${trimmomatic_options[@]}"

  echo 'loop complete for' $DIRNAME

done
# ---------------------------------------------------------------------------
# End of QualityControl3_Trim.sh script
# ---------------------------------------------------------------------------
