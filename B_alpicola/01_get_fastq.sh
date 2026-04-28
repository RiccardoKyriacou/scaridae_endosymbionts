#!/bin/bash -l

#SBATCH --job-name=sra-toolkit
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16gb
#SBATCH --export=ALL
#SBATCH --time=3-00:00:00
#SBATCH --partition=ac3-compute
#SBATCH --output=sra-toolkit.%j.log
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=s2673271@ed.ac.uk

hostname
set -e

source /home/s2673271/miniforge3/etc/profile.d/conda.sh     
conda activate /home/s2673271/miniforge3/envs/genomics

WORKDIR=/mnt/loki/ross/flies/sciaridae/endosymbiont_project/B_alpicola/outputs/fastq
mkdir -p $WORKDIR
cd $WORKDIR

export TMPDIR=$WORKDIR/tmp
mkdir -p $TMPDIR

for srr in SRR32323337 SRR32323338 SRR32323339; do
    echo "downloading $srr .."
    fasterq-dump $srr \
        --split-files \
        --threads 8 \
        --outdir $WORKDIR \
        --temp $TMPDIR
    pigz -p 8 $srr*.fastq
done

echo "Concatenating paired libraries..."
cat \
  SRR32323337_1.fastq.gz \
  SRR32323338_1.fastq.gz \
  SRR32323339_1.fastq.gz \
  > combined_R1.fastq.gz

cat \
  SRR32323337_2.fastq.gz \
  SRR32323338_2.fastq.gz \
  SRR32323339_2.fastq.gz \
  > combined_R2.fastq.gz

echo "Combined R1 reads:" $(( $(zcat combined_R1.fastq.gz | wc -l) / 4 ))
echo "Combined R2 reads:" $(( $(zcat combined_R2.fastq.gz | wc -l) / 4 ))
