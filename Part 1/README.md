# Instructions for Part 1:

Given the germline variant call (VCF), find 10 genes on the chromosome you are assigned with
the highest mutational burden (i.e., number of mutations). List the genes and submit records of
the variants you identified in the prioritized genes in a file called gene_variants_chr{i}.vcf, where i
is the number of the chromosome your team is assigned. Example variant file name is
gene_variants_chr2.vcf. In your report, describe the steps you take to identify the variants in the
genes of interest. Make sure to mention any database or software tool you use. If you write your
own code, please make sure to include it in the final submission.
[Extra credit] Suggest an alternative approach (besides using the number of point mutations in
each gene) to prioritize 10 genes. These can include methods that rely on genomic mutations
(finding genes with more pathologically relevant mutations) or other information (scoring genes
using information other than variant counts). Please submit preliminary results of your alternative
approach in a supplementary PDF should you decide to work on the extra credit section.

## ANNOVAR Files



For Part 1 of our analysis, we utilized two approaches for variant calling, specifically ANNOVAR and ENSEMBL. Our first approach for variant calling involved using the Yale Center for Genomics VCF annotation pipeline using the ANNOVAR reference sequence.

1) conda create -n hts_env -c bioconda htslib -y
Creates a small Conda environment named hts_env and installs the htslib package, which provides the two command-line utilities you’ll need next: bgzip (block gzip) and tabix (indexer for BGZF files). Run this only once.

2) conda activate hts_env
Turns that environment on so bgzip and tabix are now in your $PATH. Add this line to every new login session before you work with VCFs.

3) cd /gpfs/gibbs/project/yso_3/CBB_Project
Move into the working directory that holds YCGApipelines folder containing the YCGA RMS scripts and Z.variantCall.SNPs.vcf (your raw variants). You can download and transfer the pipeline scripts from GitHub.

4) bgzip -c Z.variantCall.SNPs.vcf > Z.variantCall.SNPs.vcf.gz
Re-compresses the plain VCF with BGZF. Tabix (and the YCGA pipeline) require this special block-gzip format; ordinary gzip is not sufficient for random access.

5) tabix -p vcf Z.variantCall.SNPs.vcf.gz
Generates the companion file Z.variantCall.SNPs.vcf.gz.tbi. This index lets software pull out individual chromosomes or positions instantly instead of scanning the whole file.

6) rms -n day ./YCGApipelines/vcfAnnotate.rms -19 Z.variantCall.SNPs.vcf.gz
rms is the Run-My-Samples engine.
• -n day tells RMS to submit jobs to McCleary’s day partition.
• ./YCGApipelines/vcfAnnotate.rms is the YCGA pipeline that adds functional and population annotations.
• -19 selects hg19/GRCh37 reference datasets (you can use -38 for GRCh38).
• The final argument is the BGZF-compressed, indexed VCF you just created.
(Add -r immediately after “rms -n day” if you ever need a hard restart that deletes old results and regenerates all scripts.)

Result files will be coding and noncoding SNP’s annotated when the pipeline finishes.

Z.variantCall.SNPs_anno.coding.xls
Z.variantCall.SNPs_anno.noncoding.xls


## ENSEMBL Files:

* ensemble.sh
* top_variants_ensembl.txt (top variants)

Our second approach used the ENSEMBL Variant Effect Predictor (VEP), which determines the effects of variants (SNPs, insertions, deletions, CNVs, or structural changes). Within this approach, a new VCF file (“chr22_vcf.gz”)  has been generated from the original VCF file to keep only chromosome 22 variants using the BCFtools package, which will be used as the input file for ENSEMBL VEP. The ENSEMBL VEP tool was run using the following key options:

--- cache: to utilize the local ENSEMBL annotation cache for efficient processing
--- pick: to return only the most biologically relevant annotation per variant, based on an internal priority system
--- fasta: to ensure consistent annotation with the genome build by specifying the reference genome FASTA file for GRCh37

Before using VEP, a cache file was downloaded for the species of interest since the cache option results in optimal performance compared to connecting to the public Ensembl database servers. VEP was run using the Genome Reference Consortium Human Build 37 (GRCh37) as reference, resulting in the annotated VCF file being utilized as the genome build. The output file (“chr22_annotated.vcf”), included the consequences of each variant in the INFO field.

To refine the variant list, we performed several post-processing steps using BFCtools and Unix shell commands:
Selection of rows where the FILTER field equals PASS to retain high-confidence variants
Extraction of the CSQ field from the INFO column to retrieve the annotated gene symbols
Used the uniq -c command to count gene frequencies
Sorted list in descending order by mutation count
Excluded non-protein-coding genes from the top results

ENSEMBL VEP was run on Yale Center for Research Computing under the McCleary cluster, therefore, it is a bash script located in the Github repository.


## Extra Credit Portion:

Variant‑Filtering Criteria

Molecular consequence – include only non‑synonymous changes

CADD conservation > 15 – retain variants in the top ≈5 % most evolutionarily conserved bases.

SIFT‑4G – keep calls D (deleterious) or . (no score).

PolyPhen‑2 HumVar – keep calls D (probably damaging), P (possibly damaging), or . (no score).


