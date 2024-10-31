#!/bin/bash

# Prepare required index and graph files for genotyping SVs using giraffe workflow


# srun -c 10 -p medium --time=7-00:00:00 --mem=300G -J 02_build_indexes_all_callers -o log/02_build_indexes_all_callers_%j.log /bin/sh ./01_scripts/02_build_indexes_all_callers.sh &

# VARIABLES 
GENOME="03_genome/genome.fasta"
FASTQ_DIR="04_reads"

VCF_DIR="05_candidates"
INPUT_VCF="$VCF_DIR/raw/merged_all_callers.ready.vcf"

GRAPH_DIR="06_graph"
INDEX_DIR="$GRAPH_DIR/index"
ALIGNED_DIR="$GRAPH_DIR/aligned"
SNARLS_DIR="$GRAPH_DIR/snarls"
PACKS_DIR="$GRAPH_DIR/packs"
GIRAFFE_DIR="$GRAPH_DIR/giraffe_workflow"

CALLS_DIR="07_calls"
MERGED_DIR="08_MERGED"
FILT_DIR="09_filtered"

#CPU=20
MEM="100G"

#CANDIDATES_VCF="$VCF_DIR/candidates/"$(basename -s .ready.vcf $INPUT_VCF)".candidates.vcf.gz"

TMP_DIR="tmp"

CANDS="$VCF_DIR/candidates/"$(basename -s .ready.vcf $INPUT_VCF)".candidates.vcf.gz"
INS_FA="$VCF_DIR/candidates/"$(basename -s .ready.vcf $INPUT_VCF)"_INS.fa"

CHRS="02_infos/chr_list.txt"

CPU=10


# 1. Construct base graph
REGIONS=$(less $CHRS | while read CHR; do echo "--region $CHR"; done)
vg construct --vcf $CANDS --insertions $INS_FA --reference $GENOME --handle-sv --alt-paths --threads $CPU $REGIONS --region-is-chrom --progress > $GRAPH_DIR/graph_regions_giraffe_all_callers.vg 

vg index $GRAPH_DIR/graph_regions_giraffe_all_callers.vg --xg-alts --xg-name $GRAPH_DIR/graph_regions_giraffe_all_callers.xg --temp-dir tmp --threads $CPU --progress --size-limit 3000 #done


# 2. Build required indexes
## gbwt 
vg index $GRAPH_DIR/graph_regions_giraffe_all_callers.vg --vcf-phasing $CANDS --gbwt-name $INDEX_DIR/graph_regions_giraffe_all_callers.gbwt --threads $CPU --size-limit 3000 --temp-dir tmp --progress

## gbz
vg gbwt --xg-name $GRAPH_DIR/graph_regions_giraffe_all_callers.xg $INDEX_DIR/graph_regions_giraffe_all_callers.gbwt --graph-name $INDEX_DIR/graph_regions_giraffe_all_callers.gbz --gbz-format --num-threads $CPU --temp-dir tmp

## dist
vg index $INDEX_DIR/graph_regions_giraffe_all_callers.gbz --dist-name $INDEX_DIR/graph_regions_giraffe_all_callers.dist --size-limit 3000 --temp-dir tmp --progress

## minimizer
vg minimizer $INDEX_DIR/graph_regions_giraffe_all_callers.gbz --distance-index $INDEX_DIR/graph_regions_giraffe_all_callers.dist --output-name $INDEX_DIR/graph_regions_giraffe_all_callers.min --threads $CPU 


# 3. Compute snarls
vg snarls $INDEX_DIR/graph_regions_giraffe_all_callers.gbz --threads $CPU --fasta $GENOME > $SNARLS_DIR/graph_regions_giraffe_all_callers.pb

