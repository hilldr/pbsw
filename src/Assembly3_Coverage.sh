#!/bin/sh

# ---------------------------------------------------------------------------
# Script:       Assembly3_CoverageCalculation.sh
# Written by:   Cieza RJ
# Purpose:      Coverage Calculation
# ---------------------------------------------------------------------------

# Fastq-info
# -----
# Bash script to generate information for 1 or 2 fastq files (paired-end Illumina data)
# https://github.com/raymondkiu/fastq-info

# DIR tree
# --------
# Script DIR structure
# Script should be run from the DIR src within a PROJECT

#  .
#  ├── bin
#  |   └── fastq-info
#  └── projects
#      └── NEC
#          ├── data
#          ├── results
#          |   ├── SPAdes
#          |   └── MultiQC
#          └── src


# ---------------------------------------------------------------------------
# (1) Set up job environment for Fastq-info
# ---------------------------------------------------------------------------
#   (a) Export PATH for Fastq-info executable (.sh)
export PATH=$PATH:../../../bin/fastq-info/

#   (b) Define 'fastq-info.sh' variable
FastqInfo=../../../bin/fastq-info/./fastq_info_3.sh


# ---------------------------------------------------------------------------
# (2) Verify Fastq-info executable
# ---------------------------------------------------------------------------
echo 'Run:' $FastqInfo


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
# (4) Create a DIR to deposit Fastq-info report
# ---------------------------------------------------------------------------
# (a) Make DIR
mkdir -p ../results/FastqInfo_report/


# ---------------------------------------------------------------------------
# (5) Run Fastq-info & deposit the results into DIR FastqInfo_report
# ---------------------------------------------------------------------------
# (a) Define output file
Info_report=../results/FastqInfo_report/coverage_report.tx

for strain in $STRAIN_NAME
do

  # (b) Define DIRNAME
  DIRNAME=${strain##*/}

  # (c) Define input files
  # Use Paired files from Trimmomatic
  TRIMM_STRAIN_NAME=$(find ../results/$DIRNAME/Trimm/ \
  -name '*_paired.fastq.gz' | \
  sed 's/\_R[1-2]_paired.fastq.gz//' | \
  sort -u)
  # Forward Paired
  R1P=$TRIMM_STRAIN_NAME\_R1_paired.fastq.gz
  # Reverse Paired
  R2P=$TRIMM_STRAIN_NAME\_R2_paired.fastq.gz
  # Assembly file (contigs.fasta)
  # Used to be able to calculate sequence coverage
  contigs=$(find ../results/$DIRNAME/SPAdes/$DIRNAME\_contigs.fasta)

  # (d) Run Fastq-info:
  $FastqInfo \
  $R1P \
  $R2P \
  $contigs \
  >> \
  $Info_report

  echo 'Running on:'
  echo 'Forward Read' $R1P
  echo 'Reverse Read' $R2P
  echo 'Contigs file' $contigs
  echo 'Loop complete'

done

# NR:   Number of records processed
awk \
'FNR == 1 {print}' \
$Info_report \
> Output.txt
awk \
'NR%2==0' \
$Info_report \
>> \
Output.txt


awk -F "\t" \
'{OFS = FS} {$1 = "$DIRNAME"; print}' \
$Info_report \
>> \
Output.txt

# ---------------------------------------------------------------------------
# End of Assembly1_SPAdes.sh script
# ---------------------------------------------------------------------------
