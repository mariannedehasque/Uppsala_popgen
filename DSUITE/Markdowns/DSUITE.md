DSUITE
================
2024-02-13

- [Sample selection and filtering](#sample-selection-and-filtering)

AIM1: testing for introgression from Sarda/Nera (“domestic breeds”) into
European Mouflon on Sardinia

## Sample selection and filtering

The following samples are selected:

- Montes (Sardinia)
- Ogliastra (Sardinia)
- Corsica (Corsica)
- Sarda (Domestic)
- Nera (Domestic)
- Argali (Outgroup)

The subsetted VCF is filtered for:

- Fmissing\<0.1
- SNPs

``` bash
#!/bin/bash -l
#SBATCH -A uppmax2023-2-31 -M snowy
#SBATCH -p core -n 4
#SBATCH -J bcftools_subset
#SBATCH -t 1-00:00:00

module load bioinfo-tools bcftools/1.14

INPUT="Mouflon_domestic_argali.Q30.sorted.G5.D3.noIndel.annot.repma.snps.autos"
OUTPUT="Sarda_Nera_Montes_Ogliastra_Corsica_Argali.Q30.sorted.G5.D3.noIndel.annot.repma.autos"
SAMPLE="ARG10-4,ARG19,ARG20,ARG2-1,ARG3-1,ARG8-2,Corsica-M1,Corsican-mouflon-N00,Corsican-Mouflon-N43,Corsican-mouflon-N47,Corsican-mouflon-N76,Corsican-mouflon-N77,Corsican-mouflon-N83,Corsican-mouflon-N85,Corsican-mouflon-N90,Corsican-mouflon-N96,Corsican-mouflon-N97,Montes-1,Montes-2,Montes-3,Montes-4,Montes-5,Montes-6,Ogliastra-11,Ogliastra-12,Ogliastra-13,Ogliastra-14,Ogliastra-15,Ogliastra-18,Ogliastra-19,Ogliastra-1,Ogliastra-3,Ogliastra-4,Ogliastra-6,Ogliastra-9,Ogliastra-17,NeraSheep-183-F,NeraSheep-227-D,NeraSheep-227-F,NeraSheep-435-F,NeraSheep-450-F,NeraSheep-450-SO,NeraSheep-ISEDDU-SO,NeraSheep-P252,NeraSheep-P435,SardaSheep-1,SardaSheep-2,SardaSheep-3,SardaSheep-4,SardaSheep-5,SardaSheep-6"
DIR="/proj/sheep_processing/private/marianne/VCF"
OUTDIR="/proj/snic2020-2-10/private/Analyses/marianne/PROJECTS/EuropeanMouflon/DSUITE"
autos="/proj/snic2020-2-10/private/Data/Non-Human/Animals/sheep/ref_seqs/ARS-UI_Ramb_v2.0/RepeatMasker/GCF_016772045.1_ARS-UI_Ramb_v2.0_genomic.autos.bed"


bcftools view -s $SAMPLE -Ob -o $OUTDIR/${OUTPUT}.bcf $DIR/${INPUT}.bcf
bcftools index $OUTDIR/${OUTPUT}.bcf

#Biallelic SNPS only
bcftools view -m2 -M2 -v snps $OUTDIR/${OUTPUT}.bcf -Ob -o $TMPDIR/${OUTPUT}.snps.bcf
bcftools index $TMPDIR/${OUTPUT}.snps.bcf

#Remove SNPS marked as SNPs in removed samples
bcftools view -e 'count(GT="0/0")+count(GT="./")=(N_SAMPLES)' $TMPDIR/${OUTPUT}.snps.bcf -Ob -o $OUTDIR/${OUTPUT}.snps.bcf
bcftools index $OUTDIR/${OUTPUT}.snps.bcf

bcftools view -i 'F_MISSING<0.1' $OUTDIR/${OUTPUT}.snps.bcf -Ob -o $OUTDIR/${OUTPUT}.snps.Fmiss0.1.bcf
bcftools index $OUTDIR/${OUTPUT}.snps.Fmiss0.1.bcf
```

To allow parallelisation, the VCF is split per chromosome.

``` bash
#!/bin/bash -l

module load bioinfo-tools bcftools

DIR="/proj/snic2020-2-10/private/Analyses/marianne/PROJECTS/EuropeanMouflon/DSUITE/"
INPUT="Sarda_Nera_Montes_Ogliastra_Corsica_Argali.Q30.sorted.G5.D3.noIndel.annot.repma.autos.snps.Fmiss0.1"

cd $DIR

for chrom in NC_056054.1 NC_056055.1 NC_056056.1 NC_056057.1 NC_056058.1 NC_056059.1 NC_056060.1 NC_056061.1 NC_056062.1 NC_056063.1 NC_056064.1 NC_056065.1 NC_056066.1 NC_056067.1 NC_056068.1 NC_056069.1 NC_056070.1 NC_056071.1 NC_056072.1 NC_056073.1 NC_056074.1 NC_056075.1 NC_056076.1 NC_056077.1 NC_056078.1 NC_056079.1
do
  bcftools view $INPUT.bcf -r $chrom -Oz -o $INPUT.${chrom}.vcf.gz
done
```

Dsuite is run per chromosome. The `SETS` file is a tab-delimited file
containing the sample ID (column 1) and group identifier (column 2). The
outgroup (Argali) has group identifier `Outgroup`.

A snippet from the file:

``` bash
#!/bin/bash -l
#SBATCH -A uppmax2023-2-31 -M snowy
#SBATCH -p core -n 2
#SBATCH -J DSUITE
#SBATCH -t 04:00:00

Dsuite="/proj/snic2020-2-10/private/Analyses/marianne/PROJECTS/EuropeanMouflon/DSUITE/Dsuite/Build/Dsuite"
DtriosParallel="/proj/snic2020-2-10/private/Analyses/marianne/PROJECTS/EuropeanMouflon/DSUITE/Dsuite/utils/DtriosParallel"
SETS="/proj/snic2020-2-10/private/Analyses/marianne/PROJECTS/EuropeanMouflon/DSUITE/Domestic_Corsica_Sardinia.txt"
VCF_FILE=$1
CHROM=$(echo $VCF_FILE| cut -d "." -f 13)

$Dsuite Dtrios $VCF_FILE $SETS -n $CHROM
```

This shows significant introgression from Nera into Sardinia (i.e Montes
and Ogliastra)

| P1       | P2       | P3       | Dstatistic | Z-score  | p-value    | f4-ratio   | BBAA       | ABBA   | BABA   |
|----------|----------|----------|------------|----------|------------|------------|------------|--------|--------|
| Sarda    | Nera     | Corsica  | 0.00173132 | 0.88741  | 0.374858   | 0.00243288 | 1101680.00 | 875470 | 872444 |
| Corsica  | Sardinia | Nera     | 0.00130758 | 0.500944 | 0.61641    | 0.00375348 | 1171860.00 | 836414 | 834229 |
| Sardinia | Corsica  | Sarda    | 0.00242141 | 0.963515 | 0.335289   | 0.00752534 | 1177200.00 | 836536 | 832494 |
| Sarda    | Nera     | Sardinia | 0.00529524 | 3.14325  | 0.00167082 | 0.0121647  | 1102290.00 | 878270 | 869017 |

To test if the elevated D-score can be attributed to specific regions,
Dinvestigate is run.

``` bash
#!/bin/bash -l
#SBATCH -A uppmax2023-2-31 -M snowy
#SBATCH -p core -n 4
#SBATCH -J DSUITE
#SBATCH -t 2-00:00:00

Dsuite="/proj/snic2020-2-10/private/Analyses/marianne/PROJECTS/EuropeanMouflon/DSUITE/Dsuite/Build/Dsuite"
SETS="/proj/snic2020-2-10/private/Analyses/marianne/PROJECTS/EuropeanMouflon/DSUITE/METADATA.txt"
TRIO="/proj/snic2020-2-10/private/Analyses/marianne/PROJECTS/EuropeanMouflon/DSUITE/METADATA_test_trios.txt"

#$Dsuite Dtrios $VCF_FILE $SETS -n $CHROM

$Dsuite Dinvestigate -w 50,25 Sarda_Nera_Montes_Ogliastra_Corsica_Argali.Q30.sorted.G5.D3.noIndel.annot.repma.autos.snps.Fmiss0.1.vcf.gz $SETS $TRIO
```
