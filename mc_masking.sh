#!/bin/bash -l

#SBATCH -A PROJECT
#SBATCH -p shared
#SBATCH -t 02:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=2GB
#SBATCH -J mc_mask
#SBATCH -e /path/to/error/dir/%x-%j.error
#SBATCH -o /path/to/out/dir/%x-%j.out
#SBATCH --mail-user=email@address.com
#SBATCH --mail-type=FAIL

# script to filter out microbial-like regions from a fasta file using the coordinates from MCworkflow

ml bedtools/2.31.0 samtools/1.20

bed_file_dir="/path/to/bed/files"
# set the fasta file path you wish to filter, uncompressed
input_fasta="/path/to/fasta_file.fna"
fasta_filename=$(basename $input_fasta .fna)
output_fasta_dir="/path/to/masked_ref_fastas"
# path to fai file from fasta that will be filtered, obtain this with samtools faidx file.fasta
fai_file="/path/to/fasta_file.fna.fai"

# convert coordinates txt file from MCworkflow to bed file
coords_file="coords_from_mcworkflow.fna.txt"
coords_file_name=$(basename "$coords_file" .fna.txt)

if [ ! -f "$bed_file_dir/$coords_file" ]; then
  echo "Error: Coords file not found: $bed_file_dir/$coords_file"
  exit 1
fi

# Mapping file
map_file="/tmp/contig_map_${coords_file_name}.txt"
awk -F'\t' '{short=$1; gsub(/.*\|/, "", short); print short "\t" $1}' "$fai_file" > "$map_file"

# Convert MCWorkflow coords to BED with lookup table
bed_file="${bed_file_dir}/${coords_file_name}_MCworkflow.bed"
awk -v OFS='\t' 'NR==FNR {map[$1]=$2; next} NR>1 && $2 in map {print map[$2], $3-1, $4}' "$map_file" "$bed_file_dir/$coords_file" > "$bed_file"
echo "Converted MCWorkflow coords to BED format: $bed_file"

if [ ! -s "$bed_file" ]; then
  echo "Error: BED file is empty!"
  head -n 5 "$map_file"
  echo "---"
  head -n 5 "$bed_file_dir/$coords_file"
  exit 1
fi

# masking step
maskfasta -fi "$input_fasta" -bed "$bed_file" -fo "$output_fasta_dir/${fasta_filename}_masked.fna"
echo "Masked FASTA created: $output_fasta_dir/${fasta_filename}_masked.fna"

rm "$map_file"
