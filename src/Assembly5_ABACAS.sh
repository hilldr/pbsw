#!/bin/sh

# ---------------------------------------------------------------------------
# Script:       Assembly5_ABACAS.sh
# Written by:   Cieza RJ
# Purpose:      Orient contigs against a reference genome
# ---------------------------------------------------------------------------

# ABACAS (v 1.3.1):
# -----
# Ordering contigs against a reference genome
# http://abacas.sourceforge.net/

# DIR tree
# --------
# Script DIR structure
# Script should be run from the DIR src within a PROJECT

#  .
#  ├── bin
#  |   └── ABACAS
#  ├── projects
#  |   └── NEC
#  |       ├── data
#  |       ├── results
#  |       |   ├── ABACAS
#  |       |   └── SPAdes
#  |       └── src
#  └── reference
#      └── Ecoli_HS


# ---------------------------------------------------------------------------
# (1) Set up job environment for ABACAS
# ---------------------------------------------------------------------------
#   (a) Export PATH for ABACAS executable (.pl)
export PATH=$PATH:../../../bin/ABACAS/

#   (b) Define 'abacas.pl' variable
ABACAS=../../../bin/ABACAS/abacas.1.3.1.pl


# ---------------------------------------------------------------------------
# (2) Verify that ABACAS can be executed
# ---------------------------------------------------------------------------
perl $ABACAS


# ---------------------------------------------------------------------------
# (3) Define Reference Genome
# ---------------------------------------------------------------------------
# Reference Genome used:  Escherichia coli HS (ASM1776v1)
# fna file:               ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/017/765/GCF_000017765.1_ASM1776v1/GCF_000017765.1_ASM1776v1_genomic.fna.gz

# Download genome into DIR reference
#   (a) Within DIR reference
#   (b) mkdir Ecoli_HS
#   (c) cd Ecoli_HS
#   (d) Download FASTA format of the genomic sequence(s) in the assembly.
#       # wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/017/765/GCF_000017765.1_ASM1776v1/GCF_000017765.1_ASM1776v1_genomic.fna.gz
#       # gunzip GCF_000017765.1_ASM1776v1_genomic.fna.gz

# Reference variables
REF_FNA=../../../reference/Ecoli_HS/GCF_000017765.1_ASM1776v1_genomic.fna


# ---------------------------------------------------------------------------
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


# ---------------------------------------------------------------------------
# (5) Run ABACAS & create a DIR to deposit the results for EACH strain
# ---------------------------------------------------------------------------
for strain in $STRAIN_NAME
do

  # (a) Define DIRNAME
  DIRNAME=${strain##*/}

  # (b) Define input file
  # Use 'contigs.fasta' file
  Contigs=../results/$DIRNAME/SPAdes/$DIRNAME\_contigs.fasta

  # (c) Define output file name
  contigs_ordered=$DIRNAME\_contigs_ordered

  # (d) Define output DIR
  Output_DIR=../results/$DIRNAME/ABACAS

  # (e) Make DIR to deposit the results
  mkdir -p $Output_DIR

  # (f) Run ABACAS:
  # PARAMETERS:
  # ----------
  # -r:     Reference sequence in a single fasta file
  # -q:     Contigs in a multi-fasta format
  # -p:     MUMmer program to use: 'nucmer' or 'promer'
  # -d:     Increase mapping sensitivity
  # -s:     Minimum length of exact matching word (nucmer default)
  # -b:     Contigs that are not used in generating the pseudomolecule will be placed in a '.bin' file
  # -a:     Append contigs that re not used to the end of the pseudomolecule
  # -o:     Output files will have this prefix
  perl $ABACAS \
  -r $REF_FNA \
  -q $Contigs \
  -p nucmer \
  -d \
  -s \
  -b \
  -a \
  -o $contigs_ordered

  # (g) Append the strain name to ABACAS output file
  # Rename 'unused_contigs.out' file
  # contigs that have a mapping information but could not be used in the ordering
  mv \
  unused_contigs.out \
  $DIRNAME\_unused_contigs.out

  # (h) Move ABACAS output files into output DIR ABACAS (for each strain)
  mv \
  $DIRNAME\_* \
  $Output_DIR

  # (i) Remove unused files
  rm nucmer.delta
  rm nucmer.filtered.delta
  rm nucmer.tiling

  echo 'loop complete'

done


# ---------------------------------------------------------------------------
# End of Assembly5_ABACAS.sh script
# ---------------------------------------------------------------------------
