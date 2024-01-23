#!/bin/bash -l
#SBATCH -A naiss2023-22-799
#SBATCH -p core -n 2
#SBATCH -J bcftools_samples
#SBATCH -t 2-00:00:00

module load bioinfo-tools bcftools/1.14 samtools/1.14
module load BEDTools/2.29.2
module load tabix/0.2.6


SAMPLE=${1}
INPUT='MOUFLON_downsampled.Q30.sorted.G5.D3.noIndel.annot.repma.Fmiss0.2.snps.bcf'
DIR='/proj/snic2020-2-10/private/Data/Non-Human/Animals/sheep/BAM_files/ARS-UI_Ramb_v2.0/VCF_PANELS/bcftools_mpileup/merged/'
OUTDIR='/proj/snic2020-2-10/private/Data/Non-Human/Animals/sheep/BAM_files/ARS-UI_Ramb_v2.0/VCF_PANELS/bcftools_mpileup/merged/Mouflon_goat.Q30.sorted.G5.D3.noIndel.annot.repma.Fmiss0.2.snps.autos/BCF'

# SAMPLES: Corsica-11 Corsica-7 Corsica-F1 Corsica-M1 Corsican-mouflon-N00 Corsican-Mouflon-N43 Corsican-mouflon-N47 Corsican-mouflon-N76 Corsican-mouflon-N77 Corsican-mouflon-N83 Corsican-mouflon-N85 Corsican-mouflon-N90 Corsican-mouflon-N96 Corsican-mouflon-N97 cym002 cym003 cym004 cym006 cym007 cym008 cym009 cym011 cym012 Montes-1 Montes-2 Montes-3 Montes-4 Montes-5 Montes-6 Ogliastra-11 Ogliastra-12 Ogliastra-13 Ogliastra-14 Ogliastra-15 Ogliastra-18 Ogliastra-19 Ogliastra-1 Ogliastra-3 Ogliastra-4 Ogliastra-6 Ogliastra-9 MUF1 MUF2-1 MUF3-1 OGA018 KR15 R-09 SH19 SH20 YZ.11

cd $DIR

bcftools view -s $SAMPLE -Ob -o $OUTDIR/${SAMPLE}.Q30.sorted.G5.D3.noIndel.annot.repma.Fmiss0.2.snps.bcf $DIR/$INPUT
bcftools index $TMPDIR/${SAMPLE}.Q30.sorted.G5.D3.noIndel.annot.repma.Fmiss0.2.snps.bcf
bcftools convert -O z -o $TMPDIR/${SAMPLE}.Q30.sorted.G5.D3.noIndel.annot.repma.Fmiss0.2.snps.vcf.gz $TMPDIR/${SAMPLE}.Q30.sorted.G5.D3.noIndel.annot.repma.Fmiss0.2.snps.bcf
