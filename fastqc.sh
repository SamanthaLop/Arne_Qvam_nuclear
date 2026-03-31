#!/bin/bash -l

#SBATCH -A PROJECT
#SBATCH -p shared
#SBATCH -t 04:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=5GB
#SBATCH -J multiqc
#SBATCH -e /path/to/error/dir/%x-%j.error
#SBATCH -o /path/to/out/dir/%x-%j.out
#SBATCH --mail-user=email@address.com
#SBATCH --mail-type=FAIL

ml fastqc/0.12.1
ml multiqc/1.30

# input fastq file
fastq_file=$1

out_dir="/path/to/out_dir/fastqc/"

# run fastqc on the input fastq_file using 8 threads and placing output in out_dir
fastqc -o $out_dir -t 8 $fastq_file

# once run for all samples, run the following ONCE:
# out_dir_multiqc="/path/to/out_dir/multiqc/"
# input_dir=$out_dir
# multiqc -o $out_dir $input_dir

