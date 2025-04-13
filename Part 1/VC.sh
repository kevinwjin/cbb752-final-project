#!/bin/bash
#SBATCH --output VC.out
#SBATCH --job-name variant_calling
#SBATCH --requeue
#SBATCH -c 8 --mem-per-cpu=10G --time=24:00:00

# Using BCFTools to extract variants from chromosome of interest
module load BCFtools/1.21-GCC-12.2.0
# Use ANNOVAR to annotate the variants 
module load annovar/20200607-GCCcore-12.2.0-Perl-5.36.1
module load SAMtools/1.21-GCC-12.2.0

annoDB="/home/lz568/project/reference/annovar_ref/humandb"

file="/home/lz568/project/final/Z.variantCall.SNPs.vcf"
new_file="/home/lz568/project/final/file.vcf.gz"

# bgzip -c $file > file.vcf.gz

bcftools index $new_file

bcftools view -r 22 file.vcf.gz -Oz -o chr22.vcf.gz

bcftools index chr22.vcf.gz

convert2annovar.pl --includeinfo --allsample --withfreq --format vcf4 chr22.vcf.gz > chr22.avinput

table_annovar.pl chr22.avinput $annoDB \
-buildver hg38  --remove -protocol refGene,genomicSuperDups,dgvMerged,avsnp150,icgc28,clinvar_20220320,esp6500siv2_all,ALL.sites.2015_08,exac03,gnomad30_genome,dbnsfp41a \
-operation g,r,r,f,f,f,f,f,f,f,f -nastring NA -csvout
