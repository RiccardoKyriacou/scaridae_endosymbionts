#!/bin/bash -l

#SBATCH --job-name=barrnap
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --export=ALL
#SBATCH --time=3-00:00:00
#SBATCH --partition=ac3-compute
#SBATCH --mem=32gb
#SBATCH --output=barrnap.%j.log
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=s2673271@ed.ac.uk

hostname
set -e

source /home/s2673271/miniforge3/etc/profile.d/conda.sh
conda activate /home/s2673271/miniforge3/envs/genomics

###############################################################
# Paths
###############################################################
SPECIES=B_impatiens

ASM="/mnt/loki/ross/flies/sciaridae/Bradysia_impatiens/UK_Bimp_assembly/outputs/hifiasm/BimpUKG_nontriobinning_primary.fa"

OUTDIR=/mnt/loki/ross/flies/sciaridae/endosymbiont_project/${SPECIES}/outputs/barrnap
mkdir -p ${OUTDIR}

echo "Starting barrnap rRNA scans..."

barrnap --kingdom bac \
  --threads 8 \
  --outseq ${OUTDIR}/16s.fasta \
  $ASM \
  > ${OUTDIR}/16s.gff
  
echo "All barrnap runs completed successfully."
