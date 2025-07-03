#!/bin/bash
#SBATCH --job-name=picard_liftover        
#SBATCH --output=logs/picard_liftover_%A_%a.log  # Output log file in logs directory
#SBATCH --error=logs/picard_liftover_%A_%a.err   # Error log file in logs directory
#SBATCH --time=12:00:00               # Time limit (format: HH:MM:SS)
#SBATCH --cpus-per-task=16            # Number of CPUs per task
#SBATCH --mem=120G                     # Memory per task
#SBATCH --array=1-21                  # Array job for chromosomes 1 to 21 (22 was done as a test)

# Create logs directory if it doesn't exist
mkdir -p logs

# Navigate to the working directory on pgcdrc
cd /gpfs/work5/0/pgcdac/DWFV2CJb8Piv_0116_pgc_data/pgcdrc/scz/working/HRC1.1_hg38/ || exit 1

# Load the necessary modules 
module load 2023
module load Java/17.0.6

# Get the chromosome number from the SLURM_ARRAY_TASK_ID
CHR=${SLURM_ARRAY_TASK_ID}

# Verify SLURM_ARRAY_TASK_ID is set
if [[ -z "${CHR}" ]]; then
    echo "Error: SLURM_ARRAY_TASK_ID is not set." >&2
    exit 1
fi

# Define the reference genome and reject file names
REFERENCE_FASTA=ensembl/Homo_sapiens.GRCh38.dna.chromosome.${CHR}.fa
REJECT=HRC.GRCh38.chr${CHR}.ensembl.rejected.vcf.gz

# Run the Picard LiftoverVcf command with memory increase -Xmx100g
java -Xmx100g -jar software/picard.jar LiftoverVcf \
     I=all_chromosomes_input/HRC.r1-1.EGA.GRCh37.chr${CHR}.haplotypes.prefix.vcf.gz \
     O=all_chromosomes_output/HRC.r1-1.EGA.GRCh38.ensembl.chr${CHR}.haplotypes.vcf.gz \
     CHAIN=ensembl/GRCh37_to_GRCh38.chain \
     REJECT=${REJECT} \
     R=${REFERENCE_FASTA} \
     RECOVER_SWAPPED_REF_ALT=true \
     MAX_RECORDS_IN_RAM=5000 \
     WARN_ON_MISSING_CONTIG=true \
     WRITE_ORIGINAL_POSITION=true || {
         echo "Error: LiftoverVcf failed for chromosome ${CHR}" >&2
         exit 1
     }
