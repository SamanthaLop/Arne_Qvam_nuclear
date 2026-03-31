#!/bin/bash -l

#SBATCH -A PROJECT
#SBATCH -p shared
#SBATCH -t 08:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem=20GB
#SBATCH -J fastp
#SBATCH -e /path/to/error/dir/%x-%j.error
#SBATCH -o /path/to/out/dir/%x-%j.out
#SBATCH --mail-user=email@address.com
#SBATCH --mail-type=FAIL

ml fastp/1.0.1-GCC-13.3.0

# set input and output dirs
input_dir="/path/to/input/dir/"
output_dir="/path/to/output/dir/"

# sample name is given as input
sample=$1
echo "Processing sample: $sample"

# set r1 and r2 files
r1_file=$(find "$input_dir" -name "${sample}_*_R1.fastq.gz") 
r2_file=$(find "$input_dir" -name "${sample}_*_R2.fastq.gz") 

# set sample name
sample_name=$(basename "$r1_file" .fastq.gz)
echo "Sample name: $sample_name"

# check if files exist, otherwise exit job
if [[ -z "$r1_file" || -z "$r2_file" ]]; then
    echo "Error: Could not find fastq files for sample $sample, file $r1_file or $r2_file is missing."
    exit 1
fi

# run fastp
fastp -i "${r1_file}" \
      -I "${r2_file}" \
      --merged_out "${output_dir}${sample_name}_merged.fastq.gz" \
      --length_required 30 \
      --thread 16 \
      --merge \
      --json "${output_dir}${sample_name}_fastp.json" \
      --html "${output_dir}${sample_name}_fastp.html"

# can be run for several samples in parallel like this on bash:
# while read sample;
# do sbatch fastp.sh "$sample";
# done < list_of_sample_names.tsv
