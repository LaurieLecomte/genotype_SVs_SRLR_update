#!/bin/bash

# Re-map short reads to reference genome graph (giraffe), compute read support for variant sites (pack) and call genotypes (call). This is done independently for each sample, in parallel.

# manitou
# parallel -a 02_infos/ind_ALL.txt -j 4 srun -c 10 -p medium --time=7-00:00:00 --mem=100G -J 03_map_pack_call_{} -o log/03_map_pack_call_{}_%j.log /bin/sh ./01_scripts/03_map_pack_call.sh {} &

# parallel -a 02_infos/ind_ALL.txt -j 4 srun -c 10 -p medium --time=7-00:00:00 --mem=100G -J 03_map_pack_call_{} -o log/03_map_pack_call_{}_%j.log /bin/sh ./01_scripts/03_map_pack_call.sh {} &
# parallel -a 02_infos/ind_SRLR.txt -j 4 srun -c 10 -p medium --time=7-00:00:00 --mem=100G -J 03_map_pack_call_{} -o log/03_map_pack_call_{}_%j.log /bin/sh ./01_scripts/03_map_pack_call.sh {} &

# srun -c 10 -p medium --time=7-00:00:00 --mem=100G -J 03_map_pack_call_safoBEAs_021-21 -o log/03_map_pack_call_safoBEAs_021-21_%j.log /bin/sh ./01_scripts/03_map_pack_call.sh safoBEAs_021-21 &

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
MERGED_DIR="08_MERGED"
FILT_DIR="09_filtered"

CPU=10
MEM="100G"

#CANDIDATES_VCF="$VCF_DIR/candidates/"$(basename -s .ready.vcf $INPUT_VCF)".candidates.vcf.gz"

TMP_DIR="tmp"

CANDS="$VCF_DIR/candidates/"$(basename -s .ready.vcf $INPUT_VCF)".candidates.vcf.gz"
INS_FA="$VCF_DIR/candidates/"$(basename -s .ready.vcf $INPUT_VCF)"_INS.fa"

CHRS="02_infos/chr_list.txt"

CPU=10

SAMPLE=$1
FASTQ1="$FASTQ_DIR/"$SAMPLE"_1.trimmed.fastq.gz"
FASTQ2="$FASTQ_DIR/"$SAMPLE"_2.trimmed.fastq.gz" 



# vg map
vg map $GRAPH_DIR/graph.vg --xg-name $GRAPH_DIR/graph.xg -f $FASQ1 -f $FASTQ2 --sample $SAMPLE --threads $CPU --debug > $ALIGNED_DIR/"$SAMPLE".gam #-x -N (--sample) -t
#vg map --xg-name $GRAPH_DIR/graph_regions.xg -f $FASQ1 -f $FASTQ2 --sample $SAMPLE --threads $CPU > $ALIGNED_DIR/"$SAMPLE"_regions.gam

# vg pack
#vg pack --xg $GRAPH_DIR/graph.xg --gam $ALIGNED_DIR/"$SAMPLE".gam --min-mapq 5 --threads $CPU --packs-out $PACKS_DIR/"$SAMPLE".pack # -x -g -Q -t -o 
#vg pack --xg $GRAPH_DIR/graph_regions.xg --gam $ALIGNED_DIR/"$SAMPLE"_regions.gam --min-mapq 5 --threads $CPU --packs-out $PACKS_DIR/"$SAMPLE"_regions.pack

# vg call # vg call whole-genome.gbz -r whole-genome.snarls -k whole-genome.pack -s <sample> -v whole-genome-vars.vcf.gz > genotypes.vcf
#vg call $GRAPH_DIR/graph.xg --snarls $SNARLS_DIR/snarls.pb --pack $PACKS_DIR/"$SAMPLE".pack --vcf $CANDS --ins-fasta $INS_FA --sample $SAMPLE --threads $CPU --progress > $CALLS_DIR/raw/"$SAMPLE".vcf #-r -k -v -i -s -t  why not -f ?
#vg call $GRAPH_DIR/graph_regions.xg --snarls $SNARLS_DIR/snarls_regions.pb --pack $PACKS_DIR/"$SAMPLE"_regions.pack --vcf $CANDS --ins-fasta $INS_FA --sample $SAMPLE --threads $CPU --progress > $CALLS_DIR/raw/"$SAMPLE"_regions.vcf



# 1. Map paired short reads to the reference graph structure 
#echo "Aligning $FASTQ1 and $FASTQ2 for $SAMPLE"
#vg giraffe -t $CPU -x $INDEX_DIR/index.xg -Z $INDEX_DIR/index.giraffe.gbz -m $INDEX_DIR/index.min -d $INDEX_DIR/index.dist -f $FASTQ1 -f $FASTQ2 -N $SAMPLE -p > $ALIGNED_DIR/"$SAMPLE".gam
  
# 2. Pack the alignments
#echo "Packing loops for $SAMPLE"
#vg pack -t $CPU -Q 5 -x $INDEX_DIR/index.xg -g $ALIGNED_DIR/"$SAMPLE".gam -o $PACKS_DIR/"$SAMPLE".pack

# 3. Call
#echo "Calling genotypes for $SAMPLE"
#vg call -t $CPU -a $INDEX_DIR/index.xg -k $PACKS_DIR/"$SAMPLE".pack -r $SNARLS_DIR/snarls.pb -f $GENOME -s "$SAMPLE"  > $CALLS_DIR/raw/"$SAMPLE".vcf


