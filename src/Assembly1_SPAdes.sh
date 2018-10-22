#!/bin/sh

# ---------------------------------------------------------------------------
# Script:       Assembly1_SPAdes.sh
# Written by:   Cieza RJ
# Purpose:      Genome assembly with SPAdes
# ---------------------------------------------------------------------------

# SPAdes (v 3.12.0)
# ------
# Genome assembly algorithm / toolkit containing various assembly pipelines
# http://cab.spbu.ru/files/release3.12.0/manual.html

# DIR tree
# --------
# Script DIR structure
# Script should be run from the DIR src within a PROJECT

#  .
#  ├── bin
#  |   └── SPAdes-3.12.0-Linux
#  |        └── bin
#  └── projects
#      └── NEC
#          ├── data
#          ├── results
#          |   ├── SPAdes
#          |   └── Trimm
#          └── src


# ---------------------------------------------------------------------------
# (1) Set up job environment for SPAdes
# ---------------------------------------------------------------------------
#   (a) Export PATH for SPAdes binaries and executable (.py)
export PATH=$PATH:../../../bin/SPAdes-3.12.0-Linux/
export PATH=$PATH:../../../bin/SPAdes-3.12.0-Linux/bin/

#   (b) Define 'spades.py' variable
SPAdes=../../../bin/SPAdes-3.12.0-Linux/bin/./spades.py


# ---------------------------------------------------------------------------
# (2) Verify that SPAdes can be executed
# ---------------------------------------------------------------------------
$SPAdes -h


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
# (4) Run SPAdes & create a DIR to deposit the results for EACH strain
# ---------------------------------------------------------------------------
for strain in $STRAIN_NAME
do

  # (a) Define DIRNAME
  DIRNAME=${strain##*/}

  # (b) Define input files
  # Use Paired & Unpaired files from Trimmomatic
  TRIMM_STRAIN_NAME=$(find ../results/$DIRNAME/Trimm/ \
  -name '*_paired.fastq.gz' | \
  sed 's/\_R[1-2]_paired.fastq.gz//' | \
  sort -u)
  # Forward Paired
  R1P=$TRIMM_STRAIN_NAME\_R1_paired.fastq.gz
  # Forward Unpaired
  R1U=$TRIMM_STRAIN_NAME\_R1_unpaired.fastq.gz
  # Reverse Paired
  R2P=$TRIMM_STRAIN_NAME\_R2_paired.fastq.gz
  # Reverse Unpaired
  R2U=$TRIMM_STRAIN_NAME\_R2_unpaired.fastq.gz

  # (c) Define the output DIR and files
  Assembly=../results/$DIRNAME/SPAdes/

  # (d) Make a DIR to deposit the results
  mkdir -p $Assembly

  # (e) Run SPAdes:
  # PARAMETERS:
  # ----------
  # -k:        k-mers to use:
  #            For multicell data sets:
  #            K values are automatically selected using maximum read length
  #            About effect of k-mer size:
  #            https://github.com/rrwick/Bandage/wiki/Effect-of-kmer-size
  # --threads: 8 (Adjust accordingly)
  # --careful: Reduce the number of mismatches and short indels
  # --pe-1:    Paired-end file with forward reads (R1)
  # --pe-2:    Paired-end file with reverse reads (R2)
  # -s:        Files with unpaired reads
  # ----------
  $SPAdes \
  --threads 8 \
  --careful \
  --pe1-1 $R1P \
  --pe1-2 $R2P \
  --pe1-s $R1U \
  --pe1-s $R2U \
  -o $Assembly

  # (f) Append the strain name to the assembly output files
  # Rename 'contigs.fasta' file
  # Contains resulting contigs
  mv \
  $Assembly/contigs.fasta \
  $Assembly/$DIRNAME\_contigs.fasta
  # Rename 'scaffolds.fasta' file
  # contains resulting scaffolds (recommended for use as resulting sequences)
  mv \
  $Assembly/scaffolds.fasta \
  $Assembly/$DIRNAME\_scaffolds.fasta
  # Rename 'assembly_graph.fastg' file
  # Contains SPAdes assembly graph in FASTG format
  mv \
  $Assembly/assembly_graph.fastg \
  $Assembly/$DIRNAME\_assembly_graph.fastg

  echo 'loop complete'

done


# ---------------------------------------------------------------------------
# End of Assembly1_SPAdes.sh script
# ---------------------------------------------------------------------------
