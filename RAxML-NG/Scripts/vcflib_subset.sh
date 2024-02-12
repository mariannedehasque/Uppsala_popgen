#!/bin/bash -l
#SBATCH -A naiss2023-22-1111
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 12:00:00
#SBATCH -J vcflib_subset

ml bioinfo-tools vcflib bcftools

INDIR='/proj/sheep_processing/private/marianne/VCF'
OUTDIR='/proj/snic2020-2-10/private/Analyses/marianne/PROJECTS/EuropeanMouflon/RAxML/Mouflon_goat_domestic_argali.Q30.sorted.G5.D3.noIndel.annot.repma.snps.autos.Fmiss0.1'
FILE='Mouflon_goat_domestic_argali.Q30.sorted.G5.D3.noIndel.annot.repma.snps.autos.Fmiss0.1'


bcftools view ${INDIR}/${FILE}.bcf | vcfrandomsample -r 0.035087719 > $TMPDIR/${FILE}.subset2M.${1}.vcf
bcftools view -Oz -o ${OUTDIR}/${FILE}.subset2M.${1}.vcf.gz $TMPDIR/${FILE}.subset2M.${1}.vcf
bcftools index ${OUTDIR}/${FILE}.subset2M.${1}.vcf.gz
