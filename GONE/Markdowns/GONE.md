GONE
================
2024-03-01

- [Installing GONE](#installing-gone)
- [Preparing input files](#preparing-input-files)
- [Running the analyis](#running-the-analyis)

## Installing GONE

The original GitHub repository can be found
[here.](https://github.com/esrud/GONE) A user’s guide and tutorial can
be found on this page.

To install GONE, simply copy the whole directory (MacOSX for MacBooks).
To download a specific folder from GitHub, I found [this
website](https://download-directory.github.io/) to be the most
convenient. After downloading the directory locally, copy it to UPPMAX
using rsync (e.g. ‘rsync -ah esrud GONE master Linux
<marideha@rackham.uppmax.uu.se>:/PATH/TO/FOLDER’).

In the PROGRAMMES directory, make sure all files are executable. This
can be done with the command `chmod 775 [FILE]`

## Preparing input files

GONE requires PLINK input files with chromosomes named with numbers per
population.

If applicable, extract the focus samples from the merged bcf file with
following code:

``` r
module load bioinfo-tools bcftools/1.14

INPUT="Mouflon_domestic_argali.Q30.sorted.G5.D3.noIndel.annot.repma.snps.autos"
OUTPUT="Sardinia.Q30.sorted.G5.D3.noIndel.annot.repma.autos"
SAMPLE="Montes-1,Montes-2,Montes-3,Montes-4,Montes-5,Montes-6,Ogliastra-11,Ogliastra-12,Ogliastra-13,Ogliastra-14,Ogliastra-15,Ogliastra-18,Ogliastra-19,Ogliastra-1,Ogliastra-3,Ogliastra-4,Ogliastra-6,Ogliastra-9,Ogliastra-17"
DIR="/proj/sheep_processing/private/marianne/VCF"
OUTDIR="/proj/snic2020-2-10/private/Analyses/marianne/PROJECTS/EuropeanMouflon/GONE"
autos="/proj/snic2020-2-10/private/Data/Non-Human/Animals/sheep/ref_seqs/ARS-UI_Ramb_v2.0/RepeatMasker/GCF_016772045.1_ARS-UI_Ramb_v2.0_genomic.autos.bed"

bcftools view -s $SAMPLE -Ob -o $OUTDIR/${OUTPUT}.bcf $DIR/${INPUT}.bcf
bcftools index $OUTDIR/${OUTPUT}.bcf

#Biallelic SNPS only
bcftools view -m2 -M2 -v snps $OUTDIR/${OUTPUT}.bcf -Ob -o $TMPDIR/${OUTPUT}.snps.bcf
bcftools index $TMPDIR/${OUTPUT}.snps.bcf

#Remove SNPS marked as SNPs in removed samples
bcftools view -e 'count(GT="0/0")+count(GT="./")=(N_SAMPLES)' $TMPDIR/${OUTPUT}.snps.bcf -Ob -o $OUTDIR/${OUTPUT}.snps.bcf
bcftools index $OUTDIR/${OUTPUT}.snps.bcf

bcftools view -i 'F_MISSING=0' $OUTDIR/${OUTPUT}.snps.bcf -Ob -o $OUTDIR/${OUTPUT}.snps.Fmiss0.bcf
bcftools index $OUTDIR/${OUTPUT}.snps.Fmiss0.bcf
```

To convert the chromosome names of the sheep genome, use the following
script:

``` r
cd $INDIR

bcftools view ${FILE}.bcf | awk '{gsub(/NC_056061.1/, "8"); gsub(/NC_056056.1/, "3"); gsub(/NC_056058.1/, "5"); gsub(/NC_056067.1/, "14"); gsub(/NC_056063.1/, "10"); gsub(/NC_056068.1/, "15"); gsub(/NC_056060.1/, "7"); gsub(/NC_056054.1/, "1"); gsub(/NC_056062.1/, "9"); gsub(/NC_056059.1/, "6"); gsub(/NC_056055.1/, "2"); gsub(/NC_056064.1/, "11"); gsub(/NC_056066.1/, "13"); gsub(/NC_056065.1/, "12"); gsub(/NC_056057.1/, "4"); gsub(/NC_056069.1/, "16"); gsub(/NC_056072.1/, "19"); gsub(/NC_056075.1/, "22"); gsub(/NC_056070.1/, "17"); gsub(/NC_056073.1/, "20"); gsub(/NC_056076.1/, "23"); gsub(/NC_056071.1/, "18"); gsub(/NC_056074.1/, "21"); gsub(/NC_056077.1/, "24"); gsub(/NC_056078.1/, "25"); gsub(/NC_056079.1/, "26"); print;}' | bgzip -c > ${OUTDIR}/${FILE}.NewChr.vcf.gz

tabix ${OUTDIR}/${FILE}.NewChr.vcf.gz
```

And to convert the vcf file to PLINK format, run the following code:

``` r
ml bioinfo-tools plink/1.90b4.9

INPUT="Corsica.Q30.sorted.G5.D3.noIndel.annot.repma.autos.snps.Fmiss0.NewChr"

plink --vcf ${INPUT}.vcf.gz --missing-genotype 0 --allow-extra-chr --chr-set 26 --recode --out ${INPUT} --set-missing-var-ids @:#
```

Finally, have a look at the `INPUT_PARAMETERS_FILE`. Default options
seem to work fine, but if desired MAF or number of generations can be
changed in this file.

Awesome, the hardest work has basically already been done!

## Running the analyis

To run the GONE analysis, use the following script:

``` r
#!/bin/bash -l
#SBATCH -A uppmax2023-2-31 -M snowy
#SBATCH -p core -n 8
#SBATCH -J GONE
#SBATCH -t 2-00:00:00

ml bioinfo-bcftools

bash script_GONE.sh ${FILE}
```

Once the script is finished, the output can be found in the following
files:

- Output_d2\_\${FILE}
- Output_Ne\_\${FILE}

For some ideas on how to plot these results, check the script ‘GONE.R’
in the PLOTS folder.
