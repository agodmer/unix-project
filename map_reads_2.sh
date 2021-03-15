#!/bin/bash

#SBATCH --array=0-29
#SBATCH --cpus-per-task=10
#SBATCH --mem=1G

module load bowtie2/2.4.1 samtools/1.10

reference_index="/shared/projects/dubii2021/trainers/module1/project/genome/sars-cov-2"
file_path="/shared/projects/dubii2021/trainers/module1/project/fastq/09"

file_list=(${file_path}/*_1.fastq.gz)
file_id=$(basename -s _1.fastq.gz "${file_list[$SLURM_ARRAY_TASK_ID]}")

echo "Accession: ${file_id}"
echo "R1: ${file_path}/${file_id}_1.fastq.gz"
echo "R2: ${file_path}/${file_id}_2.fastq.gz"

srun -J "${file_id} bowtie2" bowtie2 --threads=${SLURM_CPUS_PER_TASK} -x "${reference_index}" -1 "${file_path}/${file_id}_1.fastq.gz" -2 "${file_path}/${file_id}_2.fastq.gz" -S "${file_id}.sam"

srun -J "${file_id} filter" samtools view -hbS -q 30 -o "${file_id}.filtered.bam" "${file_id}.sam"

srun -J "${file_id} sort" samtools sort -o "${file_id}.bam" "${file_id}.filtered.bam"

rm -f "${file_id}.sam" "${file_id}.filtered.bam"
