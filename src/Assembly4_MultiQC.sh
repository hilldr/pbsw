#!/bin/sh

# ---------------------------------------------------------------------------
# Script:       Assembly4_MultiQC.sh
# Written by:   Cieza RJ
# Purpose:      Summary statistics from Assembly (QUAST)
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
#          |   ├── QUAST_report (Temporary DIR)
#          |   ├── QUAST
#          |   └── MultiQC
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
STRAIN_NAME=\
$(find ../data/ \
-name '*.fastq.gz' | \
sed 's/\_R[1-2].fastq.gz//' | \
sort -u)


# ---------------------------------------------------------------------------
# (3) Create a DIR to deposit all the QUAST reports
# ---------------------------------------------------------------------------
# (a) Make DIR
mkdir -p ../results/QUAST_report/

# (b) Define DIR variable
QUAST_report=../results/QUAST_report/


# ---------------------------------------------------------------------------
# (4) Transfer QUAST reports ('report.tsv') to DIR QUAST_report
# ---------------------------------------------------------------------------
for strain in $STRAIN_NAME
do

  # (a) Define DIRNAME
  DIRNAME=${strain##*/}

  # (b) Define input file
  report_tsv=../results/$DIRNAME/QUAST/$DIRNAME\_report.tsv

  # (c) Create a DIR for each sample into DIR QUAST_report
  mkdir -p $QUAST_report$DIRNAME/

  # (d) Define the output DIR
  QUAST_report_sample=$QUAST_report$DIRNAME/

  # (e) Copy file
  # Copy QUAST report ('report.tsv')
  cp \
  $report_tsv \
  $QUAST_report_sample

  # (e) Rename file
  # MultiQC only recognizes files named 'report.tsv'
  # Remove the sample name from 'report.tsv' file
  mv \
  $QUAST_report_sample$DIRNAME\_report.tsv \
  $QUAST_report_sample\report.tsv

  echo 'loop complete'

done


# ---------------------------------------------------------------------------
# (5) Create a DIR to deposit MultiQC report (QUAST)
# ---------------------------------------------------------------------------
mkdir -p ../results/MultiQC/


# ---------------------------------------------------------------------------
# (6) Run MultiQC on DIR QUAST_report
# ---------------------------------------------------------------------------
# (a) Input DIR
QUAST_report=../results/QUAST_report/

# (b) Define MultiQC output DIR
MultiQC=../results/MultiQC/

# (c) Define MultiQC output file name
Report_name=MultiQC_Assembly

# (d) Run MultiQC
# PARAMETERS:
# -----------
# --module:     Use only this module
# --outdir:     Create report in the specified output directory
# --filename:   Report filename
multiqc \
--module quast \
--outdir $MultiQC \
--filename $Report_name \
$QUAST_report


# ---------------------------------------------------------------------------
# (7) Remove temporarily created DIR QUAST_report
# ---------------------------------------------------------------------------
rm -R $QUAST_report
rm -R $MultiQC$Report_name\_data


# ---------------------------------------------------------------------------
# (8) Remove DIR QUAST
# ---------------------------------------------------------------------------
# DIR QUAST contains assembly reports
# DIR QUAST is not needed anymore after MultiQC

for strain in $STRAIN_NAME
do

  # (a) Define DIRNAME
  DIRNAME=${strain##*/}

  # (b) Remove DIR QUAST
  rm -R ../results/$DIRNAME/QUAST/

  echo 'loop complete'

done


# ---------------------------------------------------------------------------
# End of Assembly4_MultiQC.sh script
# ---------------------------------------------------------------------------
