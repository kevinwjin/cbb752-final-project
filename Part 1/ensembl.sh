#!/bin/bash
#SBATCH --output em.out
#SBATCH --job-name variant_calling
#SBATCH --requeue
#SBATCH -c 8 --mem-per-cpu=10G --time=01:00:00

# module load ensembldb/2.28.0
module load VEP/112-GCC-12.2.0
module load BCFtools/1.21-GCC-12.2.0


file="/home/lz568/project/final/Z.variantCall.SNPs.vcf"
new_file="/home/lz568/project/final/file.vcf.gz"

bgzip -c $file > file.vcf.gz

bcftools index $new_file

# filtering only the chromosome 22 variants and storing it in a new file
bcftools view -r 22 file.vcf.gz -Oz -o chr22.vcf.gz

bcftools index chr22.vcf.gz


# generate a folder to store downloaded files
mkdir -p ~/.vep

# Downloading cache file with respective version (Homo sapiens and GRCh37)
perl /vast/palmer/apps/avx2/software/VEP/112.0-GCC-12.2.0/INSTALL.pl \
  --AUTO c \
  --SPECIES homo_sapiens \
  --ASSEMBLY GRCh37 \
  --CACHE_VERSION 112 \
  --DEST ~/.vep

# Calling the ENSEMBL-VEP command 
vep -i chr22.vcf.gz -o chr22_annotated.vcf --vcf --cache --offline --assembly GRCh37 --everything --fasta /ycga-gpfs/datasets/genomes/Homo_sapiens/Ensembl/GRCh37/Sequence/WholeGenomeFasta/genome.fa
