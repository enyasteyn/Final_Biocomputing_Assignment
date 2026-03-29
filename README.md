# Bio Computing Assignment Workflow
This project implements a reproducible bioinformatics workflow. This pipeline includes building a container, using nextflow for read trimming, alignment, and variant calling. Variants were queried on Intergrative Genomics Viewer (IGV), a structured variant database was created using sqlite3 and files were pulled from cmd.

# Container
For this workflow, I created a container for trimmomatic using singularity. A singularity definition file ('trimmomatic.def') was created, which includes the required labels, environment setup, and installation of trimmomatic.

The container was then built using:

singularity build --fakeroot trimmomatic.sif trimmomatic.def

# Nextflow Pipeline
The workflow is implemented using nextflow and consists of the following steps:
1. Quality Control using FastQC
2. Trimming using TRIMMOMATIC
3. Sequence alignment using BWA-MEM
4. Sorting using SAM-TO-BAM
5. 
