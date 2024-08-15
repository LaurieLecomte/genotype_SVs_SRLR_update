#!/bin/bash

# Filter and format input VCF prior to building genome graph index

# manitou
# srun -c 25 -p large -J 02_construct --mem=400G -o log/02_construct_%j.log /bin/sh ./01_scripts/02_construct.sh &


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

CPU=25

# Build graph from vcf input
#vg construct --vcf $CANDS --insertions $INS_FA --reference $GENOME --flat-alts --handle-sv --alt-paths --threads $CPU --progress > $GRAPH_DIR/graph.vg # -v -I -r -f -S -a # not used

REGIONS=$(less $CHRS | while read CHR; do echo "--region $CHR"; done)
#vg construct --vcf $CANDS --insertions $INS_FA --reference $GENOME --flat-alts --handle-sv --alt-paths --threads $CPU $REGIONS --region-is-chrom --progress > $GRAPH_DIR/graph_regions.vg # -v -I -r -f -S -a -t -R -R ... -C
### the -R ... -R and -C (--region-is-chrom) are required to restrict graph to main chromosomes only

# Index
## # create an XG index (-L option must be used)
## vg index whole-genome.vg -L -x whole-genome.xg 
#vg index $GRAPH_DIR/graph.vg --xg-alts --xg-name $GRAPH_DIR/graph.xg --temp-dir tmp --threads $CPU --progress # -L -x -g -b -t -p
vg index $GRAPH_DIR/graph.vg --xg-alts --gcsa-out $GRAPH_DIR/graph.gcsa --temp-dir tmp --threads $CPU --progress

#vg index $GRAPH_DIR/graph_regions.vg --xg-alts --xg-name $GRAPH_DIR/graph_regions.xg --temp-dir tmp --threads $CPU --progress #
vg index $GRAPH_DIR/graph_regions.vg --xg-alts --gcsa-out $GRAPH_DIR/graph_regions.gcsa --temp-dir tmp --threads $CPU --progress

#vg index $GRAPH_DIR/graph.vg --xg-alts --xg-name $GRAPH_DIR/graph_z.xg --temp-dir tmp --threads $CPU --progress --actual-phasing
#vg index $GRAPH_DIR/graph_regions.vg --xg-alts --xg-name $GRAPH_DIR/graph_regions_z.xg --temp-dir tmp --threads $CPU --progress --actual-phasing # -L -x -b -t -p -z # gives same output as without -z (--actual-phasing)
### the -z option yields same output as without -z -> so vg never attempted to phase unphased genotypes 


# Snarls
#vg snarls $GRAPH_DIR/graph.vg --threads $CPU > $SNARLS_DIR/snarls.pb
vg snarls $GRAPH_DIR/graph_regions.vg --threads $CPU > $SNARLS_DIR/snarls_regions.pb

# won't use these 
#vg snarls $GRAPH_DIR/graph.vg --vcf $CANDS --fasta $GENOME --ins-fasta $INS_FA --threads $CPU --traversals > $SNARLS_DIR/snarls_vfi.pb # -v -f -i -t
#vg snarls $GRAPH_DIR/graph_regions.vg -vcf $CANDS --fasta $GENOME --ins-fasta $INS_FA --threads $CPU > $SNARLS_DIR/snarls_regions_vfi.pb