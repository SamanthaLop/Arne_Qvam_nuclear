#!/bin/bash -l

#SBATCH -A PROJECT
#SBATCH -p normal
#SBATCH -t 48:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=10GB
#SBATCH -J fastp
#SBATCH -e /path/to/error/dir/%x-%j.error
#SBATCH -o /path/to/out/dir/%x-%j.out
#SBATCH --mail-user=email@address.com
#SBATCH --mail-type=FAIL

ml R/4.4.2-gfbf-2024a
ml Bowtie2/2.5.4-GCC-13.3.0
ml SAMtools/1.21-GCC-13.3.0

# location of mc_dir
MC_dir="/path/to/MCWorkflow"
cd $MC_dir || { echo "Failed to change directory to: $MC_dir"; exit 1; }

# set input assembly name:
input_assembly=accession.1.fasta 

# to run with GTDB (note you need to have a file such as GTDB_sliced_seqs_sliding_window.fna in MC_dir
./micr_cont_detect.sh $input_assembly /path/to/MCWorkflow/data GTDB 8 GTDB_sliced_seqs_sliding_window.fna 10


