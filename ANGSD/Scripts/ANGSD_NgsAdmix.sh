#!/bin/bash -l
#SBATCH -A naiss2023-22-1111
#SBATCH -p core
#SBATCH -n 16
#SBATCH -t 1-00:00:00
#SBATCH -J ANGSD_NgsAdmix

module load bioinfo-tools
module load ANGSD/0.940-stable
module load NGSadmix

#for number in {1..99}; do sbatch ANGSD_NgsAdmix $number; done

INPUT="Mouflon_domestic"
DIR="/proj/snic2020-2-10/private/Analyses/marianne/PROJECTS/EuropeanMouflon/ANGSD"
INPUTFILE="/proj/snic2020-2-10/private/Analyses/marianne/PROJECTS/EuropeanMouflon/ANGSD/${INPUT}.list"
SITESFILE="/proj/snic2020-2-10/private/Analyses/marianne/PROJECTS/EuropeanMouflon/ANGSD/GCF_016772045.1_ARS-UI_Ramb_v2.0_genomic.repma.autos.angsd.file"
REFERENCE="/proj/snic2020-2-10/private/Data/Non-Human/Animals/sheep/ref_seqs/ARS-UI_Ramb_v2.0/RepeatMasker/GCF_016772045.1_ARS-UI_Ramb_v2.0_genomic.fna"

cd $DIR

#angsd -bam $INPUTFILE \
#  -GL 1 \
#  -nThreads 16 \
#  -doGlf 2 \
#  -doMajorMinor 1 \
#  -SNP_pval 1e-6 \
#  -doMaf 1 \
#  -minMapQ 30 -minQ 30 \
#  -uniqueOnly 1 -remove_bads 1 \
#  -sites $SITESFILE \
#	-ref $REFERENCE \
#	-out $DIR/$INPUT

NGSadmix -likes $DIR/${INPUT}.beagle.gz -t 16 -K 2 -o Mouflon_domestic_NgsAdmix_K1_run_${1} -P 16
NGSadmix -likes $DIR/${INPUT}.beagle.gz -t 16 -K 2 -o Mouflon_domestic_NgsAdmix_K2_run_${1} -P 16
NGSadmix -likes $DIR/${INPUT}.beagle.gz -t 16 -K 3 -o Mouflon_domestic_NgsAdmix_K3_run_${1} -P 16
NGSadmix -likes $DIR/${INPUT}.beagle.gz -t 16 -K 4 -o Mouflon_domestic_NgsAdmix_K4_run_${1} -P 16
NGSadmix -likes $DIR/${INPUT}.beagle.gz -t 16 -K 5 -o Mouflon_domestic_NgsAdmix_K5_run_${1} -P 16
NGSadmix -likes $DIR/${INPUT}.beagle.gz -t 16 -K 6 -o Mouflon_domestic_NgsAdmix_K6_run_${1} -P 16
NGSadmix -likes $DIR/${INPUT}.beagle.gz -t 16 -K 6 -o Mouflon_domestic_NgsAdmix_K7_run_${1} -P 16
