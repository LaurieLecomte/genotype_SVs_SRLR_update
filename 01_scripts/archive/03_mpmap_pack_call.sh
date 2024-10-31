#!/bin/bash

# Re-map short reads to reference genome graph (giraffe), compute read support for variant sites (pack) and call genotypes (call). This is done independently for each sample, in parallel.

# manitou
# parallel -a 02_infos/ind_ALL.txt -j 4 srun -c 10 -p medium --time=7-00:00:00 --mem=100G -J 03_mpmap_pack_call_{} -o log/03_mpmap_pack_call_{}_%j.log /bin/sh ./01_scripts/03_mpmap_pack_call.sh {} &

# parallel -a 02_infos/ind_ALL.txt -j 4 srun -c 10 -p medium --time=7-00:00:00 --mem=100G -J 03_mpmap_pack_call_{} -o log/03_mpmap_pack_call_{}_%j.log /bin/sh ./01_scripts/03_mpmap_pack_call.sh {} &
# parallel -a 02_infos/ind_SRLR.txt -j 4 srun -c 10 -p medium --time=7-00:00:00 --mem=100G -J 03_mpmap_pack_call_{} -o log/03_mpmap_pack_call_{}_%j.log /bin/sh ./01_scripts/03_mpmap_pack_call.sh {} &

# srun -c 20 -p medium --time=7-00:00:00 --mem=100G -J 03_mpmap_pack_call_safoBEAs_021-21 -o log/03_mpmap_pack_call_safoBEAs_021-21_%j.log /bin/sh ./01_scripts/03_mpmap_pack_call.sh safoBEAs_021-21 &
# srun -c 20 -p medium --time=7-00:00:00 --mem=100G -J 03_mpmap_pack_call_safoPUVx_001-21 -o log/03_mpmap_pack_call_safoPUVx_001-21_%j.log /bin/sh ./01_scripts/03_mpmap_pack_call.sh safoPUVx_001-21 &

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

CPU=20
MEM="100G"

#CANDIDATES_VCF="$VCF_DIR/candidates/"$(basename -s .ready.vcf $INPUT_VCF)".candidates.vcf.gz"

TMP_DIR="tmp"

CANDS="$VCF_DIR/candidates/"$(basename -s .ready.vcf $INPUT_VCF)".candidates.vcf.gz"
INS_FA="$VCF_DIR/candidates/"$(basename -s .ready.vcf $INPUT_VCF)"_INS.fa"

CHRS="02_infos/chr_list.txt"

CPU=20

SAMPLE=$1
FASTQ1="$FASTQ_DIR/"$SAMPLE"_1.trimmed.fastq.gz"
FASTQ2="$FASTQ_DIR/"$SAMPLE"_2.trimmed.fastq.gz" 


module load samtools/1.15





#vg mpmap --graph-name $GRAPH_DIR/graph_regions.xg --gcsa-name $GRAPH_DIR/graph_regions.gcsa --dist-name $GRAPH_DIR/graph_regions.dist --nt-type dna --fastq $FASTQ1 --fastq $FASTQ2 --threads $CPU --output-fmt GAM > $ALIGNED_DIR/"$SAMPLE"_mpmap_regions_wDist.gam ## too slow

vg mpmap --snarls $SNARLS_DIR/snarls_regions.pb --graph-name $GRAPH_DIR/graph_regions.xg --gcsa-name $GRAPH_DIR/graph_regions.gcsa --nt-type DNA -f $FASTQ1 -f $FASTQ2 --sample $SAMPLE --threads $CPU > $ALIGNED_DIR/"$SAMPLE"_mpmap_regions_wSnarls.gamp


#vg pack --xg $GRAPH_DIR/graph_regions.xg --gam $ALIGNED_DIR/"$SAMPLE"_mpmap_regions_trivial.gam --min-mapq 5 --threads $CPU --packs-out $PACKS_DIR/"$SAMPLE"_mpmap_regions_trivial.pack

#vg call $GRAPH_DIR/graph_regions.xg --snarls $SNARLS_DIR/graph_regions_trivial.snarls --pack $PACKS_DIR/"$SAMPLE"_mpmap_regions_trivial.pack --vcf $CANDS --ins-fasta $INS_FA --sample $SAMPLE --threads $CPU --progress > $CALLS_DIR/raw/"$SAMPLE"_mpmap_regions_trivial.vcf 


# vg map

#vg map $GRAPH_DIR/graph.vg --xg-name $GRAPH_DIR/graph.xg -f $FASTQ1 -f $FASTQ2 --sample $SAMPLE --threads $CPU --debug > $ALIGNED_DIR/"$SAMPLE".gam # does not work #-x -N (--sample) -t
# I am running this one on aug 19: vg map --xg-name $GRAPH_DIR/graph.xg --gcsa-name $GRAPH_DIR/graph.gcsa -f $FASTQ1 -f $FASTQ2 --sample $SAMPLE --threads $CPU --log-time > $ALIGNED_DIR/"$SAMPLE".gam #-x -N (--sample) -t
#vg mpmap --snarls $SNARLS_DIR/snarls.pb --graph-name $GRAPH_DIR/graph.xg --gcsa-name $GRAPH_DIR/graph.gcsa --nt-type DNA -f $FASTQ1 -f $FASTQ2 --sample $SAMPLE --threads $CPU  > $ALIGNED_DIR/"$SAMPLE"_mpmap.gamp 
#vg view -K -G $ALIGNED_DIR/"$SAMPLE"_mpmap.gamp --threads $CPU > $ALIGNED_DIR/"$SAMPLE"_mpmap.gam

