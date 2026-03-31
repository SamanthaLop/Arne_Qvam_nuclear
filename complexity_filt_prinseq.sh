#!/bin/bash -l

#SBATCH -A PROJECT
#SBATCH -p shared
#SBATCH -t 12:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=8GB
#SBATCH -J prinseq
#SBATCH -e /path/to/error/dir/%x-%j.error
#SBATCH -o /path/to/out/dir/%x-%j.out
#SBATCH --mail-user=email@address.com
#SBATCH --mail-type=FAIL

# input file (fastq, fasta)
file=$1

# set complexity method and threshold
COMPLEXITY_METHOD=dust                  # dust is the standard used by BLAST. The entropy method is an alternative, but is not widely used.
COMPLEXITY_THRESHOLD=4

echo "Filtering low complexity reads from $file using prinseq with ${COMPLEXITY_METHOD} method and threshold ${COMPLEXITY_THRESHOLD}..."

# set outdir and filename
output_dir="/path/to/out/dir"
filename=$(basename "$file" .fastq.gz)

zcat $file | prinseq-lite.pl -fastq stdin \
-out_good ${output_dir}/${filename}.rm_low_complex \
-lc_method ${COMPLEXITY_METHOD} -lc_threshold ${COMPLEXITY_THRESHOLD}

# compress output
gzip ${output_dir}/${filename}.rm_low_complex.fastq

# done file for troubleshooting
touch ${output_dir}/${filename}.complexity_filtered.done
