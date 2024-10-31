#!/bin/bash

# Filter and format input VCF prior to building genome graph index

# manitou
# srun -c 10 -p medium --time 7-00:00 -J 02_construct --mem=400G -o log/02_construct_%j.log /bin/sh ./01_scripts/02_construct.sh &


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

CPU=10



# To use mpmap
REGIONS=$(less $CHRS | while read CHR; do echo "--region $CHR"; done)
#vg construct --vcf $CANDS --insertions $INS_FA --reference $GENOME --flat-alts --handle-sv --alt-paths --threads $CPU $REGIONS --region-is-chrom --progress > $GRAPH_DIR/graph_regions.vg

#vg index $GRAPH_DIR/graph_regions.vg --xg-alts --xg-name $GRAPH_DIR/graph_regions.xg --temp-dir tmp --threads $CPU --progress --size-limit 2000 #
#vg index $GRAPH_DIR/graph_regions.vg --xg-alts --gcsa-out $GRAPH_DIR/graph_regions.gcsa --temp-dir tmp --threads $CPU --progress --size-limit 2000 # 

#vg snarls --include-trivial $GRAPH_DIR/graph_regions.xg --vcf $CANDS --ins-fasta $INS_FA --fasta $GENOME --threads $CPU > $SNARLS_DIR/graph_regions_trivial.snarls



# To use map
#vg construct --vcf $CANDS --insertions $INS_FA --reference $GENOME --flat-alts --handle-sv --alt-paths --threads $CPU $REGIONS --region-is-chrom --progress > $GRAPH_DIR/graph_regions.vg
#vg index $GRAPH_DIR/graph_regions.vg --xg-alts --xg-name $GRAPH_DIR/graph_regions.xg --temp-dir tmp --threads $CPU --progress --size-limit 2000 #

#vg prune --restore-paths --progress --threads $CPU $GRAPH_DIR/graph_regions.vg > $GRAPH_DIR/graph_regions.pruned.vg
vg prune --prune --progress --threads $CPU $GRAPH_DIR/graph_regions.vg > $GRAPH_DIR/graph_regions.prunedP.vg

#vg index $GRAPH_DIR/graph_regions.pruned.vg --xg-alts --gcsa-out $GRAPH_DIR/graph_regions.pruned.gcsa --temp-dir tmp --threads $CPU --progress --size-limit 2000 # 
vg index $GRAPH_DIR/graph_regions.prunedP.vg --xg-alts --gcsa-out $GRAPH_DIR/graph_regions.prunedP.gcsa --temp-dir tmp --threads $CPU --progress --size-limit 2000 # 


# Build graph from vcf input
#vg construct --vcf $CANDS --insertions $INS_FA --reference $GENOME --flat-alts --handle-sv --alt-paths --threads $CPU --progress > $GRAPH_DIR/graph.vg # -v -I -r -f -S -a # not used

REGIONS=$(less $CHRS | while read CHR; do echo "--region $CHR"; done)
#vg construct --vcf $CANDS --insertions $INS_FA --reference $GENOME --flat-alts --handle-sv --alt-paths --threads $CPU $REGIONS --region-is-chrom --progress > $GRAPH_DIR/graph_regions.vg # -v -I -r -f -S -a -t -R -R ... -C
### the -R ... -R and -C (--region-is-chrom) are required to restrict graph to main chromosomes only

# Index
## # create an XG index (-L option must be used)
## vg index whole-genome.vg -L -x whole-genome.xg 
#vg index $GRAPH_DIR/graph.vg --xg-alts --xg-name $GRAPH_DIR/graph.xg --temp-dir tmp --threads $CPU --progress --size-limit 2000 # -L -x -g -b -t -p
#vg index $GRAPH_DIR/graph.vg --xg-alts --gcsa-out $GRAPH_DIR/graph.gcsa --temp-dir tmp --threads $CPU --progress --size-limit 2000 # -L -x -g -b -t -p -Z ## it worked!
# -Z, --size-limit N     limit temporary disk space usage to N gigabytes (default 2048)

###vg index $GRAPH_DIR/graph_regions.vg --xg-alts --xg-name $GRAPH_DIR/graph_regions.xg --temp-dir tmp --threads $CPU --progress --size-limit 2000 #
###vg index $GRAPH_DIR/graph_regions.vg --xg-alts --gcsa-out $GRAPH_DIR/graph_regions.gcsa --temp-dir tmp --threads $CPU --progress --size-limit 2000 # 
#vg index $GRAPH_DIR/graph_regions.vg --xg-alts --dist-name $GRAPH_DIR/graph_regions.dist --temp-dir tmp --threads $CPU --progress --size-limit 2000 # # to try with vg map

# try with pruning
#vg prune $GRAPH_DIR/graph.vg --restore-paths --threads $CPU --progress > $GRAPH_DIR/graph_pruned.vg # -r -t -p # not tried
#vg index $GRAPH_DIR/graph_pruned.vg --gcsa-out $GRAPH_DIR/graph_pruned.gcsa --temp-dir tmp --threads $CPU --progress #not tried yet
# These won't be used becauxe -z had no impact
#vg index $GRAPH_DIR/graph.vg --xg-alts --xg-name $GRAPH_DIR/graph_z.xg --temp-dir tmp --threads $CPU --progress --actual-phasing
#vg index $GRAPH_DIR/graph_regions.vg --xg-alts --xg-name $GRAPH_DIR/graph_regions_z.xg --temp-dir tmp --threads $CPU --progress --actual-phasing # -L -x -b -t -p -z # gives same output as without -z (--actual-phasing)
### the -z option yields same output as without -z -> so vg never attempted to phase unphased genotypes 


# Snarls
#vg snarls $GRAPH_DIR/graph.vg --threads $CPU > $SNARLS_DIR/snarls.pb
###vg snarls $GRAPH_DIR/graph_regions.vg --threads $CPU > $SNARLS_DIR/snarls_regions.pb
#vg snarls $GRAPH_DIR/graph_regions.vg --threads $CPU --fasta $GENOME > $SNARLS_DIR/snarls_regions_wGenome.pb # not different from previous line

# won't use these 
#vg snarls $GRAPH_DIR/graph.vg --vcf $CANDS --fasta $GENOME --ins-fasta $INS_FA --threads $CPU --traversals > $SNARLS_DIR/snarls_vfi.pb # -v -f -i -t
#vg snarls $GRAPH_DIR/graph_regions.vg -vcf $CANDS --fasta $GENOME --ins-fasta $INS_FA --threads $CPU > $SNARLS_DIR/snarls_regions_vfi.pb