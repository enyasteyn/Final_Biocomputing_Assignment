# Bio Computing Assignment Workflow
This project implements a reproducible bioinformatics workflow. This pipeline includes building a container, using nextflow for read trimming, alignment, and variant calling. Variants were queried on Intergrative Genomics Viewer (IGV), a structured variant database was created using sqlite3 and files were pulled from cmd.

# Container
For this workflow, I created a container for trimmomatic using singularity. A singularity definition file ('trimmomatic.def') was created, which includes the required labels, environment setup, and installation of trimmomatic.

The container was then built using:

singularity build --fakeroot trimmomatic.sif trimmomatic.def

# Nextflow Pipeline
The workflow is implemented using nextflow and consists of the following steps:
1. Quality Control using FastQC to assess the raw read quality. The output was a html file.
2. Read trimming using Trimmomatic to remove any low-quality reads and adapters. Container was included in the nextflow.config to integrate it into the workflow.
3. Sequence alignment using BWA-MEM against the reference genome.
4. Conversion and sorting using samtools to produce sorted BAM files.
5. Variant Calling using BCFTOOLS_CALL to generate raw variant calls in bcf format.
6. Variant Filtering using CALL_VAR to produce high-quality SNPs in vcf format.

# Confirm efficient Variant Calling
A random SNP was selected from the vcf file.

Bam file and .bai file was uploaded to IGV to visualise the vcf file as well as the genome file.

The following visualisation was seen on IGV:
<img width="1565" height="693" alt="image" src="https://github.com/user-attachments/assets/9e0f3b1c-7ef5-4417-b632-513815a7df28" />

