#!/bin/sh

# ---------------------------------------------------------------------------
# Script:       QualityControl2_MultiQC.sh
# Written by:   Cieza RJ
# Purpose:      Summary statistics from FastQC (Pre-Trimmomatic)
# ---------------------------------------------------------------------------

# MultiQC (v 1.0.dev0)
# -----
# Reporting tool that parses summary statistics of various tools
# http://multiqc.info/docs/#using-multiqc

# DIR tree
# --------
# Script DIR structure
# Script should be run from the DIR src within a PROJECT

#  .
#  └── projects
#      └── NEC
#          ├── data
#          ├── results
#          |   ├── FastQC (Temporary DIR)
#          |   ├── MultiQC
#          |   └── QC
#          |       └── Pre
#          └── src


# ---------------------------------------------------------------------------
# (1) Set up job environment for MultiQC
# ---------------------------------------------------------------------------
# No further action is required
# MultiQC should have already been installed through Conda (view README)


# ---------------------------------------------------------------------------
# (2) Generate a list of the strains present in the DIR data
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
# (3) Create a DIR to deposit all the FastQC reports (Pre-Trimmomatic)
# ---------------------------------------------------------------------------
# (a) Make DIR
mkdir -p ../results/FastQC/

# (b) Define DIR variable
FastQC_pre=../results/FastQC/

# ---------------------------------------------------------------------------
# (4) Transfer FastQC reports ('.zip') to DIR FastQC
# ---------------------------------------------------------------------------
for strain in $STRAIN_NAME
do
    
  # (a) Define DIRNAME
  DIRNAME=${strain##*/}
  
  # (b) Define input file
  PreQC=../results/$DIRNAME/QC/Pre/*zip

  # (c) Output DIR
  FastQC_pre=../results/FastQC/

  # test if PreQC reports are present and copy to output dir if present
  if [ -f $PreQC ];
  then
      # (d) Copy file
      # Copy FastQC ('.zip') reports
      cp \
	  $PreQC \
	  $FastQC_pre
  else
      echo "No FastQC report available in $PreQC" >&2
  fi

done


# ---------------------------------------------------------------------------
# (5) Create a DIR to deposit MultiQC report (FastQC)
# ---------------------------------------------------------------------------
mkdir -p ../results/MultiQC/


# ---------------------------------------------------------------------------
# (6) Run MultiQC on DIR FastQC
# ---------------------------------------------------------------------------
# (a) Input DIR
FastQC_pre=../results/FastQC/

# (b) Define MultiQC output DIR
MultiQC=../results/MultiQC/

# (c) Define MultiQC output file name
Report_name=MultiQC_FastQC_Pre

# (d) Run MultiQC
# PARAMETERS:
# -----------
# --module:     Use only this module
# --outdir:     Create report in the specified output directory
# --filename:   Report filename
multiqc \
    --module fastqc \
    --outdir $MultiQC \
    --filename $Report_name \
    $FastQC_pre


# ---------------------------------------------------------------------------
# (7) Remove temporarily created DIR FastQC
# ---------------------------------------------------------------------------
if [ -d $FastQC_pre ];
  then
      rm -R $FastQC_pre
fi

if [ -d $MultiQC$Report_name\_data ];
  then
      rm -R $MultiQC$Report_name\_data
fi


# ---------------------------------------------------------------------------
# (8) Remove DIR QC/Pre/
# ---------------------------------------------------------------------------
# DIR QC/Pre/ contains FastQC reports (Pre)
# DIR QC/Pre/ is not needed anymore after MultiQC

for strain in $STRAIN_NAME
do

  # (a) Define DIRNAME
  DIRNAME=${strain##*/}

  # (b) Remove DIR QC/Pre/
  if [ -d ../results/$DIRNAME/QC/Pre/ ];
     then
     rm -R ../results/$DIRNAME/QC/Pre/
  fi

done


# ---------------------------------------------------------------------------
# End of QualityControl2_MultiQC.sh script
# ---------------------------------------------------------------------------
