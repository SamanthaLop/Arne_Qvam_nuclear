#!/bin/bash -l

#SBATCH -A PROJECT
#SBATCH -p shared
#SBATCH --cpus-per-task=4
#SBATCH --mem=2GB
#SBATCH -t 02:00:00
#SBATCH -J count_reads
#SBATCH -e /path/to/error/dir/%x-%j.error
#SBATCH -o /path/to/out/dir/%x-%j.out
#SBATCH --mail-user=email@address.com
#SBATCH --mail-type=FAIL

set -euo pipefail
shopt -s nullglob

# Takes a single fastq.gz file as input
fastq_file=$1

output_dir="/path/to/out_dir"

# Create output filename based on input
base_name=$(basename "$fastq_file" .fastq.gz)
out_file="${output_dir}/${base_name}.stats"

# Run seqkit stats on single file
seqkit-bin stats -T "$fastq_file" > "$out_file"

echo "Done! Stats written to $out_file"
