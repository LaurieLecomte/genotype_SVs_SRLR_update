#!/bin/bash

# Re-align reads to the graph and call SV genotypes

# parallel -a 02_infos/ind_SRLR.txt -j 4 srun -c 10 -p medium --time=7-00:00:00 --mem=100G -J 03_align_pack_call_{} -o log/03_map_pack_call_{}_%j.log /bin/sh ./01_scripts/03_align_pack_call.sh {} &

# srun -c 10 -p medium --time=7-00:00:00 --mem=100G -J 03_align_pack_call_safoBEAs_021-21 -o log/03_align_pack_call_safoBEAs_021-21_%j.log /bin/sh ./01_scripts/03_align_pack_call.sh safoBEAs_021-21 &

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
GIRAFFE_DIR="$GRAPH_DIR/giraffe_workflow"

CALLS_DIR="07_calls"
MERGED_DIR="08_MERGED"
FILT_DIR="09_filtered"


#CANDIDATES_VCF="$VCF_DIR/candidates/"$(basename -s .ready.vcf $INPUT_VCF)".candidates.vcf.gz"

TMP_DIR="tmp"

CANDS="$VCF_DIR/candidates/"$(basename -s .ready.vcf $INPUT_VCF)".candidates.vcf.gz"
INS_FA="$VCF_DIR/candidates/"$(basename -s .ready.vcf $INPUT_VCF)"_INS.fa"

CHRS="02_infos/chr_list.txt"

CPU=10

SAMPLE=$1
FASTQ1="$FASTQ_DIR/"$SAMPLE"_1.trimmed.fastq.gz"
FASTQ2="$FASTQ_DIR/"$SAMPLE"_2.trimmed.fastq.gz" 


# 1. Map trimmed reads to graph
vg giraffe --xg-name $GRAPH_DIR/graph_regions_giraffe.xg --gbz-name $INDEX_DIR/graph_regions_giraffe.gbz --dist-name $INDEX_DIR/graph_regions_giraffe.dist --minimizer-name $INDEX_DIR/graph_regions_giraffe.min -f $FASTQ1 -f $FASTQ2 -N $SAMPLE --threads $CPU > $ALIGNED_DIR/"$SAMPLE"_regions_giraffe.gam

# 2. Compute read support
vg pack --xg $GRAPH_DIR/graph_regions_giraffe.xg --gam $ALIGNED_DIR/"$SAMPLE"_regions_giraffe.gam --packs-out $PACKS_DIR/"$SAMPLE"_regions_giraffe.pack --min-mapq 5 --threads $CPU

# 3. Call SV genotypes
vg call  $GRAPH_DIR/graph_regions_giraffe.xg --pack $PACKS_DIR/"$SAMPLE"_regions_giraffe.pack --snarls $SNARLS_DIR/graph_regions_giraffe.pb --ref-fasta $GENOME --ins-fasta $INS_FA --sample "$SAMPLE" --threads $CPU --vcf $CANDS > $CALLS_DIR/raw/"$SAMPLE".vcf # --genotype-snarls does not keep SV info and genotypes less SVs

