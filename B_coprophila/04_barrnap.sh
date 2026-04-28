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
WORKDIR=/mnt/loki/ross/flies/sciaridae/endosymbiont_project/B_coprophila/outputs/gtdb_inputs
cd $WORKDIR

echo "Starting barrnap rRNA scans..."

###############################################################
# 1) Actinomycetota
###############################################################
echo "Running barrnap on Actinomycetota"

barrnap --kingdom bac \
  --threads 8 \
  --outseq Actinomycetota/16s.fasta \
  Actinomycetota/B_coprophila_p_ctg.Actinomycetota.fna \
  > Actinomycetota/16s.gff

echo "Actinomycetota finished"

###############################################################
# 2) Pseudomonadota_highGC_lowCov
###############################################################
echo "Running barrnap on Pseudomonadota_highGC_lowCov"

barrnap --kingdom bac \
  --threads 8 \
  --outseq Pseudomonadota_highGC_lowCov/16s.fasta \
  Pseudomonadota_highGC_lowCov/B_coprophila_p_ctg.Pseudomonadota_highGC_lowCov.fna \
  > Pseudomonadota_highGC_lowCov/16s.gff

echo "Pseudomonadota_highGC_lowCov finished"

###############################################################
# 3) Pseudomonadota_lowGC_highCov
###############################################################
echo "Running barrnap on Pseudomonadota_lowGC_highCov"

barrnap --kingdom bac \
  --threads 8 \
  --outseq Pseudomonadota_lowGC_highCov/16s.fasta \
  Pseudomonadota_lowGC_highCov/B_coprophila_p_ctg.Pseudomonadota_lowGC_highCov.fna \
  > Pseudomonadota_lowGC_highCov/16s.gff

echo "Pseudomonadota_lowGC_highCov finished"

echo "All barrnap runs completed successfully."
