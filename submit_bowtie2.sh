#!/bin/bash

# input lists of references and fastas with their full paths, one on each line
assembly_list=/path/to/tsv/of/indexed/assemblies.tsv
fasta_list=/path/to/tsv/of/fastq/files.tsv
script=/path/to/script/bowtie2.sh


while IFS= read -r ref_path; do
    [[ -z "$ref_path" ]] && continue
    ref_accession=$(basename "$ref_path")
    while IFS= read -r fastq_path; do
        [[ -z "$fastq_path" ]] && continue
        fastq_file=$(basename "$fastq_path")
        echo "Submitting $fastq_file against reference $ref_accession"
        job_id=$(sbatch --parsable "$script" "$ref_path" "$fastq_path")
        echo "Submitted job $job_id for $fastq_file against reference $ref_accession"
        sleep 1
    done < <(cat "$fasta_list")
done < <(cat "$assembly_list")

echo "All jobs submitted."

# make executable: chmod +x submit_bowtie2.sh
# run: ./submit_bowtie2.sh
