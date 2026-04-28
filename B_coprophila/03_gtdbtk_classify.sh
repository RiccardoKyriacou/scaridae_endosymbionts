#!/bin/bash -l

#SBATCH --job-name=GTDB-Tk
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --export=ALL
#SBATCH --time=3-00:00:00
#SBATCH --partition=ac3-compute
#SBATCH --mem=32gb
#SBATCH --output=GTDB-Tk.%j.log
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=s2673271@ed.ac.uk

hostname
set -e
source /home/s2673271/miniforge3/etc/profile.d/conda.sh
conda activate /home/s2673271/miniforge3/envs/gtdbtk-2.6.1

###############################################################
# Paths
###############################################################
WORKDIR=/mnt/loki/ross/flies/sciaridae/endosymbiont_project/B_coprophila/outputs/gtdb_inputs
cd $WORKDIR

###############################################################
# Get endosymbiont genomes
###############################################################
# grep ">ptg000203l" -A 1 B_coprophila_p_ctg.Pseudomonadota_lowGC_highCov.fa > Ca_Tisiphia_1.fasta
# grep ">ptg000067l" -A 1 B_coprophila_p_ctg.Pseudomonadota_lowGC_highCov.fa > Ca_Tisiphia_2.fasta
# grep ">ptg000201l" -A 1 B_coprophila_p_ctg.Pseudomonadota_lowGC_highCov.fa > wolbachia.fasta

# # Check size 

# # grep -v "^>" Ca_Tisiphia_1.fasta | tr -d '\n' | wc -c
# # grep -v "^>" Ca_Tisiphia_2.fasta | tr -d '\n' | wc -c
# # grep -v "^>" wolbachia.fasta | tr -d '\n' | wc -c

###############################################################
# Loop through endosymbionts
###############################################################
for SAMPLE in Ca_Tisiphia_1 Ca_Tisiphia_2 wolbachia; do
  echo "$SAMPLE"
  ASM=$SAMPLE/$SAMPLE.fna

  source /home/s2673271/miniforge3/etc/profile.d/conda.sh
  conda activate /home/s2673271/miniforge3/envs/gtdbtk-2.6.1

  gtdbtk classify_wf \
    --genome_dir $SAMPLE \
    --out_dir $SAMPLE/gtdbtk_out \
    --cpus 8
  
  source /home/s2673271/miniforge3/etc/profile.d/conda.sh
  conda activate /home/s2673271/miniforge3/envs/genomics

  barrnap --kingdom bac \
    --threads 8 \
    --outseq $SAMPLE/16s_${SAMPLE}.fasta \
    $ASM \
    > $SAMPLE/16s_${SAMPLE}.gff

  busco \
    -i $ASM \
    -l rickettsiales_odb10 \
    -o $SAMPLE/BUSCO \
    -m genome \
    --cpu 8
done

echo "gtdbtk + barrnap + BUSCO finished"

