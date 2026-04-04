# Bio Computing Assignment Workflow
This project implements a reproducible bioinformatics workflow. This pipeline includes building a container, using nextflow for read trimming, alignment, and variant calling. Variants were validated on Integrative Genomics Viewer (IGV), and a structured variant database was created using sqlite3.

# Container
For this workflow, I created a container for TRIMMOMATIC using singularity. A singularity definition file ('trimmomatic.def') was created, which includes the required labels, environment setup, and installation of TRIMMOMATIC.

The container was then built using:

singularity build --fakeroot trimmomatic.sif trimmomatic.def

# Nextflow Pipeline
The workflow was implemented using nextflow and consists of the following steps:
1. Quality Control using FastQC to assess the raw read quality. The output was a html file.
2. Read trimming using TRIMMOMATIC to remove any low-quality reads and adapters. Container was included in the nextflow.config to integrate it into the workflow.
3. Sequence alignment using BWA-MEM against the reference genome.
4. Conversion and sorting using samtools to produce sorted BAM files.
5. Variant Calling using BCFTOOLS_CALL to generate raw variant calls in bcf format.
6. Variant Filtering using CALL_VAR to produce high-quality single nucleotide polymorphisms (SNPs) in vcf format.

The pipeline was implemented using:

 ./nextflow run -profile local main.nf

# Variant Validation
To confirm the accuracy of the variant calling step, a random SNP from the vcf file was selected and visualised using IGV.

The BAM file, along with its index (.bai) and the reference genome (chr19), were loaded in IGV.

The following visualisation was seen on IGV:
<img width="1565" height="693" alt="image" src="https://github.com/user-attachments/assets/9e0f3b1c-7ef5-4417-b632-513815a7df28" />
**Figure 1:** IGV visualisation of a SNP on chromosome 19 at position 5,461,428.

At the genomic position 5,461,428, a clear SNP was observed, highlighted in red. This variation shows the reference base, T, changing to a C.
Multiple aligned reads consistently display this alternate base at the same position, supporting the accuracy and reliability of the variant call.

# Structured variant database
A sqlite3 database was created and called variants.db.

The variants table was created using the following fields:

chromosome TEXT - Chromosome identifier

position INTEGER - SNP location on the chromosome

ref_allele TEXT - Reference genomic base

alt_allele TEXT - Alternate base from vcf file

quality REAL - Phred score

The vcf file was converted to a tsv file to extract the data and store it in the database using the following commands:

bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%QUAL\n' variants.vcf > variants.tsv

.mode tab

.import variants.tsv variants

# Usage
This workflow was executed using provided data and reference files.
