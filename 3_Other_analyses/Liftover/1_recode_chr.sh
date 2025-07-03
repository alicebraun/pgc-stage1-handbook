#!/bin/bash
#SBATCH --job-name=bcf_rename         # Name of the job
#SBATCH --output=bcf_rename_%A_%a.log # Output log file, includes array and task IDs
#SBATCH --error=bcf_rename_%A_%a.err  # Error log file, includes array and task IDs
#SBATCH --time=12:00:00               # Time limit (format: HH:MM:SS)
#SBATCH --cpus-per-task=16            # Number of CPUs per task
#SBATCH --mem=10G                     # Memory per task
#SBATCH --array=1-22                  # Array job for chromosomes 1 to 22

# Load the necessary modules 
module load 2023
module load BCFtools/1.18-GCC-12.3.0

# Navigate to the working directory on pgcdrc
cd /gpfs/work5/0/pgcdac/DWFV2CJb8Piv_0116_pgc_data/pgcdrc/scz/working/HRC1.1_hg38/all_chromosomes_input || exit 1

# Get the chromosome number from the SLURM_ARRAY_TASK_ID
CHR=${SLURM_ARRAY_TASK_ID}

# Create a symbolic link to the chromosome VCF file
ln -s /gpfs/work5/0/pgcdac/DWFV2CJb8Piv_0116_pgc_data/HRC_reference.r1-1/HRC.r1-1.EGA.GRCh37.chr${CHR}.haplotypes.vcf.gz || exit 1

# Index the VCF file if it does not already exist
if [ ! -f HRC.r1-1.EGA.GRCh37.chr${CHR}.haplotypes.vcf.gz.csi ]; then
    bcftools index --threads 16 HRC.r1-1.EGA.GRCh37.chr${CHR}.haplotypes.vcf.gz
fi

# Prepare the chromosome name conversion file
echo -e "${CHR}\tchr${CHR}" > chr_name_conv.txt

# Run BCFtools to add "chr" prefix to chromosome names
bcftools annotate --threads 16 --rename-chrs chr_name_conv.txt \
    HRC.r1-1.EGA.GRCh37.chr${CHR}.haplotypes.vcf.gz \
    -Oz -o HRC.r1-1.EGA.GRCh37.chr${CHR}.haplotypes.prefix.vcf.gz || exit 1

# Index the newly created VCF file
bcftools index --threads 16 HRC.r1-1.EGA.GRCh37.chr${CHR}.haplotypes.prefix.vcf.gz

# Clean up the chromosome name conversion file
rm -f chr_name_conv.txt
