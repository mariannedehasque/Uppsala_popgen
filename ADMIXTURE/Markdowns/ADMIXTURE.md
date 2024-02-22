ADMIXTURE
================
2024-02-12

- [Preparing INPUT files](#preparing-input-files)
  - [Filtering](#filtering)
  - [Change chromosome names](#change-chromosome-names)
  - [Convert BCF to PLINK and prune PLINK
    file](#convert-bcf-to-plink-and-prune-plink-file)
- [Run ADMIXTURE](#run-admixture)

## Preparing INPUT files

### Filtering

Filters used for ADMIXTURE:

- FMISS = 0.1
- No Private alleles

``` bash
bcftools -i 'F_MISSING<0.1'$FILE.bcf -Ob -o $FILE.Fmiss0.1.bcf
bcftools index $FILE.Fmiss0.1.bcf

bcftools view -e 'count(GT="0/0")+count(GT="./.")=(N_SAMPLES)' $FILE.snps.bcf -Ob -o $FILE.snps.NoPrivate.bcf
bcftools index $FILE.snps.NoPrivate.bcf
```

### Change chromosome names

ADMIXTURE only accepts chromosomenames with following naming convention:
`1,2,3` etc. Sheep chromosome names (`NC056056.1, NC056057.1` etc.)
therefore have to be converted.

``` bash
#!/bin/bash -l
#SBATCH -A naiss2023-22-1111
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 02:00:00
#SBATCH -J BCF_edit_chromname

module load bioinfo-tools bcftools/1.14


bcftools view $FILE.snps.NoPrivate.bcf | awk '{gsub(/NC_056061.1/, "8"); gsub(/NC_056056.1/, "3"); gsub(/NC_056058.1/, "5"); gsub(/NC_056067.1/, "14"); gsub(/NC_056063.1/, "10"); gsub(/NC_056068.1/, "15"); gsub(/NC_056060.1/, "7"); gsub(/NC_056054.1/, "1"); gsub(/NC_056062.1/, "9"); gsub(/NC_056059.1/, "6"); gsub(/NC_056055.1/, "2"); gsub(/NC_056064.1/, "11"); gsub(/NC_056066.1/, "13"); gsub(/NC_056065.1/, "12"); gsub(/NC_056057.1/, "4"); gsub(/NC_056069.1/, "16"); gsub(/NC_056072.1/, "19"); gsub(/NC_056075.1/, "22"); gsub(/NC_056070.1/, "17"); gsub(/NC_056073.1/, "20"); gsub(/NC_056076.1/, "23"); gsub(/NC_056071.1/, "18"); gsub(/NC_056074.1/, "21"); gsub(/NC_056077.1/, "24"); gsub(/NC_056078.1/, "25"); gsub(/NC_056079.1/, "26"); print;}' > $FILE.snps.NoPrivate.newChr.vcf
```

And next convert the vcf file to bcf file

``` bash
bcftools convert -Ob -o $FILE.snps.NoPrivate.newChr.bcf $FILE.snps.NoPrivate.newChr.vcf
bcftools index $FILE.snps.NoPrivate.newChr.bcf
```

### Convert BCF to PLINK and prune PLINK file

``` bash
#!/bin/bash -l
#SBATCH -A naiss2023-22-1111
#SBATCH -p core -n 1
#SBATCH -J plink_pca
#SBATCH -t 0-2:00:00

FILE=""
DIR="/proj/sheep_processing/private/marianne/VCF/temp"
OUTDIR="/proj/sheep_processing/private/marianne/PLINK"

cd $OUTDIR

plink --bcf ${DIR}/${FILE}.bcf --make-bed --allow-extra-chr --chr-set 26 --set-missing-var-ids @:# --out ${FILE}
plink --bfile ${FILE} --missing-genotype 0 --allow-extra-chr --chr-set 26 --indep-pairwise 50 5 0.5 --out ${FILE}
plink --bfile ${FILE} --extract ${FILE}.prune.in --make-bed --chr-set 26 --allow-extra-chr --out ${FILE}.LDprune
```

## Run ADMIXTURE

20 runs  
K = {1..15}

Start the 20 runs as follows:

``` bash
for run in 1 2; do bash /proj/snic2020-2-10/private/Analyses/marianne/PROJECTS/EuropeanMouflon/SCRIPTS/ADMIXTURE_wrapper.sh $run; done
```

Calculate Cross validation mean and standard error using R.

First extract the CV values of each run (grep “CV” \*out). Reformat
using awk or excel into a tab-delimited column, with the first column
representing the K value and the second the CV value.

``` r
calculate_mean_and_sd <- function(file_path) {
  data <- read.table(file_path, header = TRUE)  # Assuming the file is tab-separated
  result <- aggregate(CV ~ K, data = data, FUN = function(x) c(mean = mean(x), sd = sd(x)))
  return(result)
}

result <- calculate_mean_and_sd("~/Library/CloudStorage/OneDrive-Personal/CTS/Rscripts/ADMIXTURE/CV.txt")
print(result)
```
