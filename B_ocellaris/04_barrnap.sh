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
WORKDIR=/mnt/loki/ross/flies/sciaridae/endosymbiont_project/B_ocellaris/outputs/
cd $WORKDIR
OUTDIR=/mnt/loki/ross/flies/sciaridae/endosymbiont_project/B_ocellaris/outputs/barrnap
mkdir -p $OUTDIR
mkdir -p ${OUTDIR}/{Actinomycetota,Pseudomonadota,Bacteroidota}

echo "Starting barrnap rRNA scans..."
###############################################################
# 1) Actinomycetota
###############################################################
echo "Running barrnap on Actinomycetota"

barrnap --kingdom bac \
  --threads 8 \
  --outseq ${OUTDIR}/Actinomycetota/16s.fasta \
  B_ocellaris_p_ctg.B_ocellaris_Actinomycetota.fa \
  > ${OUTDIR}/Actinomycetota/16s.gff

echo "Actinomycetota finished"

###############################################################
# 2) Pseudomonadota_highGC_lowCov
###############################################################
echo "Running barrnap on Pseudomonadota"

barrnap --kingdom bac \
  --threads 8 \
  --outseq ${OUTDIR}/Pseudomonadota/16s.fasta \
 B_ocellaris_p_ctg.B_ocellaris_Pseudomonadota.fa \
  > ${OUTDIR}/Pseudomonadota/16s.gff

echo "Pseudomonadota finished"

###############################################################
# 3) Pseudomonadota_lowGC_highCov
###############################################################
echo "Running barrnap on Bacteroidota"

barrnap --kingdom bac \
  --threads 8 \
  --outseq ${OUTDIR}/Bacteroidota/16s.fasta \
  B_ocellaris_p_ctg.B_ocellaris_Bacteroidota.fa \
  > ${OUTDIR}/Bacteroidota/16s.gff

echo "Bacteroidota finished"

echo "All barrnap runs completed successfully."
