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
# Paths
###############################################################
OUTDIR=/mnt/loki/ross/flies/sciaridae/endosymbiont_project/B_coprophila/outputs/blobtools
mkdir -p $OUTDIR

BLOBDIR="${OUTDIR}/Bcop_blobdir"
ASM="${OUTDIR}/B_coprophila_p_ctg.fa"

###############################################################
# Actinomycetota (single species)
###############################################################
TAXON=Actinomycetota

blobtools filter \
  --invert \
  --param bestsumorder_phylum--Keys=$TAXON \
  --fasta ${ASM} \
  --output ${OUTDIR}/${TAXON}_blobdir \
  --suffix ${TAXON} \
  $BLOBDIR

####################################################################################
# Step 1: Extract all Pseudomonadota sequences
####################################################################################
TAXON=Pseudomonadota

blobtools filter \
  --invert \
  --param bestsumorder_phylum--Keys=$TAXON \
  --fasta ${ASM} \
  --output ${OUTDIR}/${TAXON}_temp_blobdir \
  --suffix ${TAXON}_temp \
  $BLOBDIR

ASM_PSEUDO="${OUTDIR}/B_coprophila_p_ctg.${TAXON}_temp.fa"

####################################################################################
# Step 2a: Filter for high GC, low coverage Pseudomonadota
####################################################################################
SPECIES=Pseudomonadota_highGC_lowCov

blobtools filter \
  --param gc--Min=0.4 \
  --param coverage--Max=10 \
  --fasta ${ASM_PSEUDO} \
  --output ${OUTDIR}/${SPECIES}_blobdir \
  --suffix ${SPECIES} \
  ${OUTDIR}/${TAXON}_temp_blobdir

# Rename to cleaner filename
mv ${OUTDIR}/B_coprophila_p_ctg.${TAXON}_temp.${SPECIES}.fa \
   ${OUTDIR}/B_coprophila_p_ctg.${SPECIES}.fa

####################################################################################
# Step 2b: Filter for low GC, high coverage Pseudomonadota
####################################################################################
SPECIES=Pseudomonadota_lowGC_highCov

blobtools filter \
  --param gc--Max=0.4 \
  --param coverage--Min=10 \
  --fasta ${ASM_PSEUDO} \
  --output ${OUTDIR}/${SPECIES}_blobdir \
  --suffix ${SPECIES} \
  ${OUTDIR}/${TAXON}_temp_blobdir

# Rename to cleaner filename
mv ${OUTDIR}/B_coprophila_p_ctg.${TAXON}_temp.${SPECIES}.fa \
   ${OUTDIR}/B_coprophila_p_ctg.${SPECIES}.fa

####################################################################################
# Step 3: Clean up temporary files
####################################################################################
rm -rf ${OUTDIR}/${TAXON}_temp_blobdir
rm -f ${ASM_PSEUDO}

echo "Filtering complete. Temporary files removed."
