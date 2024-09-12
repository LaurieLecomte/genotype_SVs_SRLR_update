#!/bin/bash

# srun -p small - c 6 -J trim_reads_safoPUVx_001-21 -o log/trim_reads_safoPUVx_001-21_%j.log /bin/sh 01_scripts/trim_reads.sh safoPUVx_001-21 &
# parallel -a FILE -j 10 srun -p small - c 6 -J trim_reads_{} -o log/trim_reads_{}_%j.log /bin/sh 01_scripts/trim_reads.sh {} &

# VARIABLES
GENOME="03_genome/genome.fasta"
FASTQ_DIR="04_reads"

VCF_DIR="05_candidates"
INPUT_VCF="$VCF_DIR/raw/merged_SUPP2.ready.vcf"

GRAPH_DIR="06_graph"
INDEX_DIR="$GRAPH_DIR/index"
ALIGNED_DIR="$GRAPH_DIR/aligned"
SNARLS_DIR="$GRAPH_DIR/snarls"
PACKS_DIR="$GRAPH_DIR/packs"

CALLS_DIR="07_calls"
MERGED_DIR="08_merged"
FILT_DIR="09_filtered"

CANDS="$VCF_DIR/candidates/"$(basename -s .ready.vcf $INPUT_VCF)".candidates.vcf.gz"
INS_FA="$VCF_DIR/candidates/"$(basename -s .ready.vcf $INPUT_VCF)"_INS.fa"

CHRS="02_infos/chr_list.txt"

CPU=6

SAMPLE=$1


fastp -w $CPU -i 04_reads/raw/"$SAMPLE"_R1.fastq.gz -I 04_reads/raw/"$SAMPLE"_R2.fastq.gz -o 04_reads/"$SAMPLE"_1.trimmed.fastq.gz -O 04_reads/"$SAMPLE"_2.trimmed.fastq.gz -j 04_reads/reports/"$SAMPLE".json -h 04_reads/reports_"$SAMPLE".html