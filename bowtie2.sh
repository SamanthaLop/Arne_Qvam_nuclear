#!/bin/bash -l

#SBATCH -A PROJECT
#SBATCH -p shared
#SBATCH -t 12:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=20GB
#SBATCH -J bowtie2
#SBATCH -e /path/to/error/dir/%x-%j.error
#SBATCH -o /path/to/out/dir/%x-%j.out
#SBATCH --mail-user=email@address.com
#SBATCH --mail-type=FAIL

ml Bowtie2/2.5.4-GCC-13.3.0
ml SAMtools/1.21-GCC-13.3.0

# if ref not yet indexed:
# ref_dir="/path/to/ref/assemblies/dir"
# assembly="assembly_ID"
# input_ref_assembly="${ref_dir}/${assembly}_masked.fna"
# bowtie2-build --threads 8 "$input_ref_assembly" "${ref_dir}/$(basename "$input_ref_assembly" .fna)"

indexed_ref_path=$1
input_fasta_path=$2

$ref_name=$(basename "$indexed_ref_path")
$sample_name=$(basename "$input_fasta_path" _merged.rm_low_complex.fastq.gz)

# enter working dir
cd /path/for/bams

# run bowtie2, use rg-id and rg flags to keep sample name in SM info, so that if the bams are merged at a later stage, it is still possible to subset them again by sample name
bowtie2 --very-sensitive -p 8 -x "$indexed_ref_path" -U "$input_fasta_path" --rg-id "$sample_name" --rg "SM:$sample_name" | samtools view -b -F 4 -@ 8 -o "${sample_name}_${ref_name}_mcmasked_comfil_mapped.bam" - 

if [ $? -ne 0 ]; then
    echo "Bowtie2 mapping failed for $sample_name against $ref_name. Exiting."
    exit 1
fi

# sort, index, markdup
samtools sort -@ 8 -o "${sample_name}_${ref_name}_mcmasked_comfil_mapped_sorted.bam" "${sample_name}_${ref_name}_mcmasked_comfil_mapped.bam"
samtools index -@ 8 "${sample_name}_${ref_name}_mcmasked_comfil_mapped_sorted.bam"
samtools markdup "${sample_name}_${ref_name}_mcmasked_comfil_mapped_sorted.bam" "${sample_name}_${ref_name}_mcmasked_comfil_mapped_sorted_dedup.bam"
samtools index -@ 8 "${sample_name}_${ref_name}_mcmasked_comfil_mapped_sorted_dedup.bam"

# get depth
samtools depth -@ 8 "${sample_name}_${ref_name}_mcmasked_comfil_mapped_sorted_dedup.bam" > "${sample_name}_${ref_name}_depth.txt"
gzip "${sample_name}_${ref_name}_depth.txt"

# rm intermediate files
rm "${sample_name}_${ref_name}_mcmasked_comfil_mapped.bam"
rm "${sample_name}_${ref_name}_mcmasked_comfil_mapped_sorted.bam"
rm "${sample_name}_${ref_name}_mcmasked_comfil_mapped_sorted.bam.bai"

echo "Bowtie2 mapping of $sample_name against masked $ref_name completed."
