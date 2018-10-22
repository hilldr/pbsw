#!/bin/sh

# ---------------------------------------------------------------------------
# Script:       Assembly2_QUAST.sh
# Written by:   Cieza RJ
# Purpose:      Evaluate genome assemblies with QUAST
# ---------------------------------------------------------------------------

# QUAST (v 5.0.0)
# -----
# Quality Assessment Tool for Genome Assemblies
# http://quast.bioinf.spbau.ru/manual.html#sec1

# DIR tree
# --------
# Script DIR structure
# Script should be run from the DIR src within a PROJECT

#  .
#  ├── projects
#  |   └── NEC
#  |       ├── data
#  |       ├── results
#  |       |   ├── QUAST
#  |       |   └── SPAdes
#  |       └── src
#  └── reference
#      └── Ecoli_HS


# ---------------------------------------------------------------------------
# (1) Set up job environment for QUAST
# ---------------------------------------------------------------------------
# No further action is required
# QUAST should have already been installed through Conda (view README)


# (2) Verify that QUAST can be executed
# ---------------------------------------------------------------------------
quast.py --help
# ---------------------------------------------------------------------------


# (3) Define Reference Genome
# ---------------------------------------------------------------------------
# Reference Genome used:  Escherichia coli HS (ASM1776v1)
# fna file:               ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/017/765/GCF_000017765.1_ASM1776v1/GCF_000017765.1_ASM1776v1_genomic.fna.gz
# gff file:               ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/017/765/GCF_000017765.1_ASM1776v1/GCF_000017765.1_ASM1776v1_genomic.gff.gz

# Download genome into DIR reference
#   (a) Within DIR reference
#   (b) mkdir Ecoli_HS
#   (c) cd Ecoli_HS
#   (d) Download FASTA format of the genomic sequence
#       # wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/017/765/GCF_000017765.1_ASM1776v1/GCF_000017765.1_ASM1776v1_genomic.fna.gz
#       # gunzip GCF_000017765.1_ASM1776v1_genomic.fna.gz
#   (e) Download annotation of the genomic sequences (GFF)
#       # wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/017/765/GCF_000017765.1_ASM1776v1/GCF_000017765.1_ASM1776v1_genomic.gff.gz
#       # gunzip GCF_000017765.1_ASM1776v1_genomic.gff.gz

# Reference variables
REF_FNA=../../../reference/Ecoli_HS/GCF_000017765.1_ASM1776v1_genomic.fna
REF_GFF=../../../reference/Ecoli_HS/GCF_000017765.1_ASM1776v1_genomic.gff


# (4) Generate a list of the strains present in the DIR data
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


# (5) Run QUAST & create a DIR to deposit the results for EACH strain
# ---------------------------------------------------------------------------
for strain in $STRAIN_NAME
do

  # (a) Define DIRNAME
  DIRNAME=${strain##*/}

  # (b) Define input file
  # Use scaffolds.fasta file
  Scaffolds=../results/$DIRNAME/SPAdes/$DIRNAME\_scaffolds.fasta

  # (c) Define the output varible
  Quast=../results/$DIRNAME/QUAST

  # (d) Make DIR to deposit the results
  mkdir -p $Quast

  # (e) Run QUAST:
  # PARAMETERS:
  # -----------
  # -o:     Output directory
  # -r:     Reference genome file FASTA
  # -g:     File with genomic feature coordinates in the reference
  # -t:     Number of threads (Adjust accordingly) / Run on High-Performance Computer (HPC) server
  # -l:     Names of assemblies to use in reports
  quast.py \
  -o $Quast \
  -r $REF_FNA \
  -g $REF_GFF \
  -t 8 \
  -l $DIRNAME \
  $Scaffolds

  # (f) Append the strain name to QUAST output files
  # Rename 'report.txt' file
  # Summary Table
  mv \
  $Quast/report.txt \
  $Quast/$DIRNAME\_report.txt
  # Rename 'report.html' file
  # Everything in an interactive HTML file
  mv \
  $Quast/report.html \
  $Quast/$DIRNAME\_report.html
  # Rename 'report.tsv' file
  # Tab-separated version, for parsing, or for spreadsheets
  mv \
  $Quast/report.tsv \
  $Quast/$DIRNAME\_report.tsv
  # Rename 'icarus.html' file
  # Icarus main menu with links to interactive viewers
  mv \
  $Quast/icarus.html \
  $Quast/$DIRNAME\_icarus.html

  echo 'loop complete'

done


# ---------------------------------------------------------------------------
# End of Assembly2_QUAST.sh script
# ---------------------------------------------------------------------------
