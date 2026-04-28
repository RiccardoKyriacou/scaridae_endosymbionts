#!/bin/bash -l

#SBATCH --job-name=blobtools2
#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --export=ALL
#SBATCH --time=3-00:00:00
#SBATCH --partition=ac3-compute
#SBATCH --mem=32gb
#SBATCH --output=blobtools2.%j.log
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=s2673271@ed.ac.uk

set -e

# Don't change these
BLASTDB="/mnt/loki/db/core_nt/core_nt"
# Get NCBI TAXDUMP - Unc
# mkdir -p ./taxdump
# curl https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/new_taxdump/new_taxdump.tar.gz | tar xzf - -C ./taxdump
TAXDUMP="/mnt/loki/ross/flies/chironomidae/Belgica_antarctica/soma_v_germline/05_assemble_pulled_reads/outputs/taxdump"

# change these 
BLOBDIR="Bimp_blbodir"
BLAST_OUT="Bimp_vs_nt.blastn"
BLOBNAME="B_impatiens" 

# change these 
ASM="/mnt/loki/ross/flies/sciaridae/endosymbiont_project/B_impatiens/outputs/blobtools/BimpUKG_nontriobinning_primary.fa"

# change these 
WORKDIR=/mnt/loki/ross/flies/sciaridae/endosymbiont_project/"${BLOBNAME}"/outputs/blobtools
mkdir -p $WORKDIR
cd $WORKDIR

###############################################################
# Filter using blobtools2
###############################################################

for TAXON in Pseudomonadota Bacteroidota; do
  source /home/s2673271/miniforge3/etc/profile.d/conda.sh     
  conda activate /home/s2673271/miniforge3/envs/blobtools2
  
  echo "Blobtool filter"
  blobtools filter \
    --param bestsumorder_phylum--Keys=$TAXON \
    --invert \
    --fasta ${ASM} \
    --output ${WORKDIR}/B_ocellaris_${TAXON}_blobdir \
    --suffix ${TAXON} \
    $BLOBDIR
  
  source /home/s2673271/miniforge3/etc/profile.d/conda.sh     
  conda activate /home/s2673271/miniforge3/envs/genomics

  echo "barrnap"
  barrnap --kingdom bac \
  --threads 32 \
  --outseq ${WORKDIR}/${TAXON}_16S.fasta \
  BimpUKG_nontriobinning_primary.${TAXON}.fa \
  > ${WORKDIR}/${TAXON}_16S.gff

done

echo "Done."
