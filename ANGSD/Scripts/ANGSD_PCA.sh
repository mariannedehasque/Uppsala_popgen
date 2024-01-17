#!/bin/bash -l
#SBATCH -A uppmax2023-2-31 -M snowy
#SBATCH -p core
#SBATCH -n 16
#SBATCH -t 10-00:00:00
#SBATCH -J ANGSD_PCA

module load bioinfo-tools
module load ANGSD/0.940-stable
module load PCAngsd

INPUT="Mouflon_domestic_wild"
DIR="/proj/snic2020-2-10/private/Analyses/marianne/PROJECTS/EuropeanMouflon/ANGSD"
INPUTFILE="/proj/snic2020-2-10/private/Analyses/marianne/PROJECTS/EuropeanMouflon/ANGSD/${INPUT}.list"
SITESFILE="/proj/snic2020-2-10/private/Analyses/marianne/PROJECTS/EuropeanMouflon/ANGSD/GCF_016772045.1_ARS-UI_Ramb_v2.0_genomic.repma.autos.angsd.file"
REFERENCE="/proj/snic2020-2-10/private/Data/Non-Human/Animals/sheep/ref_seqs/ARS-UI_Ramb_v2.0/RepeatMasker/GCF_016772045.1_ARS-UI_Ramb_v2.0_genomic.fna"

angsd -bam $INPUTFILE \
  -GL 1 \
  -nThreads 16 \
  -doGlf 2 \
  -doMajorMinor 1 \
  -SNP_pval 1e-6 \
  -doMaf 1 \
  -minMapQ 30 -minQ 30 \
  -uniqueOnly 1 -remove_bads 1 \
  -sites $SITESFILE \
	-ref $REFERENCE \
	-out $DIR/$INPUT

pcangsd -b $DIR/${INPUT}.beagle.gz -t 16 -o $DIR/${INPUT}.pcangsd
