#!/bin/sh

# ---------------------------------------------------------------------------
# Script:       QualityControl1_FastQCpre.sh
# Written by:   Cieza RJ
# Purpose:      Quality control (QC) with FastQC before Trimmomatic
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
#          |   └── QC
#          |       └── Pre
#          └── src


# ---------------------------------------------------------------------------
# (1) Set up job environment for FastQC
# ---------------------------------------------------------------------------
# No further action is required
# FastQC should have already been installed through Conda (view README)

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

  # (b) Define input reads
  # Forward Paired
  R1=$strain\_R1.fastq.gz
  # Reverse Paired
  R2=$strain\_R2.fastq.gz

  # (c) Define the output varible
  QCpre=../results/$DIRNAME/QC/Pre/

  # (d) Make a DIR to deposit the results
  mkdir -p $QCpre

  # (e) Run FastQC on Forward & Reverse reads
  # Forward read
  fastqc \
  --threads 8 \
  -o $QCpre \
  $R1
  # Reverse read
  fastqc \
  --threads 8 \
  -o $QCpre \
  $R2

  echo 'loop complete'

done


# -------------------------------------------------------------------------
# End of QualityControl1_FastQCpre.sh script
# -------------------------------------------------------------------------
