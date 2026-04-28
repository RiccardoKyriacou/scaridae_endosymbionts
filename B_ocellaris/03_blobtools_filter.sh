#!/bin/bash -l

#SBATCH --job-name=blobtools2_filter
#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --export=ALL
#SBATCH --time=3-00:00:00
#SBATCH --partition=ac3-compute
#SBATCH --mem=32gb
#SBATCH --output=blobtools2_filter.%j.log
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=s2673271@ed.ac.uk

set -e
source /home/s2673271/miniforge3/etc/profile.d/conda.sh     
conda activate /home/s2673271/miniforge3/envs/blobtools2

###############################################################
# Output directory
###############################################################
OUTDIR=/mnt/loki/ross/flies/sciaridae/endosymbiont_project/B_ocellaris/outputs/blobtools/
mkdir -p $OUTDIR

BLOBDIR="/mnt/loki/ross/flies/sciaridae/endosymbiont_project/B_ocellaris/outputs/blobtools/Boce_blbodir"
ASM="/mnt/loki/ross/flies/sciaridae/endosymbiont_project/B_ocellaris/outputs/B_ocellaris_p_ctg.fa"

###############################################################
# Extract only bacterial contigs using blobtools2
###############################################################
for TAXON in Pseudomonadota Bacteroidota Actinomycetota; do
    blobtools filter \
      --param bestsumorder_phylum--Keys=$TAXON \
      --invert \
      --fasta ${ASM} \
      --output ${OUTDIR}/B_ocellaris_${TAXON}_blobdir \
      --suffix ${TAXON} \
      $BLOBDIR
done

echo "Done."
