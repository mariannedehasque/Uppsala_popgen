#!/bin/bash -l
#SBATCH -A uppmax2025-2-133
#SBATCH -p core -n 10
#SBATCH -J ADMIXTURE
#SBATCH -t 10-00:00:00
#Loading modules

module load bioinfo-tools ADMIXTURE/1.3.0

#set variables
DATA="/proj/sheep_processing/private/marianne/VCF/FERAL.snps.noprivate.autos.header.Fmiss0.1.NewChr.LDprune.bed"
OUT=${3}
seed=${1}
K=${2}

cd $OUT

#run admixture in several Ks
admixture $DATA $K --seed $seed -j10 --cv=10