#vg mpmap --snarls $SNARLS_DIR/snarls_regions.pb --graph-name $GRAPH_DIR/graph_regions.xg --gcsa-name $GRAPH_DIR/graph_regions.gcsa --nt-type DNA -f $FASTQ1 -f $FASTQ2 --sample $SAMPLE --threads $CPU > $ALIGNED_DIR/"$SAMPLE"_mpmap_regions.gamp # done
#vg view -K -G $ALIGNED_DIR/"$SAMPLE"_mpmap_regions.gamp --threads $CPU > $ALIGNED_DIR/"$SAMPLE"_mpmap_regions.gam # done

#vg map --base-name $GRAPH_DIR/graph_regions -f $FASTQ1 -f $FASTQ2 --sample $SAMPLE --threads $CPU --log-time > $ALIGNED_DIR/"$SAMPLE"_regions.gam

# vg pack
#vg pack --xg $GRAPH_DIR/graph.xg --gam $ALIGNED_DIR/"$SAMPLE".gam --min-mapq 5 --threads $CPU --packs-out $PACKS_DIR/"$SAMPLE".pack # -x -g -Q -t -o 
#vg pack --xg $GRAPH_DIR/graph_regions.xg --gam $ALIGNED_DIR/"$SAMPLE"_regions.gam --min-mapq 5 --threads $CPU --packs-out $PACKS_DIR/"$SAMPLE"_regions.pack

#vg pack --xg $GRAPH_DIR/graph_regions.xg --gam $ALIGNED_DIR/"$SAMPLE"_mpmap_regions.gam --min-mapq 5 --threads $CPU --packs-out $PACKS_DIR/"$SAMPLE"_mpmap_regions.pack

# vg call # vg call whole-genome.gbz -r whole-genome.snarls -k whole-genome.pack -s <sample> -v whole-genome-vars.vcf.gz > genotypes.vcf
#vg call $GRAPH_DIR/graph.xg --snarls $SNARLS_DIR/snarls.pb --pack $PACKS_DIR/"$SAMPLE".pack --vcf $CANDS --ins-fasta $INS_FA --sample $SAMPLE --threads $CPU --progress > $CALLS_DIR/raw/"$SAMPLE".vcf #-r -k -v -i -s -t  why not -f ?
#vg call $GRAPH_DIR/graph_regions.xg --snarls $SNARLS_DIR/snarls_regions.pb --pack $PACKS_DIR/"$SAMPLE"_regions.pack --vcf $CANDS --ins-fasta $INS_FA --sample $SAMPLE --threads $CPU --progress > $CALLS_DIR/raw/"$SAMPLE"_regions.vcf

###vg call $GRAPH_DIR/graph_regions.xg --snarls $SNARLS_DIR/snarls_regions.pb --pack $PACKS_DIR/"$SAMPLE"_mpmap_regions.pack --vcf $CANDS --ins-fasta $INS_FA --sample $SAMPLE --threads $CPU --progress > $CALLS_DIR/raw/"$SAMPLE"_mpmap_regions.vcf 



#vg surject $ALIGNED_DIR/"$SAMPLE"_mpmap_regions.gam --xg-name $GRAPH_DIR/graph_regions.xg --threads $CPU --bam-output > $ALIGNED_DIR/"$SAMPLE"_mpmap_regions.bam

#samtools sort $ALIGNED_DIR/"$SAMPLE"_mpmap_regions.bam -@ $CPU -o $ALIGNED_DIR/"$SAMPLE"_mpmap_regions.sorted.bam
#samtools index $ALIGNED_DIR/"$SAMPLE"_mpmap_regions.sorted.bam -@ $CPU




# 1. Map paired short reads to the reference graph structure 
#echo "Aligning $FASTQ1 and $FASTQ2 for $SAMPLE"
#vg giraffe -t $CPU -x $INDEX_DIR/index.xg -Z $INDEX_DIR/index.giraffe.gbz -m $INDEX_DIR/index.min -d $INDEX_DIR/index.dist -f $FASTQ1 -f $FASTQ2 -N $SAMPLE -p > $ALIGNED_DIR/"$SAMPLE".gam
  
# 2. Pack the alignments
#echo "Packing loops for $SAMPLE"
#vg pack -t $CPU -Q 5 -x $INDEX_DIR/index.xg -g $ALIGNED_DIR/"$SAMPLE".gam -o $PACKS_DIR/"$SAMPLE".pack

# 3. Call
#echo "Calling genotypes for $SAMPLE"
#vg call -t $CPU -a $INDEX_DIR/index.xg -k $PACKS_DIR/"$SAMPLE".pack -r $SNARLS_DIR/snarls.pb -f $GENOME -s "$SAMPLE"  > $CALLS_DIR/raw/"$SAMPLE".vcf


