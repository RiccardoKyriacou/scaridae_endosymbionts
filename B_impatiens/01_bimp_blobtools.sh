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
source /home/s2673271/miniforge3/etc/profile.d/conda.sh     
conda activate /home/s2673271/miniforge3/envs/blobtools2

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
ASM="/mnt/loki/ross/flies/sciaridae/Bradysia_impatiens/UK_Bimp_assembly/outputs/hifiasm/BimpUKG_nontriobinning_primary.fa"
READS="/mnt/loki/ross/sequencing/raw/202507_Bradysia_impatiens_WGS_HiFi/B.impatiens_Fp_1/hifi_reads/m84140_250716_161940_s1.hifi_reads.16_UDI_2_B01_F--16_UDI_2_B01_R.hifi_reads.fastq.gz"

# change these 
WORKDIR=/mnt/loki/ross/flies/sciaridae/endosymbiont_project/"${BLOBNAME}"/outputs/blobtools
mkdir -p $WORKDIR
cd $WORKDIR

###############################################################
# Create Blobtools db
###############################################################
blobtools create \
  --fasta ${ASM} \
  ${BLOBDIR}

##############################################################
# BLAST
##############################################################
echo "running BLASTn"
blastn -db ${BLASTDB} \
       -query ${ASM} \
       -outfmt "6 qseqid staxids bitscore std" \
       -max_target_seqs 10 \
       -max_hsps 1 \
       -evalue 1e-25 \
       -num_threads 32 \
       -out ${BLAST_OUT}  

echo "adding BLAST to blobdir"
blobtools add \
  --hits ${BLAST_OUT} \
  --taxrule bestsumorder \
  --taxdump ${TAXDUMP} \
  ${BLOBDIR}

# ###############################################################
# # Add Mapping to blobtools
# ###############################################################
# # Run minimap2
echo "Running minimap2"
echo "For males"
minimap2 -ax map-hifi \
         -t 32 ${ASM} \
         ${READS} \
| samtools sort -@32 -O BAM -o ${ASM}.bam -
samtools index -c ${ASM}.bam 

#add to dir 
blobtools add \
    --cov ${ASM}.bam \
    ${BLOBDIR}

###############################################################
# View (using blobtools1) - we will then filter using blobtools2 ls
###############################################################
conda deactivate
source /home/s2673271/miniforge3/etc/profile.d/conda.sh     
conda activate /home/s2673271/miniforge3/envs/blobtools

~/programmes/blobtools/blobtools create \
    -i ${ASM} \
    -t ${BLAST_OUT} \
    -b ${ASM}.bam \
    -o ${BLOBNAME} # change this

~/programmes/blobtools/blobtools view -i ${BLOBNAME}.blobDB.json
~/programmes/blobtools/blobtools plot -i ${BLOBNAME}.blobDB.json 

###############################################################
# Filter using blobtools2
###############################################################
# conda deactivate
# source /home/s2673271/miniforge3/etc/profile.d/conda.sh     
# conda activate /home/s2673271/miniforge3/envs/blobtoolkit

# blobtools filter \
#   --param bestsumorder_phylum--Keys=Bacteria \
#   --fasta ${ASM} \
#   --output male_GRC_clean \
#   --suffix cleaned \
#   male_GRC_blobdir
