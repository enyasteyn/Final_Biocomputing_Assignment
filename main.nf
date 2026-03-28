#!/usr/bin/env nextflow

process FASTQC {                                                            

publishDir "${params.outdir}/fastqc", mode: 'copy', overwrite: false            

input:                                                                       
tuple val(id), path (reads)
output:
path "*.html"                                                                                                                                       

script:                                                                     
"""
fastqc -t 2 ${reads[0]} ${reads[1]}

"""
}

process TRIMMOMATIC {
 
  container "${projectDir}/containers/trimmomatic.sif"

  publishDir "${params.outdir}/trim", mode: 'copy', overwrite: false

  input:
    tuple val(id), path(reads)

  output:
    tuple val(id),
          path("${id}_R1_paired.fastq.gz"),
          path("${id}_R2_paired.fastq.gz"),
          emit: trim_fq

  script:
  """
 trimmomatic PE \
      -threads 2 \
      -phred33 \
      ${reads[0]} ${reads[1]} \
      ${id}_R1_paired.fastq.gz ${id}_R1_unpaired.fastq.gz \
      ${id}_R2_paired.fastq.gz ${id}_R2_unpaired.fastq.gz \
      ILLUMINACLIP:/opt/Trimmomatic-0.39/adapters/TruSeq3-PE.fa:2:30:10 \
      LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
  """
}


process BWA {
 publishDir "${params.outdir}/bwa", mode: 'copy', overwrite: true
 
 input:
    tuple val(id), path(read1), path(read2)
 output:
    tuple val(id), path("${id}.sam*"), emit: bwa_sam
 script:
 """
  bwa mem -t 2 ${params.chr19} ${read1} ${read2} > ${id}.sam
 """
}

process SAMTOBAM {

  publishDir "${params.outdir}/samtobam", mode: 'copy', overwrite: false

  input:
    tuple val(id), path(sam)

  output:
    tuple val(id), path("${id}.bam"), emit: bam_align

  script:
  """
samtools view -b $sam > ${id}.unsorted.bam
samtools sort -m 500M -@ 2 ${id}.unsorted.bam -o ${id}.bam
samtools index ${id}.bam
"""
}
process BCFTOOLS_CALL {
   publishDir "${params.outdir}/bcf", mode: 'copy', overwrite: false
   input:
     tuple val(id), path(bam)

   output:
      tuple val(id), path("${id}.bcf"), emit: call_bcf

   script:
    """
    bcftools mpileup -Ou -f $params.chr19 $bam | bcftools call -mv -Ob -o ${id}.bcf
    """
}


process CALLVAR {

    publishDir "${params.outdir}/callvar", mode: 'copy', overwrite: false

    input:
        tuple val(id), path(call_bcf)

    output:
        tuple val(id), path("${id}.vcf"), emit: filtered_vcf

    script:
    """
    bcftools view -i 'QUAL>100 && DP>50' -v snps $call_bcf -Ov -o ${id}.vcf
    """

}

workflow {
  def fastq = Channel.fromFilePairs(params.fastq)
  def genome = Channel.fromPath(params.chr19Folder)

  TRIMMOMATIC(fastq)
  BWA(TRIMMOMATIC.out.trim_fq)
  SAMTOBAM(BWA.out.bwa_sam)
  BCFTOOLS_CALL(SAMTOBAM.out.bam_align)
  CALLVAR(BCFTOOLS_CALL.out.call_bcf)

} 
