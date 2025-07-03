#!/bin/bash
#SBATCH --job-name=ensembl_ref         # Name of the job
#SBATCH --output=logs/ensembl_ref_%A_%a.log  # Output log file in logs directory
#SBATCH --error=logs/ensembl_ref_%A_%a.err   # Error log file in logs directory
#SBATCH --time=6:00:00                # Time limit (format: HH:MM:SS)
#SBATCH --cpus-per-task=16            # Number of CPUs per task
#SBATCH --mem=16G                     # Memory per task
#SBATCH --array=1-21                  # Array job for chromosomes 1 to 21 (22 was excluded intentionally)

# Navigate to the working directory on pgcdrc
cd /gpfs/work5/0/pgcdac/DWFV2CJb8Piv_0116_pgc_data/pgcdrc/scz/working/HRC1.1_hg38/ensembl || exit 1

# Load the necessary modules 
module load 2023
module load Java/17.0.6

# Get the chromosome number from the SLURM_ARRAY_TASK_ID
CHR=${SLURM_ARRAY_TASK_ID}

# Download the chromosome-specific reference file from Ensembl
wget -q https://ftp.ensembl.org/pub/release-113/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.chromosome.${CHR}.fa.gz

# Decompress the downloaded file
gunzip -f Homo_sapiens.GRCh38.dna.chromosome.${CHR}.fa.gz

# Define the reference file name 
REFERENCE_FASTA="Homo_sapiens.GRCh38.dna.chromosome.${CHR}.fa"

# Create a sequence dictionary using Picard
java -jar ../software/picard.jar CreateSequenceDictionary \
      R=${REFERENCE_FASTA} \
      O=${REFERENCE_FASTA}.dict
