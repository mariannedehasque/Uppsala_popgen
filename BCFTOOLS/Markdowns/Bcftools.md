Bcftools
================
2024-01-18

- [Genotyping](#genotyping)
  - [Bcftools mpileup](#bcftools-mpileup)
  - [Filtering](#filtering)
  - [Quality control single BCF
    files](#quality-control-single-bcf-files)
- [Merging BCF files](#merging-bcf-files)
  - [Filtering](#filtering-1)
  - [Quality control](#quality-control)

# Genotyping

## Bcftools mpileup

Prerequisites  

- BAM file (`${SAMPLE}.ARS-UI_Ramb_v2.0.bam`)  
- BAM index file (`${SAMPLE}.ARS-UI_Ramb_v2.0.bam.bai`)  
- BAM depth file (`${SAMPLE}.ARS-UI_Ramb_v2.0.bam.dpstats.txt`)  

``` bash
#!/bin/bash -l
#SBATCH -A naiss2023-22-1111
#SBATCH -p core -n 6
#SBATCH -J bcftools_mpileup_external
#SBATCH -t 10-00:00:00

#Load modules
module load bioinfo-tools bcftools/1.14

REF_SEQ='/proj/snic2020-2-10/private/Data/Non-Human/Animals/sheep/ref_seqs/ARS-UI_Ramb_v2.0/RepeatMasker/GCF_016772045.1_ARS-UI_Ramb_v2.0_genomic.fna'
INPUT_BAM=$1
NAME=$(basename $INPUT_BAM)
OUTPUT_VCF=$(echo $NAME | cut -d "." -f1)
OUTDIR='/proj/snic2020-2-10/private/Data/Non-Human/Animals/sheep/BAM_files/ARS-UI_Ramb_v2.0/VCF_PANELS/bcftools_mpileup'

#Code

cd $TMPDIR

 #Call variants from the bam file
 #"""Minimum mapping quality for a read to be considered: 30"""
 #"""Minimum base quality for a base to be considered: 30"""
 #"""-B: Disabled probabilistic realignment for the computation of base alignment quality (BAQ). BAQ is the Phred-scaled probability of a read base being misaligned. Applying this option greatly helps to reduce false SNPs caused by misalignments"""

bcftools mpileup -q 30 -Q 30 -B -Ou -f $REF_SEQ $INPUT_BAM| bcftools call -m -M -Ob -o ${OUTPUT_VCF}.Q30.bcf

#Sort bcf
bcftools sort -O b -o $OUTDIR/${OUTPUT_VCF}.Q30.sorted.bcf ${OUTPUT_VCF}.Q30.bcf

#Index sorted bcf
bcftools index -o $OUTDIR/${OUTPUT_VCF}.Q30.sorted.bcf.csi $OUTDIR/${OUTPUT_VCF}.Q30.sorted.bcf

#Stats sorted bcf
bcftools stats $OUTDIR/${OUTPUT_VCF}.Q30.sorted.bcf > $OUTDIR/stats/bcf_sorted/${OUTPUT_VCF}.Q30.sorted.bcf.stats.txt
```

## Filtering

``` bash

#!/bin/bash -l
#SBATCH -A naiss2023-22-1111
#SBATCH -p core -n 6
#SBATCH -J bcftools_mpileup_external
#SBATCH -t 10-00:00:00

#Load modules
module load bioinfo-tools bcftools/1.14
module load BEDTools/2.29.2
module load tabix/0.2.6

REF_GENOME='/proj/snic2020-2-10/private/Data/Non-Human/Animals/sheep/ref_seqs/ARS-UI_Ramb_v2.0/RepeatMasker/GCF_016772045.1_ARS-UI_Ramb_v2.0_genomic.genome'
DEPTH=$2
NAME=$(basename $INPUT_BAM)
OUTPUT_VCF=$(echo $NAME | cut -d "." -f1)
OUTDIR='/proj/snic2020-2-10/private/Data/Non-Human/Animals/sheep/BAM_files/ARS-UI_Ramb_v2.0/VCF_PANELS/bcftools_mpileup'
REPMA='/proj/snic2020-2-10/private/Data/Non-Human/Animals/sheep/ref_seqs/ARS-UI_Ramb_v2.0/RepeatMasker/GCF_016772045.1_ARS-UI_Ramb_v2.0_genomic.repma.bed'
minDP=$(($DEPTH/3))
maxDP=$(($DEPTH*3))

if (($minDP<3)); then minDP=3; fi

#Filter SNPs within 5bp of indels

bcftools filter -g 5 -O b -o ${OUTPUT_VCF}.Q30.sorted.G5.bcf $OUTDIR/${OUTPUT_VCF}.Q30.sorted.bcf

#Remove indels, genotypes of genotype quality < 30 and keep only sites within depth thresholds
bcftools filter -i "(DP4[0]+DP4[1]+DP4[2]+DP4[3])>${minDP} & (DP4[0]+DP4[1]+DP4[2]+DP4[3])<${maxDP} & QUAL>=30 & INDEL=0" ${OUTPUT_VCF}.Q30.sorted.G5.bcf | bcftools annotate -x ^INFO/DP,INFO/DP4,^FORMAT/GT,FORMAT/PL -O b -o ${OUTPUT_VCF}.Q30.sorted.G5.D3.noIndel.annot.bcf

#Index BCF
bcftools index ${OUTPUT_VCF}.Q30.sorted.G5.D3.noIndel.annot.bcf

#Stats after filtering
bcftools stats ${OUTPUT_VCF}.Q30.sorted.G5.D3.noIndel.annot.bcf > $OUTDIR/stats/bcf_annot/${OUTPUT_VCF}.Q30.sorted.G5.D3.noIndel.annot.bcf.stats.txt

#Mask repeats
bcftools view ${OUTPUT_VCF}.Q30.sorted.G5.D3.noIndel.annot.bcf | bedtools intersect -a stdin -b $REPMA -g $REF_GENOME -header -sorted | bgzip -c > ${OUTPUT_VCF}.Q30.sorted.G5.D3.noIndel.annot.repma.vcf.gz

#Convert vcf to bcf
bcftools convert -O b -o $OUTDIR/${OUTPUT_VCF}.Q30.sorted.G5.D3.noIndel.annot.repma.bcf ${OUTPUT_VCF}.Q30.sorted.G5.D3.noIndel.annot.repma.vcf.gz

bcftools index $OUTDIR/${OUTPUT_VCF}.Q30.sorted.G5.D3.noIndel.annot.repma.bcf

bcftools stats $OUTDIR/${OUTPUT_VCF}.Q30.sorted.G5.D3.noIndel.annot.repma.bcf > $OUTDIR/stats/bcf_repma/${OUTPUT_VCF}.Q30.sorted.G5.D3.noIndel.annot.repma.bcf.stats.txt
```

## Quality control single BCF files

Obtaining statistics per `bcf file`:

``` bash
#!/bin/bash -l
#SBATCH -A snic2022-22-618
#SBATCH -p core -n 1
#SBATCH -J vcf_stats
#SBATCH -t 1-00:00:00

#Load modules
module load bioinfo-tools bcftools/1.14

INDIR="/proj/snic2020-2-10/private/Data/Non-Human/Animals/sheep/BAM_files/ARS-UI_Ramb_v2.0/VCF_PANELS/bcftools_mpileup"

cd $indir

bcftools stats ${INDIR}/${SAMPLE}.sorted.G5.D3.noIndel.annot.repma.bcf  > ${INDIR}/stats/${SAMPLE}.sorted.G5.D3.noIndel.annot.repma.bcf.stats
```

Summarizing data using MultiQC:

``` bash

#!/bin/bash -l
#SBATCH -A naiss2023-22-799
#SBATCH -p core -n 2
#SBATCH -J multiqc_modern
#SBATCH -t 02:00:00

module load bioinfo-tools MultiQC/1.7

DIR=''

multiqc -f $DIR/stats/ -o $DIR/stats/multiqc
```

# Merging BCF files

``` bash
#!/bin/bash -l
#SBATCH -A uppmax2023-2-31 -M snowy
#SBATCH -p core -n 10
#SBATCH -J bcftools_merge
#SBATCH -t 2-00:00:00

#Load modules
module load bioinfo-tools bcftools/1.14 samtools/1.14
module load BEDTools/2.29.2
module load tabix/0.2.6

outdir="/proj/sheep_processing/private/marianne/VCF"
files_to_merge="/proj/sheep_processing/private/marianne/VCF/argali.list"
bfile="Mouflon_goat_domestic_argali.Q30.sorted.G5.D3.noIndel.annot.repma"
autos="/proj/snic2020-2-10/private/Data/Non-Human/Animals/sheep/ref_seqs/ARS-UI_Ramb_v2.0/RepeatMasker/GCF_016772045.1_ARS-UI_Ramb_v2.0_genomic.autos.bed"

#Merge bcf files into one bcf file, allowing multiallelic SNP records
cat $files_to_merge | xargs bcftools merge -m snps --threads 10 -Ob -o $outdir/$bfile.bcf
bcftools index $outdir/$bfile.bcf

#Biallelic SNPS only
bcftools view -m2 -M2 -v snps $outdir/$bfile.bcf -Ob -o $outdir/$bfile.snps.bcf
bcftools index $outdir/$bfile.snps.bcf

#Extract autosomes
bcftools view $outdir/$bfile.snps.bcf -R $autos -O b -o $outdir/${bfile}.snps.autos.bcf
bcftools index $outdir/${bfile}.snps.autos.bcf

#Extract chromosome X
bcftools view $outdir/$bfile.snps.bcf -r NC_056080.1 -O b -o $outdir/$bfile.snps.chrX.bcf
bcftools index $outdir/$bfile.snps.chrX.bcf
```

## Filtering

Biallelic snps only:

``` bash
bcftools view -m2 -M2 -v snps $INFILE.bcf -Ob -o $OUTFILE.snps.bcf
```

Missingness:

``` bash
bcftools view -i 'F_MISSING<0.2'$INFILE.bcf -Ob -o $OUTFILE.Fmiss0.2.bcf #Maximum 20% of genotypes missing per site allowed
bcftools view -i 'F_MISSING=0'$INFILE.bcf -Ob -o $OUTFILE.Fmiss0.bcf #No missing genotypes allowed
```

Only including sites covered in at least two samples (alternative to
Fmiss):

``` bash
bcftools view -i 'count(GT="./.")<(N_SAMPLES-1)' $INFILE.bcf -Ob -o $OUTFILE.snps.bcf
```

MAF filters:

``` bash
#The :minor is necessary to filter for minor allele frequency, not non-reference frequency
bcftools view -q 0.05:minor $FILE.bcf -Ob -o $FILE.maf005.bcf
```

Removing samples from merged BCF file

``` bash
bcftools view -S ^$FILE.txt -Ob -o $OUTFILE.bcf
```

Options:

- -S, –samples-file: File of sample names to include or exclude if
  prefixed with “^”. One sample per line.
- -s, –samples : Comma-separated list of samples to include or exclude
  if prefixed with “^.”

## Quality control

Inspecting missingness per individual:

``` bash
module load vcftools

vcftools --bcf ${SAMPLE}.bcf --missing-indv --out stats/${SAMPLE}
```
