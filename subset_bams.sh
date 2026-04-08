#!/bin/bash -l

#SBATCH -A PROJECT
#SBATCH -p shared
#SBATCH -t 00:20:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=2GB
#SBATCH -J subset_bams
#SBATCH -e /path/to/error/dir/%x-%j.error
#SBATCH -o /path/to/out/dir/%x-%j.out
#SBATCH --mail-user=email@address.com
#SBATCH --mail-type=FAIL

ml SAMtools/1.21-GCC-13.3.0

# to filter for quality:
input_bam="/path/to/file.bam"
output_dir="/path/to/output/"
QUALITY=25
samtools view -@ 8 -b -h -q $QUALITY $input_bam -o "${output_dir}/$(basename $input_bam .bam)_mapq_${QUALITY}.bam"
samtools index "${output_dir}/$(basename $input_bam .bam)_mapq_${QUALITY}.bam"

# to filter using a bed file - like for example when removing microbial-like or repetitive regions:
input_bam="/path/to/file.bam"
output_dir="/path/to/output/"
bed_file="/path/to/file.bed"
output_bam="${output_dir}/$(basename $input_bam .bam)_bed_filtered.bam"
removed_bam="${output_dir}/$(basename $input_bam - bam)_bed_removed.bam"
samtools view -@ 8 -b -h -L $bed_file -o $removed_bam -U $output_bam $input_bam
samtoos index $output_bam

# you can see how many reads were removed by using flagstat on the removed bam:
# samtools flagstat $removed_bam > "${output_dir}/${removed_bam}.flagstat"
# rm $removed_bam

