#!/bin/sh

# ---------------------------------------------------------------------------
# Script:       QualityControl4_FastQCpost.sh
# Written by:   Cieza RJ
# Purpose:      Quality control (QC) with FastQC after Trimmomatic
# ---------------------------------------------------------------------------

# FastQC (v 0.11.5)
# ------
# QC checks on raw sequence data from high throughput sequencing pipelines
# https://www.bioinformatics.babraham.ac.uk/projects/fastqc/

# DIR tree
# --------
# Script DIR structure
# Script should be run from the DIR src within a PROJECT

#  .
#  └── projects
#      └── NEC
#          ├── data
#          ├── results
#          |   ├── QC
#          |   |   └── Post
#          |   └── Trimm
#          └── src


# ---------------------------------------------------------------------------
# (1) Set up job environment for FastQC
# ---------------------------------------------------------------------------
module purge
module load fastqc/0.11.5

echo 'These are the modules loaded'
module list


# ---------------------------------------------------------------------------
# (2) Verify that FastQC can be executed
# ---------------------------------------------------------------------------
fastqc -h


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
STRAIN_NAME=\
$(find ../data/ \
-name '*.fastq.gz' | \
sed 's/\_R[1-2].fastq.gz//' | \
sort -u)


# ---------------------------------------------------------------------------
# (4) Run FastQC & create a DIR to deposit the results for EACH strain
# ---------------------------------------------------------------------------
for strain in $STRAIN_NAME
do

  # (a) Define DIRNAME variable
  DIRNAME=${strain##*/}

  # (b) Define input variables
  # Run QC only on 'Paired' files from Trimmomatic
  # Forward 'paired.fastq.gz'
  # Reverse 'paired.fastq.gz'
  TRIMM_STRAIN_NAME=$(find ../results/$DIRNAME/Trimm/ \
  -name '*_paired.fastq.gz' | \
  sed 's/\_R[1-2]_paired.fastq.gz//' | \
  sort -u)

  # (c) Define input reads
  # Forward Paired
  R1P=$TRIMM_STRAIN_NAME\_R1_paired.fastq.gz
  # Reverse Paired
  R2P=$TRIMM_STRAIN_NAME\_R2_paired.fastq.gz

  # (d) Define the output varible
  QCpost=../results/$DIRNAME/QC/Post/

  # (e) Make a DIR to deposit the results
  mkdir -p $QCpost

  # (f) Run FastQC on Forward & Reverse reads
  # Forward read
  fastqc \
  --threads 8 \
  -o $QCpost \
  $R1P
  # Reverse read
  fastqc \
  --threads 8 \
  -o $QCpost \
  $R2P

  echo 'loop complete'

done


# -------------------------------------------------------------------------
# End of QualityControl4_FastQCpost.sh script
# -------------------------------------------------------------------------
